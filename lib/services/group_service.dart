import 'package:Billy/exceptions/app_exception.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:logging/logging.dart';
import 'package:Billy/models/group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final Logger log = Logger('GroupService');
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<GroupModel>> fetchGroups() async {
    final res = await supabase.rpc('get_user_groups');
    return (res as List)
      .map((g) => GroupModel.fromMap(g as Map<String, dynamic>))
      .toList();
  }

  Future<GroupModel> fetchGroupDetailsAndParticipants(String groupId) async {
    // Prendi dettagli gruppo e partecipanti (join con profiles)
    final res = await supabase
      .from('groups')
      .select('*, group_participants:group_participants(user_id, profiles:profiles(*))')
      .eq('id', groupId)
      .single();

    return GroupModel.fromMap(res);
  }

  Future<GroupModel> createGroup({ required String name, String? description }) async {
    try {
      final res = await supabase
        .from('groups')
        .insert({'name': name, 'description': description})
        .select()
        .single();
      return GroupModel.fromMap(res);
    } 
    catch (e) {
      throw GroupException("Impossibile creare il gruppo: $e");
    }
  }

  Future<GroupModel> updateGroup({ 
    required String id, 
    required String name, 
    String? description,
    List<GroupParticipantModel>? participantsToAdd,
    List<String>? participantsToRemoveIds,
  })
  async {
    try {
      final res = await supabase.rpc('update_group_and_participants', params: {
        'p_group_id': id,
        'p_name': name,
        'p_description': description,
        'p_participants_to_add': participantsToAdd?.map((u) => u.userId).toList() ?? [],
        'p_participants_to_remove': participantsToRemoveIds ?? [],
      }).single();
      return GroupModel.fromMap(res);
    }
    catch (e) {
      throw GroupException("Impossibile aggiornare il gruppo: $e");
    }
  }

  Future<dynamic> deleteGroup(String groupId) async {
    final res = await supabase
      .from('groups')
      .delete()
      .eq('id', groupId);
    return res;
  }
}
