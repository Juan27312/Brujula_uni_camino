import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:brujula_uni/service/bienvenidaService.dart';
import 'package:brujula_uni/service/caminoEstadoService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class InicioPremiumPage extends StatefulWidget {
  final VoidCallback abrirProyecto;
  final VoidCallback abrirCamino;
  final VoidCallback abrirExplorar;
  final VoidCallback cerrarSesion;
  final void Function(Map<String, dynamic>) abrirActividad;

  const InicioPremiumPage({
    super.key,
    required this.abrirProyecto,
    required this.abrirCamino,
    required this.abrirExplorar,
    required this.cerrarSesion,
    required this.abrirActividad,
  });

  @override
  State<InicioPremiumPage> createState() => _InicioPremiumPageState();
}

class _InicioPremiumPageState extends State<InicioPremiumPage> {
  final CaminoEstadoService _camino = CaminoEstadoService.instancia;

  Map<String, dynamic>? _bienvenida;
  bool _cargandoBienvenida = true;

  // =====================================================
  // PALETA INSTITUCIONAL ADAPTABLE
  // =====================================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _secundario => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _acento => BrujulaColores.acento(context);
  Color get _destacado => BrujulaColores.destacado(context);

  Color get _superficieDestacada => BrujulaColores.superficieDestacada(context);

  // =====================================================
  // CICLO DE VIDA
  // =====================================================

  @override
  void initState() {
    super.initState();

    _camino.addListener(_escucharCamino);
    _cargarBienvenida();
  }

  @override
  void dispose() {
    _camino.removeListener(_escucharCamino);
    super.dispose();
  }

  void _escucharCamino() {
    if (mounted) {
      setState(() {});
    }
  }

  // =====================================================
  // CARGA DE INFORMACIÓN
  // =====================================================

  Future<void> _cargarBienvenida() async {
    try {
      final resultado = await BienvenidaService.getAll();

      if (!mounted) return;

      setState(() {
        _bienvenida = resultado.isEmpty ? null : resultado.first;

        _cargandoBienvenida = false;
      });
    } catch (e) {
      debugPrint('Error consultando bienvenida: $e');

      if (!mounted) return;

      setState(() {
        _cargandoBienvenida = false;
      });
    }
  }

  Future<void> _actualizarCamino() async {
    try {
      await _camino.cargar(forzar: true);
    } catch (e) {
      debugPrint('Error actualizando Inicio: $e');
    }
  }

  Future<void> _actualizar() async {
    await Future.wait<void>([
      _cargarBienvenida(),
      _actualizarCamino(),
    ]);
  }

  String _fecha(dynamic valor) {
    final fecha = DateTime.tryParse(
      valor?.toString() ?? '',
    );

    if (fecha == null) return '';

    final local = fecha.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  // =====================================================
  // ESTILOS DE TEXTO
  // =====================================================

  TextStyle _principal(double size) {
    return BrujulaTipografia.principal(
      size: size,
    ).copyWith(
      color: _texto,
    );
  }

  TextStyle _seccion(double size) {
    return BrujulaTipografia.seccion(
      size: size,
    ).copyWith(
      color: _texto,
    );
  }

  TextStyle _tarjeta(double size) {
    return BrujulaTipografia.tarjeta(
      size: size,
    ).copyWith(
      color: _texto,
    );
  }

  TextStyle _secundaria(double size) {
    return BrujulaTipografia.secundario(
      size: size,
    ).copyWith(
      color: _secundario,
    );
  }

  // =====================================================
  // ENCABEZADO
  // =====================================================

  Widget _encabezado() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: BrujulaColores.rojoUNI,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.explore_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BRÚJULA UNI',
                style: _tarjeta(15).copyWith(
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Tu experiencia universitaria',
                style: _secundaria(11.5),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: widget.cerrarSesion,
          tooltip: 'Cerrar sesión',
          style: IconButton.styleFrom(
            backgroundColor: _superficie,
            side: BorderSide(color: _borde),
          ),
          icon: Icon(
            Icons.logout_rounded,
            size: 19,
            color: _acento,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // INTRODUCCIÓN
  // =====================================================

  Widget _introduccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Un espacio para descubrir, crecer y avanzar',
          style: BrujulaTipografia.etiqueta().copyWith(
            color: _acento,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Construye tu\npropio camino.',
          style: _principal(30).copyWith(
            height: 1.17,
            letterSpacing: -0.95,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cada experiencia cuenta. Encuentra tu próximo '
          'paso y descubre lo que puedes lograr.',
          style: BrujulaTipografia.cuerpo(
            size: 13.5,
          ).copyWith(
            color: _secundario,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // COMPONENTES DEL HERO
  // =====================================================

  Widget _etiquetaHero({
    required IconData icono,
    required String texto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.13,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            color: BrujulaColores.doradoUNI,
            size: 15,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BrujulaTipografia.boton(
                size: 11.5,
                color: BrujulaColores.doradoUNI,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accionHero(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texto,
            style: BrujulaTipografia.boton(
              size: 12.5,
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
    );
  }

  // =====================================================
  // TARJETA DESTACADA: TU SIGUIENTE PASO
  // =====================================================

  Widget _hero() {
    final bool cargando = !_camino.inicializado && _camino.cargando;

    final List<Map<String, dynamic>> pendientes = _camino.actividadesPendientes;

    final bool tieneActividad = _camino.inicializado && pendientes.isNotEmpty;

    final Map<String, dynamic> actividad =
        tieneActividad ? pendientes.first : <String, dynamic>{};

    final bool hayError = !_camino.inicializado && _camino.error != null;

    final bool sinActividades =
        _camino.inicializado && _camino.totalActividades == 0;

    final bool todasRealizadas = _camino.inicializado &&
        _camino.totalActividades > 0 &&
        pendientes.isEmpty;

    String titulo;
    String descripcion;

    if (cargando) {
      titulo = 'Preparando tu siguiente paso';
      descripcion = 'Estamos consultando tus actividades.';
    } else if (tieneActividad) {
      titulo = actividad['titulo']?.toString() ?? 'Continuar mi actividad';

      descripcion = 'Meta: ${actividad['meta_titulo'] ?? ''}';
    } else if (hayError) {
      titulo = 'Retoma tu camino';
      descripcion = 'No pudimos consultar tus actividades. '
          'Puedes ingresar a Mi Camino para continuar.';
    } else if (todasRealizadas) {
      titulo = 'Ya completaste tus actividades';
      descripcion = 'Puedes reflexionar sobre tus logros '
          'o definir nuevos objetivos.';
    } else if (sinActividades) {
      titulo = 'Dale forma a tu futuro';
      descripcion = 'Define tu primera meta y conviértela '
          'en una acción concreta.';
    } else {
      titulo = 'Dale forma a tu futuro';
      descripcion = 'Explora tus objetivos, actividades '
          'y oportunidades de crecimiento.';
    }

    final String fecha =
        tieneActividad ? _fecha(actividad['fecha_prevista']) : '';

    final String etiqueta =
        tieneActividad ? 'TU SIGUIENTE PASO' : 'TU PROYECTO PERSONAL';

    final String boton =
        tieneActividad ? 'Continuar actividad' : 'Ir a Mi Camino';

    void abrir() {
      if (tieneActividad) {
        widget.abrirActividad(actividad);
      } else {
        widget.abrirCamino();
      }
    }

    return Material(
      color: _destacado,
      borderRadius: BorderRadius.circular(23),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: abrir,
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            Positioned(
              top: -65,
              right: -53,
              child: IgnorePointer(
                child: Container(
                  width: 186,
                  height: 186,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.10,
                      ),
                      width: 27,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 17,
              bottom: 26,
              child: IgnorePointer(
                child: Icon(
                  Icons.explore_outlined,
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                  size: 112,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                21,
                23,
                21,
                23,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiquetaHero(
                    icono: Icons.near_me_outlined,
                    texto: etiqueta,
                  ),
                  const SizedBox(height: 21),
                  Text(
                    titulo,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: BrujulaTipografia.principal(
                      size: 23,
                      color: Colors.white,
                    ).copyWith(
                      height: 1.24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: BrujulaTipografia.cuerpo(
                      size: 12.5,
                      color: const Color(0xFFF4E4E1),
                    ),
                  ),
                  if (fecha.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFFF4E4E1),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Prevista: $fecha',
                          style: BrujulaTipografia.cuerpo(
                            size: 11.5,
                            color: const Color(0xFFF4E4E1),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 21),
                  _accionHero(boton),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ENCABEZADOS DE SECCIÓN
  // =====================================================

  Widget _tituloSeccion(
    String titulo, {
    String? accion,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: _seccion(18),
          ),
        ),
        if (accion != null && onTap != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: _acento,
            ),
            child: Text(
              accion,
              style: BrujulaTipografia.boton(
                size: 12,
              ).copyWith(
                color: _acento,
              ),
            ),
          ),
      ],
    );
  }

  // =====================================================
  // TARJETAS EDITORIALES
  // =====================================================

  Widget _accesoEditorial({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
    bool destacado = false,
  }) {
    return Material(
      color: destacado ? _superficieDestacada : _superficie,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color:
                  destacado ? BrujulaColores.bordeDestacado(context) : _borde,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BrujulaColores.iconoFondo(context),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icono,
                  color: _acento,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: _tarjeta(14.5),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      descripcion,
                      style: _secundaria(12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_outward_rounded,
                color: _acento,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // PROGRESO DEL ESTUDIANTE
  // =====================================================

  Widget _progreso() {
    if (!_camino.inicializado || _camino.totalActividades == 0) {
      return const SizedBox.shrink();
    }

    final int total = _camino.totalActividades;
    final int realizadas = _camino.realizadas;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        15,
        16,
        15,
      ),
      decoration: BoxDecoration(
        color: _superficieDestacada,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _superficie,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.route_rounded,
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
                  'Tus avances',
                  style: _tarjeta(13.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '$realizadas de $total actividades realizadas',
                  style: _secundaria(11.5),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: realizadas / total,
                    backgroundColor: _superficie,
                    color: _acento,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          IconButton(
            onPressed: widget.abrirCamino,
            tooltip: 'Ver Mi Camino',
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: _acento,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // CONTENIDO PUBLICADO DESDE CONSOLA WEB
  // =====================================================

  Widget _desdeBrujula() {
    final String titulo = _bienvenida?['titulo']?.toString().trim() ?? '';

    final String descripcion = _bienvenida?['descripcion']
            ?.toString()
            .replaceAll(r'\n', '\n')
            .trim() ??
        '';

    if (descripcion.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Desde Brújula UNI'),
        const SizedBox(height: 11),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: _superficie,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _borde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (titulo.isNotEmpty) ...[
                Text(
                  titulo,
                  style: _tarjeta(15),
                ),
                const SizedBox(height: 10),
              ],
              MarkdownBody(
                data: descripcion,
                styleSheet: MarkdownStyleSheet(
                  p: BrujulaTipografia.cuerpo(
                    size: 13,
                  ).copyWith(
                    color: _secundario,
                  ),
                  h1: _seccion(18),
                  h2: _seccion(16),
                  h3: _tarjeta(14),
                  listBullet: BrujulaTipografia.cuerpo(
                    size: 13,
                  ).copyWith(
                    color: _secundario,
                  ),
                  blockquote: BrujulaTipografia.cuerpo(
                    size: 13,
                  ).copyWith(
                    color: _secundario,
                  ),
                ),
              ),
            ],
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
    return Theme(
      data: BrujulaTipografia.aplicar(
        Theme.of(context),
      ),
      child: Scaffold(
        backgroundColor: _fondo,
        body: SafeArea(
          child: RefreshIndicator(
            color: _acento,
            onRefresh: _actualizar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                19,
                21,
                19,
                32,
              ),
              children: [
                _encabezado(),
                const SizedBox(height: 34),
                _introduccion(),
                const SizedBox(height: 25),
                _hero(),
                if (_camino.inicializado && _camino.totalActividades > 0) ...[
                  const SizedBox(height: 14),
                  _progreso(),
                ],
                const SizedBox(height: 30),
                _tituloSeccion(
                  'Tu espacio de crecimiento',
                ),
                const SizedBox(height: 14),
                _accesoEditorial(
                  icono: Icons.explore_outlined,
                  titulo: 'Mi Proyecto de Vida',
                  descripcion: 'Define tu visión y los objetivos '
                      'que orientan tu futuro.',
                  onTap: widget.abrirProyecto,
                  destacado: true,
                ),
                const SizedBox(height: 10),
                _accesoEditorial(
                  icono: Icons.route_outlined,
                  titulo: 'Mi Camino',
                  descripcion: 'Organiza tus metas, actividades '
                      'y próximos pasos.',
                  onTap: widget.abrirCamino,
                ),
                const SizedBox(height: 27),
                _tituloSeccion(
                  'Descubre algo nuevo',
                  accion: 'Explorar',
                  onTap: widget.abrirExplorar,
                ),
                const SizedBox(height: 10),
                _accesoEditorial(
                  icono: Icons.auto_stories_outlined,
                  titulo: 'Recursos y oportunidades',
                  descripcion: 'Ideas y herramientas para tu desarrollo '
                      'personal, académico y profesional.',
                  onTap: widget.abrirExplorar,
                ),
                if (_cargandoBienvenida) ...[
                  const SizedBox(height: 23),
                  Center(
                    child: CircularProgressIndicator(
                      color: _acento,
                    ),
                  ),
                ] else if (_bienvenida != null) ...[
                  const SizedBox(height: 27),
                  _desdeBrujula(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
