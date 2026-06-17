import 'package:Billy/models/category/category_model.dart';

class CreateCategoryResponseModel {
  final CategoryModel? category;
  final String? newName;
  final bool isNew;

  CreateCategoryResponseModel({
    this.category,
    this.newName,
    required this.isNew,
  });
}