import 'package:supabase_flutter/supabase_flutter.dart';

class Evaluacionesservice {
  static final supabase = Supabase.instance.client;

  // Obtener evaluaciones (tests)
  static Future<List<Map<String, dynamic>>> getEvaluaciones() async {
    final result = await supabase.from('test').select('*');
    return List<Map<String, dynamic>>.from(result);
  }

  //Obtener preguntas con sus opciones
  static Future<List<Map<String, dynamic>>> getPreguntas(int testId) async {
    final result = await supabase.from('pregunta').select('''
        id, 
        pregunta,
        orden,
        opcion_respuesta (
          id, 
          respuesta, 
          puntaje
        )
      ''').eq('test_id', testId)
      .order('orden',ascending: true);
      
    return List<Map<String, dynamic>>.from(result);
  }



  // Obtener consejo según puntaje
  
  static Future<Map<String, dynamic>?> getConsejo(int testId, int puntaje) async {
  try {
    final results = await supabase
        .from('consejo_resultado')
        .select('*')
        .eq('test_id', testId)
        .filter('rango_min', 'lte', puntaje)
        .filter('rango_max', 'gte', puntaje);
    
    if (results.isEmpty) {
      final allRanges = await supabase
          .from('consejo_resultado')
          .select('rango_min, rango_max')
          .eq('test_id', testId);
      return null;
    }

    final result = results.first;
    print('✅ Consejo encontrado: $result');
    return result;

  } catch (e) {
    print('❌ Error al obtener consejo: $e');
    print('📊 Parámetros - TestID: $testId, Puntaje: $puntaje');
    return null;
  }
}
  
  
  
  
  
  
  // Guardar resultado de un test
  static Future<bool> guardarResultado({
    required int usuarioId,
    required int testId,
    required int puntajeTotal,
  }) async {
    try {
      await supabase.from('resultado_test').insert([
        {
          'usuario_id': usuarioId,
          'test_id': testId,
          'puntaje_total': puntajeTotal,
        }
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }
}
