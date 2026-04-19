// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum SyncStatusEnum {
  SYNCED("SYNCED"), // in sync col server
  PENDING("PENDING"), // creato offline, da sincronizzare
  DELETED("DELETED"); // eliminato offline, da sincronizzare

  final String value;
  const SyncStatusEnum(this.value);
}