
import 'package:brujula_uni/service/perfilService.dart';
import 'package:brujula_uni/service/brujulaConexionService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemService {
  static final supabase = Supabase.instance.client;

  // =====================================
  // ITEMS
  // =====================================

  static Future<List<Map<String, dynamic>>> getItems(
    int itemId,
  ) async {
    final tabla = 'item$itemId';

    final result = await supabase
        .from(tabla)
        .select('*')
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(result);
  }

  // =====================================
  // OBTENER ID DEL PERFIL
  // =====================================

  static Future<int> obtenerIdPerfil(int authId) async {
    final perfil = await PerfilService.getPerfilUsuario(authId);

    if (perfil == null || perfil['id'] == null) {
      throw Exception(
        'No se encontró el perfil del estudiante',
      );
    }

    return (perfil['id'] as num).toInt();
  }

  // =====================================
  // OBTENER PUBLICACIONES Y VALORACIONES
  // SEGÚN LA CARRERA DEL ESTUDIANTE
  // =====================================

  static Future<List<Map<String, dynamic>>> getSubItemsPorItem(
    int itemId,
    int itemPadre,
    int authId,
  ) async {
    if (itemId <= 0 || itemPadre < 1 || itemPadre > 10) {
      throw Exception('La sección solicitada no es válida.');
    }

    final conexion = BrujulaConexionService.instancia;

    // Recuperar la sesión protegida si ha vencido.
    if (!conexion.tieneSesion) {
      await conexion.iniciarSesionConAuth();
    }

    final token = conexion.tokenSesion;

    if (token == null || token.isEmpty) {
      throw const BrujulaConexionException(
        'Tu sesión ha vencido. Vuelve a ingresar.',
      );
    }

    // Las publicaciones se seleccionan en Supabase.
    // La carrera se obtiene del perfil autenticado
    // y no de un dato enviado por Flutter.
    final resultado = await supabase.functions.invoke(
      'brujula-conexion',
      body: {
        'accion': 'listar_publicaciones',
        'item_padre': itemPadre,
        'item_id': itemId,
      },
      headers: {
        'X-Brujula-Session': token,
      },
    );

    if (resultado.data is! Map) {
      throw const BrujulaConexionException(
        'No se pudieron consultar las publicaciones.',
      );
    }

    final respuesta =
        Map<String, dynamic>.from(resultado.data as Map);

    if (respuesta['ok'] != true) {
      throw BrujulaConexionException(
        respuesta['mensaje']?.toString() ??
            'No se pudieron consultar las publicaciones.',
      );
    }

    final publicaciones = respuesta['publicaciones'];

    if (publicaciones is! List) {
      throw const BrujulaConexionException(
        'La información recibida no es válida.',
      );
    }

    return publicaciones.map<Map<String, dynamic>>(
      (publicacion) {
        if (publicacion is! Map) {
          throw const BrujulaConexionException(
            'La información recibida no es válida.',
          );
        }

        return Map<String, dynamic>.from(publicacion);
      },
    ).toList();
  }

  // =====================================
  // GUARDAR O ACTUALIZAR VALORACIÓN
  // =====================================

  static Future<bool> guardarValoracion({
    required int subItemId,
    required int authId,
    required int itemPadre,
    required int valoracion,
  }) async {
    if (valoracion < 1 || valoracion > 5) {
      return false;
    }

    try {
      final tabla = 'sub_items${itemPadre}_likes';
      final campoSubItem = 'sub_item${itemPadre}_id';

      final idPerfil = await obtenerIdPerfil(authId);

      await supabase.from(tabla).upsert(
        {
          campoSubItem: subItemId,
          'estudiante_id': idPerfil,
          'valoracion': valoracion,
        },
        onConflict: '$campoSubItem,estudiante_id',
      );

      return true;
    } catch (e) {
      print('Error al guardar valoración: $e');
      return false;
    }
  }

  // =====================================
  // MÉTODO ANTERIOR DE LIKES
  // Compatibilidad temporal
  // =====================================

  static Future<bool> toggleLike({
    required int subItemId,
    required int estudianteId,
    required int itemPadre,
  }) async {
    try {
      final tabla = 'sub_items${itemPadre}_likes';
      final campoSubItem = 'sub_item${itemPadre}_id';

      final idPerfil = await obtenerIdPerfil(estudianteId);

      final existing = await supabase
          .from(tabla)
          .select('id')
          .eq(campoSubItem, subItemId)
          .eq('estudiante_id', idPerfil);

      if (existing.isEmpty) {
        await supabase.from(tabla).insert({
          campoSubItem: subItemId,
          'estudiante_id': idPerfil,
        });
      } else {
        await supabase
            .from(tabla)
            .delete()
            .eq(campoSubItem, subItemId)
            .eq('estudiante_id', idPerfil);
      }

      return true;
    } catch (e) {
      print('Error toggleLike: $e');
      return false;
    }
  }

  // =====================================
  // COMENTARIOS
  // =====================================

  static Future<List<Map<String, dynamic>>> getComentarios({
    required int subItemId,
    required int itemPadre,
  }) async {
    try {
      final tabla = 'sub_items${itemPadre}_comentarios';
      final campoSubItem = 'sub_item${itemPadre}_id';

      // Obtener comentarios sin consultar directamente
      // los perfiles estudiantiles.
      final result = await supabase
          .from(tabla)
          .select(
            'id, comentario, fecha_comentario, estudiante_id',
          )
          .eq(campoSubItem, subItemId)
          .order('fecha_comentario', ascending: true);

      final comentarios =
          List<Map<String, dynamic>>.from(result);

      if (comentarios.isEmpty) {
        return comentarios;
      }

      // Consultar los datos básicos de los autores
      // mediante la función protegida de Supabase.
      final resultadoAutores =
          await supabase.rpc('brujula_autores_foro');

      final autores =
          List<Map<String, dynamic>>.from(resultadoAutores);

      // Organizar los autores por identificador.
      final autoresPorId = <int, Map<String, dynamic>>{};

      for (final autor in autores) {
        final id = (autor['id'] as num).toInt();
        autoresPorId[id] = autor;
      }

      // Mantener la estructura original que utiliza
      // la interfaz de comentarios.
      for (final comentario in comentarios) {
        final estudianteId =
            (comentario['estudiante_id'] as num).toInt();

        comentario['perfiles_estudiante'] =
            autoresPorId[estudianteId];
      }

      return comentarios;
    } catch (e) {
      print('Error obteniendo comentarios: $e');
      return [];
    }
  }

  static Future<bool> agregarComentario({
    required int subItemId,
    required int itemPadre,
    required int authId,
    required String comentario,
  }) async {
    try {
      final tabla = 'sub_items${itemPadre}_comentarios';
      final campoSubItem = 'sub_item${itemPadre}_id';

      final idPerfil = await obtenerIdPerfil(authId);

      await supabase.from(tabla).insert({
        campoSubItem: subItemId,
        'estudiante_id': idPerfil,
        'comentario': comentario,
      });

      return true;
    } catch (e) {
      print('Error al agregar comentario: $e');
      return false;
    }
  }

  static Future<bool> eliminarComentario({
    required int idComentario,
    required int itemPadre,
  }) async {
    try {
      final tabla = 'sub_items${itemPadre}_comentarios';

      await supabase
          .from(tabla)
          .delete()
          .eq('id', idComentario);

      return true;
    } catch (e) {
      print('Error al eliminar comentario: $e');
      return false;
    }
  }
}
