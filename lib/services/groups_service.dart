import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/models/group_details_model.dart';
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
    List<Map<String, dynamic>>? participantsToRemove,
  })
  async {
    try {
      final res = await supabase.from('groups').update({
        'name': name,
        'description': description
      })
      .eq("id", id)
      .select().single();

      // TODO:
      // if (participantsToAdd != null && participantsToAdd.isNotEmpty) {
      //   await supabase.from('group_participants').insert(
      //     participantsToAdd.map((u) => {
      //       'group_id': id,
      //       'user_id': u['id'],
      //       // aggiungi altri campi se necessari
      //     }).toList(),
      //   );
      // }
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: res);
    } 
    catch (e) {
      print("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }


}
