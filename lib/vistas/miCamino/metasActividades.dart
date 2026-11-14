import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brujula_uni/service/brujulaConexionService.dart';
import 'package:brujula_uni/service/caminoEstadoService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:brujula_uni/vistas/miCamino/evidenciasActividad.dart';

class MetasActividadesPage extends StatefulWidget {
  final int authId;

  const MetasActividadesPage({
    super.key,
    required this.authId,
  });

  @override
  State<MetasActividadesPage> createState() => _MetasActividadesPageState();
}

class _MetasActividadesPageState extends State<MetasActividadesPage> {
  final _api = BrujulaConexionService.instancia;
  final _camino = CaminoEstadoService.instancia;

  final List<Map<String, dynamic>> _anteriores = [];
  final Set<String> _guardandoLocales = {};

  bool _cargandoLocales = true;
  bool _ocupado = false;

  String _vista = 'lista';
  String? _metaSeleccionada;

  String get _clave => 'brujula_metas_actividades_borrador_${widget.authId}';

  // =====================================================
  // PALETA INSTITUCIONAL
  // =====================================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _gris => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _acento => BrujulaColores.acento(context);

  Color get _suave => BrujulaColores.superficieDestacada(context);

  // =====================================================
  // CICLO DE VIDA
  // =====================================================

  @override
  void initState() {
    super.initState();

    _camino.addListener(_escucharCambios);
    _iniciar();
  }

  @override
  void dispose() {
    _camino.removeListener(_escucharCambios);
    super.dispose();
  }

  void _escucharCambios() {
    if (mounted) setState(() {});
  }

  // =====================================================
  // DATOS Y COMPATIBILIDAD
  // =====================================================

  List<Map<String, dynamic>> _lista(dynamic valor) {
    if (valor is! List) return [];

    return valor
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  List<Map<String, dynamic>> _actividadesLocales(
    Map<String, dynamic> meta,
  ) {
    final valor = meta['actividades'];

    if (valor is List<Map<String, dynamic>>) {
      return valor;
    }

    final lista = _lista(valor);
    meta['actividades'] = lista;
    return lista;
  }

  List<Map<String, dynamic>> get _todas => [
        ..._camino.metasConActividades,
        ..._anteriores,
      ];

  bool _esAnterior(Map<String, dynamic> meta) {
    return _anteriores.any(
      (elemento) => identical(elemento, meta),
    );
  }

  List<Map<String, dynamic>> _actividades(
    Map<String, dynamic> meta,
  ) {
    return _esAnterior(meta)
        ? _actividadesLocales(meta)
        : _lista(meta['actividades']);
  }

  bool _completada(Map<String, dynamic> actividad) {
    return actividad['estado'] == 'completada' ||
        actividad['completada'] == true;
  }

  int get _cantidadActividades {
    return _todas.fold<int>(
      0,
      (total, meta) => total + _actividades(meta).length,
    );
  }

  int get _completadas {
    return _todas.fold<int>(
      0,
      (total, meta) => total + _actividades(meta).where(_completada).length,
    );
  }

  String _idMeta(Map<String, dynamic> meta) {
    return '${_esAnterior(meta) ? 'local' : 'cuenta'}:${meta['id']}';
  }

  Map<String, dynamic>? get _metaActual {
    for (final meta in _todas) {
      if (_idMeta(meta) == _metaSeleccionada) {
        return meta;
      }
    }
    return null;
  }

  String _claveLocal(
    Map<String, dynamic> meta,
    Map<String, dynamic> actividad,
  ) {
    return '${meta['id']}:${actividad['id']}';
  }

  // =====================================================
  // INICIALIZACIÓN Y PERSISTENCIA LOCAL
  // =====================================================

  Future<void> _iniciar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final contenido = prefs.getString(_clave);

      if (contenido != null) {
        final lista = _lista(
          jsonDecode(contenido),
        );

        _anteriores
          ..clear()
          ..addAll(
            lista.map(
              (meta) => {
                ...meta,
                'actividades': _lista(meta['actividades']),
              },
            ),
          );
      }
    } catch (e) {
      debugPrint(
        'Error leyendo actividades anteriores: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargandoLocales = false;
        });
      }
    }

    await _actualizar(
      forzar: !_camino.inicializado,
    );
  }

  Future<void> _guardarAnteriores() async {
    final prefs = await SharedPreferences.getInstance();

    final guardado = await prefs.setString(
      _clave,
      jsonEncode(_anteriores),
    );

    if (!guardado) {
      throw StateError(
        'No se pudo guardar la información local.',
      );
    }
  }

  Future<void> _actualizar({
    bool forzar = true,
  }) async {
    if (_ocupado || _guardandoLocales.isNotEmpty) {
      return;
    }

    try {
      await _camino.cargar(forzar: forzar);
    } catch (e) {
      debugPrint(
        'No se pudo actualizar Mis metas: $e',
      );
    }
  }

  // =====================================================
  // ESTILOS
  // =====================================================

  TextStyle _titulo(double size) {
    return BrujulaTipografia.seccion(
      size: size,
    ).copyWith(
      color: _texto,
    );
  }

  TextStyle _principal(double size) {
    return BrujulaTipografia.principal(
      size: size,
    ).copyWith(
      color: _texto,
    );
  }

  TextStyle _cuerpo(double size) {
    return BrujulaTipografia.cuerpo(
      size: size,
    ).copyWith(
      color: _gris,
    );
  }

  // =====================================================
  // MENSAJES
  // =====================================================

  void _mensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            mensaje,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: BrujulaColores.rojoUNI,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // FORMULARIOS
  // =====================================================

  Future<String?> _pedirTexto({
    required String titulo,
    required String etiqueta,
    String inicial = '',
    int maximo = 200,
  }) async {
    final control = TextEditingController(
      text: inicial,
    );

    final form = GlobalKey<FormState>();

    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: BrujulaColores.superficie(ctx),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            titulo,
            style: BrujulaTipografia.seccion(
              size: 18,
            ).copyWith(
              color: BrujulaColores.texto(ctx),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: TextFormField(
                controller: control,
                autofocus: true,
                maxLength: maximo,
                minLines: 1,
                maxLines: maximo > 200 ? 6 : 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: etiqueta,
                  border: const OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Completa este campo.';
                  }
                  return null;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: BrujulaColores.rojoUNI,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (form.currentState!.validate()) {
                  Navigator.pop(
                    ctx,
                    control.text.trim(),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      control.dispose();
    });

    return resultado;
  }

  Future<bool> _confirmar(
    String mensaje,
  ) async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: BrujulaColores.superficie(ctx),
              surfaceTintColor: Colors.transparent,
              title: const Text('Confirmar'),
              content: Text(mensaje),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // =====================================================
  // CREAR META
  // =====================================================

  Future<void> _crearMeta() async {
    if (_ocupado || _camino.cargando) return;

    final titulo = await _pedirTexto(
      titulo: 'Nueva meta',
      etiqueta: '¿Qué deseas lograr?',
    );

    if (!mounted || titulo == null) return;

    if (!_api.tieneSesion) {
      _mensaje('Vuelve a ingresar para continuar.');
      return;
    }

    setState(() {
      _ocupado = true;
    });

    try {
      final nueva = await _api.crearMeta(
        titulo: titulo,
      );

      _camino.registrarMeta(nueva);

      _mensaje('Guardado correctamente.');

      // Entrar directamente en la meta creada.
      if (mounted) {
        _abrirDetallePorId('cuenta:${nueva['id']}');
      }
    } catch (e) {
      debugPrint('Error creando meta: $e');
      _mensaje('No se pudo guardar la meta.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // =====================================================
  // EDITAR META
  // =====================================================

  Future<void> _editarMeta(
    Map<String, dynamic> meta,
  ) async {
    if (_ocupado) return;

    final titulo = await _pedirTexto(
      titulo: 'Editar meta',
      etiqueta: 'Nombre de la meta',
      inicial: meta['titulo']?.toString() ?? '',
    );

    if (!mounted || titulo == null) return;

    setState(() {
      _ocupado = true;
    });

    try {
      if (_esAnterior(meta)) {
        final anterior = meta['titulo'];
        meta['titulo'] = titulo;

        try {
          await _guardarAnteriores();
        } catch (_) {
          meta['titulo'] = anterior;
          rethrow;
        }

        if (mounted) setState(() {});
      } else {
        final actualizada = await _api.actualizarMeta(
          metaId: (meta['id'] as num).toInt(),
          titulo: titulo,
          descripcion: meta['descripcion']?.toString() ?? '',
        );

        _camino.registrarMeta({
          ...meta,
          ...actualizada,
          'titulo': actualizada['titulo'] ?? titulo,
        });
      }

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error editando meta: $e');
      _mensaje('No se pudo actualizar la meta.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // =====================================================
  // RETIRAR META
  // =====================================================

  Future<void> _archivarMeta(
    Map<String, dynamic> meta,
  ) async {
    if (_ocupado) return;

    final confirmado = await _confirmar(
      '¿Deseas retirar esta meta de tu lista?',
    );

    if (!confirmado || !mounted) return;

    setState(() {
      _ocupado = true;
    });

    try {
      if (_esAnterior(meta)) {
        final indice = _anteriores.indexOf(meta);
        _anteriores.remove(meta);

        try {
          await _guardarAnteriores();
        } catch (_) {
          _anteriores.insert(indice, meta);
          rethrow;
        }

        if (mounted) setState(() {});
      } else {
        final id = (meta['id'] as num).toInt();

        await _api.archivarMeta(id);
        _camino.retirarMeta(id);
      }

      if (mounted) {
        setState(() {
          _vista = 'lista';
          _metaSeleccionada = null;
        });
      }

      _mensaje('Meta retirada de tu lista.');
    } catch (e) {
      debugPrint('Error archivando meta: $e');
      _mensaje('No se pudo retirar la meta.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // =====================================================
  // AÑADIR ACTIVIDAD
  // =====================================================

  Future<void> _agregarActividad(
    Map<String, dynamic> meta,
  ) async {
    if (_ocupado) return;

    final titulo = await _pedirTexto(
      titulo: 'Nueva actividad',
      etiqueta: '¿Qué acción realizarás?',
    );

    if (!mounted || titulo == null) return;

    setState(() {
      _ocupado = true;
    });

    try {
      if (_esAnterior(meta)) {
        final nueva = <String, dynamic>{
          'id': DateTime.now().microsecondsSinceEpoch,
          'titulo': titulo,
          'estado': 'pendiente',
          'completada': false,
        };

        final lista = _actividadesLocales(meta);

        lista.add(nueva);

        try {
          await _guardarAnteriores();
        } catch (_) {
          lista.remove(nueva);
          rethrow;
        }

        if (mounted) setState(() {});
      } else {
        final metaId = (meta['id'] as num).toInt();

        final nueva = await _api.crearActividad(
          metaId: metaId,
          titulo: titulo,
        );

        _camino.registrarActividad(
          nueva,
          metaId: metaId,
        );
      }

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error creando actividad: $e');
      _mensaje('No se pudo guardar la actividad.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // =====================================================
  // MARCAR ACTIVIDAD
  // =====================================================

  Future<void> _marcarActividad(
    Map<String, dynamic> meta,
    Map<String, dynamic> actividad,
    bool completada,
  ) async {
    if (_ocupado) return;

    if (_esAnterior(meta)) {
      final clave = _claveLocal(
        meta,
        actividad,
      );

      if (_guardandoLocales.contains(clave)) {
        return;
      }

      final anterior = Map<String, dynamic>.from(actividad);

      setState(() {
        _guardandoLocales.add(clave);

        actividad['estado'] = completada ? 'completada' : 'pendiente';

        actividad['completada'] = completada;

        actividad['completada_en'] =
            completada ? DateTime.now().toIso8601String() : null;
      });

      try {
        await _guardarAnteriores();
      } catch (e) {
        actividad
          ..clear()
          ..addAll(anterior);

        _mensaje(
          'No se pudo guardar el cambio.',
        );
      } finally {
        if (mounted) {
          setState(() {
            _guardandoLocales.remove(clave);
          });
        } else {
          _guardandoLocales.remove(clave);
        }
      }

      return;
    }

    final id = (actividad['id'] as num).toInt();

    if (_camino.guardando(id)) return;

    final correcto = await _camino.cambiarEstado(
      actividadId: id,
      completada: completada,
    );

    if (!correcto) {
      _mensaje(
        'No se pudo guardar el cambio.',
      );
    }
  }

  // =====================================================
  // REFLEXIÓN DE ACTIVIDAD
  // =====================================================

  Future<void> _guardarReflexion(
    Map<String, dynamic> meta,
    Map<String, dynamic> actividad,
  ) async {
    if (_ocupado) return;

    final reflexion = await _pedirTexto(
      titulo: 'Mi reflexión',
      etiqueta: '¿Qué aprendiste?',
      inicial: actividad['reflexion']?.toString() ?? '',
      maximo: 3000,
    );

    if (!mounted || reflexion == null) return;

    setState(() {
      _ocupado = true;
    });

    try {
      if (_esAnterior(meta)) {
        final anterior = actividad['reflexion'];

        actividad['reflexion'] = reflexion;

        try {
          await _guardarAnteriores();
        } catch (_) {
          actividad['reflexion'] = anterior;
          rethrow;
        }

        if (mounted) setState(() {});
      } else {
        final id = (actividad['id'] as num).toInt();

        final correcto = await _camino.guardarReflexion(
          actividadId: id,
          reflexion: reflexion,
        );

        if (!correcto) {
          throw StateError(
            'No se pudo guardar.',
          );
        }
      }

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error guardando reflexión: $e');
      _mensaje(
        'No se pudo guardar la reflexión.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // =====================================================
  // ELIMINAR ACTIVIDAD
  // =====================================================

  Future<void> _eliminarActividad(
    Map<String, dynamic> meta,
    Map<String, dynamic> actividad,
  ) async {
    if (_ocupado) return;

    final confirmado = await _confirmar(
      '¿Eliminar esta actividad?',
    );

    if (!confirmado || !mounted) return;

    setState(() {
      _ocupado = true;
    });

    try {
      if (_esAnterior(meta)) {
        final lista = _actividadesLocales(meta);

        final indice = lista.indexOf(actividad);

        lista.remove(actividad);

        try {
          await _guardarAnteriores();
        } catch (_) {
          if (indice >= 0) {
            lista.insert(indice, actividad);
          }
          rethrow;
        }

        if (mounted) setState(() {});
      } else {
        final id = (actividad['id'] as num).toInt();

        if (_camino.guardando(id)) return;

        await _api.eliminarActividad(id);

        _camino.retirarActividad(id);
      }

      _mensaje('Actividad eliminada.');
    } catch (e) {
      debugPrint('Error eliminando actividad: $e');
      _mensaje(
        'No se pudo eliminar la actividad.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // =====================================================
  // EVIDENCIAS
  // =====================================================

  Future<void> _abrirEvidencias(
    Map<String, dynamic> meta,
    Map<String, dynamic> actividad,
  ) async {
    if (_esAnterior(meta)) {
      _mensaje(
        'Las evidencias están disponibles '
        'para actividades registradas en tu cuenta.',
      );
      return;
    }

    if (!_api.tieneSesion) {
      _mensaje(
        'Vuelve a ingresar para continuar.',
      );
      return;
    }

    final id = actividad['id'];

    if (id is! num || id <= 0) {
      _mensaje(
        'No se pudo abrir la actividad.',
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EvidenciasActividadPage(
          actividadId: id.toInt(),
          actividadTitulo: actividad['titulo']?.toString() ?? 'Actividad',
        ),
      ),
    );

    if (mounted) {
      await _actualizar();
    }
  }

  // =====================================================
  // NAVEGACIÓN INTERNA
  // =====================================================

  void _abrirDetalle(
    Map<String, dynamic> meta,
  ) {
    setState(() {
      _metaSeleccionada = _idMeta(meta);
      _vista = 'detalle';
    });
  }

  void _abrirDetallePorId(String id) {
    setState(() {
      _metaSeleccionada = id;
      _vista = 'detalle';
    });
  }

  void _volver() {
    if (_ocupado) return;

    if (_vista == 'detalle') {
      setState(() {
        _vista = 'lista';
        _metaSeleccionada = null;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // =====================================================
  // RESUMEN COMPACTO
  // =====================================================

  Widget _resumen() {
    final total = _cantidadActividades;
    final realizadas = _completadas;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _suave,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: _acento,
                size: 21,
              ),
              const SizedBox(width: 9),
              Text(
                'Tu recorrido',
                style: _titulo(16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _dato(
                '${_todas.length}',
                'Metas',
              ),
              _dato(
                '$realizadas',
                'Realizadas',
              ),
              _dato(
                '$total',
                'Actividades',
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: realizadas / total,
                minHeight: 5,
                color: _acento,
                backgroundColor: _superficie,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$realizadas de $total actividades realizadas',
              style: _cuerpo(11.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dato(String numero, String nombre) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numero,
            style: _principal(24).copyWith(
              color: _acento,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nombre,
            style: _cuerpo(11),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TARJETA DE META — SIN EXPANDIR ACTIVIDADES
  // =====================================================

  Widget _tarjetaMeta(
    Map<String, dynamic> meta,
  ) {
    final actividades = _actividades(meta);

    final total = actividades.length;
    final realizadas = actividades.where(_completada).length;

    final anterior = _esAnterior(meta);

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: _superficie,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirDetalle(meta),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borde,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: _acento,
                      size: 22,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        meta['titulo']?.toString() ?? '',
                        style: _titulo(15),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _gris,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  total == 0
                      ? 'Sin actividades registradas'
                      : '$realizadas de $total actividades realizadas',
                  style: _cuerpo(12),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : realizadas / total,
                    color: _acento,
                    backgroundColor: _suave,
                    minHeight: 5,
                  ),
                ),
                if (anterior) ...[
                  const SizedBox(height: 11),
                  Text(
                    'Guardada en este dispositivo',
                    style: _cuerpo(10.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // LISTA PRINCIPAL
  // =====================================================

  Widget _vistaLista() {
    return RefreshIndicator(
      color: _acento,
      onRefresh: _actualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          19,
          22,
          19,
          32,
        ),
        children: [
          Text(
            'MI CAMINO',
            style: BrujulaTipografia.etiqueta().copyWith(color: _acento),
          ),
          const SizedBox(height: 9),
          Text(
            'Mis metas',
            style: _principal(26),
          ),
          const SizedBox(height: 8),
          Text(
            'Organiza lo que deseas lograr '
            'y continúa avanzando a tu ritmo.',
            style: _cuerpo(13),
          ),
          const SizedBox(height: 22),
          _resumen(),
          if (_camino.error != null) ...[
            const SizedBox(height: 13),
            Text(
              'No se pudo actualizar tu información.',
              style: _cuerpo(12),
            ),
          ],
          const SizedBox(height: 27),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mis metas',
                  style: _titulo(19),
                ),
              ),
              TextButton.icon(
                onPressed: _ocupado || _camino.cargando ? null : _crearMeta,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 18,
                ),
                label: const Text('Nueva meta'),
                style: TextButton.styleFrom(
                  foregroundColor: _acento,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_todas.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _superficie,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _borde,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: _acento,
                    size: 35,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Comienza con tu primera meta',
                    style: _titulo(15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige algo que desees conseguir. '
                    'Después podrás añadir las actividades '
                    'que te ayudarán a lograrlo.',
                    style: _cuerpo(12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _crearMeta,
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                    label: const Text('Crear meta'),
                  ),
                ],
              ),
            )
          else
            ..._todas.map(_tarjetaMeta),
        ],
      ),
    );
  }

  // =====================================================
  // FILA DE ACTIVIDAD
  // =====================================================

  Widget _filaActividad(
    Map<String, dynamic> meta,
    Map<String, dynamic> actividad,
  ) {
    final realizada = _completada(actividad);
    final local = _esAnterior(meta);

    final id = actividad['id'] is num ? (actividad['id'] as num).toInt() : -1;

    final guardando = local
        ? _guardandoLocales.contains(
            _claveLocal(meta, actividad),
          )
        : _camino.guardando(id);

    final reflexion = actividad['reflexion']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _superficie,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          10,
          8,
          7,
          8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: realizada,
              activeColor: _acento,
              visualDensity: VisualDensity.compact,
              onChanged: guardando || _ocupado
                  ? null
                  : (valor) => _marcarActividad(
                        meta,
                        actividad,
                        valor ?? false,
                      ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad['titulo']?.toString() ?? '',
                    style: BrujulaTipografia.cuerpo(
                      size: 13,
                    ).copyWith(
                      color: realizada ? _gris : _texto,
                      fontWeight: FontWeight.w600,
                      decoration: realizada
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (reflexion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reflexión registrada',
                      style: _cuerpo(11),
                    ),
                  ],
                  if (guardando) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Guardando...',
                      style: _cuerpo(11),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: !_ocupado && !guardando,
              icon: Icon(
                Icons.more_vert_rounded,
                color: _gris,
                size: 20,
              ),
              onSelected: (opcion) {
                switch (opcion) {
                  case 'evidencias':
                    _abrirEvidencias(
                      meta,
                      actividad,
                    );
                    break;
                  case 'reflexion':
                    _guardarReflexion(
                      meta,
                      actividad,
                    );
                    break;
                  case 'eliminar':
                    _eliminarActividad(
                      meta,
                      actividad,
                    );
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'reflexion',
                  child: Text('Mi reflexión'),
                ),
                PopupMenuItem(
                  value: 'evidencias',
                  child: Text('Evidencias'),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Text('Eliminar actividad'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DETALLE DE META
  // =====================================================

  Widget _vistaDetalle() {
    final meta = _metaActual;

    if (meta == null) {
      return Center(
        child: Text(
          'Meta no disponible.',
          style: _cuerpo(13),
        ),
      );
    }

    final actividades = _actividades(meta);
    final total = actividades.length;
    final realizadas = actividades.where(_completada).length;

    final descripcion = meta['descripcion']?.toString() ?? '';

    final anterior = _esAnterior(meta);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        19,
        22,
        19,
        32,
      ),
      children: [
        Text(
          'MI CAMINO · META',
          style: BrujulaTipografia.etiqueta().copyWith(
            color: _acento,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          meta['titulo']?.toString() ?? '',
          style: _principal(25),
        ),
        if (descripcion.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(
            descripcion,
            style: _cuerpo(13),
          ),
        ],
        if (anterior) ...[
          const SizedBox(height: 10),
          Text(
            'Esta meta se guarda en este dispositivo.',
            style: _cuerpo(11),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _ocupado ? null : () => _editarMeta(meta),
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
              ),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _acento,
                side: BorderSide(color: _borde),
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: _ocupado ? null : () => _archivarMeta(meta),
              icon: const Icon(
                Icons.archive_outlined,
                size: 17,
              ),
              label: const Text('Retirar'),
              style: TextButton.styleFrom(
                foregroundColor: _gris,
              ),
            ),
          ],
        ),
        const SizedBox(height: 21),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: _suave,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avance de esta meta',
                style: _titulo(15),
              ),
              const SizedBox(height: 7),
              Text(
                total == 0
                    ? 'Añade una actividad para comenzar.'
                    : '$realizadas de $total actividades realizadas',
                style: _cuerpo(12),
              ),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : realizadas / total,
                  minHeight: 6,
                  color: _acento,
                  backgroundColor: _superficie,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Actividades',
                style: _titulo(19),
              ),
            ),
            TextButton.icon(
              onPressed: _ocupado ? null : () => _agregarActividad(meta),
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
              ),
              label: const Text('Añadir'),
              style: TextButton.styleFrom(
                foregroundColor: _acento,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Marca las actividades que hayas realizado. '
          'Puedes registrar aprendizajes y evidencias '
          'desde sus opciones.',
          style: _cuerpo(12),
        ),
        const SizedBox(height: 17),
        if (actividades.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _superficie,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _borde,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 30,
                  color: _acento,
                ),
                const SizedBox(height: 10),
                Text(
                  'Todavía no hay actividades',
                  style: _titulo(14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 7),
                Text(
                  'Empieza definiendo una acción concreta.',
                  style: _cuerpo(12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...actividades.map(
            (actividad) => _filaActividad(
              meta,
              actividad,
            ),
          ),
      ],
    );
  }

  // =====================================================
  // PANTALLA PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final cargando =
        _cargandoLocales || (!_camino.inicializado && _camino.cargando);

    final enLista = _vista == 'lista';

    return PopScope<void>(
      canPop: enLista && !_ocupado,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !enLista && !_ocupado) {
          _volver();
        }
      },
      child: Theme(
        data: BrujulaTipografia.aplicar(
          Theme.of(context),
        ),
        child: Scaffold(
          backgroundColor: _fondo,
          appBar: AppBar(
            backgroundColor: _fondo,
            foregroundColor: _texto,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: _ocupado ? null : _volver,
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            title: Text(
              enLista ? 'Mis metas' : 'Detalle de meta',
              style: _titulo(17),
            ),
          ),
          body: SafeArea(
            child: cargando
                ? Center(
                    child: CircularProgressIndicator(
                      color: _acento,
                    ),
                  )
                : enLista
                    ? _vistaLista()
                    : _vistaDetalle(),
          ),
        ),
      ),
    );
  }
}
