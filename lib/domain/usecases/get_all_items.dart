import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class GetAllItems implements UseCase<List<ItemEntity>, NoParams> {
  final ItemRepository repository;

  GetAllItems(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(NoParams params) async {
    return await repository.getItems();
  }
}
