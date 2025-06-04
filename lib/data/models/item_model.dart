import '../../domain/entities/item_entity.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.title,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
    };
  }
}
