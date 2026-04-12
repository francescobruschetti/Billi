// TODO: ISAR
//import 'package:Billy/enums/sync_status_enum.dart';
// import 'package:isar/isar.dart';
// import 'package:Billy/entities/category_local.dart';
// import 'package:Billy/models/category_model.dart';

// class CategoryCacheService {
//   final Isar _isar;
//   final Duration ttl;

//   CategoryCacheService(this._isar, {this.ttl = const Duration(hours: 1)});

//   // Leggi dalla cache — null se scaduta o vuota
//   Future<List<CategoryModel>?> getCategories() async {
//     final cached = await _isar.categoryLocals
//       .filter()
//       .syncStatusEqualTo(SyncStatusEnum.SYNCED)
//       .findAll();

//     if (cached.isEmpty) return null;

//     // Controlla se la cache è scaduta
//     final oldest = cached.map((c) => c.expiresAt).reduce(
//       (a, b) => a.isBefore(b) ? a : b,
//     );
//     if (DateTime.now().isAfter(oldest)) return null; // scaduta

//     return cached.map(CategoryModel.fromLocal).toList();
//   }

//   // Salva lista dal server
//   Future<void> saveCategories(List<CategoryModel> categories) async {
//     await _isar.writeTxn(() async {
//       // Rimuovi solo i synced, tieni i pending
//       await _isar.categoryLocals
//         .filter()
//         .syncStatusEqualTo(SyncStatusEnum.SYNCED)
//         .deleteAll();

//       await _isar.categoryLocals.putAll(
//         categories.map((c) => c.toLocal(ttl: ttl)).toList(),
//       );
//     });
//   }

//   // Aggiunta offline
//   Future<void> savePending(CategoryModel category) async {
//     await _isar.writeTxn(() async {
//       await _isar.categoryLocals.put(
//         category.toLocal(ttl: ttl, syncStatus: SyncStatusEnum.PENDING),
//       );
//     });
//   }

//   // Leggi pending da sincronizzare
//   Future<List<CategoryModel>> getPending() async {
//     final pending = await _isar.categoryLocals
//       .filter()
//       .syncStatusEqualTo(SyncStatusEnum.PENDING)
//       .findAll();
//     return pending.map(CategoryModel.fromLocal).toList();
//   }

//   // Marca come sincronizzato dopo il sync
//   Future<void> markSynced(String id) async {
//     await _isar.writeTxn(() async {
//       final local = await _isar.categoryLocals
//         .filter()
//         .idEqualTo(id)
//         .findFirst();
//       if (local != null) {
//         local.syncStatus = SyncStatusEnum.SYNCED;
//         local.expiresAt = DateTime.now().add(ttl);
//         await _isar.categoryLocals.put(local);
//       }
//     });
//   }

//   Future<void> clear() async {
//     await _isar.writeTxn(() => _isar.categoryLocals.clear());
//   }
// }