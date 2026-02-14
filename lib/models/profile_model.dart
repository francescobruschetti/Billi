
class ProfileModel {
  final String id;
  final String name;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });  
  
  factory ProfileModel.empty() {
    return ProfileModel(
      id: '', name: '', username: '', 
      createdAt: DateTime.fromMillisecondsSinceEpoch(0), 
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0)
    );
  }
 
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}