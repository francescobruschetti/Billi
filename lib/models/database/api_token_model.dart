class ApiTokenModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  ApiTokenModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastUsedAt,
    this.revokedAt,
  });
}