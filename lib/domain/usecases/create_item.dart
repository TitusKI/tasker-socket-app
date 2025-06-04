import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class CreateItemParams extends Equatable {
  final String title;
  final String? description;

  const CreateItemParams({required this.title, this.description});

  @override
  List<Object?> get props => [title, description];
}

class CreateItem implements UseCase<ItemEntity, CreateItemParams> {
  final ItemRepository repository;

  CreateItem(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(CreateItemParams params) async {
    return await repository.createItem(params.title, params.description);
  }
}
