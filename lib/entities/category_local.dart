import 'package:Billy/enums/sync_status_enum.dart';
import 'package:isar/isar.dart';

// part '../entity/category_local_model.g.dart'; // genera questo file con `flutter pub run build_runner build`

@collection
class CategoryLocal {
  Id isarId = Isar.autoIncrement; // id interno di Isar

  @Index(unique: true)
  late String id; // uuid di Supabase

  late String name;
  late String? userId;
  late DateTime createdAt;
  late DateTime updatedAt;

  // TTL — quando scadono i dati
  late DateTime cachedAt;
  late DateTime expiresAt;

  // Sync offline
  @Enumerated(EnumType.name)
  late SyncStatusEnum syncStatus;
}