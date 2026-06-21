import 'dart:convert';
import 'dart:math';
import 'package:Billy/constants.dart';
import 'package:logging/logging.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiTokenService {
  final Logger log = Logger('ApiTokenService');
  final supabase = Supabase.instance.client;

  String generateApiToken() {
    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return '${AppConstants.apiTokenPrefix}${base64Url.encode(bytes)}';
  }

  String sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  Future<void> saveHashedTokenToSecureStorage({required String hashedToken, String? tokenName}) async {
    try {
      await supabase
        .from('api_tokens')
        .insert({
          'user_id': supabase.auth.currentUser!.id,
          'name': tokenName,
          'token_hash': hashedToken,
        });
    } 
    catch (e) {
      log.severe('Error saving hashed token to secure storage: $e');
      rethrow;
    }
  }
}
