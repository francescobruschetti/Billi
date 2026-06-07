import 'package:Billy/enums/group_role_enum.dart';
import 'package:Billy/models/profile_model.dart';

class GroupParticipantModel {
  final String userId;
  final GroupRoleEnum role;
  final bool isEnabled;
  final DateTime? leftAt;
  final ProfileModel profile;

  GroupParticipantModel({
    required this.userId,
    required this.role,
    required this.isEnabled,
    this.leftAt,
    required this.profile,
  });
 
  factory GroupParticipantModel.fromMap(Map<String, dynamic> map) {
    // accetta sia 'profiles' che 'profile' come chiave
    final profileMap = map['profiles'] ?? map['profile'];
    return GroupParticipantModel(
      userId: map['user_id'],
      role: GroupRoleEnum.values.firstWhere((e) => e.value == map['role'], orElse: () => GroupRoleEnum.MEMBER),
      isEnabled: map['is_enabled'],
      leftAt: map['left_at'] != null ? DateTime.parse(map['left_at']) : null,
      profile: profileMap != null ? ProfileModel.fromMap(profileMap) : ProfileModel.empty(),
    );
  }
}