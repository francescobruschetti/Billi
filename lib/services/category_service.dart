import 'package:Billy/models/category_model.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final Logger _log = Logger('CategoryService');
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> fetchCategories( ) async {
    final userId = _supabase.auth.currentUser!.id;

    final res = await _supabase
      .from('categories')
      .select('*')
      .or('user_id.is.null,user_id.eq.$userId')
      .order('name', ascending: true);
    return (res as List).map((c) => CategoryModel.fromMap(c)).toList();
  }

  // TODO: ISAR
  // Future<CategoryModel> createCategory(String name) async {
  //   final res = await _supabase
  //     .from('categories')
  //     .insert({'name': name})
  //     .select()
  //     .single();
  //   return CategoryModel.fromMap(res);
  // }
}