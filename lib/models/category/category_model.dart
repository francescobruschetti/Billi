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
}