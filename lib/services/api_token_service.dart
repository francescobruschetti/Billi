import 'dart:convert';
import 'dart:math';
import 'package:Billy/constants.dart';
import 'package:Billy/models/database/api_token_model.dart';
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

  Future<ApiTokenModel> saveHashedTokenToSecureStorage({required String hashedToken, required DateTime validUntil, required String? tokenName}) async {
    try {
      final res = await supabase
        .from('api_tokens')
        .insert({
          'user_id': supabase.auth.currentUser!.id,
          'name': tokenName,
          'valid_until': validUntil.toIso8601String(),
          'token_hash': hashedToken,
        })
        .select()
        .single();
        return ApiTokenModel.fromMap(res);
    } 
    catch (e) {
      log.severe('Error saving hashed token to secure storage: $e');
      rethrow;
    }
  }

  Future<List<ApiTokenModel>> fetchApiTokens() async {
    try {
      final response = await supabase
        .from('api_tokens')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id);

      return ApiTokenModel.fromList(response);
    } 
    catch (e) {
      log.severe('Error fetching API tokens: $e');
      rethrow;
    }
  }
}
