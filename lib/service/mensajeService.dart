
import 'package:supabase_flutter/supabase_flutter.dart';

class mensajeService{
  static final supabase = Supabase.instance.client;
  
  static Future<List<Map<String,dynamic>>> getMensajeSemanal() async{
    final result = await supabase
      .from('mensaje_semanal')
      .select('*')
      .order('fecha_publicacion', ascending: false);
      return List<Map<String,dynamic>>.from(result);
  }
}

