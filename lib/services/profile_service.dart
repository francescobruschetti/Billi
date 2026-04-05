import 'package:Billy/models/profile_model.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final Logger _log = Logger('ProfileService');
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfileModel> getUserByEmailOrUsername(String key) async {
    final res = await _supabase.rpc('get_user_by_email_or_username', params: {
      'p_email': key,
      'p_username': key,
    });
    _log.fine("Fetched user by email or username '$key': $res");

    return ProfileModel.fromMap((res as List).first);
  }
}
