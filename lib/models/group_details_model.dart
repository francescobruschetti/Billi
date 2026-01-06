import 'package:monitoraggio_spese/models/group_participant_model.dart';
import 'package:monitoraggio_spese/models/profile_model.dart';

class GroupDetailsModel {
  final String id;
  final String name;
  final String? description;
  final String link;
  final String creatorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<GroupParticipantModel> groupParticipants;

  GroupDetailsModel({
    required this.id,
    required this.name,
    required this.link,
    required this.description,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
    required this.groupParticipants,
  });

  factory GroupDetailsModel.fromMap(Map<String, dynamic> map) {
    return GroupDetailsModel(
      id: map['id'],
      name: map['name'],
      link: map['link'],
      description: map['description'],
      creatorId: map['creator_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.fromMillisecondsSinceEpoch(0),
      groupParticipants: (map['group_participants'] as List? ?? [])
        .map((e) => GroupParticipantModel.fromMap(e as Map<String, dynamic>))
        .toList(),
    );
  }
}