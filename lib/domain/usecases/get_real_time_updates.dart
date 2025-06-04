import 'package:dartz/dartz.dart';
import 'package:tasker/core/error/failures.dart';
import 'package:tasker/core/usecase/usecase.dart';
import 'package:tasker/domain/repositories/item_repository.dart';

class GetRealTimeUpdates implements StreamUseCase<dynamic, NoParams> {
  final ItemRepository repository;

  GetRealTimeUpdates(this.repository);

  @override
  Stream<Either<Failure, dynamic>> call(NoParams params) {
    return repository.getRealtimeUpdates();
  }
}
