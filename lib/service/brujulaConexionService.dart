import 'package:supabase_flutter/supabase_flutter.dart';

class BrujulaConexionException implements Exception {
  final String mensaje;

  const BrujulaConexionException(this.mensaje);

  @override
  String toString() => mensaje;
}

class BrujulaConexionService {
  BrujulaConexionService._();

  static final BrujulaConexionService instancia = BrujulaConexionService._();

  final SupabaseClient _cliente = Supabase.instance.client;

  static const String _funcion = 'brujula-conexion';

  String? _token;
  DateTime? _vencimiento;
  int? _perfilId;

  bool get tieneSesion =>
      _token != null &&
      _vencimiento != null &&
      DateTime.now().isBefore(_vencimiento!);

  String? get tokenSesion => tieneSesion ? _token : null;

  int? get perfilId => _perfilId;

  // Establecer la conexión utilizando Supabase Authentication.
  Future<void> iniciarSesionConAuth() async {
    cerrarSesion();

    try {
      var sesion = _cliente.auth.currentSession;

      if (sesion == null) {
        throw const BrujulaConexionException(
          'Tu sesión ha vencido. Vuelve a ingresar.',
        );
      }

      // Renovar la sesión de Supabase cuando sea necesario.
      if (sesion.isExpired) {
        final renovada = await _cliente.auth.refreshSession();
        sesion = renovada.session;
      }

      if (sesion == null) {
        throw const BrujulaConexionException(
          'Tu sesión ha vencido. Vuelve a ingresar.',
        );
      }

      // Solicitar una sesión de Mi Camino utilizando
      // la identidad autenticada del estudiante.
      final resultado = await _cliente.functions.invoke(
        _funcion,
        body: {
          'accion': 'iniciar_sesion_auth',
        },
        headers: {
          'Authorization': 'Bearer ${sesion.accessToken}',
        },
      );

      if (resultado.data is! Map) {
        throw const BrujulaConexionException(
          'No se pudo establecer la sesión.',
        );
      }

      final respuesta = Map<String, dynamic>.from(resultado.data as Map);

      if (respuesta['ok'] != true) {
        throw BrujulaConexionException(
          respuesta['mensaje']?.toString() ??
              'No se pudo establecer la sesión.',
        );
      }

      final token = respuesta['token'];
      final perfil = respuesta['perfil_id'];
      final duracion = respuesta['expires_in'];

      if (token is! String ||
          token.isEmpty ||
          perfil is! num ||
          duracion is! num ||
          duracion.toInt() <= 15) {
        throw const BrujulaConexionException(
          'No se pudo establecer la sesión.',
        );
      }

      _token = token;
      _perfilId = perfil.toInt();

      _vencimiento = DateTime.now().add(
        Duration(seconds: duracion.toInt() - 15),
      );
    } on BrujulaConexionException {
      rethrow;
    } on FunctionException catch (e) {
      final details = e.details;

      if (details is Map && details['mensaje'] != null) {
        throw BrujulaConexionException(
          details['mensaje'].toString(),
        );
      }

      throw const BrujulaConexionException(
        'No se pudo establecer la sesión.',
      );
    } catch (_) {
      throw const BrujulaConexionException(
        'No se pudo conectar. Intenta nuevamente.',
      );
    }
  }

  // Compatibilidad temporal con llamadas anteriores.
  // La autenticación ahora corresponde a Supabase Auth.
  Future<void> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    await iniciarSesionConAuth();
  }

  // Ejecutar las operaciones protegidas de Mi Camino.
  Future<Map<String, dynamic>> _ejecutar(
    Map<String, dynamic> datos, {
    bool requiereSesion = true,
  }) async {
    // Recuperar la conexión si ha vencido.
    if (requiereSesion && !tieneSesion) {
      await iniciarSesionConAuth();
    }

    try {
      final resultado = await _cliente.functions.invoke(
        _funcion,
        body: datos,
        headers: requiereSesion ? {'X-Brujula-Session': _token!} : null,
      );

      if (resultado.data is! Map) {
        throw const BrujulaConexionException(
          'No se pudo procesar la respuesta.',
        );
      }

      final respuesta = Map<String, dynamic>.from(resultado.data as Map);

      if (respuesta['ok'] != true) {
        throw BrujulaConexionException(
          respuesta['mensaje']?.toString() ??
              'No se pudo completar la operación.',
        );
      }

      return respuesta;
    } on BrujulaConexionException {
      rethrow;
    } on FunctionException catch (e) {
      final details = e.details;

      if (details is Map && details['mensaje'] != null) {
        throw BrujulaConexionException(
          details['mensaje'].toString(),
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

  Map<String, dynamic> _objeto(dynamic valor) {
    if (valor is! Map) {
      throw const BrujulaConexionException(
        'La información recibida no es válida.',
      );
    }

    return Map<String, dynamic>.from(valor);
  }

  List<Map<String, dynamic>> _lista(dynamic valor) {
    if (valor is! List) {
      throw const BrujulaConexionException(
        'La información recibida no es válida.',
      );
    }

    return valor.map(_objeto).toList();
  }

  // ==================================================
  // PROYECTO DE VIDA
  // ==================================================

  Future<Map<String, dynamic>> consultarProyecto() {
    return _ejecutar({
      'accion': 'consultar_proyecto',
    });
  }

  Future<Map<String, dynamic>> guardarProyecto({
    required String visionPersonal,
    required String reflexionPersonal,
  }) {
    return _ejecutar({
      'accion': 'guardar_proyecto',
      'vision_personal': visionPersonal,
      'reflexion_personal': reflexionPersonal,
    });
  }

  Future<Map<String, dynamic>> crearObjetivo({
    required String titulo,
    required String horizonte,
    String descripcion = '',
  }) async {
    final resultado = await _ejecutar({
      'accion': 'crear_objetivo',
      'titulo': titulo,
      'horizonte': horizonte,
      'descripcion': descripcion,
    });

    return _objeto(resultado['objetivo']);
  }

  Future<Map<String, dynamic>> actualizarObjetivo({
    required int objetivoId,
    required String titulo,
    required String horizonte,
    String descripcion = '',
  }) async {
    final resultado = await _ejecutar({
      'accion': 'actualizar_objetivo',
      'objetivo_id': objetivoId,
      'titulo': titulo,
      'horizonte': horizonte,
      'descripcion': descripcion,
    });

    return _objeto(resultado['objetivo']);
  }

  Future<void> archivarObjetivo(int objetivoId) async {
    await _ejecutar({
      'accion': 'archivar_objetivo',
      'objetivo_id': objetivoId,
    });
  }

  // ==================================================
  // METAS
  // ==================================================

  Future<List<Map<String, dynamic>>> listarMetas() async {
    final resultado = await _ejecutar({
      'accion': 'listar_metas',
    });

    return _lista(resultado['metas']);
  }

  Future<Map<String, dynamic>> crearMeta({
    required String titulo,
    String descripcion = '',
    String ambito = 'personal',
    int? objetivoId,
  }) async {
    final resultado = await _ejecutar({
      'accion': 'crear_meta',
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'ambito': ambito,
      if (objetivoId != null) 'objetivo_id': objetivoId,
    });

    return _objeto(resultado['meta']);
  }

  Future<Map<String, dynamic>> actualizarMeta({
    required int metaId,
    required String titulo,
    String descripcion = '',
  }) async {
    final resultado = await _ejecutar({
      'accion': 'actualizar_meta',
      'meta_id': metaId,
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
    });

    return _objeto(resultado['meta']);
  }

  Future<void> archivarMeta(int metaId) async {
    await _ejecutar({
      'accion': 'archivar_meta',
      'meta_id': metaId,
    });
  }

  // ==================================================
  // ACTIVIDADES
  // ==================================================

  Future<List<Map<String, dynamic>>> listarActividades(
    int metaId,
  ) async {
    final resultado = await _ejecutar({
      'accion': 'listar_actividades',
      'meta_id': metaId,
    });

    return _lista(resultado['actividades']);
  }

  Future<Map<String, dynamic>> crearActividad({
    required int metaId,
    required String titulo,
  }) async {
    final resultado = await _ejecutar({
      'accion': 'crear_actividad',
      'meta_id': metaId,
      'titulo': titulo.trim(),
    });

    return _objeto(resultado['actividad']);
  }

  Future<Map<String, dynamic>> actualizarActividad({
    required int actividadId,
    String? titulo,
    String? estado,
    String? reflexion,
  }) async {
    final datos = <String, dynamic>{
      'accion': 'actualizar_actividad',
      'actividad_id': actividadId,
    };

    if (titulo != null) {
      datos['titulo'] = titulo;
    }

    if (estado != null) {
      datos['estado'] = estado;
    }

    if (reflexion != null) {
      datos['reflexion'] = reflexion;
    }

    final resultado = await _ejecutar(datos);

    return _objeto(resultado['actividad']);
  }

  Future<void> eliminarActividad(int actividadId) async {
    await _ejecutar({
      'accion': 'eliminar_actividad',
      'actividad_id': actividadId,
    });
  }

  // ==================================================
  // CIERRE DE SESIÓN
  // ==================================================

  void cerrarSesion() {
    _token = null;
    _vencimiento = null;
    _perfilId = null;
  }
}
