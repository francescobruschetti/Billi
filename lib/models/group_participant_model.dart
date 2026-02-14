import 'package:monitoraggio_spese/models/profile_model.dart';

class GroupParticipantModel {
  final String userId;
  final ProfileModel profile;

  GroupParticipantModel({
    required this.userId,
    required this.profile,
  });
 
  factory GroupParticipantModel.fromMap(Map<String, dynamic> map) {
    // accetta sia 'profiles' che 'profile' come chiave
    final profileMap = map['profiles'] ?? map['profile'];
    return GroupParticipantModel(
      userId: map['user_id'],
      profile: profileMap != null ? ProfileModel.fromMap(profileMap) : ProfileModel.empty(),
    );
  }
}