import 'package:Billy/models/category_model.dart';
import 'package:Billy/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryModel>>>(
  (ref) => CategoryNotifier(ref.read(categoryServiceProvider)),
);

class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoryService _service;

  CategoryNotifier(this._service) : super(const AsyncLoading()) {
    _loadFromServer();
  }

  // Carica dal server — chiamato solo all'avvio e su refresh forzato
  Future<void> _loadFromServer() async {
    try {
      state = const AsyncLoading();
      final categories = await _service.fetchCategories();
      state = AsyncData(categories);
    } 
    catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void addCategoryLocally(CategoryModel newCategory) {
    state = state.whenData((categories) => [newCategory, ...categories]);
  }
}