import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:brujula_uni/service/caminoEstadoService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

import 'package:brujula_uni/vistas/evaluaciones/evaluaciones.dart';
import 'package:brujula_uni/vistas/foros/temasForos.dart';
import 'package:brujula_uni/vistas/inicio/inicioPremium.dart';
import 'package:brujula_uni/vistas/item1/item.dart';
import 'package:brujula_uni/vistas/miCamino/evidenciasActividad.dart';
import 'package:brujula_uni/vistas/miCamino/metasActividades.dart';
import 'package:brujula_uni/vistas/miCamino/miTrayectoria.dart';
import 'package:brujula_uni/vistas/perfil/perfil.dart';
import 'package:brujula_uni/vistas/proyectoVida/proyectoVida.dart';

// =====================================================
// DESTINOS DE NAVEGACIÓN
// =====================================================

class _DestinoNav {
  final String nombre;
  final IconData icono;
  final IconData iconoActivo;

  const _DestinoNav(
    this.nombre,
    this.icono,
    this.iconoActivo,
  );
}

const List<_DestinoNav> _destinos = [
  _DestinoNav(
    'Inicio',
    Icons.home_outlined,
    Icons.home_rounded,
  ),
  _DestinoNav(
    'Mi Camino',
    Icons.route_outlined,
    Icons.route_rounded,
  ),
  _DestinoNav(
    'Explorar',
    Icons.search_outlined,
    Icons.search_rounded,
  ),
  _DestinoNav(
    'Comunidad',
    Icons.groups_outlined,
    Icons.groups_rounded,
  ),
  _DestinoNav(
    'Mi Perfil',
    Icons.account_circle_outlined,
    Icons.account_circle,
  ),
];

// =====================================================
// COMPONENTES REUTILIZABLES
// =====================================================

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: BrujulaTipografia.etiqueta().copyWith(
        color: BrujulaColores.acento(context),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String titulo;

  const _TituloSeccion(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: BrujulaTipografia.seccion(
        size: 18,
      ).copyWith(
        color: BrujulaColores.texto(context),
      ),
    );
  }
}

class _AccesoCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _AccesoCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final superficie = BrujulaColores.superficie(context);
    final borde = BrujulaColores.borde(context);
    final acento = BrujulaColores.acento(context);
    final texto = BrujulaColores.texto(context);
    final secundario = BrujulaColores.secundario(context);

    return Material(
      color: superficie,
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borde),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: BrujulaColores.iconoFondo(
                    context,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: acento,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: BrujulaTipografia.tarjeta(
                        size: 15,
                      ).copyWith(
                        color: texto,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      descripcion,
                      style: BrujulaTipografia.secundario(
                        size: 12,
                      ).copyWith(
                        color: secundario,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: acento,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PANTALLA PRINCIPAL
// =====================================================

class BienvenidaPage extends StatefulWidget {
  final int userId;
  final VoidCallback onCerrarSesion;

  const BienvenidaPage({
    super.key,
    required this.userId,
    required this.onCerrarSesion,
  });

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  int _indice = 0;
  bool _cerrandoSesion = false;

  final CaminoEstadoService _camino = CaminoEstadoService.instancia;

  late final List<GlobalKey<NavigatorState>> _navegadores;

  @override
  void initState() {
    super.initState();

    _navegadores = List.generate(
      _destinos.length,
      (_) => GlobalKey<NavigatorState>(),
    );

    _cargarCamino();
  }

  Future<void> _cargarCamino({
    bool forzar = false,
  }) async {
    try {
      await _camino.cargar(forzar: forzar);
    } catch (e) {
      debugPrint(
        'No se pudo cargar Mi Camino: $e',
      );
    }
  }

  // ===================================================
  // CONFIRMACIONES
  // ===================================================

  Future<bool> _confirmar({
    required String titulo,
    required String descripcion,
    required String accion,
  }) async {
    final resultado = await showDialog<bool>(
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
          content: Text(
            descripcion,
            style: BrujulaTipografia.cuerpo(
              size: 13,
            ).copyWith(
              color: BrujulaColores.secundario(ctx),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: BrujulaColores.rojoUNI,
                foregroundColor: Colors.white,
              ),
              child: Text(accion),
            ),
          ],
        );
      },
    );

    return resultado ?? false;
  }

  Future<void> _confirmarCerrarSesion() async {
    if (_cerrandoSesion || !mounted) return;

    final confirmar = await _confirmar(
      titulo: 'Cerrar sesión',
      descripcion: '¿Deseas cerrar sesión?',
      accion: 'Cerrar sesión',
    );

    if (!mounted || !confirmar) return;

    setState(() {
      _cerrandoSesion = true;
    });

    _camino.limpiar();
    widget.onCerrarSesion();
  }

  Future<void> _confirmarSalidaAplicacion() async {
    if (!mounted || _cerrandoSesion) return;

    final salir = await _confirmar(
      titulo: 'Salir de Brújula UNI',
      descripcion: '¿Deseas salir de la aplicación?',
      accion: 'Salir',
    );

    if (salir && mounted) {
      await SystemNavigator.pop();
    }
  }

  // ===================================================
  // NAVEGACIÓN
  // ===================================================

  void _manejarAtrasEnRaiz() {
    if (!mounted || _cerrandoSesion) return;

    final navegador = _navegadores[_indice].currentState;

    if (navegador != null && navegador.canPop()) {
      navegador.pop();
      return;
    }

    if (_indice != 0) {
      setState(() {
        _indice = 0;
      });
      return;
    }

    _confirmarSalidaAplicacion();
  }

  void _seleccionar(int indice) {
    if (_cerrandoSesion || indice < 0 || indice >= _destinos.length) {
      return;
    }

    if (_indice == indice) {
      final navegador = _navegadores[indice].currentState;

      if (navegador != null && navegador.canPop()) {
        navegador.popUntil(
          (ruta) => ruta.isFirst,
        );
      }
      return;
    }

    setState(() {
      _indice = indice;
    });
  }

  Future<void> _abrir(Widget pagina) async {
    if (_cerrandoSesion) return;

    final navegador = _navegadores[_indice].currentState;

    if (navegador == null) return;

    await navegador.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => pagina,
      ),
    );
  }

  void _abrirActividad(
    Map<String, dynamic> actividad,
  ) {
    final id = actividad['id'];

    if (id is! num || id <= 0) return;

    _abrir(
      _DetalleActividadPage(
        actividadId: id.toInt(),
      ),
    );
  }

  void _abrirModulo(
    int id,
    String titulo,
  ) {
    _abrir(
      ItemMenusPage(
        itemId: id,
        authId: widget.userId,
        texto: titulo,
      ),
    );
  }

  void _abrirProyecto() {
    _abrir(
      ProyectoVidaPage(authId: widget.userId),
    );
  }

  void _abrirMetas() {
    _abrir(
      MetasActividadesPage(
        authId: widget.userId,
      ),
    );
  }

  void _abrirTrayectoria() {
    _abrir(
      MiTrayectoriaPage(
        authId: widget.userId,
      ),
    );
  }

  void _abrirEvaluaciones() {
    _abrir(
      Evaluaciones(
        authId: widget.userId,
        texto: 'Evaluaciones',
      ),
    );
  }

  void _abrirForos() {
    _abrir(
      ForosPage(
        text: 'Foros',
        userId: widget.userId,
      ),
    );
  }

  // ===================================================
  // PÁGINAS
  // ===================================================

  Widget _paginaPrincipal(int indice) {
    switch (indice) {
      case 0:
        return InicioPremiumPage(
          abrirProyecto: _abrirProyecto,
          abrirCamino: () => _seleccionar(1),
          abrirExplorar: () => _seleccionar(2),
          cerrarSesion: _confirmarCerrarSesion,
          abrirActividad: _abrirActividad,
        );

      case 1:
        return _CaminoPage(
          abrirProyecto: _abrirProyecto,
          abrirMetas: _abrirMetas,
          abrirTrayectoria: _abrirTrayectoria,
          abrirRecursos: () => _abrirModulo(2, 'Mi Camino'),
          abrirActividad: _abrirActividad,
        );

      case 2:
        return _ExplorarPage(
          abrirModulo: _abrirModulo,
          abrirEvaluaciones: _abrirEvaluaciones,
        );

      case 3:
        return _ComunidadPage(
          abrirComunidad: () => _abrirModulo(6, 'Comunidad'),
          abrirForos: _abrirForos,
        );

      case 4:
        return _PerfilConSalida(
          authId: widget.userId,
          cerrarSesion: _confirmarCerrarSesion,
        );

      default:
        return const Scaffold(
          body: Center(
            child: Text('Sección no disponible'),
          ),
        );
    }
  }

  Widget _crearNavegador(int indice) {
    return NavigatorPopHandler<void>(
      enabled: indice == _indice,
      onPopWithResult: (_) {
        final navegador = _navegadores[indice].currentState;

        if (navegador != null && navegador.canPop()) {
          navegador.pop();
        }
      },
      child: Navigator(
        key: _navegadores[indice],
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => _paginaPrincipal(indice),
          );
        },
      ),
    );
  }

  // ===================================================
  // NAVEGACIÓN INFERIOR
  // ===================================================

  Widget _navbar() {
    final superficie = BrujulaColores.superficie(context);

    final borde = BrujulaColores.borde(context);

    final acento = BrujulaColores.acento(context);

    final secundario = BrujulaColores.secundario(context);

    return Container(
      decoration: BoxDecoration(
        color: superficie,
        border: Border(
          top: BorderSide(
            color: borde,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            4,
            7,
            4,
            5,
          ),
          child: Row(
            children: List.generate(
              _destinos.length,
              (indice) {
                final destino = _destinos[indice];
                final activo = _indice == indice;

                return Expanded(
                  child: Semantics(
                    label: destino.nombre,
                    button: true,
                    selected: activo,
                    child: InkWell(
                      onTap: () => _seleccionar(indice),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 1,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activo ? destino.iconoActivo : destino.icono,
                              color: activo ? acento : secundario,
                              size: 24,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              destino.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    activo ? FontWeight.w700 : FontWeight.w400,
                                color: activo ? acento : secundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _manejarAtrasEnRaiz();
        }
      },
      child: Scaffold(
        backgroundColor: BrujulaColores.fondo(context),
        body: IndexedStack(
          index: _indice,
          children: List.generate(
            _destinos.length,
            _crearNavegador,
          ),
        ),
        bottomNavigationBar: _navbar(),
      ),
    );
  }
}

// =====================================================
// MI CAMINO
// =====================================================

class _CaminoPage extends StatefulWidget {
  final VoidCallback abrirProyecto;
  final VoidCallback abrirMetas;
  final VoidCallback abrirTrayectoria;
  final VoidCallback abrirRecursos;
  final void Function(Map<String, dynamic>) abrirActividad;

  const _CaminoPage({
    required this.abrirProyecto,
    required this.abrirMetas,
    required this.abrirTrayectoria,
    required this.abrirRecursos,
    required this.abrirActividad,
  });

  @override
  State<_CaminoPage> createState() => _CaminoPageState();
}

class _CaminoPageState extends State<_CaminoPage> {
  final CaminoEstadoService _camino = CaminoEstadoService.instancia;

  @override
  void initState() {
    super.initState();
    _camino.addListener(_escucharCambios);
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

  Future<void> _actualizar() async {
    try {
      await _camino.cargar(
        forzar: true,
      );
    } catch (e) {
      debugPrint(
        'No se pudo actualizar Mi Camino: $e',
      );
    }
  }

  // ===================================================
  // INDICADORES
  // ===================================================

  Widget _dato(
    String numero,
    String nombre,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numero,
            style: BrujulaTipografia.principal(
              size: 24,
            ).copyWith(
              color: BrujulaColores.acento(context),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            nombre,
            style: BrujulaTipografia.secundario(
              size: 11,
            ).copyWith(
              color: BrujulaColores.secundario(
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelResumen() {
    final total = _camino.totalActividades;
    final realizadas = _camino.realizadas;
    final pendientes = _camino.pendientes;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: BrujulaColores.superficieDestacada(
          context,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi avance',
            style: BrujulaTipografia.seccion(
              size: 16,
            ).copyWith(
              color: BrujulaColores.texto(context),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Resumen de tus actividades registradas',
            style: BrujulaTipografia.secundario(
              size: 12,
            ).copyWith(
              color: BrujulaColores.secundario(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _dato(
                '${_camino.totalMetas}',
                'Metas',
              ),
              _dato(
                '$realizadas',
                'Realizadas',
              ),
              _dato(
                '$pendientes',
                'Pendientes',
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: realizadas / total,
                minHeight: 6,
                color: BrujulaColores.acento(context),
                backgroundColor: BrujulaColores.superficie(
                  context,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$realizadas de $total actividades realizadas',
              style: BrujulaTipografia.secundario(
                size: 11,
              ).copyWith(
                color: BrujulaColores.secundario(
                  context,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  DateTime? _fecha(
    Map<String, dynamic> actividad,
  ) {
    return DateTime.tryParse(
      actividad['fecha_prevista']?.toString() ?? '',
    );
  }

  // ===================================================
  // SIGUIENTE PASO
  // ===================================================

  Widget _siguientePaso() {
    final pendientes = _camino.actividadesPendientes;

    if (pendientes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BrujulaColores.superficie(context),
          border: Border.all(
            color: BrujulaColores.borde(context),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.explore_outlined,
              color: BrujulaColores.acento(context),
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              _camino.totalActividades == 0
                  ? 'Tu camino comienza con una meta'
                  : 'Has realizado las actividades registradas',
              style: BrujulaTipografia.tarjeta(
                size: 15,
              ).copyWith(
                color: BrujulaColores.texto(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _camino.totalActividades == 0
                  ? 'Define qué deseas conseguir y añade '
                      'una primera actividad.'
                  : 'Puedes reflexionar sobre lo aprendido '
                      'o definir un nuevo paso.',
              style: BrujulaTipografia.cuerpo(
                size: 12,
              ).copyWith(
                color: BrujulaColores.secundario(
                  context,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: widget.abrirMetas,
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
              label: const Text('Ir a mis metas'),
              style: TextButton.styleFrom(
                foregroundColor: BrujulaColores.acento(context),
              ),
            ),
          ],
        ),
      );
    }

    final actividad = pendientes.first;
    final fecha = _fecha(actividad);

    return Material(
      color: BrujulaColores.destacado(context),
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.abrirActividad(actividad),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.near_me_outlined,
                    color: BrujulaColores.doradoUNI,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'TU SIGUIENTE PASO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: BrujulaColores.doradoUNI,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                actividad['titulo']?.toString() ?? '',
                style: BrujulaTipografia.principal(
                  size: 19,
                  color: Colors.white,
                ).copyWith(
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Meta: ${actividad['meta_titulo'] ?? ''}',
                style: BrujulaTipografia.cuerpo(
                  size: 12,
                  color: const Color(0xFFF4E4E1),
                ),
              ),
              if (fecha != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Fecha prevista: '
                  '${fecha.day.toString().padLeft(2, '0')}/'
                  '${fecha.month.toString().padLeft(2, '0')}/'
                  '${fecha.year}',
                  style: BrujulaTipografia.cuerpo(
                    size: 12,
                    color: const Color(0xFFF4E4E1),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              Text(
                'Continuar actividad  →',
                style: BrujulaTipografia.boton(
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otrasPendientes() {
    final otras = _camino.actividadesPendientes.skip(1).take(3).toList();

    if (otras.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: _TituloSeccion(
                'Después puedes continuar con',
              ),
            ),
            TextButton(
              onPressed: widget.abrirMetas,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...otras.map(
          (actividad) => Container(
            margin: const EdgeInsets.only(bottom: 9),
            decoration: BoxDecoration(
              color: BrujulaColores.superficie(context),
              border: Border.all(
                color: BrujulaColores.borde(context),
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: ListTile(
              onTap: () => widget.abrirActividad(actividad),
              leading: Icon(
                Icons.radio_button_unchecked_rounded,
                color: BrujulaColores.acento(context),
              ),
              title: Text(
                actividad['titulo']?.toString() ?? '',
                style: BrujulaTipografia.tarjeta(
                  size: 13,
                ).copyWith(
                  color: BrujulaColores.texto(context),
                ),
              ),
              subtitle: Text(
                actividad['meta_titulo']?.toString() ?? '',
                style: BrujulaTipografia.secundario(
                  size: 11,
                ).copyWith(
                  color: BrujulaColores.secundario(
                    context,
                  ),
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: BrujulaColores.acento(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cargando = !_camino.inicializado && _camino.cargando;

    return Scaffold(
      backgroundColor: BrujulaColores.fondo(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: BrujulaColores.acento(context),
          onRefresh: _actualizar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              19,
              22,
              19,
              30,
            ),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _Etiqueta(
                      'TU TRAYECTORIA',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: _camino.cargando ? null : _actualizar,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: BrujulaColores.acento(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Mi Camino',
                style: BrujulaTipografia.principal(
                  size: 27,
                ).copyWith(
                  color: BrujulaColores.texto(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cada paso cuenta. Organiza tus metas, '
                'continúa tus actividades y registra lo aprendido.',
                style: BrujulaTipografia.cuerpo(
                  size: 13,
                ).copyWith(
                  color: BrujulaColores.secundario(
                    context,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              if (cargando)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: CircularProgressIndicator(
                      color: BrujulaColores.acento(
                        context,
                      ),
                    ),
                  ),
                )
              else if (!_camino.inicializado && _camino.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrujulaColores.superficie(
                      context,
                    ),
                    border: Border.all(
                      color: BrujulaColores.borde(
                        context,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No pudimos actualizar tu información.',
                        style: TextStyle(
                          color: BrujulaColores.texto(
                            context,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _actualizar,
                        child: const Text(
                          'Volver a intentar',
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _siguientePaso(),
                const SizedBox(height: 19),
                _panelResumen(),
                _otrasPendientes(),
              ],
              const SizedBox(height: 26),
              const _TituloSeccion(
                'Organiza tu trayectoria',
              ),
              const SizedBox(height: 13),
              _AccesoCard(
                icono: Icons.explore_outlined,
                titulo: 'Mi Proyecto de Vida',
                descripcion: 'Define tu visión y tus objetivos '
                    'de corto, mediano y largo plazo.',
                onTap: widget.abrirProyecto,
              ),
              const SizedBox(height: 12),
              _AccesoCard(
                icono: Icons.flag_outlined,
                titulo: 'Mis metas y actividades',
                descripcion: 'Organiza acciones, registra avances '
                    'y adjunta evidencias.',
                onTap: widget.abrirMetas,
              ),
              const SizedBox(height: 12),
              _AccesoCard(
                icono: Icons.timeline_rounded,
                titulo: 'Mi Trayectoria',
                descripcion: 'Reconoce tus avances, consulta tus evidencias '
                    'y revisa lo aprendido durante tu recorrido.',
                onTap: widget.abrirTrayectoria,
              ),
              const SizedBox(height: 12),
              _AccesoCard(
                icono: Icons.menu_book_outlined,
                titulo: 'Recursos de Mi Camino',
                descripcion: 'Consulta publicaciones, orientaciones '
                    'y materiales disponibles.',
                onTap: widget.abrirRecursos,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// DETALLE DE ACTIVIDAD
// =====================================================

class _DetalleActividadPage extends StatefulWidget {
  final int actividadId;

  const _DetalleActividadPage({
    required this.actividadId,
  });

  @override
  State<_DetalleActividadPage> createState() => _DetalleActividadPageState();
}

class _DetalleActividadPageState extends State<_DetalleActividadPage> {
  final CaminoEstadoService _camino = CaminoEstadoService.instancia;

  @override
  void initState() {
    super.initState();
    _camino.addListener(_escucharCambios);
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

  Map<String, dynamic>? get _actividad => _camino.actividad(widget.actividadId);

  void _mensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: BrujulaColores.rojoUNI,
          behavior: SnackBarBehavior.floating,
          content: Text(mensaje),
        ),
      );
  }

  Future<void> _cambiarEstado(
    bool completar,
  ) async {
    final correcto = await _camino.cambiarEstado(
      actividadId: widget.actividadId,
      completada: completar,
    );

    if (!correcto) {
      _mensaje(
        'No se pudo guardar el cambio.',
      );
    }
  }

  Future<void> _editarReflexion() async {
    final actividad = _actividad;

    if (actividad == null || _camino.guardando(widget.actividadId)) {
      return;
    }

    final control = TextEditingController(
      text: actividad['reflexion']?.toString() ?? '',
    );

    final form = GlobalKey<FormState>();

    final texto = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: BrujulaColores.superficie(ctx),
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Mi reflexión',
            style: BrujulaTipografia.seccion(
              size: 18,
            ).copyWith(
              color: BrujulaColores.texto(ctx),
            ),
          ),
          content: Form(
            key: form,
            child: TextFormField(
              controller: control,
              autofocus: true,
              minLines: 3,
              maxLines: 7,
              maxLength: 3000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué aprendiste?',
                hintText: 'Describe tus aprendizajes, avances '
                    'o dificultades.',
                border: OutlineInputBorder(),
              ),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Escribe tu reflexión.'
                  : null,
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
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      control.dispose();
    });

    if (!mounted || texto == null) return;

    final correcto = await _camino.guardarReflexion(
      actividadId: widget.actividadId,
      reflexion: texto,
    );

    _mensaje(
      correcto ? 'Guardado correctamente.' : 'No se pudo guardar la reflexión.',
    );
  }

  Future<void> _abrirEvidencias() async {
    final actividad = _actividad;

    if (actividad == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EvidenciasActividadPage(
          actividadId: widget.actividadId,
          actividadTitulo: actividad['titulo']?.toString() ?? 'Actividad',
        ),
      ),
    );
  }

  Widget _seccion(Widget hijo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: BrujulaColores.superficie(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: BrujulaColores.borde(context),
        ),
      ),
      child: hijo,
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: BrujulaTipografia.seccion(
        size: 16,
      ).copyWith(
        color: BrujulaColores.texto(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actividad = _actividad;
    final guardando = _camino.guardando(widget.actividadId);

    if (actividad == null) {
      return Scaffold(
        backgroundColor: BrujulaColores.fondo(context),
        appBar: AppBar(
          backgroundColor: BrujulaColores.fondo(context),
          foregroundColor: BrujulaColores.texto(context),
          title: const Text('Mi actividad'),
        ),
        body: const Center(
          child: Text(
            'Actividad no disponible.',
          ),
        ),
      );
    }

    final titulo = actividad['titulo']?.toString() ?? 'Actividad';

    final metaTitulo = actividad['meta_titulo']?.toString() ?? '';

    final realizada = actividad['estado'] == 'completada';

    final reflexion = actividad['reflexion']?.toString() ?? '';

    return Scaffold(
      backgroundColor: BrujulaColores.fondo(context),
      appBar: AppBar(
        backgroundColor: BrujulaColores.fondo(context),
        foregroundColor: BrujulaColores.texto(context),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Mi actividad',
          style: BrujulaTipografia.seccion(
            size: 17,
          ).copyWith(
            color: BrujulaColores.texto(context),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            22,
            18,
            32,
          ),
          children: [
            const _Etiqueta('MI CAMINO'),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: BrujulaTipografia.principal(
                size: 24,
              ).copyWith(
                color: BrujulaColores.texto(context),
              ),
            ),
            if (metaTitulo.isNotEmpty) ...[
              const SizedBox(height: 9),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: BrujulaColores.acento(context),
                    size: 19,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Meta: $metaTitulo',
                      style: BrujulaTipografia.secundario(
                        size: 13,
                      ).copyWith(
                        color: BrujulaColores.secundario(
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // ESTADO DE LA ACTIVIDAD
            _seccion(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titulo(
                    'Estado de la actividad',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    realizada
                        ? 'Actividad realizada'
                        : actividad['estado'] == 'en_proceso'
                            ? 'Actividad en proceso'
                            : 'Actividad pendiente',
                    style: BrujulaTipografia.secundario(
                      size: 12,
                    ).copyWith(
                      color: BrujulaColores.secundario(
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: BrujulaColores.superficieDestacada(
                      context,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: CheckboxListTile(
                      value: realizada,
                      onChanged: guardando
                          ? null
                          : (valor) => _cambiarEstado(
                                valor ?? false,
                              ),
                      activeColor: BrujulaColores.acento(
                        context,
                      ),
                      title: Text(
                        'Marcar como realizada',
                        style: BrujulaTipografia.tarjeta(
                          size: 14,
                        ).copyWith(
                          color: BrujulaColores.texto(
                            context,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        realizada
                            ? 'Puedes desmarcarla si necesitas '
                                'continuar trabajando.'
                            : 'Márcala cuando hayas completado '
                                'la actividad.',
                        style: BrujulaTipografia.secundario(
                          size: 11,
                        ).copyWith(
                          color: BrujulaColores.secundario(
                            context,
                          ),
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                    ),
                  ),
                  if (guardando) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      color: BrujulaColores.acento(
                        context,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 13),

            // MI REFLEXIÓN
            _seccion(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: BrujulaColores.acento(
                          context,
                        ),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      _titulo('Mi reflexión'),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    reflexion.trim().isEmpty
                        ? 'Registra qué aprendiste, qué '
                            'dificultades encontraste o cómo avanzaste.'
                        : reflexion,
                    style: BrujulaTipografia.cuerpo(
                      size: 13,
                    ).copyWith(
                      color: BrujulaColores.secundario(
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextButton.icon(
                    onPressed: guardando ? null : _editarReflexion,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: Text(
                      reflexion.trim().isEmpty
                          ? 'Registrar reflexión'
                          : 'Editar reflexión',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: BrujulaColores.acento(
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            // MIS EVIDENCIAS
            _seccion(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        color: BrujulaColores.acento(
                          context,
                        ),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      _titulo('Mis evidencias'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Consulta o incorpora documentos y enlaces '
                    'que respalden esta actividad.',
                    style: BrujulaTipografia.cuerpo(
                      size: 13,
                    ).copyWith(
                      color: BrujulaColores.secundario(
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _abrirEvidencias,
                      icon: const Icon(
                        Icons.folder_open_outlined,
                      ),
                      label: const Text(
                        'Ver mis evidencias',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BrujulaColores.acento(
                          context,
                        ),
                        side: BorderSide(
                          color: BrujulaColores.acento(
                            context,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// EXPLORAR
// =====================================================

class _ExplorarPage extends StatelessWidget {
  final void Function(int, String) abrirModulo;
  final VoidCallback abrirEvaluaciones;

  const _ExplorarPage({
    required this.abrirModulo,
    required this.abrirEvaluaciones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrujulaColores.fondo(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            19,
            25,
            19,
            30,
          ),
          children: [
            const _Etiqueta('DESCUBRE'),
            const SizedBox(height: 10),
            Text(
              'Explorar',
              style: BrujulaTipografia.principal(
                size: 27,
              ).copyWith(
                color: BrujulaColores.texto(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra contenidos y oportunidades '
              'que contribuyen a tu formación integral.',
              style: BrujulaTipografia.cuerpo(
                size: 14,
              ).copyWith(
                color: BrujulaColores.secundario(
                  context,
                ),
              ),
            ),
            const SizedBox(height: 23),
            _AccesoCard(
              icono: Icons.campaign_outlined,
              titulo: 'Inspiración',
              descripcion: 'Mensajes, experiencias y motivación.',
              onTap: () => abrirModulo(1, 'Inspiración'),
            ),
            const SizedBox(height: 11),
            _AccesoCard(
              icono: Icons.spa_outlined,
              titulo: 'Desarrollo Personal',
              descripcion: 'Bienestar, talleres y habilidades blandas.',
              onTap: () => abrirModulo(
                3,
                'Desarrollo Personal',
              ),
            ),
            const SizedBox(height: 11),
            _AccesoCard(
              icono: Icons.menu_book_outlined,
              titulo: 'Desarrollo Académico',
              descripcion: 'Investigación, proyectos y tesis.',
              onTap: () => abrirModulo(
                4,
                'Desarrollo Académico',
              ),
            ),
            const SizedBox(height: 11),
            _AccesoCard(
              icono: Icons.work_outline_rounded,
              titulo: 'Desarrollo Profesional',
              descripcion: 'Prácticas, empleabilidad y '
                  'crecimiento profesional.',
              onTap: () => abrirModulo(
                5,
                'Desarrollo Profesional',
              ),
            ),
            const SizedBox(height: 11),
            _AccesoCard(
              icono: Icons.assignment_outlined,
              titulo: 'Evaluaciones',
              descripcion: 'Autoevaluaciones y recursos '
                  'de retroalimentación.',
              onTap: abrirEvaluaciones,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// COMUNIDAD
// =====================================================

class _ComunidadPage extends StatelessWidget {
  final VoidCallback abrirComunidad;
  final VoidCallback abrirForos;

  const _ComunidadPage({
    required this.abrirComunidad,
    required this.abrirForos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrujulaColores.fondo(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            19,
            25,
            19,
            30,
          ),
          children: [
            const _Etiqueta('COMUNIDAD UNI'),
            const SizedBox(height: 10),
            Text(
              'Conecta y participa',
              style: BrujulaTipografia.principal(
                size: 27,
              ).copyWith(
                color: BrujulaColores.texto(context),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Comparte experiencias y descubre '
              'oportunidades de colaboración universitaria.',
              style: BrujulaTipografia.cuerpo(
                size: 14,
              ).copyWith(
                color: BrujulaColores.secundario(
                  context,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _AccesoCard(
              icono: Icons.forum_outlined,
              titulo: 'Foros',
              descripcion: 'Participa en conversaciones '
                  'e intercambia ideas.',
              onTap: abrirForos,
            ),
            const SizedBox(height: 12),
            _AccesoCard(
              icono: Icons.groups_outlined,
              titulo: 'Red y oportunidades',
              descripcion: 'Docentes, egresados, asociaciones '
                  'y eventos.',
              onTap: abrirComunidad,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// MI PERFIL
// =====================================================

class _PerfilConSalida extends StatelessWidget {
  final int authId;
  final VoidCallback cerrarSesion;

  const _PerfilConSalida({
    required this.authId,
    required this.cerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrujulaColores.fondo(context),
      body: SafeArea(
        child: Perfil(
          authId: authId,
          cerrarSesion: cerrarSesion,
        ),
      ),
    );
  }
}
