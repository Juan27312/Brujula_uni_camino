import 'package:flutter/material.dart';

import 'package:brujula_uni/service/brujulaConexionService.dart';
import 'package:brujula_uni/service/caminoEstadoService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:brujula_uni/vistas/miCamino/evidenciasActividad.dart';
import 'package:brujula_uni/vistas/proyectoVida/proyectoVida.dart';

class MiTrayectoriaPage extends StatefulWidget {
  final int authId;

  const MiTrayectoriaPage({
    super.key,
    required this.authId,
  });

  @override
  State<MiTrayectoriaPage> createState() => _MiTrayectoriaPageState();
}

class _MiTrayectoriaPageState extends State<MiTrayectoriaPage> {
  final BrujulaConexionService _api = BrujulaConexionService.instancia;

  final CaminoEstadoService _camino = CaminoEstadoService.instancia;

  String _vision = '';
  String _reflexionPersonal = '';

  List<Map<String, dynamic>> _objetivos = [];

  bool _cargandoProyecto = true;
  bool _actualizandoProyecto = false;
  bool _creandoActividad = false;

  String? _errorProyecto;

  // 0 = Resumen
  // 1 = Recorrido
  // 2 = Aprendizajes
  int _seccion = 0;
  int _filtroAprendizajes = 0;
  int? _metaExpandida;

  // ===================================================
  // COLORES UNI
  // ===================================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _secundario => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _acento => BrujulaColores.acento(context);

  Color get _suave => BrujulaColores.superficieDestacada(context);

  // ===================================================
  // CICLO DE VIDA
  // ===================================================

  @override
  void initState() {
    super.initState();
    _camino.addListener(_escucharCambios);
    _cargarTodo();
  }

  @override
  void dispose() {
    _camino.removeListener(_escucharCambios);
    super.dispose();
  }

  void _escucharCambios() {
    if (mounted) {
      setState(() {});
    }
  }

  // ===================================================
  // UTILIDADES
  // ===================================================

  List<Map<String, dynamic>> _lista(dynamic valor) {
    if (valor is! List) return [];

    return valor
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int? _id(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '');
  }

  bool _realizada(Map<String, dynamic> actividad) {
    return actividad['estado'] == 'completada' ||
        actividad['completada'] == true;
  }

  String _nombreHorizonte(String horizonte) {
    switch (horizonte) {
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

  // ===================================================
  // TIPOGRAFÍA
  // ===================================================

  TextStyle _principal(double size) {
    return BrujulaTipografia.principal(
      size: size,
    ).copyWith(color: _texto);
  }

  TextStyle _titulo(double size) {
    return BrujulaTipografia.seccion(
      size: size,
    ).copyWith(color: _texto);
  }

  TextStyle _tarjetaTexto(double size) {
    return BrujulaTipografia.tarjeta(
      size: size,
    ).copyWith(color: _texto);
  }

  TextStyle _cuerpo(double size) {
    return BrujulaTipografia.cuerpo(
      size: size,
    ).copyWith(color: _secundario);
  }

  TextStyle _etiqueta() {
    return BrujulaTipografia.etiqueta().copyWith(
      color: _acento,
    );
  }

  // ===================================================
  // MENSAJES
  // ===================================================

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
            style: BrujulaTipografia.cuerpo(
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  // ===================================================
  // CONSULTA DE DATOS
  // ===================================================

  Future<void> _cargarTodo({bool forzar = false}) async {
    await Future.wait<void>([
      _cargarProyecto(),
      _cargarCamino(forzar: forzar),
    ]);
  }

  Future<void> _cargarCamino({
    bool forzar = false,
  }) async {
    try {
      await _camino.cargar(forzar: forzar);
    } catch (e) {
      debugPrint('Error cargando Mi Camino: $e');
    }
  }

  Future<void> _cargarProyecto() async {
    if (_actualizandoProyecto) return;

    if (mounted) {
      setState(() {
        _actualizandoProyecto = true;
        _errorProyecto = null;
      });
    }

    try {
      final respuesta = await _api.consultarProyecto();

      if (!mounted) return;

      final proyecto = respuesta['proyecto'];

      setState(() {
        if (proyecto is Map) {
          _vision = proyecto['vision_personal']?.toString() ?? '';

          _reflexionPersonal = proyecto['reflexion_personal']?.toString() ?? '';
        } else {
          _vision = '';
          _reflexionPersonal = '';
        }

        _objetivos = _lista(respuesta['objetivos']);
      });
    } catch (e) {
      debugPrint('Error consultando Proyecto de Vida: $e');

      if (mounted) {
        setState(() {
          _errorProyecto = 'No se pudo actualizar tu Proyecto de Vida.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _actualizandoProyecto = false;
          _cargandoProyecto = false;
        });
      }
    }
  }

  Future<void> _actualizar() async {
    await _cargarTodo(forzar: true);
  }

  // ===================================================
  // NAVEGACIÓN
  // ===================================================

  Future<void> _abrirProyecto() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProyectoVidaPage(
          authId: widget.authId,
        ),
      ),
    );

    if (mounted) {
      await _actualizar();
    }
  }

  Future<void> _abrirEvidencias(
    Map<String, dynamic> actividad,
  ) async {
    final actividadId = _id(actividad['id']);

    if (actividadId == null || actividadId <= 0) {
      _mensaje('No se pudo abrir la actividad.');
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EvidenciasActividadPage(
          actividadId: actividadId,
          actividadTitulo: actividad['titulo']?.toString() ?? 'Actividad',
        ),
      ),
    );
  }

  // ===================================================
  // FORMULARIOS
  // ===================================================

  Future<String?> _pedirTexto({
    required String titulo,
    required String etiqueta,
    String inicial = '',
    int maximo = 200,
    int lineas = 3,
  }) async {
    final control = TextEditingController(text: inicial);
    final form = GlobalKey<FormState>();

    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Theme(
          data: BrujulaTipografia.aplicar(
            Theme.of(ctx),
          ),
          child: AlertDialog(
            backgroundColor: BrujulaColores.superficie(ctx),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              titulo,
              style: BrujulaTipografia.seccion(
                size: 19,
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
                  maxLines: lineas,
                  textCapitalization: TextCapitalization.sentences,
                  style: BrujulaTipografia.cuerpo(
                    size: 14,
                  ).copyWith(
                    color: BrujulaColores.texto(ctx),
                  ),
                  decoration: InputDecoration(
                    labelText: etiqueta,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: BrujulaColores.acento(ctx),
                        width: 1.5,
                      ),
                    ),
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
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(
                      ctx,
                      control.text.trim(),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: BrujulaColores.rojoUNI,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      control.dispose();
    });

    return resultado;
  }

  // ===================================================
  // OPERACIONES DE ACTIVIDADES
  // ===================================================

  Future<void> _agregarActividad(
    Map<String, dynamic> meta,
  ) async {
    if (_creandoActividad) return;

    final metaId = _id(meta['id']);

    if (metaId == null || metaId <= 0) {
      _mensaje('No se pudo identificar la meta.');
      return;
    }

    if (!_api.tieneSesion) {
      _mensaje('Vuelve a ingresar para continuar.');
      return;
    }

    final titulo = await _pedirTexto(
      titulo: 'Nueva actividad',
      etiqueta: '¿Qué acción realizarás?',
    );

    if (!mounted || titulo == null) return;

    setState(() => _creandoActividad = true);

    try {
      final nueva = await _api.crearActividad(
        metaId: metaId,
        titulo: titulo,
      );

      if (!mounted) return;

      _camino.registrarActividad(
        nueva,
        metaId: metaId,
      );

      _mensaje('Guardado correctamente.');
    } catch (e) {
      debugPrint('Error creando actividad: $e');
      _mensaje('No se pudo guardar la actividad.');
    } finally {
      if (mounted) {
        setState(() => _creandoActividad = false);
      }
    }
  }

  Future<void> _registrarReflexion(
    Map<String, dynamic> actividad,
  ) async {
    final actividadId = _id(actividad['id']);

    if (actividadId == null || actividadId <= 0) {
      _mensaje('No se pudo identificar la actividad.');
      return;
    }

    if (_camino.guardando(actividadId)) return;

    final actual = _camino.actividad(actividadId);

    if (actual == null) {
      _mensaje('No se pudo abrir la actividad.');
      return;
    }

    final reflexion = await _pedirTexto(
      titulo: 'Mi reflexión',
      etiqueta: '¿Qué aprendiste?',
      inicial: actual['reflexion']?.toString() ?? '',
      maximo: 3000,
      lineas: 6,
    );

    if (!mounted || reflexion == null) return;

    final correcto = await _camino.guardarReflexion(
      actividadId: actividadId,
      reflexion: reflexion,
    );

    if (!mounted) return;

    _mensaje(
      correcto ? 'Guardado correctamente.' : 'No se pudo guardar la reflexión.',
    );
  }

  // ===================================================
  // DATOS DERIVADOS
  // ===================================================

  List<Map<String, dynamic>> _metasDeObjetivo(
    int objetivoId,
  ) {
    return _camino.metasConActividades.where((meta) {
      return _id(meta['objetivo_id']) == objetivoId;
    }).toList();
  }

  List<Map<String, dynamic>> get _metasIndependientes {
    final idsObjetivos = _objetivos
        .map((objetivo) => _id(objetivo['id']))
        .whereType<int>()
        .toSet();

    return _camino.metasConActividades.where((meta) {
      final objetivoId = _id(meta['objetivo_id']);

      return objetivoId == null || !idsObjetivos.contains(objetivoId);
    }).toList();
  }

  List<Map<String, dynamic>> _actividadesDeMeta(
    Map<String, dynamic> meta,
  ) {
    return _lista(meta['actividades']).map((actividad) {
      return <String, dynamic>{
        ...actividad,
        'meta_titulo': meta['titulo']?.toString() ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _todasLasActividades {
    return _camino.metasConActividades.expand(_actividadesDeMeta).toList();
  }

  List<Map<String, dynamic>> get _conReflexion {
    final actividades = _todasLasActividades.where((a) {
      return (a['reflexion']?.toString() ?? '').trim().isNotEmpty;
    }).toList();

    if (_filtroAprendizajes == 1) {
      return actividades.where(_realizada).toList();
    }

    if (_filtroAprendizajes == 2) {
      return actividades.where((a) => !_realizada(a)).toList();
    }

    return actividades;
  }

  int get _totalReflexiones {
    return _todasLasActividades.where((actividad) {
      return (actividad['reflexion']?.toString() ?? '').trim().isNotEmpty;
    }).length;
  }

  // ===================================================
  // COMPONENTES
  // ===================================================

  Widget _tarjeta({
    required Widget child,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: color ?? _superficie,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: child,
    );
  }

  Widget _tituloSeccion(
    String titulo,
    IconData icono,
  ) {
    return Row(
      children: [
        Icon(icono, color: _acento, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: _titulo(18),
          ),
        ),
      ],
    );
  }

  Widget _indicador(
    String valor,
    String titulo,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: _principal(24).copyWith(
              color: _acento,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: _cuerpo(11),
          ),
        ],
      ),
    );
  }

  Widget _resumen() {
    return _tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion(
            'Mi recorrido',
            Icons.route_outlined,
          ),
          const SizedBox(height: 8),
          Text(
            'Un resumen de tus acciones y aprendizajes.',
            style: _cuerpo(12),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _indicador(
                '${_camino.totalMetas}',
                'Metas',
              ),
              _indicador(
                '${_camino.realizadas}',
                'Realizadas',
              ),
              _indicador(
                '$_totalReflexiones',
                'Reflexiones',
              ),
            ],
          ),
          if (_camino.totalActividades > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _camino.realizadas / _camino.totalActividades,
                minHeight: 5,
                color: _acento,
                backgroundColor: _suave,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              '${_camino.realizadas} de '
              '${_camino.totalActividades} '
              'actividades realizadas',
              style: _cuerpo(11.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _selectorSecciones() {
    const opciones = [
      'Resumen',
      'Recorrido',
      'Aprendizajes',
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _borde),
      ),
      child: Row(
        children: List.generate(opciones.length, (indice) {
          final activo = _seccion == indice;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _seccion = indice;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 2,
                ),
                decoration: BoxDecoration(
                  color: activo ? _acento : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  opciones[indice],
                  textAlign: TextAlign.center,
                  style: BrujulaTipografia.boton(
                    size: 11.5,
                  ).copyWith(
                    color: activo ? _fondo : _secundario,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===================================================
  // RESUMEN PERSONAL
  // ===================================================

  Widget _rumboCompacto() {
    final tieneVision = _vision.trim().isNotEmpty;

    return _tarjeta(
      color: _suave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion(
            'Mi dirección personal',
            Icons.explore_outlined,
          ),
          const SizedBox(height: 12),
          Text(
            tieneVision
                ? _vision
                : 'Todavía no has definido tu visión personal.',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: tieneVision
                ? BrujulaTipografia.cuerpo(
                    size: 13.5,
                  ).copyWith(color: _texto)
                : _cuerpo(13),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _abrirProyecto,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 17,
            ),
            label: Text(
              tieneVision ? 'Revisar mi visión' : 'Definir mi visión',
            ),
            style: TextButton.styleFrom(
              foregroundColor: _acento,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaResumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resumen(),
        const SizedBox(height: 14),
        _rumboCompacto(),
        const SizedBox(height: 27),
        _tituloSeccion(
          'Lo que he aprendido',
          Icons.auto_stories_outlined,
        ),
        const SizedBox(height: 10),
        if (_totalReflexiones == 0)
          _tarjeta(
            child: Text(
              'Tus reflexiones aparecerán aquí '
              'cuando registres lo aprendido '
              'durante una actividad.',
              style: _cuerpo(12.5),
            ),
          )
        else
          _tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes $_totalReflexiones '
                  '${_totalReflexiones == 1 ? 'reflexión registrada' : 'reflexiones registradas'}.',
                  style: _tarjetaTexto(14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Puedes revisar lo que aprendiste '
                  'en cada experiencia.',
                  style: _cuerpo(12),
                ),
                const SizedBox(height: 9),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _seccion = 2;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: const Text(
                    'Ver mis aprendizajes',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ===================================================
  // RECORRIDO: OBJETIVOS Y METAS
  // ===================================================

  Widget _metaExpandible(
    Map<String, dynamic> meta,
  ) {
    final metaId = _id(meta['id']);

    final actividades = _actividadesDeMeta(meta);
    final total = actividades.length;
    final realizadas = actividades.where(_realizada).length;

    final expandida = metaId != null && _metaExpandida == metaId;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: metaId == null
                  ? null
                  : () {
                      setState(() {
                        _metaExpandida = expandida ? null : metaId;
                      });
                    },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      total > 0 && realizadas == total
                          ? Icons.check_circle_outline_rounded
                          : Icons.flag_outlined,
                      color: _acento,
                      size: 21,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta['titulo']?.toString() ?? '',
                            style: _tarjetaTexto(13.5),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            total == 0
                                ? 'Sin actividades'
                                : '$realizadas de $total realizadas',
                            style: _cuerpo(11.5),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expandida
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _secundario,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            alignment: Alignment.topCenter,
            child: expandida
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      0,
                      14,
                      14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: _borde),
                        if (actividades.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              'No hay actividades registradas.',
                              style: _cuerpo(12),
                            ),
                          )
                        else
                          ...actividades.map(
                            _filaActividadCompacta,
                          ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: _creandoActividad
                              ? null
                              : () => _agregarActividad(meta),
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Añadir actividad',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _acento,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _filaActividadCompacta(
    Map<String, dynamic> actividad,
  ) {
    final realizada = _realizada(actividad);
    final reflexion = actividad['reflexion']?.toString().trim() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            realizada
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: realizada ? _acento : _secundario,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad['titulo']?.toString() ?? '',
                  style: _tarjetaTexto(12.5),
                ),
                if (reflexion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Reflexión registrada',
                    style: _cuerpo(11),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: _secundario,
            ),
            onSelected: (opcion) {
              if (opcion == 'reflexion') {
                _registrarReflexion(actividad);
              } else if (opcion == 'evidencias') {
                _abrirEvidencias(actividad);
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaObjetivo(
    Map<String, dynamic> objetivo,
  ) {
    final objetivoId = _id(objetivo['id']);

    final metas = objetivoId == null
        ? <Map<String, dynamic>>[]
        : _metasDeObjetivo(objetivoId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _tarjeta(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _nombreHorizonte(
                objetivo['horizonte']?.toString() ?? '',
              ),
              style: _etiqueta(),
            ),
            const SizedBox(height: 8),
            Text(
              objetivo['titulo']?.toString() ?? '',
              style: _tarjetaTexto(15),
            ),
            const SizedBox(height: 7),
            Text(
              '${metas.length} '
              '${metas.length == 1 ? 'meta vinculada' : 'metas vinculadas'}',
              style: _cuerpo(12),
            ),
            if (metas.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...metas.map(_metaExpandible),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vistaRecorrido() {
    const horizontes = [
      'corto',
      'mediano',
      'largo',
    ];

    final ordenados = <Map<String, dynamic>>[];

    for (final horizonte in horizontes) {
      ordenados.addAll(
        _objetivos.where(
          (objetivo) => objetivo['horizonte'] == horizonte,
        ),
      );
    }

    ordenados.addAll(
      _objetivos.where(
        (objetivo) => !horizontes.contains(objetivo['horizonte']),
      ),
    );

    final independientes = _metasIndependientes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Objetivos y metas',
          Icons.track_changes_outlined,
        ),
        const SizedBox(height: 8),
        Text(
          'Consulta el recorrido de tus objetivos '
          'y las actividades relacionadas.',
          style: _cuerpo(12.5),
        ),
        const SizedBox(height: 18),
        if (ordenados.isEmpty && independientes.isEmpty)
          _tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todavía no has registrado objetivos o metas.',
                  style: _tarjetaTexto(14),
                ),
                const SizedBox(height: 9),
                TextButton.icon(
                  onPressed: _abrirProyecto,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: const Text(
                    'Ir a Mi Proyecto de Vida',
                  ),
                ),
              ],
            ),
          )
        else ...[
          ...ordenados.map(_tarjetaObjetivo),
          if (independientes.isNotEmpty) ...[
            const SizedBox(height: 18),
            _tituloSeccion(
              'Metas independientes',
              Icons.flag_outlined,
            ),
            const SizedBox(height: 12),
            ...independientes.map(_metaExpandible),
          ],
        ],
      ],
    );
  }

  // ===================================================
  // APRENDIZAJES
  // ===================================================

  Widget _filtrosAprendizajes() {
    const opciones = [
      'Todas',
      'Realizadas',
      'Pendientes',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(opciones.length, (indice) {
        final activo = _filtroAprendizajes == indice;

        return ChoiceChip(
          label: Text(opciones[indice]),
          selected: activo,
          onSelected: (_) {
            setState(() {
              _filtroAprendizajes = indice;
            });
          },
          backgroundColor: _superficie,
          selectedColor: _suave,
          side: BorderSide(
            color: activo ? _acento : _borde,
          ),
          showCheckmark: false,
          labelStyle: BrujulaTipografia.boton(
            size: 11.5,
          ).copyWith(
            color: activo ? _acento : _texto,
          ),
        );
      }),
    );
  }

  Widget _tarjetaAprendizaje(
    Map<String, dynamic> actividad,
  ) {
    final realizada = _realizada(actividad);
    final reflexion = actividad['reflexion']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: _tarjeta(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  realizada
                      ? Icons.check_circle_outline_rounded
                      : Icons.pending_outlined,
                  color: _acento,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  realizada ? 'Actividad realizada' : 'Actividad pendiente',
                  style: _etiqueta(),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              actividad['titulo']?.toString() ?? '',
              style: _tarjetaTexto(14.5),
            ),
            const SizedBox(height: 5),
            Text(
              'Meta: ${actividad['meta_titulo'] ?? ''}',
              style: _cuerpo(12),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _suave,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                reflexion,
                style: BrujulaTipografia.cuerpo(
                  size: 13,
                ).copyWith(color: _texto),
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              children: [
                TextButton.icon(
                  onPressed: () => _registrarReflexion(actividad),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                  ),
                  label: const Text('Editar reflexión'),
                  style: TextButton.styleFrom(
                    foregroundColor: _acento,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _abrirEvidencias(actividad),
                  icon: const Icon(
                    Icons.attach_file_rounded,
                    size: 16,
                  ),
                  label: const Text('Evidencias'),
                  style: TextButton.styleFrom(
                    foregroundColor: _acento,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaAprendizajes() {
    final actividades = _conReflexion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Mis aprendizajes',
          Icons.auto_stories_outlined,
        ),
        const SizedBox(height: 8),
        Text(
          'Revisa lo aprendido en tus actividades.',
          style: _cuerpo(12.5),
        ),
        const SizedBox(height: 17),
        if (_totalReflexiones == 0)
          _tarjeta(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.edit_note_outlined,
                  color: _acento,
                  size: 29,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tu historia de aprendizajes '
                  'comienza con una reflexión.',
                  style: _tarjetaTexto(14),
                ),
                const SizedBox(height: 8),
                Text(
                  'En la sección Recorrido, abre '
                  'una meta y registra lo aprendido '
                  'en alguna actividad.',
                  style: _cuerpo(12.5),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _seccion = 1;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: const Text('Ver mi recorrido'),
                ),
              ],
            ),
          )
        else ...[
          _filtrosAprendizajes(),
          const SizedBox(height: 16),
          if (actividades.isEmpty)
            _tarjeta(
              child: Text(
                'No hay reflexiones en esta categoría.',
                style: _cuerpo(12.5),
              ),
            )
          else
            ...actividades.map(_tarjetaAprendizaje),
        ],
      ],
    );
  }

  // ===================================================
  // PANTALLA PRINCIPAL
  // ===================================================

  @override
  Widget build(BuildContext context) {
    final cargandoCamino = !_camino.inicializado && _camino.cargando;

    final cargando = _cargandoProyecto || cargandoCamino;

    return Theme(
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
          title: Text(
            'Mi Trayectoria',
            style: _titulo(17),
          ),
        ),
        body: RefreshIndicator(
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
                'TU DESARROLLO UNIVERSITARIO',
                style: _etiqueta(),
              ),
              const SizedBox(height: 9),
              Text(
                'Mi Trayectoria',
                style: _principal(26),
              ),
              const SizedBox(height: 8),
              Text(
                'Reconoce tus avances y lo que '
                'has aprendido durante tu recorrido.',
                style: _cuerpo(13),
              ),
              const SizedBox(height: 22),
              if (cargando)
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _acento,
                    ),
                  ),
                )
              else ...[
                if (_errorProyecto != null) ...[
                  _tarjeta(
                    child: Text(
                      _errorProyecto!,
                      style: _cuerpo(12),
                    ),
                  ),
                  const SizedBox(height: 13),
                ],
                _selectorSecciones(),
                const SizedBox(height: 22),
                if (_seccion == 0) ...[
                  if (_camino.inicializado)
                    _vistaResumen()
                  else
                    _tarjeta(
                      child: Text(
                        'No se pudieron cargar tus avances. '
                        'Desliza hacia abajo para actualizar.',
                        style: _cuerpo(12.5),
                      ),
                    ),
                ] else if (_seccion == 1) ...[
                  if (_camino.inicializado)
                    _vistaRecorrido()
                  else
                    _tarjeta(
                      child: Text(
                        'No se pudo cargar tu recorrido.',
                        style: _cuerpo(12.5),
                      ),
                    ),
                ] else ...[
                  if (_camino.inicializado)
                    _vistaAprendizajes()
                  else
                    _tarjeta(
                      child: Text(
                        'No se pudieron cargar tus aprendizajes.',
                        style: _cuerpo(12.5),
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
