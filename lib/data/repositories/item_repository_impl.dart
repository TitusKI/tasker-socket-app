import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tasker/core/error/exceptions.dart';
import 'package:tasker/core/error/failures.dart';
import 'package:tasker/data/datasources/item_remote_data_source.dart';
import 'package:tasker/data/datasources/item_websocket_data_source.dart';
import 'package:tasker/domain/repositories/item_repository.dart';

import '../../domain/entities/item_entity.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;
  final ItemWebsocketDataSource webSocketDataSource;
  ItemRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketDataSource,
  });
  Future<Either<Failure, T>> _tryCatch<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure("Network error: ${e.message}"));
    } catch (e) {
      return Left(UnknownFailure("An unexpected error occurred: $e"));
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getItems() async {
    return await _tryCatch(() => remoteDataSource.getItems());
  }

  @override
  Future<Either<Failure, ItemEntity>> createItem(
    String title,
    String? description,
  ) async {
    return await _tryCatch(
      () => remoteDataSource.createItem(title, description),
    );
  }

  @override
  Future<Either<Failure, ItemEntity>> updateItem(
    String id,
    String title,
    String? description,
  ) async {
    return await _tryCatch(
      () => remoteDataSource.updateItem(id, title, description),
    );
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    return await _tryCatch(() => remoteDataSource.deleteItem(id));
  }

  @override
  Stream<Either<Failure, dynamic>> getRealtimeUpdates() {
    try {
      return webSocketDataSource
          .connectAndListen()
          .map((event) {
            return Right<Failure, dynamic>(event);
          })
          .handleError((error) {
            if (error is NetworkException) {
              {
                return Left<Failure, dynamic>(
                  NetworkFailure("WebSocket failure : ${error.message}"),
                );
              }
            }
            return Left<Failure, dynamic>(
              UnknownFailure("WebSocket stream error: ${error.toString()}"),
            );
          });
    } catch (e) {
      return Stream.value(
        Left(
          NetworkFailure(
            "Failed to establish websocket connection: ${e.toString()}",
          ),
        ),
      );
    }
  }
}
