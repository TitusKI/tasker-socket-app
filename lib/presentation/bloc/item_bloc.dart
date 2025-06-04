import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasker/domain/usecases/get_real_time_updates.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/item_model.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/usecases/create_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_all_items.dart';
import '../../domain/usecases/update_item.dart';

part 'item_event.dart';
part 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetAllItems getAllItems;
  final CreateItem createItem;
  final UpdateItem updateItem;
  final DeleteItem deleteItem;
  final GetRealTimeUpdates listenToRealtimeUpdates;

  StreamSubscription? _realtimeSubscription;

  ItemBloc({
    required this.getAllItems,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
    required this.listenToRealtimeUpdates,
  }) : super(ItemInitial()) {
    on<LoadItemsEvent>(_onLoadItems);
    on<AddItemEvent>(_onAddItem);
    on<EditItemEvent>(_onEditItem);
    on<RemoveItemEvent>(_onRemoveItem);
    on<_RealtimeUpdateReceived>(_onRealtimeUpdateReceived);

    _initializeRealtimeUpdates();
  }

  void _initializeRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = listenToRealtimeUpdates.call(NoParams()).listen((
      eitherUpdate,
    ) {
      eitherUpdate.fold(
        (failure) => addError(
          Exception('WebSocket Error: ${failure.message}'),
          StackTrace.current,
        ),
        (data) => add(_RealtimeUpdateReceived(data)),
      );
    });
  }

  Future<void> _onLoadItems(
    LoadItemsEvent event,
    Emitter<ItemState> emit,
  ) async {
    emit(ItemLoading());
    final failureOrItems = await getAllItems(NoParams());
    failureOrItems.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemLoaded(items: items)),
    );
  }

  Future<void> _onAddItem(AddItemEvent event, Emitter<ItemState> emit) async {
    final failureOrItem = await createItem(
      CreateItemParams(title: event.title, description: event.description),
    );
    failureOrItem.fold(
      (failure) {
        if (state is ItemLoaded) {
          emit(
            ItemError(
              'Failed to add item: ${failure.message}. Previous items might be stale.',
            ),
          );
        } else {
          emit(ItemError('Failed to add item: ${failure.message}'));
        }
      },
      (item) {
        add(LoadItemsEvent());
      },
    );
  }

  Future<void> _onEditItem(EditItemEvent event, Emitter<ItemState> emit) async {
    final failureOrItem = await updateItem(
      UpdateItemParams(
        id: event.id,
        title: event.title,
        description: event.description,
      ),
    );
    failureOrItem.fold(
      (failure) {
        if (state is ItemLoaded) {
          emit(
            ItemError(
              'Failed to edit item: ${failure.message}. Previous items might be stale.',
            ),
          );
        } else {
          emit(ItemError('Failed to edit item: ${failure.message}'));
        }
      },
      (updatedItem) {
        add(LoadItemsEvent());
      },
    );
  }

  Future<void> _onRemoveItem(
    RemoveItemEvent event,
    Emitter<ItemState> emit,
  ) async {
    final failureOrVoid = await deleteItem(DeleteItemParams(id: event.id));
    failureOrVoid.fold((failure) {
      if (state is ItemLoaded) {
        emit(
          ItemError(
            'Failed to remove item: ${failure.message}. Previous items might be stale.',
          ),
        );
      } else {
        emit(ItemError('Failed to remove item: ${failure.message}'));
      }
    }, (_) {});
  }

  void _onRealtimeUpdateReceived(
    _RealtimeUpdateReceived event,
    Emitter<ItemState> emit,
  ) {
    final data = event.data as Map<String, dynamic>;
    final type = data['type'] as String?;

    if (state is ItemLoaded || state is ItemInitial || state is ItemLoading) {
      List<ItemEntity> currentItems = [];
      int currentActiveUsers = 0;

      if (state is ItemLoaded) {
        currentItems = List.from((state as ItemLoaded).items);
        currentActiveUsers = (state as ItemLoaded).activeUsersCount;
      }

      switch (type) {
        case 'ITEM_CREATED':
          final newItem = ItemModel.fromJson(
            data['item'] as Map<String, dynamic>,
          );

          if (!currentItems.any((item) => item.id == newItem.id)) {
            currentItems.add(newItem);
          }
          emit(
            ItemLoaded(
              items: currentItems,
              activeUsersCount: currentActiveUsers,
            ),
          );
          break;
        case 'ITEM_UPDATED':
          final updatedItemData = data['item'] as Map<String, dynamic>;
          final updatedItem = ItemModel.fromJson(updatedItemData);
          final index = currentItems.indexWhere(
            (item) => item.id == updatedItem.id,
          );
          if (index != -1) {
            currentItems[index] = updatedItem;
          } else {
            currentItems.add(updatedItem);
          }
          emit(
            ItemLoaded(
              items: currentItems,
              activeUsersCount: currentActiveUsers,
            ),
          );
          break;
        case 'ITEM_DELETED':
          final deletedItemId = data['id'] as String;
          currentItems.removeWhere((item) => item.id == deletedItemId);
          emit(
            ItemLoaded(
              items: currentItems,
              activeUsersCount: currentActiveUsers,
            ),
          );
          break;
        case 'ACTIVE_USERS_COUNT':
          final count = data['count'] as int;
          emit(ItemLoaded(items: currentItems, activeUsersCount: count));
          break;
        default:
          break;
      }
    }
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();

    return super.close();
  }
}
