import 'package:Billy/models/category_model.dart';
import 'package:Billy/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

final categoryProvider = NotifierProvider<CategoryNotifier, AsyncValue<List<CategoryModel>>>(
  CategoryNotifier.new,
);

class CategoryNotifier extends Notifier<AsyncValue<List<CategoryModel>>> {
  late final CategoryService _service;

  @override
  AsyncValue<List<CategoryModel>> build() {
    _service = ref.read(categoryServiceProvider);

    // stato iniziale
    _loadFromServer();

    return const AsyncLoading();
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