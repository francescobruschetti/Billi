import 'package:Billy/models/category_model.dart';
// TODO: ISAR: import 'package:Billy/services/cache/category_cache_service.dart';
import 'package:Billy/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: ISAR: import 'package:supabase_flutter/supabase_flutter.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

// TODO: ISAR
// final categoryCacheServiceProvider = Provider((ref) {
//   final isar = ref.read(isarProvider); // il tuo provider Isar
//   return CategoryCacheService(isar, ttl: const Duration(hours: 1));
// });

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryModel>>>(
  (ref) => CategoryNotifier(ref.read(categoryServiceProvider)),
);

// TODO: ISAR
// final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
//   CategoriesNotifier.new,
// );

// TODO: ISAR
// class CategoryNotifier extends AsyncNotifier<List<CategoryModel>> {
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

  // Aggiunta ottimistica — aggiorna la memoria immediatamente poi sincronizza col server
  Future<void> addCategory({ required String name, String? description }) async {
    // TODO: da implementare
    // try {
    //   final newCategory = await _service.createCategory(name: name, description: description);
    //   state = state.whenData((categories) => [newCategory, ...categories]);
    // } catch (e, st) {
    //   state = AsyncError(e, st);
    // }
  }

  void addCategoryLocally(CategoryModel newCategory) {
    state = state.whenData((categories) => [newCategory, ...categories]);
  }

  // ----------------------------------------------------------

  // TODO: ISAR
  // @override
  // Future<List<CategoryModel>> build() async {
  //   return await _loadCategories();
  // }
  // 
//   Future<List<CategoryModel>> _loadCategories() async {
//     final cache = ref.read(categoryCacheServiceProvider);
//     final service = ref.read(categoryServiceProvider);
//     // 1. Prova dalla cache
//     final cached = await cache.getCategories();
//     if (cached != null) return cached;

//     // 2. Cache scaduta o vuota → fetch dal server
//     final remote = await service.fetchCategories();
//     await cache.saveCategories(remote);
//     return remote;
//   }

//   // Refresh forzato — ignora la cache
//   Future<void> refresh() async {
//     state = const AsyncLoading();
//     try {
//       final service = ref.read(categoryServiceProvider);
//       final cache = ref.read(categoryCacheServiceProvider);
//       final remote = await service.fetchCategories();
//       await cache.saveCategories(remote);
//       state = AsyncData(remote);
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }

//   // Aggiunta — online o offline
//   Future<void> addCategory(String name) async {
//     final cache = ref.read(categoryCacheServiceProvider);
//     final service = ref.read(categoryServiceProvider);

//     try {
//       // Online → salva sul server e aggiorna cache
//       final created = await service.createCategory(name);
//       await cache.markSynced(created.id);
//       state = state.whenData((cats) => [...cats, created]);
//     } 
//     on Exception {
//       // Offline → salva in pending
//       final pending = CategoryModel(
//         id: const Uuid().v4(), // id temporaneo
//         name: name,
//         userId: Supabase.instance.client.auth.currentUser!.id,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//       await cache.savePending(pending);
//       state = state.whenData((cats) => [...cats, pending]);
//     }
//   }

//   // Sincronizza i pending quando torna la connessione
//   Future<void> syncPending() async {
//     final cache = ref.read(categoryCacheServiceProvider);
//     final service = ref.read(categoryServiceProvider);
//     final pending = await cache.getPending();

//     for (final category in pending) {
//       try {
//         final created = await service.createCategory(category.name);
//         await cache.markSynced(created.id);
//       } catch (e) {
//         break; // ancora offline, riprova dopo
//       }
//     }
//   }
}