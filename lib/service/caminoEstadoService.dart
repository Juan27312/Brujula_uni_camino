import 'package:flutter/foundation.dart';

import 'package:brujula_uni/service/brujulaConexionService.dart';

class CaminoEstadoService extends ChangeNotifier {
  CaminoEstadoService._();

  static final CaminoEstadoService instancia = CaminoEstadoService._();

  final BrujulaConexionService _api = BrujulaConexionService.instancia;

  final Map<int, Map<String, dynamic>> _metas = {};
  final Map<int, Map<String, dynamic>> _actividades = {};
  final Set<int> _guardando = {};

  Future<void>? _carga;
  int _generacion = 0;
  int _revision = 0;
  bool _inicializado = false;
  bool _cargando = false;
  String? _error;

  bool get inicializado => _inicializado;
  bool get cargando => _cargando;
  String? get error => _error;

  int get totalMetas => _metas.length;
  int get totalActividades => _actividades.length;

  int get realizadas =>
      _actividades.values.where((a) => a['estado'] == 'completada').length;

  int get pendientes => totalActividades - realizadas;

  bool guardando(int actividadId) => _guardando.contains(actividadId);

  List<Map<String, dynamic>> get metas {
    return _metas.values.map((m) => Map<String, dynamic>.from(m)).toList();
  }

  List<Map<String, dynamic>> actividadesDeMeta(int metaId) {
    return _actividades.values
        .where((a) => a['meta_id'] == metaId)
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
  }

  Map<String, dynamic>? actividad(int id) {
    final dato = _actividades[id];
    return dato == null ? null : Map<String, dynamic>.from(dato);
  }

  List<Map<String, dynamic>> get actividadesPendientes {
    final lista = _actividades.values
        .where((a) => a['estado'] != 'completada')
        .map((a) => Map<String, dynamic>.from(a))
        .toList();

    DateTime? fecha(Map<String, dynamic> a) {
      return DateTime.tryParse(
        a['fecha_prevista']?.toString() ?? '',
      );
    }

    lista.sort((a, b) {
      final fa = fecha(a);
      final fb = fecha(b);

      if (fa != null && fb == null) return -1;
      if (fa == null && fb != null) return 1;

      if (fa != null && fb != null) {
        final orden = fa.compareTo(fb);
        if (orden != 0) return orden;
      }

      return (a['titulo']?.toString() ?? '')
          .compareTo(b['titulo']?.toString() ?? '');
    });

    return lista;
  }

  List<Map<String, dynamic>> get metasConActividades {
    return metas.map((meta) {
      final id = (meta['id'] as num).toInt();

      return {
        ...meta,
        'actividades': actividadesDeMeta(id),
      };
    }).toList();
  }

  Future<void> cargar({bool forzar = false}) {
    if (_carga != null) return _carga!;

    if (_inicializado && !forzar) {
      return Future<void>.value();
    }

    final operacion = _cargarDatos();
    _carga = operacion;

    operacion.then(
      (_) {
        if (identical(_carga, operacion)) {
          _carga = null;
        }
      },
      onError: (Object _, StackTrace __) {
        if (identical(_carga, operacion)) {
          _carga = null;
        }
      },
    );

    return operacion;
  }

  Future<void> _cargarDatos() async {
    final generacion = _generacion;
    final revisionInicial = _revision;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      if (!_api.tieneSesion) {
        throw StateError('Sesión no disponible');
      }

      final metasServidor = await _api.listarMetas();

      final grupos = await Future.wait(
        metasServidor.map((meta) {
          return _api.listarActividades(
            (meta['id'] as num).toInt(),
          );
        }),
      );

      // Una respuesta anterior al cierre de sesión
      // jamás puede reconstruir los datos privados.
      if (generacion != _generacion) return;

      final nuevasMetas = <int, Map<String, dynamic>>{};
      final nuevasActividades = <int, Map<String, dynamic>>{};

      for (var i = 0; i < metasServidor.length; i++) {
        final meta = Map<String, dynamic>.from(metasServidor[i]);

        final metaId = (meta['id'] as num).toInt();
        nuevasMetas[metaId] = meta;

        for (final original in grupos[i]) {
          final actividad = Map<String, dynamic>.from(original);

          final id = (actividad['id'] as num).toInt();

          actividad['meta_id'] = metaId;
          actividad['meta_titulo'] = meta['titulo']?.toString() ?? '';

          nuevasActividades[id] = actividad;
        }
      }

      // No aplicar una respuesta obtenida antes de
      // una modificación realizada por el estudiante.
      if (revisionInicial != _revision) {
        return;
      }

      _metas
        ..clear()
        ..addAll(nuevasMetas);

      _actividades
        ..clear()
        ..addAll(nuevasActividades);

      _inicializado = true;
      _error = null;
    } catch (e) {
      if (generacion != _generacion) return;

      debugPrint('Mi Camino - carga: $e');
      _error = 'No se pudo actualizar la información.';
      rethrow;
    } finally {
      if (generacion == _generacion) {
        _cargando = false;
        notifyListeners();
      }
    }
  }

  void registrarMeta(Map<String, dynamic> meta) {
    final id = meta['id'];
    if (id is! num) return;

    _revision++;
    _metas[id.toInt()] = Map<String, dynamic>.from(meta);
    notifyListeners();
  }

  void retirarMeta(int metaId) {
    _revision++;
    _metas.remove(metaId);

    _actividades.removeWhere(
      (_, actividad) => actividad['meta_id'] == metaId,
    );

    notifyListeners();
  }

  void registrarActividad(
    Map<String, dynamic> actividad, {
    required int metaId,
  }) {
    final id = actividad['id'];
    if (id is! num) return;

    final meta = _metas[metaId];

    _revision++;
    _actividades[id.toInt()] = {
      ...actividad,
      'meta_id': metaId,
      'meta_titulo': meta?['titulo']?.toString() ?? '',
    };

    notifyListeners();
  }

  void retirarActividad(int actividadId) {
    _revision++;
    _actividades.remove(actividadId);
    notifyListeners();
  }

  Future<bool> cambiarEstado({
    required int actividadId,
    required bool completada,
  }) async {
    final actual = _actividades[actividadId];

    if (actual == null || _guardando.contains(actividadId)) {
      return false;
    }

    final generacion = _generacion;
    final anterior = Map<String, dynamic>.from(actual);

    _guardando.add(actividadId);
    _revision++;

    actual['estado'] = completada ? 'completada' : 'pendiente';
    actual['completada'] = completada;
    actual['completada_en'] =
        completada ? DateTime.now().toIso8601String() : null;

    // Todas las pantallas reciben este cambio
    // inmediatamente, antes de esperar la red.
    notifyListeners();

    try {
      final respuesta = await _api.actualizarActividad(
        actividadId: actividadId,
        estado: completada ? 'completada' : 'pendiente',
      );

      if (generacion != _generacion) return false;

      final vigente = _actividades[actividadId];

      if (vigente != null) {
        vigente['estado'] =
            respuesta['estado'] ?? (completada ? 'completada' : 'pendiente');
        vigente['completada'] = vigente['estado'] == 'completada';
        vigente['completada_en'] = respuesta['completada_en'];
      }

      return true;
    } catch (e) {
      if (generacion != _generacion) return false;

      debugPrint('Mi Camino - guardar estado: $e');
      _actividades[actividadId] = anterior;
      _revision++;
      return false;
    } finally {
      if (generacion == _generacion) {
        _guardando.remove(actividadId);
        notifyListeners();
      }
    }
  }

  Future<bool> guardarReflexion({
    required int actividadId,
    required String reflexion,
  }) async {
    final actual = _actividades[actividadId];

    if (actual == null || _guardando.contains(actividadId)) {
      return false;
    }

    final generacion = _generacion;
    final anterior = actual['reflexion'];

    _guardando.add(actividadId);
    _revision++;

    actual['reflexion'] = reflexion;
    notifyListeners();

    try {
      final respuesta = await _api.actualizarActividad(
        actividadId: actividadId,
        reflexion: reflexion,
      );

      if (generacion != _generacion) return false;

      final vigente = _actividades[actividadId];

      if (vigente != null) {
        vigente['reflexion'] = respuesta['reflexion'] ?? reflexion;
      }

      return true;
    } catch (e) {
      if (generacion != _generacion) return false;

      debugPrint('Mi Camino - guardar reflexión: $e');

      final vigente = _actividades[actividadId];
      if (vigente != null) {
        vigente['reflexion'] = anterior;
      }

      _revision++;
      return false;
    } finally {
      if (generacion == _generacion) {
        _guardando.remove(actividadId);
        notifyListeners();
      }
    }
  }

  void limpiar() {
    _generacion++;
    _revision++;

    _metas.clear();
    _actividades.clear();
    _guardando.clear();

    _carga = null;
    _inicializado = false;
    _cargando = false;
    _error = null;

    notifyListeners();
  }
}
