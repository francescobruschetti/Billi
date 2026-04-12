import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninSignupLogoutService {
  final Logger log = Logger('SigninSignupLogoutService');
  final SupabaseClient supabase = Supabase.instance.client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
    }
    catch (e) {
      log.severe("Errore login: $e");
      throw Exception("Errore login");
    }
  }
  
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    try {
      return await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'username': username.trim(),
          'name': name.trim(),
        },
      );
      
    }
    catch (e) {
      log.severe("Errore registrazione: $e");
      throw Exception("Errore registrazione");
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } 
    catch (e) {
      log.severe("Errore logout: $e");
      throw Exception("Errore logout");
    }
  }
}