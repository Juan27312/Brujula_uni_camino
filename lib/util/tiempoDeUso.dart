import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:brujula_uni/service/metricasService.dart';
import 'package:brujula_uni/service/perfilService.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;
  final int userId;

  const AppLifecycleManager({
    super.key,
    required this.child,
    required this.userId,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  int? registroId;
  int? estudianteId;

  bool _registrandoInicio = false;
  bool _registrandoFin = false;
  bool _aplicacionActiva = true;
  bool _cerrado = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _registrarInicio();
  }

  @override
  void didUpdateWidget(
    covariant AppLifecycleManager oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _cerrarRegistroActual();

      estudianteId = null;
      registroId = null;

      if (_aplicacionActiva) {
        _registrarInicio();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    debugPrint('Estado del ciclo de vida: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _aplicacionActiva = true;
        _registrarInicio();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _aplicacionActiva = false;
        _cerrarRegistroActual();
        break;
    }
  }

  Future<int?> _obtenerEstudianteId() async {
    if (estudianteId != null) {
      return estudianteId;
    }

    final id = await PerfilService.getIdPerfilUsuario(
      widget.userId,
    );

    if (id != null) {
      estudianteId = id;
    }

    return id;
  }

  Future<void> _registrarInicio() async {
    if (_cerrado ||
        !_aplicacionActiva ||
        _registrandoInicio ||
        _registrandoFin ||
        registroId != null) {
      return;
    }

    _registrandoInicio = true;

    try {
      final idEstudiante = await _obtenerEstudianteId();

      if (idEstudiante == null) {
        debugPrint(
          'No se encontró el perfil del estudiante.',
        );
        return;
      }

      final nuevoRegistro = await metricasService.inicioSesion(
        estudianteId: idEstudiante,
      );

      if (nuevoRegistro == null) {
        debugPrint(
          'No se pudo iniciar el registro de tiempo.',
        );
        return;
      }

      registroId = nuevoRegistro;

      debugPrint(
        'Registro iniciado con ID: $nuevoRegistro',
      );

      // Si la aplicación quedó en segundo plano
      // durante la solicitud, cerrar el registro.
      if (_cerrado || !_aplicacionActiva) {
        await _cerrarRegistroActual();
      }
    } catch (e) {
      debugPrint(
        'Error al registrar inicio de actividad: $e',
      );
    } finally {
      _registrandoInicio = false;
    }
  }

  Future<void> _cerrarRegistroActual() async {
    if (_registrandoFin) return;

    final id = registroId;

    if (id == null) return;

    _registrandoFin = true;

    // Evita que otra llamada cierre el mismo ID.
    registroId = null;

    try {
      final resultado = await metricasService.terminarTiempo(
        id: id,
      );

      if (resultado) {
        debugPrint('Registro cerrado con ID: $id');
      } else {
        debugPrint(
          'No se pudo cerrar el registro con ID: $id',
        );
      }
    } catch (e) {
      debugPrint(
        'Error al cerrar el registro $id: $e',
      );
    } finally {
      _registrandoFin = false;

      // Si regresó al primer plano durante el cierre,
      // permitir que comience una nueva sesión.
      if (!_cerrado && _aplicacionActiva) {
        _registrarInicio();
      }
    }
  }

  @override
  void dispose() {
    _cerrado = true;

    WidgetsBinding.instance.removeObserver(this);

    _cerrarRegistroActual();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
