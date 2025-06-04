import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<Either<Failure, List<ItemEntity>>> getItems();
  Future<Either<Failure, ItemEntity>> createItem(
    String title,
    String? description,
  );
  Future<Either<Failure, ItemEntity>> updateItem(
    String id,
    String title,
    String? description,
  );
  Future<Either<Failure, void>> deleteItem(String id);
  Stream<Either<Failure, dynamic>> getRealtimeUpdates();
}
