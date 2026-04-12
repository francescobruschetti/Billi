import 'package:Billy/extentions/category_enum_extention.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Widget get icon {
    return CategoryEnumParsing(name).toCategoryEnum().toIcon();
  }

  // TODO: ISAR
  // factory CategoryModel.fromLocal(CategoryLocal local) => CategoryModel(
  //   id: local.id,
  //   name: local.name,
  //   userId: local.userId,
  //   createdAt: local.createdAt,
  //   updatedAt: local.updatedAt,
  // );

  // CategoryLocal toLocal({ required Duration ttl, SyncStatusEnum syncStatus = SyncStatusEnum.SYNCED, }) 
  // {
  //   final now = DateTime.now();
  //   return CategoryLocal()
  //     ..id = id
  //     ..name = name
  //     ..userId = userId
  //     ..createdAt = createdAt
  //     ..updatedAt = updatedAt
  //     ..cachedAt = now
  //     ..expiresAt = now.add(ttl)
  //     ..syncStatus = syncStatus;
  // }
}