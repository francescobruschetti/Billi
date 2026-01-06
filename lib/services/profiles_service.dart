import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<dynamic>> getUserByEmailOrUsername(String key) async {
    final res = await supabase.rpc('get_user_by_email_or_username', params: {
      'p_email': key,
      'p_username': key,
    });
    print("Fetched user by email or username '$key': $res");

    return res;
  }
}
