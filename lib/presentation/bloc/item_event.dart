part of 'item_bloc.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadItemsEvent extends ItemEvent {}

class AddItemEvent extends ItemEvent {
  final String title;
  final String? description;

  const AddItemEvent({required this.title, this.description});

  @override
  List<Object?> get props => [title, description];
}

class EditItemEvent extends ItemEvent {
  final String id;
  final String title;
  final String? description;

  const EditItemEvent({
    required this.id,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, description];
}

class RemoveItemEvent extends ItemEvent {
  final String id;

  const RemoveItemEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// Internal event for BLoC to process WebSocket messages
class _RealtimeUpdateReceived extends ItemEvent {
  final dynamic data; // This will be the decoded JSON from WebSocket

  const _RealtimeUpdateReceived(this.data);

  @override
  List<Object?> get props => [data];
}
