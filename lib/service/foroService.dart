
import 'package:supabase_flutter/supabase_flutter.dart';

class Foroservice {
  static final SupabaseClient supabase = Supabase.instance.client;

  // =====================================================
  // CONSULTAR TEMAS DISPONIBLES
  // =====================================================
  static Future<List<Map<String, dynamic>>> getTemasForos() async {
    final result = await supabase
        .from('tema_foro')
        .select('*')
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  // =====================================================
  // CONSULTAR UN TEMA
  // =====================================================
  static Future<Map<String, dynamic>> getTemaForoPorId(int id) async {
    final result = await supabase
        .from('tema_foro')
        .select('*')
        .eq('id', id)
        .single();

    return Map<String, dynamic>.from(result);
  }

  // =====================================================
  // CONSULTAR MENSAJES DE UN TEMA
  // =====================================================
  static Future<List<Map<String, dynamic>>> getMensajePorTema(
    int temaId,
  ) async {
    final result = await supabase
        .from('mensaje_foro')
        .select('id, contenido, fecha, user_id')
        .eq('tema_id', temaId)
        .order('fecha', ascending: true);

    final mensajes = List<Map<String, dynamic>>.from(result);

    if (mensajes.isEmpty) {
      return mensajes;
    }

    // La información de los autores se obtiene mediante la función
    // protegida existente, sin consultar directamente sus perfiles.
    final resultadoAutores = await supabase.rpc('brujula_autores_foro');
    final autores = List<Map<String, dynamic>>.from(resultadoAutores);
    final autoresPorId = <int, Map<String, dynamic>>{};

    for (final autor in autores) {
      final id = (autor['id'] as num).toInt();
      autoresPorId[id] = autor;
    }

    for (final mensaje in mensajes) {
      final userId = (mensaje['user_id'] as num).toInt();
      mensaje['perfiles_estudiante'] = autoresPorId[userId];
    }

    return mensajes;
  }

  // =====================================================
  // IDENTIFICAR AL ESTUDIANTE QUE INICIÓ SESIÓN
  // =====================================================
  static Future<int> _obtenerPerfilActual() async {
    final usuario = supabase.auth.currentUser;

    if (usuario == null) {
      throw StateError(
        'Su sesión ha finalizado. Inicie sesión nuevamente.',
      );
    }

    final perfil = await supabase
        .from('perfiles_estudiante')
        .select('id')
        .eq('auth_uid', usuario.id)
        .maybeSingle();

    if (perfil == null) {
      throw StateError('No fue posible identificar su cuenta.');
    }

    return (perfil['id'] as num).toInt();
  }

  // =====================================================
  // FORMATO ORDENADO DE LAS PARTICIPACIONES
  // =====================================================
  // Conserva un máximo de una línea vacía entre párrafos.
  // No cambia las palabras ni el orden de los párrafos.
  static String normalizarContenido(String contenido) {
    final texto = contenido.replaceAll(RegExp(r'\r\n?'), '\n');

    final lineas = texto.split('\n').map((linea) {
      return linea.trim().replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    });

    return lineas
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  // =====================================================
  // PUBLICAR UN MENSAJE
  // =====================================================
  static Future<void> agregarMensaje({
    required int userId,
    required int temaId,
    required String contenido,
    int? parentId,
  }) async {
    final texto = normalizarContenido(contenido);

    if (texto.isEmpty) {
      throw ArgumentError('Escriba un mensaje antes de publicarlo.');
    }

    final perfilActual = await _obtenerPerfilActual();

    if (perfilActual != userId) {
      throw StateError(
        'No tiene autorización para publicar este mensaje.',
      );
    }

    await supabase.from('mensaje_foro').insert({
      'user_id': perfilActual,
      'tema_id': temaId,
      'contenido': texto,
      'parend_id': parentId,
    });
  }

  // =====================================================
  // ELIMINAR UN MENSAJE PROPIO
  // =====================================================
  static Future<bool> eliminarMensaje({
    required int idMensaje,
  }) async {
    final perfilActual = await _obtenerPerfilActual();

    final eliminados = await supabase
        .from('mensaje_foro')
        .delete()
        .eq('id', idMensaje)
        .eq('user_id', perfilActual)
        .select('id');

    return eliminados.isNotEmpty;
  }
}
