class ApiTokenModel {
  // ! IMPORTANT: Never return the actual token value from the database, not even the hashed value (which would be useless anyway)
  final String id;
  final String userId;
  final String name;
  final String tokenHash;
  final DateTime validUntil;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  ApiTokenModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.tokenHash,
    required this.validUntil,
    required this.createdAt,
    this.updatedAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  factory ApiTokenModel.fromMap(Map<String, dynamic> map) {
    return ApiTokenModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      tokenHash: map['token_hash'],
      validUntil: DateTime.parse(map['valid_until']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      lastUsedAt: map['last_used_at'] != null ? DateTime.parse(map['last_used_at']) : null,
      revokedAt: map['revoked_at'] != null ? DateTime.parse(map['revoked_at']) : null,
    );
  }

  factory ApiTokenModel.fromJson(Map<String, dynamic> json) {
    return ApiTokenModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      tokenHash: json['token_hash'],
      validUntil: DateTime.parse(json['valid_until']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at']) : null,
      revokedAt: json['revoked_at'] != null ? DateTime.parse(json['revoked_at']) : null,
    );
  }

  static List<ApiTokenModel> fromList(List<dynamic> tokensMap) {
    List<ApiTokenModel> tokens = [];
    for (var item in tokensMap) {
      tokens.add(ApiTokenModel.fromJson(item));
    }
    return tokens;
  }
}