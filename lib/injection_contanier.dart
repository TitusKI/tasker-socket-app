import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tasker/data/datasources/item_websocket_data_source.dart';
import 'data/datasources/item_remote_data_source.dart';
import 'data/repositories/item_repository_impl.dart';
import 'domain/repositories/item_repository.dart';
import 'domain/usecases/create_item.dart';
import 'domain/usecases/delete_item.dart';
import 'domain/usecases/get_all_items.dart';
import 'domain/usecases/get_real_time_updates.dart';
import 'domain/usecases/update_item.dart';
import 'presentation/bloc/item_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // dio
  final dio = Dio();
  sl.registerLazySingleton<Dio>(() => dio);
  // bloc

  sl.registerFactory(
    () => ItemBloc(
      getAllItems: sl(),
      createItem: sl(),
      updateItem: sl(),
      deleteItem: sl(),
      listenToRealtimeUpdates: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllItems(sl()));
  sl.registerLazySingleton(() => CreateItem(sl()));
  sl.registerLazySingleton(() => UpdateItem(sl()));
  sl.registerLazySingleton(() => DeleteItem(sl()));
  sl.registerLazySingleton(() => GetRealTimeUpdates(sl()));

  // Repository
  sl.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(remoteDataSource: sl(), webSocketDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ItemRemoteDataSource>(
    () => ItemRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ItemWebsocketDataSource>(
    () => ItemWebSocketDataSourceImpl(),
  );
}
