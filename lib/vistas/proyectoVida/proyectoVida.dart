import 'package:flutter/material.dart';

import 'package:brujula_uni/service/brujulaConexionService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class ProyectoVidaPage extends StatefulWidget {
  final int authId;

  const ProyectoVidaPage({
    super.key,
    required this.authId,
  });

  @override
  State<ProyectoVidaPage> createState() => _ProyectoVidaPageState();
}

class _ProyectoVidaPageState extends State<ProyectoVidaPage> {
  final _api = BrujulaConexionService.instancia;

  final List<Map<String, dynamic>> _objetivos = [];
  final List<Map<String, dynamic>> _metas = [];

  String _vision = '';
  String _reflexion = '';

  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  // Navegación interna
  String _vista = 'inicio';
  String _filtro = 'todos';
  int? _objetivoSeleccionado;

  // =====================================================
  // COLORES
  // =====================================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _secundario => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _acento => BrujulaColores.acento(context);
  Color get _destacado => BrujulaColores.destacado(context);

  Color get _suave => BrujulaColores.superficieDestacada(context);

  // =====================================================
  // CICLO DE VIDA
  // =====================================================

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // =====================================================
  // UTILIDADES
  // =====================================================

  List<Map<String, dynamic>> _lista(dynamic valor) {
    if (valor is! List) return [];

    return valor
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _nombreHorizonte(String valor) {
    switch (valor) {
      case 'corto':
        return 'Corto plazo';
      case 'mediano':
        return 'Mediano plazo';
      case 'largo':
        return 'Largo plazo';
      default:
        return 'Sin plazo';
    }
  }

  int? _id(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '');
  }

  Map<String, dynamic>? get _objetivoActual {
    for (final objetivo in _objetivos) {
      if (_id(objetivo['id']) == _objetivoSeleccionado) {
        return objetivo;
      }
    }
    return null;
  }

  int _cantidadMetas(int? objetivoId) {
    if (objetivoId == null) return 0;

    return _metas
        .where(
          (meta) => _id(meta['objetivo_id']) == objetivoId,
        )
        .length;
  }

  List<Map<String, dynamic>> _metasDe(int? objetivoId) {
    if (objetivoId == null) return [];

    return _metas
        .where(
          (meta) => _id(meta['objetivo_id']) == objetivoId,
        )
        .toList();
  }

  // =====================================================
  // TIPOGRAFÍA
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
      color: _secundario,
    );
  }

  TextStyle _etiqueta() {
    return BrujulaTipografia.etiqueta().copyWith(
      color: _acento,
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
          backgroundColor: BrujulaColores.rojoUNI,
          behavior: SnackBarBehavior.floating,
          content: Text(
            mensaje,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
  }

  // =====================================================
  // CARGA DE DATOS
  // =====================================================

  Future<void> _cargar() async {
    if (!mounted || _guardando) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final proyectoFuture = _api.consultarProyecto();
      final metasFuture = _api.listarMetas();

      final respuestaProyecto = await proyectoFuture;
      final metas = await metasFuture;

      if (!mounted) return;

      final proyecto = respuestaProyecto['proyecto'];

      setState(() {
        _vision = proyecto is Map
            ? proyecto['vision_personal']?.toString() ?? ''
            : '';

        _reflexion = proyecto is Map
            ? proyecto['reflexion_personal']?.toString() ?? ''
            : '';

        _objetivos
          ..clear()
          ..addAll(
            _lista(respuestaProyecto['objetivos']),
          );

        _metas
          ..clear()
          ..addAll(metas);
      });
    } catch (e) {
      debugPrint('Error cargando proyecto de vida: $e');

      if (mounted) {
        setState(() {
          _error = 'No pudimos cargar tu información.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // =====================================================
  // NAVEGACIÓN INTERNA
  // =====================================================

  void _abrirObjetivos() {
    setState(() {
      _vista = 'objetivos';
      _objetivoSeleccionado = null;
      _filtro = 'todos';
    });
  }

  void _abrirDetalle(Map<String, dynamic> objetivo) {
    final objetivoId = _id(objetivo['id']);
    if (objetivoId == null) return;

    setState(() {
      _objetivoSeleccionado = objetivoId;
      _vista = 'detalle';
    });
  }

  void _volver() {
    if (_vista == 'detalle') {
      setState(() {
        _vista = 'objetivos';
        _objetivoSeleccionado = null;
      });
    } else if (_vista == 'objetivos') {
      setState(() {
        _vista = 'inicio';
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // =====================================================
  // EDITAR VISIÓN O REFLEXIÓN
  // =====================================================

  Future<void> _editarTexto({
    required bool esVision,
  }) async {
    if (_guardando) return;

    final control = TextEditingController(
      text: esVision ? _vision : _reflexion,
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
            esVision ? 'Mi visión personal' : 'Mi reflexión personal',
            style: BrujulaTipografia.seccion(
              size: 18,
            ).copyWith(
              color: BrujulaColores.texto(ctx),
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esVision
                        ? '¿Cómo te gustaría verte en el futuro?'
                        : '¿Qué fortalezas tienes y qué aspectos deseas mejorar?',
                    style: BrujulaTipografia.cuerpo(
                      size: 12.5,
                    ).copyWith(
                      color: BrujulaColores.secundario(ctx),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: control,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 4000,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: BrujulaColores.texto(ctx),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí...',
                      filled: true,
                      fillColor: BrujulaColores.superficie(ctx),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Escribe tu respuesta.';
                      }
                      return null;
                    },
                  ),
                ],
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
                  Navigator.pop(ctx, control.text.trim());
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

    if (!mounted || resultado == null) return;

    setState(() {
      _guardando = true;
    });

    try {
      await _api.guardarProyecto(
        visionPersonal: esVision ? resultado : _vision,
        reflexionPersonal: esVision ? _reflexion : resultado,
      );

      if (!mounted) return;

      setState(() {
        if (esVision) {
          _vision = resultado;
        } else {
          _reflexion = resultado;
        }
      });

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error guardando proyecto: $e');
      _mensaje('No se pudo guardar. Intenta nuevamente.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // FORMULARIO DE OBJETIVO
  // =====================================================

  Future<Map<String, String>?> _formularioObjetivo({
    Map<String, dynamic>? existente,
  }) async {
    final control = TextEditingController(
      text: existente?['titulo']?.toString() ?? '',
    );

    final form = GlobalKey<FormState>();

    var horizonte = existente?['horizonte']?.toString() ?? 'corto';

    if (!['corto', 'mediano', 'largo'].contains(horizonte)) {
      horizonte = 'corto';
    }

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, actualizar) {
            return AlertDialog(
              backgroundColor: BrujulaColores.superficie(ctx),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                existente == null ? 'Nuevo objetivo' : 'Editar objetivo',
                style: BrujulaTipografia.seccion(
                  size: 18,
                ).copyWith(
                  color: BrujulaColores.texto(ctx),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: control,
                        autofocus: true,
                        maxLength: 200,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: '¿Qué deseas conseguir?',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Escribe tu objetivo.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: horizonte,
                        decoration: const InputDecoration(
                          labelText: 'Plazo',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'corto',
                            child: Text('Corto plazo'),
                          ),
                          DropdownMenuItem(
                            value: 'mediano',
                            child: Text('Mediano plazo'),
                          ),
                          DropdownMenuItem(
                            value: 'largo',
                            child: Text('Largo plazo'),
                          ),
                        ],
                        onChanged: (valor) {
                          if (valor != null) {
                            actualizar(() {
                              horizonte = valor;
                            });
                          }
                        },
                      ),
                    ],
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
                      Navigator.pop(ctx, {
                        'titulo': control.text.trim(),
                        'horizonte': horizonte,
                      });
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      control.dispose();
    });

    return resultado;
  }

  // =====================================================
  // CREAR OBJETIVO
  // =====================================================

  Future<void> _crearObjetivo() async {
    if (_guardando) return;

    final datos = await _formularioObjetivo();

    if (!mounted || datos == null) return;

    setState(() {
      _guardando = true;
    });

    try {
      final objetivo = await _api.crearObjetivo(
        titulo: datos['titulo']!,
        horizonte: datos['horizonte']!,
      );

      if (!mounted) return;

      setState(() {
        _objetivos.add(objetivo);
      });

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error creando objetivo: $e');
      _mensaje('No se pudo guardar el objetivo.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // EDITAR OBJETIVO
  // =====================================================

  Future<void> _editarObjetivo(
    Map<String, dynamic> objetivo,
  ) async {
    if (_guardando) return;

    final datos = await _formularioObjetivo(
      existente: objetivo,
    );

    if (!mounted || datos == null) return;

    final objetivoId = _id(objetivo['id']);
    if (objetivoId == null) return;

    setState(() {
      _guardando = true;
    });

    try {
      final actualizado = await _api.actualizarObjetivo(
        objetivoId: objetivoId,
        titulo: datos['titulo']!,
        horizonte: datos['horizonte']!,
        descripcion: objetivo['descripcion']?.toString() ?? '',
      );

      if (!mounted) return;

      setState(() {
        final posicion = _objetivos.indexWhere(
          (item) => _id(item['id']) == objetivoId,
        );

        if (posicion >= 0) {
          _objetivos[posicion] = actualizado;
        }
      });

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error actualizando objetivo: $e');
      _mensaje('No se pudo actualizar el objetivo.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // RETIRAR OBJETIVO
  // =====================================================

  Future<void> _retirarObjetivo(
    Map<String, dynamic> objetivo,
  ) async {
    if (_guardando) return;

    final objetivoId = _id(objetivo['id']);
    if (objetivoId == null) return;

    final confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Retirar objetivo'),
              content: const Text(
                'El objetivo dejará de aparecer en tu lista. '
                'Las metas que creaste se conservarán.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Retirar'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted || !confirmar) return;

    setState(() {
      _guardando = true;
    });

    try {
      await _api.archivarObjetivo(objetivoId);

      if (!mounted) return;

      setState(() {
        _objetivos.removeWhere(
          (item) => _id(item['id']) == objetivoId,
        );

        _vista = 'objetivos';
        _objetivoSeleccionado = null;
      });

      _mensaje('Objetivo retirado de tu lista.');
    } catch (e) {
      debugPrint('Error retirando objetivo: $e');
      _mensaje('No se pudo retirar el objetivo.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // CREAR META
  // =====================================================

  Future<void> _crearMeta(
    Map<String, dynamic> objetivo,
  ) async {
    if (_guardando) return;

    final objetivoId = _id(objetivo['id']);
    if (objetivoId == null) return;

    final control = TextEditingController();
    final form = GlobalKey<FormState>();

    final titulo = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nueva meta'),
          content: Form(
            key: form,
            child: TextFormField(
              controller: control,
              autofocus: true,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué resultado alcanzarás?',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Escribe tu meta.';
                }
                return null;
              },
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

    if (!mounted || titulo == null) return;

    setState(() {
      _guardando = true;
    });

    try {
      final meta = await _api.crearMeta(
        titulo: titulo,
        objetivoId: objetivoId,
      );

      if (!mounted) return;

      setState(() {
        _metas.insert(0, meta);
      });

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error creando meta: $e');
      _mensaje('No se pudo guardar la meta.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // TARJETA REUTILIZABLE
  // =====================================================

  Widget _tarjeta({
    required Widget hijo,
    VoidCallback? alTocar,
  }) {
    return Material(
      color: _superficie,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _borde),
          ),
          child: hijo,
        ),
      ),
    );
  }

  Widget _indicadorPlazo(String horizonte) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _suave,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _nombreHorizonte(horizonte),
        style: BrujulaTipografia.boton(
          size: 10.5,
        ).copyWith(
          color: _acento,
        ),
      ),
    );
  }

  // =====================================================
  // VISTA PRINCIPAL: HERO
  // =====================================================

  Widget _heroVision() {
    final tieneVision = _vision.trim().isNotEmpty;

    return Material(
      color: _destacado,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _guardando ? null : () => _editarTexto(esVision: true),
        child: Padding(
          padding: const EdgeInsets.all(21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.explore_outlined,
                    color: BrujulaColores.doradoUNI,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'MI DIRECCIÓN PERSONAL',
                    style: BrujulaTipografia.etiqueta().copyWith(
                      color: BrujulaColores.doradoUNI,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                tieneVision ? 'Esta es mi visión' : '¿Hacia dónde quiero ir?',
                style: BrujulaTipografia.principal(
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tieneVision
                    ? _vision
                    : 'Imagina la persona y el profesional '
                        'en quien deseas convertirte.',
                maxLines: tieneVision ? 5 : 3,
                overflow: TextOverflow.ellipsis,
                style: BrujulaTipografia.cuerpo(
                  size: 13,
                  color: const Color(0xFFF7E8E5),
                ),
              ),
              const SizedBox(height: 19),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tieneVision ? 'Revisar mi visión' : 'Definir mi visión',
                      style: BrujulaTipografia.boton(
                        size: 12,
                        color: BrujulaColores.rojoUNI,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: BrujulaColores.rojoUNI,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // RESUMEN DE UN OBJETIVO
  // =====================================================

  Widget _resumenObjetivo(
    Map<String, dynamic> objetivo,
  ) {
    final objetivoId = _id(objetivo['id']);
    final cantidad = _cantidadMetas(objetivoId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _tarjeta(
        alTocar: () => _abrirDetalle(objetivo),
        hijo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  color: _acento,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    objetivo['titulo']?.toString() ?? '',
                    style: _titulo(14),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _secundario,
                  size: 21,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _indicadorPlazo(
                  objetivo['horizonte']?.toString() ?? '',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$cantidad ${cantidad == 1 ? 'meta vinculada' : 'metas vinculadas'}',
                    style: _cuerpo(11.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // VISTA PRINCIPAL
  // =====================================================

  Widget _vistaInicio() {
    final tieneReflexion = _reflexion.trim().isNotEmpty;

    final vistaPrevia = _objetivos.take(2).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        19,
        22,
        19,
        32,
      ),
      children: [
        Text(
          'MI CAMINO',
          style: _etiqueta(),
        ),
        const SizedBox(height: 9),
        Text(
          'Mi Proyecto de Vida',
          style: _principal(26),
        ),
        const SizedBox(height: 8),
        Text(
          'Un espacio para pensar en tu futuro '
          'y darle dirección a tus decisiones.',
          style: _cuerpo(13),
        ),
        const SizedBox(height: 24),
        _heroVision(),
        const SizedBox(height: 29),
        Row(
          children: [
            Expanded(
              child: Text(
                'Mis objetivos',
                style: _titulo(19),
              ),
            ),
            if (_objetivos.isNotEmpty)
              TextButton(
                onPressed: _abrirObjetivos,
                child: const Text('Ver todos'),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Lo que deseo conseguir en mi trayectoria.',
          style: _cuerpo(12),
        ),
        const SizedBox(height: 15),
        if (_objetivos.isEmpty)
          _tarjeta(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 26,
                  color: _acento,
                ),
                const SizedBox(height: 10),
                Text(
                  'Todavía no tienes objetivos',
                  style: _titulo(15),
                ),
                const SizedBox(height: 7),
                Text(
                  'Empieza con algo que te gustaría conseguir.',
                  style: _cuerpo(12),
                ),
              ],
            ),
          )
        else
          ...vistaPrevia.map(_resumenObjetivo),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: _abrirObjetivos,
          icon: const Icon(
            Icons.arrow_forward_rounded,
            size: 18,
          ),
          label: Text(
            _objetivos.isEmpty
                ? 'Crear mi primer objetivo'
                : 'Organizar mis objetivos',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _acento,
            side: BorderSide(color: _borde),
            minimumSize: const Size.fromHeight(47),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Divider(color: _borde),
        const SizedBox(height: 14),
        _tarjeta(
          alTocar: _guardando ? null : () => _editarTexto(esVision: false),
          hijo: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _suave,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  color: _acento,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi reflexión personal',
                      style: _titulo(15),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tieneReflexion
                          ? _reflexion
                          : 'Reconoce tus fortalezas y oportunidades de mejora.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _cuerpo(12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right_rounded,
                color: _secundario,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // VISTA DE OBJETIVOS
  // =====================================================

  Widget _filtroPlazo(
    String valor,
    String texto,
  ) {
    final activo = _filtro == valor;

    return ChoiceChip(
      label: Text(texto),
      selected: activo,
      onSelected: (_) {
        setState(() {
          _filtro = valor;
        });
      },
      selectedColor: _suave,
      backgroundColor: _superficie,
      side: BorderSide(
        color: activo ? _acento : _borde,
      ),
      labelStyle: TextStyle(
        color: activo ? _acento : _texto,
        fontSize: 12,
        fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
      ),
      showCheckmark: false,
    );
  }

  Widget _vistaObjetivos() {
    final filtrados = _filtro == 'todos'
        ? _objetivos
        : _objetivos
            .where(
              (item) => item['horizonte'] == _filtro,
            )
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        19,
        22,
        19,
        32,
      ),
      children: [
        Text(
          'ORGANIZA TU FUTURO',
          style: _etiqueta(),
        ),
        const SizedBox(height: 9),
        Text(
          'Mis objetivos',
          style: _principal(25),
        ),
        const SizedBox(height: 8),
        Text(
          'Define lo que deseas lograr. Después '
          'podrás vincular metas a cada objetivo.',
          style: _cuerpo(13),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _guardando ? null : _crearObjetivo,
            style: FilledButton.styleFrom(
              backgroundColor: BrujulaColores.rojoUNI,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(47),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo objetivo'),
          ),
        ),
        const SizedBox(height: 22),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filtroPlazo('todos', 'Todos'),
              const SizedBox(width: 8),
              _filtroPlazo('corto', 'Corto'),
              const SizedBox(width: 8),
              _filtroPlazo('mediano', 'Mediano'),
              const SizedBox(width: 8),
              _filtroPlazo('largo', 'Largo'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (filtrados.isEmpty)
          _tarjeta(
            hijo: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: _acento,
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay objetivos en este plazo.',
                  style: _titulo(14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 7),
                Text(
                  'Puedes crear uno cuando lo necesites.',
                  style: _cuerpo(12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...filtrados.map(_resumenObjetivo),
      ],
    );
  }

  // =====================================================
  // DETALLE DEL OBJETIVO
  // =====================================================

  Widget _vistaDetalle() {
    final objetivo = _objetivoActual;

    if (objetivo == null) {
      return Center(
        child: Text(
          'Objetivo no disponible.',
          style: _cuerpo(13),
        ),
      );
    }

    final metas = _metasDe(_objetivoSeleccionado);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        19,
        22,
        19,
        32,
      ),
      children: [
        _indicadorPlazo(
          objetivo['horizonte']?.toString() ?? '',
        ),
        const SizedBox(height: 15),
        Text(
          objetivo['titulo']?.toString() ?? '',
          style: _principal(24),
        ),
        const SizedBox(height: 12),
        Text(
          'Un objetivo representa algo que deseas '
          'conseguir. Sus metas te ayudan a concretarlo.',
          style: _cuerpo(13),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _guardando ? null : () => _editarObjetivo(objetivo),
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
              onPressed: _guardando ? null : () => _retirarObjetivo(objetivo),
              icon: const Icon(
                Icons.archive_outlined,
                size: 17,
              ),
              label: const Text('Retirar'),
              style: TextButton.styleFrom(
                foregroundColor: _secundario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Metas vinculadas',
          style: _titulo(19),
        ),
        const SizedBox(height: 7),
        Text(
          'Resultados concretos que te ayudarán '
          'a alcanzar este objetivo.',
          style: _cuerpo(12),
        ),
        const SizedBox(height: 17),
        if (metas.isEmpty)
          _tarjeta(
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: _acento,
                  size: 26,
                ),
                const SizedBox(height: 11),
                Text(
                  'Aún no tienes metas vinculadas',
                  style: _titulo(14),
                ),
                const SizedBox(height: 7),
                Text(
                  'Crea una meta que represente '
                  'un resultado alcanzable.',
                  style: _cuerpo(12),
                ),
              ],
            ),
          )
        else
          ...metas.map(
            (meta) => Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: _tarjeta(
                hijo: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: _acento,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meta['titulo']?.toString() ?? '',
                        style: _titulo(13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 15),
        OutlinedButton.icon(
          onPressed: _guardando ? null : () => _crearMeta(objetivo),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Crear meta'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _acento,
            side: BorderSide(color: _borde),
            minimumSize: const Size.fromHeight(47),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PANTALLA
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final enInicio = _vista == 'inicio';

    return PopScope<void>(
      canPop: enInicio && !_guardando,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_guardando && !enInicio) {
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
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: _guardando ? null : _volver,
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            title: Text(
              enInicio
                  ? 'Mi Proyecto de Vida'
                  : _vista == 'objetivos'
                      ? 'Mis objetivos'
                      : 'Detalle del objetivo',
              style: _titulo(17),
            ),
          ),
          body: SafeArea(
            child: _cargando
                ? Center(
                    child: CircularProgressIndicator(
                      color: _acento,
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: _acento,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: _titulo(15),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _cargar,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                ),
                                label: const Text(
                                  'Volver a intentar',
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _vista == 'objetivos'
                        ? _vistaObjetivos()
                        : _vista == 'detalle'
                            ? _vistaDetalle()
                            : _vistaInicio(),
          ),
        ),
      ),
    );
  }
}
