import 'package:Billy/exceptions/app_exception.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final Logger log = Logger('GroupService');
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<GroupDetailsModel>> fetchGroups() async {
    try {
      final res = await supabase.rpc('get_user_groups');
      return (res as List)
        .map((g) => GroupDetailsModel.fromMap(g as Map<String, dynamic>))
        .toList();
    } catch (e) {
      log.severe("Errore fetching groups: $e");
      throw AppException("Impossibile caricare i gruppi. Riprova più tardi.");
    }
  }

  Future<GroupDetailsModel> fetchGroupDetailsAndParticipants(String groupId) async {
    // Prendi dettagli gruppo e partecipanti (join con profiles)
    final res = await supabase
      .from('groups')
      .select('*, group_participants:group_participants(user_id, profiles:profiles(*))')
      .eq('id', groupId)
      .single();

    return GroupDetailsModel.fromMap(res);
  }

  Future<GroupDetailsModel> createGroup({ required String name, String? description }) async {
    try {
      final res = await supabase
        .from('groups')
        .insert({'name': name, 'description': description})
        .select()
        .single();
      return GroupDetailsModel.fromMap(res);
    } 
    catch (e) {
      throw GroupException("Impossibile creare il gruppo: $e");
    }
  }

  Future<GroupDetailsModel> updateGroup({ 
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
      return GroupDetailsModel.fromMap(res);
    }
    catch (e) {
      throw GroupException("Impossibile aggiornare il gruppo: $e");
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await supabase
      .from('groups')
      .delete()
      .eq('id', groupId);
    return;
  }
}
