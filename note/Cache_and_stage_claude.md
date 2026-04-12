# Step 1
in flutter voglio usare isar per archivare localmente i dati scaricati dal db. in particolare, quando scarico la lista di categorie, voglio salvare con un TTL e usarle dalla memoria. In futuro, la soluzione dovrà anche gestire l'inserimento di nuove categorie in assenza di connessione. Alla riconessione, il sistema dovrà sincronizzarsi con il backend. Al momento sto usando una tabella categories su supabase fatta cosi: 

```sql
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  user_id uuid default auth.uid() references auth.users(id),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);
```
--- 

Ottima scelta per una app finanziaria. Ecco un'architettura completa pensata per evolvere verso la sincronizzazione offline:

---

## 1. Modello Isar — `category_local_model.dart`

```dart
import 'package:isar/isar.dart';

part 'category_local_model.g.dart';

@collection
class CategoryLocal {
  Id isarId = Isar.autoIncrement; // id interno di Isar

  @Index(unique: true)
  late String id; // uuid di Supabase

  late String name;
  late String userId;
  late DateTime createdAt;
  late DateTime updatedAt;

  // TTL — quando scadono i dati
  late DateTime cachedAt;
  late DateTime expiresAt;

  // Sync offline
  @Enumerated(EnumType.name)
  late SyncStatus syncStatus;
}

enum SyncStatus {
  synced,     // in sync col server
  pending,    // creato offline, da sincronizzare
  deleted,    // eliminato offline, da sincronizzare
}
```

---

## 2. Modello di dominio — `category_model.dart`

```dart
import 'package:Billy/local/models/category_local_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
    id: map['id'],
    name: map['name'],
    userId: map['user_id'],
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
  );

  factory CategoryModel.fromLocal(CategoryLocal local) => CategoryModel(
    id: local.id,
    name: local.name,
    userId: local.userId,
    createdAt: local.createdAt,
    updatedAt: local.updatedAt,
  );

  CategoryLocal toLocal({
    required Duration ttl,
    SyncStatus syncStatus = SyncStatus.synced,
  }) {
    final now = DateTime.now();
    return CategoryLocal()
      ..id = id
      ..name = name
      ..userId = userId
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..cachedAt = now
      ..expiresAt = now.add(ttl)
      ..syncStatus = syncStatus;
  }
}
```

---

## 3. Cache service — `category_cache_service.dart`

```dart
import 'package:isar/isar.dart';
import 'package:Billy/local/models/category_local_model.dart';
import 'package:Billy/models/category_model.dart';

class CategoryCacheService {
  final Isar _isar;
  final Duration ttl;

  CategoryCacheService(this._isar, {this.ttl = const Duration(hours: 1)});

  // Leggi dalla cache — null se scaduta o vuota
  Future<List<CategoryModel>?> getCategories() async {
    final cached = await _isar.categoryLocals
      .filter()
      .syncStatusEqualTo(SyncStatus.synced)
      .findAll();

    if (cached.isEmpty) return null;

    // Controlla se la cache è scaduta
    final oldest = cached.map((c) => c.expiresAt).reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );
    if (DateTime.now().isAfter(oldest)) return null; // scaduta

    return cached.map(CategoryModel.fromLocal).toList();
  }

  // Salva lista dal server
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _isar.writeTxn(() async {
      // Rimuovi solo i synced, tieni i pending
      await _isar.categoryLocals
        .filter()
        .syncStatusEqualTo(SyncStatus.synced)
        .deleteAll();

      await _isar.categoryLocals.putAll(
        categories.map((c) => c.toLocal(ttl: ttl)).toList(),
      );
    });
  }

  // Aggiunta offline
  Future<void> savePending(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryLocals.put(
        category.toLocal(ttl: ttl, syncStatus: SyncStatus.pending),
      );
    });
  }

  // Leggi pending da sincronizzare
  Future<List<CategoryModel>> getPending() async {
    final pending = await _isar.categoryLocals
      .filter()
      .syncStatusEqualTo(SyncStatus.pending)
      .findAll();
    return pending.map(CategoryModel.fromLocal).toList();
  }

  // Marca come sincronizzato dopo il sync
  Future<void> markSynced(String id) async {
    await _isar.writeTxn(() async {
      final local = await _isar.categoryLocals
        .filter()
        .idEqualTo(id)
        .findFirst();
      if (local != null) {
        local.syncStatus = SyncStatus.synced;
        local.expiresAt = DateTime.now().add(ttl);
        await _isar.categoryLocals.put(local);
      }
    });
  }

  Future<void> clear() async {
    await _isar.writeTxn(() => _isar.categoryLocals.clear());
  }
}
```

---

## 4. Category service — `category_service.dart`

```dart
class CategoryService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<CategoryModel>> fetchCategories() async {
    final res = await supabase
      .from('categories')
      .select()
      .order('name');
    return (res as List).map((c) => CategoryModel.fromMap(c)).toList();
  }

  Future<CategoryModel> createCategory(String name) async {
    final res = await supabase
      .from('categories')
      .insert({'name': name})
      .select()
      .single();
    return CategoryModel.fromMap(res);
  }
}
```

---

## 5. Provider — `category_provider.dart`

```dart
final categoryServiceProvider = Provider((ref) => CategoryService());

final categoryCacheServiceProvider = Provider((ref) {
  final isar = ref.read(isarProvider); // il tuo provider Isar
  return CategoryCacheService(isar, ttl: const Duration(hours: 1));
});

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    return await _loadCategories();
  }

  Future<List<CategoryModel>> _loadCategories() async {
    final cache = ref.read(categoryCacheServiceProvider);
    final service = ref.read(categoryServiceProvider);

    // 1. Prova dalla cache
    final cached = await cache.getCategories();
    if (cached != null) return cached;

    // 2. Cache scaduta o vuota → fetch dal server
    final remote = await service.fetchCategories();
    await cache.saveCategories(remote);
    return remote;
  }

  // Refresh forzato — ignora la cache
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(categoryServiceProvider);
      final cache = ref.read(categoryCacheServiceProvider);
      final remote = await service.fetchCategories();
      await cache.saveCategories(remote);
      state = AsyncData(remote);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Aggiunta — online o offline
  Future<void> addCategory(String name) async {
    final cache = ref.read(categoryCacheServiceProvider);
    final service = ref.read(categoryServiceProvider);

    try {
      // Online → salva sul server e aggiorna cache
      final created = await service.createCategory(name);
      await cache.markSynced(created.id);
      state = state.whenData((cats) => [...cats, created]);
    } on CategoryException {
      // Offline → salva in pending
      final pending = CategoryModel(
        id: const Uuid().v4(), // id temporaneo
        name: name,
        userId: Supabase.instance.client.auth.currentUser!.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await cache.savePending(pending);
      state = state.whenData((cats) => [...cats, pending]);
    }
  }

  // Sincronizza i pending quando torna la connessione
  Future<void> syncPending() async {
    final cache = ref.read(categoryCacheServiceProvider);
    final service = ref.read(categoryServiceProvider);
    final pending = await cache.getPending();

    for (final category in pending) {
      try {
        final created = await service.createCategory(category.name);
        await cache.markSynced(created.id);
      } catch (e) {
        break; // ancora offline, riprova dopo
      }
    }
  }
}
```

---

## Schema del flusso

```
getCategories()
  ├── cache valida?  → restituisce dalla cache (Isar)
  └── cache scaduta? → fetch da Supabase → salva in Isar → restituisce

addCategory()
  ├── online  → Supabase → markSynced → aggiorna state
  └── offline → savePending (Isar) → aggiorna state ottimisticamente

syncPending()  ← chiamato quando torna la connessione
  └── per ogni pending → Supabase → markSynced
```

Quando vorrai aggiungere il rilevamento della connessione, basterà ascoltare `connectivity_plus` e chiamare `syncPending()` automaticamente al reconnect.