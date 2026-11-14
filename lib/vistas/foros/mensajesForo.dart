
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brujula_uni/service/foroService.dart';
import 'package:brujula_uni/service/perfilService.dart';
import 'package:brujula_uni/util/fecha.dart';
import 'package:brujula_uni/util/colores.dart';

class MensajesForo extends StatefulWidget {
  final int itemId;
  final String texto;
  final int userId;

  const MensajesForo({
    super.key,
    required this.itemId,
    required this.texto,
    required this.userId,
  });

  @override
  State<MensajesForo> createState() => _MensajesForoState();
}

class _MensajesForoState extends State<MensajesForo>
    with SingleTickerProviderStateMixin {
  final TextEditingController _comentarioController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FocusNode _campoFocus = FocusNode();

  late final AnimationController _panelController;
  late Future<void> _preparacionFuture;

  Map<String, dynamic>? _tema;
  List<Map<String, dynamic>> _mensajes = [];

  int? _perfilId;
  int? _eliminandoId;

  // Participaciones que el estudiante mantiene abiertas.
  final Set<int> _mensajesExpandidos = <int>{};

  bool _redaccionAbierta = false;
  bool _enviando = false;
  bool _actualizando = false;

  static const Color _tirador = Color(0xFFABA6A1);

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 260),
    );

    _preparacionFuture = _prepararConversacion();
  }

  @override
  void dispose() {
    _panelController.dispose();
    _comentarioController.dispose();
    _scrollController.dispose();
    _campoFocus.dispose();
    super.dispose();
  }

  // =====================================================
  // IDENTIDAD VISUAL BRÚJULA UNI
  // =====================================================

  Color get _fondo => BrujulaColores.fondo(context);

  Color get _superficie => BrujulaColores.superficie(context);

  Color get _texto => BrujulaColores.texto(context);

  Color get _secundario => BrujulaColores.secundario(context);

  Color get _borde => BrujulaColores.borde(context);

  Color get _acento => BrujulaColores.acento(context);

  Color get _destacado => BrujulaColores.superficieDestacada(context);

  TextStyle _jakarta(
    double size, {
    FontWeight peso = FontWeight.w600,
    Color? color,
    double altura = 1.3,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: peso,
      color: color ?? _texto,
      height: altura,
      letterSpacing: -0.35,
    );
  }

  TextStyle _inter(
    double size, {
    FontWeight peso = FontWeight.w400,
    Color? color,
    double altura = 1.55,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: peso,
      color: color ?? _texto,
      height: altura,
    );
  }

  // =====================================================
  // CARGA INICIAL
  // =====================================================

  Future<void> _prepararConversacion() async {
    final resultados = await Future.wait<dynamic>([
      Foroservice.getTemaForoPorId(widget.itemId),
      Foroservice.getMensajePorTema(widget.itemId),
      PerfilService.getIdPerfilUsuario(widget.userId),
    ]).timeout(const Duration(seconds: 20));

    if (!mounted) return;

    final tema = Map<String, dynamic>.from(
      resultados[0] as Map,
    );

    final mensajes = List<Map<String, dynamic>>.from(
      resultados[1] as List,
    );

    final perfilId = resultados[2];

    if (perfilId is! int) {
      throw StateError(
        'No fue posible identificar al estudiante.',
      );
    }

    _tema = tema;
    _mensajes = mensajes;
    _perfilId = perfilId;
  }

  void _reintentarPreparacion() {
    setState(() {
      _tema = null;
      _mensajes = [];
      _perfilId = null;

      _preparacionFuture = _prepararConversacion();
    });
  }

  // =====================================================
  // AVISOS DISCRETOS
  // =====================================================

  void _mostrarAviso(
    String texto, {
    bool esError = false,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          texto,
          style: _inter(
            13,
            color: Colors.white,
          ),
        ),
        backgroundColor:
            esError ? const Color(0xFF923A3A) : const Color(0xFF424B42),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // =====================================================
  // PANEL LATERAL
  // =====================================================

  void _abrirPanel() {
    _campoFocus.unfocus();

    if (_redaccionAbierta) {
      setState(() {
        _redaccionAbierta = false;
      });
    }

    _panelController.animateTo(
      1,
      curve: Curves.easeOutCubic,
    );
  }

  void _cerrarPanel() {
    _panelController.animateTo(
      0,
      curve: Curves.easeOutCubic,
    );
  }

  void _moverPanel(
    DragUpdateDetails details,
    double ancho,
  ) {
    final desplazamiento = details.primaryDelta ?? 0;

    _panelController.value =
        (_panelController.value - desplazamiento / ancho).clamp(0.0, 1.0);
  }

  void _terminarMovimiento(
    DragEndDetails details,
  ) {
    final velocidad = details.primaryVelocity ?? 0;

    if (velocidad < -350) {
      _abrirPanel();
      return;
    }

    if (velocidad > 350) {
      _cerrarPanel();
      return;
    }

    if (_panelController.value >= 0.45) {
      _abrirPanel();
    } else {
      _cerrarPanel();
    }
  }

  // =====================================================
  // CONTENIDO DEL PANEL: GEOMETRÍA RECTA
  // =====================================================

  Widget _contenidoPanel() {
    final tema = _tema ?? {};

    final titulo = (tema['titulo'] ?? widget.texto).toString().trim();

    final descripcion = (tema['descripcion'] ?? '').toString().trim();

    return Material(
      color: _superficie,
      elevation: 12,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.zero,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              23,
              27,
              22,
              18,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  color: _acento,
                ),
                const SizedBox(width: 11),
                Text(
                  'TEMA DEL FORO',
                  style: _inter(
                    11,
                    peso: FontWeight.w600,
                    color: _acento,
                    altura: 1.4,
                  ).copyWith(
                    letterSpacing: 0.35,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                23,
                6,
                23,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: _jakarta(
                      20,
                      peso: FontWeight.w600,
                      altura: 1.38,
                    ),
                  ),
                  const SizedBox(height: 23),
                  Divider(
                    color: _borde,
                    height: 1,
                  ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 23),
                    Text(
                      'Orientaciones para participar',
                      style: _jakarta(
                        15,
                        peso: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      descripcion,
                      style: _inter(
                        14,
                        color: _secundario,
                        altura: 1.65,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PANEL DESLIZANTE CON TIRADOR GRIS
  // =====================================================

  Widget _panelDeslizante() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoPantalla = MediaQuery.sizeOf(context).width;

        final anchoPanel = math.min(
          anchoPantalla * 0.88,
          430.0,
        );

        const alturaTactil = 108.0;

        final centroVertical = math.max(
          0.0,
          (constraints.maxHeight - alturaTactil) / 2,
        );

        return AnimatedBuilder(
          animation: _panelController,
          builder: (context, child) {
            final progreso = _panelController.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (progreso > 0.001)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: progreso < 0.15,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _cerrarPanel,
                        child: ColoredBox(
                          color: Colors.black.withValues(
                            alpha: progreso * 0.24,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Panel arrastrable desde la derecha.
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: -anchoPanel * (1 - progreso),
                  width: anchoPanel,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      _moverPanel(
                        details,
                        anchoPanel,
                      );
                    },
                    onHorizontalDragEnd: _terminarMovimiento,
                    child: _contenidoPanel(),
                  ),
                ),

                // Tirador vertical centrado.
                Positioned(
                  top: centroVertical,
                  right: anchoPanel * progreso,
                  width: 28,
                  height: alturaTactil,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      _moverPanel(
                        details,
                        anchoPanel,
                      );
                    },
                    onHorizontalDragEnd: _terminarMovimiento,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 5,
                        height: 62,
                        decoration: BoxDecoration(
                          color: _tirador,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // ACTUALIZAR PARTICIPACIONES
  // =====================================================

  Future<bool> _actualizarMensajes({
    bool mostrarError = true,
  }) async {
    if (_actualizando) return false;

    _actualizando = true;

    try {
      final nuevosMensajes = await Foroservice.getMensajePorTema(
        widget.itemId,
      );

      if (!mounted) return false;

      setState(() {
        _mensajes = nuevosMensajes;
      });

      return true;
    } catch (_) {
      if (mostrarError) {
        _mostrarAviso(
          'No fue posible actualizar las participaciones.',
          esError: true,
        );
      }

      return false;
    } finally {
      _actualizando = false;
    }
  }

  void _irAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =====================================================
  // REDACCIÓN
  // =====================================================

  void _abrirRedaccion() {
    if (_perfilId == null) {
      _mostrarAviso(
        'No fue posible identificar su cuenta.',
        esError: true,
      );
      return;
    }

    _cerrarPanel();

    setState(() {
      _redaccionAbierta = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _campoFocus.requestFocus();
      }
    });
  }

  void _contraerRedaccion() {
    _campoFocus.unfocus();

    setState(() {
      _redaccionAbierta = false;
    });

    // Se conserva el borrador.
  }

  // =====================================================
  // PUBLICAR
  // =====================================================

  Future<void> _publicarMensaje() async {
    if (_enviando || _perfilId == null) return;

    final texto = _comentarioController.text.trim();

    if (texto.isEmpty) {
      _mostrarAviso(
        'Escriba su participación antes de enviarla.',
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      await Foroservice.agregarMensaje(
        userId: _perfilId!,
        temaId: widget.itemId,
        contenido: texto,
      );

      if (!mounted) return;

      final actualizado = await _actualizarMensajes(
        mostrarError: false,
      );

      if (!mounted) return;

      _comentarioController.clear();
      _contraerRedaccion();

      if (actualizado) {
        _irAlFinal();

        _mostrarAviso(
          'Su participación fue publicada.',
        );
      } else {
        _mostrarAviso(
          'Su participación fue publicada. '
          'Actualice para verla.',
        );
      }
    } catch (_) {
      _mostrarAviso(
        'No fue posible publicar su participación. '
        'Inténtelo nuevamente.',
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  // =====================================================
  // ELIMINAR PARTICIPACIÓN PROPIA
  // =====================================================

  Future<void> _confirmarEliminacion(
    int mensajeId,
  ) async {
    if (_eliminandoId != null || _perfilId == null) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: BrujulaColores.superficie(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Eliminar participación',
            style: _jakarta(18),
          ),
          content: Text(
            '¿Desea eliminar esta participación? '
            'Esta acción no se puede deshacer.',
            style: _inter(
              14,
              color: _secundario,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancelar',
                style: _inter(
                  13,
                  peso: FontWeight.w600,
                  color: _secundario,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _acento,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Eliminar',
                style: _inter(
                  13,
                  peso: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      _eliminandoId = mensajeId;
    });

    try {
      final eliminado = await Foroservice.eliminarMensaje(
        idMensaje: mensajeId,
      );

      if (!mounted) return;

      if (!eliminado) {
        _mostrarAviso(
          'No fue posible eliminar la participación.',
          esError: true,
        );
        return;
      }

      await _actualizarMensajes();

      if (!mounted) return;

      _mostrarAviso(
        'La participación fue eliminada.',
      );
    } catch (_) {
      _mostrarAviso(
        'No fue posible eliminar la participación. '
        'Inténtelo nuevamente.',
        esError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _eliminandoId = null;
        });
      }
    }
  }

  // =====================================================
  // IDENTIFICACIÓN DEL ESTUDIANTE
  // =====================================================

  Widget _iconoPerfil(bool esPropio) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: BrujulaColores.iconoFondo(context),
      child: Icon(
        Icons.person_outline_rounded,
        size: 18,
        color: esPropio ? _acento : _secundario,
      ),
    );
  }

  // Obtiene el nombre de la carrera si ya forma
  // parte de los datos entregados por Foroservice.
  //
  // No inventa una carrera cuando el servicio
  // todavía no devuelve esa información.
  String _nombreCarrera(
    Map<String, dynamic> perfil,
  ) {
    final posiblesValores = [
      perfil['nombre_carrera'],
      perfil['carrera_nombre'],
      perfil['carrera'],
      perfil['carreras'],
    ];

    for (final valor in posiblesValores) {
      if (valor == null) continue;

      if (valor is String) {
        final nombre = valor.trim();

        if (nombre.isNotEmpty) {
          return nombre;
        }
      }

      if (valor is Map) {
        final datos = Map<String, dynamic>.from(
          valor,
        );

        final nombre = (datos['nombre'] ??
                datos['nombre_carrera'] ??
                datos['denominacion'] ??
                '')
            .toString()
            .trim();

        if (nombre.isNotEmpty) {
          return nombre;
        }
      }
    }

    return '';
  }

  // =====================================================
  // DISTINTIVO ACADÉMICO
  // =====================================================

  Widget _distintivoCarrera(String carrera) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 220,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _destacado,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: BrujulaColores.bordeDestacado(context),
        ),
      ),
      child: Text(
        carrera,
        softWrap: true,
        style: _inter(
          11,
          peso: FontWeight.w600,
          color: _acento,
          altura: 1.3,
        ),
      ),
    );
  }

  // =====================================================
  // PARTICIPACIÓN INDIVIDUAL
  // =====================================================

  Widget _mensajeItem(
    Map<String, dynamic> mensaje,
  ) {
    final perfilDato = mensaje['perfiles_estudiante'];

    final Map<String, dynamic> perfil = perfilDato is Map
        ? Map<String, dynamic>.from(perfilDato)
        : <String, dynamic>{};

    final nombres = (perfil['nombres'] ?? '').toString().trim();

    final apellidos = (perfil['apellidos'] ?? '').toString().trim();

    final nombreCompleto = '$nombres $apellidos'.trim();

    final autor = nombreCompleto.isNotEmpty
        ? nombreCompleto
        : 'Estudiante UNI';

    final carrera = _nombreCarrera(perfil);

    // Ordenar visualmente los espacios excesivos,
    // incluso en participaciones anteriores.
    final contenido = Foroservice.normalizarContenido(
      (mensaje['contenido'] ?? '').toString(),
    );

    final autorId = mensaje['user_id'];
    final mensajeId = mensaje['id'];

    final esPropio = _perfilId != null &&
        autorId != null &&
        autorId.toString() == _perfilId.toString();

    final puedeEliminar = esPropio && mensajeId is int;

    final fecha = formatearFecha(
      (mensaje['fecha'] ?? '').toString(),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        14,
        7,
        14,
        7,
      ),
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        13,
      ),
      decoration: BoxDecoration(
        color: esPropio ? _destacado : _superficie,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esPropio
              ? BrujulaColores.bordeDestacado(context)
              : _borde,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 1,
                ),
                child: _iconoPerfil(esPropio),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        Text(
                          autor,
                          softWrap: true,
                          style: _jakarta(
                            13,
                            peso: FontWeight.w600,
                            color: esPropio ? _acento : _texto,
                          ),
                        ),
                        if (carrera.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: _distintivoCarrera(carrera),
                          ),
                      ],
                    ),
                    if (fecha.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        fecha,
                        style: _inter(
                          11,
                          color: _secundario,
                          altura: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (puedeEliminar)
                PopupMenuButton<String>(
                  tooltip: 'Opciones de participación',
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: _secundario,
                    size: 21,
                  ),
                  onSelected: (opcion) {
                    if (opcion == 'eliminar') {
                      _confirmarEliminacion(mensajeId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                          ),
                          SizedBox(width: 9),
                          Text('Eliminar participación'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 11),
          _textoParticipacion(
            contenido: contenido,
            mensajeId: mensajeId is int ? mensajeId : null,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LEER MÁS / LEER MENOS
  // =====================================================

  Widget _textoParticipacion({
    required String contenido,
    required int? mensajeId,
  }) {
    final estilo = _inter(14, altura: 1.55);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Contar líneas visuales reales según ancho
        // disponible y tamaño de letra del dispositivo.
        final medidor = TextPainter(
          text: TextSpan(
            text: contenido,
            style: estilo,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 14,
        )..layout(
            maxWidth: constraints.maxWidth,
          );

        final esExtenso = medidor.didExceedMaxLines;
        medidor.dispose();

        final expandido = mensajeId != null &&
            _mensajesExpandidos.contains(mensajeId);

        // Comentario breve o comentario expandido.
        if (!esExtenso || expandido || mensajeId == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                contenido,
                textAlign: TextAlign.left,
                style: estilo,
              ),
              if (esExtenso && expandido && mensajeId != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _mensajesExpandidos.remove(mensajeId);
                      });
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 18,
                    ),
                    label: const Text('Leer menos'),
                    style: TextButton.styleFrom(
                      foregroundColor: _acento,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
            ],
          );
        }

        // Comentario de más de 14 líneas:
        // mostrar únicamente las primeras 8.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contenido,
              textAlign: TextAlign.left,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: estilo,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _mensajesExpandidos.add(mensajeId);
                  });
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                ),
                label: const Text('Leer más'),
                style: TextButton.styleFrom(
                  foregroundColor: _acento,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // LISTADO SIN TÍTULO NI CONTADOR REPETIDOS
  // =====================================================

  Widget _listaParticipaciones() {
    return RefreshIndicator(
      color: _acento,
      onRefresh: () async {
        await _actualizarMensajes();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 100,
        ),
        itemCount: _mensajes.isEmpty ? 1 : _mensajes.length,
        itemBuilder: (context, index) {
          if (_mensajes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                110,
                20,
                20,
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      color: _secundario,
                      size: 37,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Todavía no hay participaciones',
                      textAlign: TextAlign.center,
                      style: _jakarta(16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puede iniciar la conversación '
                      'compartiendo su opinión.',
                      textAlign: TextAlign.center,
                      style: _inter(
                        13,
                        color: _secundario,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return _mensajeItem(
            _mensajes[index],
          );
        },
      ),
    );
  }

  // =====================================================
  // BOTÓN PARTICIPAR A LA DERECHA
  // =====================================================

  Widget _botonParticipar() {
    return Material(
      color: _acento,
      borderRadius: BorderRadius.circular(13),
      elevation: 2,
      child: InkWell(
        onTap: _abrirRedaccion,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 17,
                color: Colors.white,
              ),
              const SizedBox(width: 7),
              Text(
                'Participar',
                style: _inter(
                  13,
                  peso: FontWeight.w600,
                  color: Colors.white,
                  altura: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CAMPO DE ESCRITURA EXPANDIBLE
  // =====================================================

  Widget _campoExtendido() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 350) {
          _contraerRedaccion();
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _superficie,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _borde,
                ),
              ),
              child: TextField(
                controller: _comentarioController,
                focusNode: _campoFocus,
                enabled: !_enviando,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textAlign: TextAlign.left,
                minLines: 1,
                maxLines: 5,
                style: _inter(
                  14,
                  altura: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Escriba su participación...',
                  hintStyle: _inter(
                    13,
                    color: _secundario,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Material(
            color: _enviando ? _secundario : _acento,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: _enviando ? null : _publicarMensaje,
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          size: 21,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // COMPOSICIÓN GENERAL
  // =====================================================

  Widget _conversacion() {
    return Stack(
      children: [
        Positioned.fill(
          child: _listaParticipaciones(),
        ),

        // Botón flotante, abajo a la derecha.
        if (!_redaccionAbierta)
          Positioned(
            right: 12,
            bottom: 12,
            child: _botonParticipar(),
          ),

        // Campo de redacción al abrirse.
        if (_redaccionAbierta)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: AnimatedSize(
              duration: const Duration(
                milliseconds: 260,
              ),
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: _campoExtendido(),
            ),
          ),

        // Panel lateral independiente.
        Positioned.fill(
          child: _panelDeslizante(),
        ),
      ],
    );
  }

  // =====================================================
  // CARGA Y ERRORES
  // =====================================================

  Widget _cargaInicial() {
    return Center(
      key: const ValueKey('carga'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: _acento,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Preparando conversación...',
            style: _inter(
              12,
              color: _secundario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorInicial() {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 36,
              color: _acento,
            ),
            const SizedBox(height: 14),
            Text(
              'No fue posible abrir las participaciones.',
              textAlign: TextAlign.center,
              style: _inter(
                14,
                color: _secundario,
              ),
            ),
            const SizedBox(height: 17),
            OutlinedButton.icon(
              onPressed: _reintentarPreparacion,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Volver a intentar',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _acento,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PANTALLA PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: BrujulaColores.rojoUNI,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Participaciones',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          tooltip: 'Volver a foros',
        ),
      ),
      body: FutureBuilder<void>(
        future: _preparacionFuture,
        builder: (context, snapshot) {
          final cargando =
              snapshot.connectionState != ConnectionState.done;

          return AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 280,
            ),
            child: cargando
                ? _cargaInicial()
                : snapshot.hasError ||
                        _tema == null ||
                        _perfilId == null
                    ? _errorInicial()
                    : KeyedSubtree(
                        key: const ValueKey('contenido'),
                        child: _conversacion(),
                      ),
          );
        },
      ),
    );
  }
}
