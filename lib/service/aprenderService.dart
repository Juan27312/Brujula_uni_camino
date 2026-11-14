
import 'package:supabase_flutter/supabase_flutter.dart';

class Aprenderservice{
  static final supabase = Supabase.instance.client;
  
  static Future<List<Map<String,dynamic>>> getAprender(int aprender_id) async{
    final result = await supabase
      .from('items_aprender')
      .select('*')
      .eq("aprender_id", aprender_id);
      return List<Map<String,dynamic>>.from(result);
  }
}

