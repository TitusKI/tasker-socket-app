part of 'item_bloc.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoaded extends ItemState {
  final List<ItemEntity> items;
  final int activeUsersCount;
  final bool isProcessing;
  final String? errorMessage;

  const ItemLoaded({
    required this.items,
    this.activeUsersCount = 0,
    this.isProcessing = false,
    this.errorMessage,
  });

  ItemLoaded copyWith({
    List<ItemEntity>? items,
    int? activeUsersCount,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return ItemLoaded(
      items: items ?? this.items,
      activeUsersCount: activeUsersCount ?? this.activeUsersCount,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    items,
    activeUsersCount,
    isProcessing,
    errorMessage,
  ];
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object> get props => [message];
}
