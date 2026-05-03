import 'package:Billy/models/profile_model.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final Logger log = Logger('ProfileService');
  final SupabaseClient supabase = Supabase.instance.client;

  Future<ProfileModel> getUserByEmailOrUsername(String key) async {
    final res = await supabase.rpc('get_user_by_email_or_username', params: {
      'p_email': key,
      'p_username': key,
    });
    log.fine("Fetched user by email or username '$key': $res");

    if (res == null || (res is List && res.isEmpty)) {
      log.warning("No user found with email or username '$key'. Returning empty profile.");
      return ProfileModel.empty();
    }

    return ProfileModel.fromMap((res as List).first);
  }

  String getCurrentUserId() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      log.warning('No user is currently logged in. Returning empty user ID.');
      throw Exception('No user logged in');
    }
    return userId;
  }
}
