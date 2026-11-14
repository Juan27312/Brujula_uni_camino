import 'package:supabase_flutter/supabase_flutter.dart';

class metricasService {
  static final supabase = Supabase.instance.client;

  static Future<int?> inicioSesion({
    required int estudianteId,
  }) async {
    try {
      print('📝 Intentando crear registro para estudiante: $estudianteId');
      
      final result = await supabase
          .from('registro_accesos')
          .insert({
            'estudiante_id': estudianteId,
            'fecha_inicio': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();
      
      print('✅ Registro creado exitosamente: ${result['id']}');
      return result['id'] as int;
    } catch (e) {
      print('❌ Error al iniciar sesión: $e');
      return null;
    }
  }

  static Future<bool> terminarTiempo({required int id}) async {
    try {
      print('📝 Intentando cerrar registro ID: $id');
      
      await supabase
          .from('registro_accesos')
          .update({
            'fecha_fin': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      print('✅ Registro cerrado exitosamente: $id');
      return true;
    } catch (e) {
      print('❌ Error al terminar tiempo: $e');
      return false;
    }
  }

  // Método útil para verificar registros abiertos (opcional)
  static Future<List<Map<String, dynamic>>> obtenerRegistrosAbiertos({
    required int estudianteId,
  }) async {
    try {
      final result = await supabase
          .from('registro_accesos')
          .select()
          .eq('estudiante_id', estudianteId)
          .isFilter('fecha_fin', null);
      
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('❌ Error al obtener registros abiertos: $e');
      return [];
    }
  }
}