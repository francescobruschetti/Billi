class MerchantModel {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantModel.fromMap(Map<String, dynamic> map) {
    return MerchantModel(
      id: map['id'],
      name: map['name'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}