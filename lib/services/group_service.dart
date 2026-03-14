import 'package:logging/logging.dart';
import 'package:Billy/models/api_response_model.dart';
import 'package:Billy/models/group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final Logger log = Logger('GroupService');
  final SupabaseClient supabase = Supabase.instance.client;

  // TODO: replace all Map<String, dynamic> with proper models

  Future<ApiResponseModel<Map<String, dynamic>>> createGroup({ required String name, String? description }) async {
    try {
      final res = await supabase.from('groups').insert({
        'name': name,
        'description': description
      }).select().single();
      return ApiResponseModel<Map<String, dynamic>>(success: true, message: null, data: res);
    } 
    catch (e) {
      log.severe("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }

  // TODO: created to test and implement group_provider.dart
  Future<GroupModel> createGroupProvider(String name) async {
    try {
      final response = await supabase
        .from('groups')
        .insert({'name': name})
        .select()
        .single();

      return GroupModel.fromMap(response);
    } 
    catch (e) {
      log.severe("Errore creazione gruppo: $e");
      return GroupModel.fromMap({});
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllGroupsForUser() async {
    final res = await supabase.rpc('get_user_groups');
    return (res as List)
        .map((g) => g as Map<String, dynamic>)
        .toList();
  }

  // TODO: created to test and implement group_provider.dart
  Future<List<GroupModel>> fetchGroupsProvider() async {
    try {
      final res = await supabase.rpc('get_user_groups');
      return (res as List)
        .map((g) => GroupModel.fromMap(g as Map<String, dynamic>))
        .toList();
    }
    catch (e) {
      log.severe("Errore fetchGroups: $e");
      return [];
    }

  }

  Future<ApiResponseModel<GroupModel>> getGroupDetailsAndParticipants(String groupId) async {
    try {
      // Prendi dettagli gruppo e partecipanti (join con profiles)
      final res = await supabase
        .from('groups')
        .select('*, group_participants:group_participants(user_id, profiles:profiles(*))')
        .eq('id', groupId)
        .single();

      return ApiResponseModel<GroupModel>(success: true, message: null, data: GroupModel.fromMap(res));
    } 
    catch (e) {
      log.severe("Errore getGroupDetailsAndParticipants: $e");
      return ApiResponseModel<GroupModel>(success: false, message: e.toString(), data: GroupModel.fromMap({}));
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
      log.severe("Errore creazione gruppo: $e");
      return ApiResponseModel<Map<String, dynamic>>(success: false, message: e.toString(), data: {});
    }
  }
}
