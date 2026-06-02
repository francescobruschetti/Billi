class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String link;
  final String userId;  
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.link,
    this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'],
      name: map['name'],
      link: map['link'],
      description: map['description'] ?? '',
      userId: map['user_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}