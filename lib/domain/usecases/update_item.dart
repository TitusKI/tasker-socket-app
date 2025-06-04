import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class UpdateItemParams extends Equatable {
  final String id;
  final String title;
  final String? description;

  const UpdateItemParams({
    required this.id,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, description];
}

class UpdateItem implements UseCase<ItemEntity, UpdateItemParams> {
  final ItemRepository repository;

  UpdateItem(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(UpdateItemParams params) async {
    return await repository.updateItem(
      params.id,
      params.title,
      params.description,
    );
  }
}
