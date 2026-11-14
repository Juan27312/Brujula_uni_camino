
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brujula_uni/service/brujulaConexionService.dart';

class EvidenciasService {
  EvidenciasService._();

  static final EvidenciasService instancia =
      EvidenciasService._();

  static const _funcion = 'brujula-evidencias';
  static const _bucket = 'brujula-evidencias';
  static const _maxBytes = 50 * 1024 * 1024;

  final _cliente = Supabase.instance.client;

  Future<Map<String, dynamic>> _invocar(
    Map<String, dynamic> datos,
  ) async {
    final sesion =
        BrujulaConexionService.instancia.tokenSesion;

    if (sesion == null) {
      throw const BrujulaConexionException(
        'Vuelve a ingresar para continuar.',
      );
    }

    try {
      final respuesta = await _cliente.functions.invoke(
        _funcion,
        body: datos,
        headers: {'X-Brujula-Session': sesion},
      );

      if (respuesta.data is! Map) {
        throw const BrujulaConexionException(
          'No se pudo procesar la respuesta.',
        );
      }

      final contenido =
          Map<String, dynamic>.from(respuesta.data as Map);

      if (contenido['ok'] != true) {
        throw BrujulaConexionException(
          contenido['mensaje']?.toString() ??
              'No se pudo completar la operación.',
        );
      }

      return contenido;
    } on BrujulaConexionException {
      rethrow;
    } on FunctionException catch (e) {
      final detalles = e.details;
      if (detalles is Map && detalles['mensaje'] != null) {
        throw BrujulaConexionException(
          detalles['mensaje'].toString(),
        );
      }
      throw const BrujulaConexionException(
        'No se pudo completar la operación.',
      );
    } catch (_) {
      throw const BrujulaConexionException(
        'No se pudo conectar. Intenta nuevamente.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> listar(
    int actividadId,
  ) async {
    final resultado = await _invocar({
      'accion': 'listar',
      'actividad_id': actividadId,
    });

    final evidencias = resultado['evidencias'];

    if (evidencias is! List) return [];

    return evidencias
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<bool> seleccionarYSubir({
    required int actividadId,
  }) async {
    final seleccion = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'webp'
      ],
      withData: false,
      allowMultiple: false,
    );

    if (seleccion == null || seleccion.files.isEmpty) {
      return false;
    }

    final archivo = seleccion.files.first;
    final rutaLocal = archivo.path;

    if (rutaLocal == null) {
      throw const BrujulaConexionException(
        'No se pudo acceder al archivo seleccionado.',
      );
    }

    final fichero = File(rutaLocal);
    final bytes = await fichero.length();

    if (bytes <= 0 || bytes > _maxBytes) {
      throw const BrujulaConexionException(
        'El archivo debe tener un tamaño máximo de 50 MB.',
      );
    }

    final preparado = await _invocar({
      'accion': 'preparar_archivo',
      'actividad_id': actividadId,
      'nombre': archivo.name,
      'tamano': bytes,
    });

    final ruta = preparado['ruta']?.toString();
    final token = preparado['token']?.toString();
    final mime = preparado['mime']?.toString();

    if (ruta == null || token == null || mime == null) {
      throw const BrujulaConexionException(
        'No se pudo preparar el archivo.',
      );
    }

    // Subida directa al bucket mediante permiso firmado.
    await _cliente.storage.from(_bucket).uploadToSignedUrl(
      ruta,
      token,
      fichero,
      FileOptions(
        contentType: mime,
        upsert: false,
      ),
    );

    await _invocar({
      'accion': 'confirmar_archivo',
      'actividad_id': actividadId,
      'ruta': ruta,
      'titulo': archivo.name.length > 200
          ? archivo.name.substring(0, 200)
          : archivo.name,
    });

    return true;
  }

  Future<void> agregarEnlace({
    required int actividadId,
    required String titulo,
    required String enlace,
  }) async {
    await _invocar({
      'accion': 'agregar_enlace',
      'actividad_id': actividadId,
      'titulo': titulo,
      'enlace_url': enlace,
    });
  }

  Future<String> obtenerUrl(int evidenciaId) async {
    final resultado = await _invocar({
      'accion': 'abrir',
      'evidencia_id': evidenciaId,
    });

    final url = resultado['url']?.toString();

    if (url == null || url.isEmpty) {
      throw const BrujulaConexionException(
        'No se pudo abrir la evidencia.',
      );
    }

    return url;
  }

  Future<void> eliminar(int evidenciaId) async {
    await _invocar({
      'accion': 'eliminar',
      'evidencia_id': evidenciaId,
    });
  }
}
