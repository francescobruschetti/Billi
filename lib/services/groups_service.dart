import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/models/group_details_model.dart';
import 'package:monitoraggio_spese/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<ApiResponseModel<Map<String, dynamic>>> createGroup({ required String name, String? description }) async {
    try {
      final res = await supabase.from('groups').insert({
        'name': name,
        'description': description
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: res);
    } 
    catch (e) {
      print("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllGroupsForUser() async {
    final res = await supabase.rpc('get_user_groups');
    print("Fetched groups: $res");

    return (res as List)
        .map((g) => g as Map<String, dynamic>)
        .toList();
  }

  Future<ApiResponseModel<GroupDetailsModel>> getGroupDetailsAndParticipants(String groupId) async {
    try {
      // Prendi dettagli gruppo e partecipanti (join con profiles)
      final res = await supabase
        .from('groups')
        .select('*, group_participants:group_participants(user_id, profiles:profiles(*))')
        .eq('id', groupId)
        .single();

      return ApiResponseModel<GroupDetailsModel>(success: true, message: null, data: GroupDetailsModel.fromMap(res));
    } 
    catch (e) {
      print("Errore getGroupDetailsAndParticipants: $e");
      return ApiResponseModel<GroupDetailsModel>(success: false, message: e.toString(), data: GroupDetailsModel.fromMap({}));
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>>> updateGroup({ 
    required String id, 
    required String name, 
    String? description,
    List<Map<String, dynamic>>? participantsToAdd,
    List<String>? participantsToRemoveIds,
  })
  async {
    try {
      final res = await supabase.rpc('update_group_and_participants', params: {
        'p_group_id': id,
        'p_name': name,
        'p_description': description,
        'p_participants_to_add': participantsToAdd?.map((u) => u['id']).toList() ?? [],
        'p_participants_to_remove': participantsToRemoveIds ?? [],
      });

      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: {'id': res});
    } 
    catch (e) {
      print("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }


}
