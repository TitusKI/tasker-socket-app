import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/item_model.dart';

abstract class ItemRemoteDataSource {
  Future<List<ItemModel>> getItems();
  Future<ItemModel> createItem(String title, String? description);
  Future<ItemModel> updateItem(String id, String title, String? description);
  Future<void> deleteItem(String id);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final Dio dio;

  ItemRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItemModel>> getItems() async {
    try {
      final response = await dio.get('${ApiConstants.httpBaseUrl}/items');
      if (response.statusCode == 200) {
        final List<dynamic> itemList = response.data['data'];
        return itemList.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Failed to load items: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Dio error getting items: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error getting items: $e');
    }
  }

  @override
  Future<ItemModel> createItem(String title, String? description) async {
    try {
      final response = await dio.post(
        '${ApiConstants.httpBaseUrl}/items',
        data: {'title': title, 'description': description},
      );
      if (response.statusCode == 201) {
        return ItemModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          'Failed to create item: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Dio error creating item: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error creating item: $e');
    }
  }

  @override
  Future<ItemModel> updateItem(
    String id,
    String title,
    String? description,
  ) async {
    try {
      final response = await dio.put(
        '${ApiConstants.httpBaseUrl}/items/$id',
        data: {'title': title, 'description': description},
      );
      if (response.statusCode == 200) {
        return ItemModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          'Failed to update item: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Dio error updating item: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error updating item: $e');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.httpBaseUrl}/items/$id',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          'Failed to delete item: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Dio error deleting item: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error deleting item: $e');
    }
  }
}
