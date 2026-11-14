import 'package:flutter/material.dart';
import 'package:brujula_uni/service/evaluacionesService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:brujula_uni/vistas/evaluaciones/cuestionario.dart';

class Evaluaciones extends StatefulWidget {
  final int authId;
  final String texto;

  const Evaluaciones({
    super.key,
    required this.authId,
    required this.texto,
  });

  @override
  State<Evaluaciones> createState() => _EvaluacionesState();
}

class _EvaluacionesState extends State<Evaluaciones> {
  late Future<List<Map<String, dynamic>>> evaluacionesFuture;

  // =====================================
  // IDENTIDAD VISUAL
  // =====================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _secundario => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _acento => BrujulaColores.acento(context);
  Color get _suave => BrujulaColores.superficieDestacada(context);

  TextStyle _principal(double size) {
    return BrujulaTipografia.principal(
      size: size,
      color: _texto,
    );
  }

  TextStyle _titulo(double size) {
    return BrujulaTipografia.seccion(
      size: size,
      color: _texto,
    );
  }

  TextStyle _tarjetaTexto(double size) {
    return BrujulaTipografia.tarjeta(
      size: size,
      color: _texto,
    );
  }

  TextStyle _cuerpo(double size) {
    return BrujulaTipografia.cuerpo(
      size: size,
      color: _secundario,
    );
  }

  // =====================================
  // CARGA Y ACTUALIZACIÓN
  // =====================================

  @override
  void initState() {
    super.initState();
    evaluacionesFuture = Evaluacionesservice.getEvaluaciones();
  }

  Future<void> _actualizar() async {
    final futuro = Evaluacionesservice.getEvaluaciones();

    setState(() {
      evaluacionesFuture = futuro;
    });

    try {
      await futuro;
    } catch (e) {
      debugPrint('Error actualizando evaluaciones: $e');
    }
  }

  // =====================================
  // FORMATO DE FECHAS
  // =====================================

  String _fecha(dynamic valor) {
    if (valor == null) return '';

    final original = valor.toString().trim();
    if (original.isEmpty) return '';

    final fecha = DateTime.tryParse(original);
    if (fecha == null) return '';

    final local = fecha.toLocal();

    String dosDigitos(int numero) {
      return numero.toString().padLeft(2, '0');
    }

    return '${dosDigitos(local.day)}/'
        '${dosDigitos(local.month)}/'
        '${local.year}';
  }

  // =====================================
  // ENCABEZADO INSTITUCIONAL
  // =====================================

  Widget _encabezadoVisual() {
    final oscuro = BrujulaColores.esOscuro(context);

    return SizedBox(
      height: 206,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // =====================================
          // ILUSTRACIÓN DE EVALUACIONES
          // =====================================
          Positioned(
            right: 0,
            top: 12,
            width: 174,
            height: 145,
            child: IgnorePointer(
              child: Opacity(
                opacity: oscuro ? 0.48 : 0.68,
                child: Image.asset(
                  'assets/ilustraciones/evaluaciones.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          // =====================================
          // DEGRADADO PARA PROTEGER EL TEXTO
          // =====================================
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      _fondo,
                      _fondo.withOpacity(0.99),
                      _fondo.withOpacity(0.88),
                      _fondo.withOpacity(0.08),
                    ],
                    stops: const [
                      0,
                      0.43,
                      0.70,
                      1,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =====================================
          // CONTENIDO DEL ENCABEZADO
          // =====================================
          Padding(
            padding: const EdgeInsets.fromLTRB(
              19,
              20,
              19,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _suave,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'EXPLORA TU RUTA',
                    style: BrujulaTipografia.etiqueta(
                      color: _acento,
                    ).copyWith(
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  'Mis evaluaciones',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _principal(27),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 310,
                  ),
                  child: Text(
                    'Encuentra las evaluaciones disponibles '
                    'y accede a sus cuestionarios.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: _cuerpo(13),
                  ),
                ),
              ],
            ),
          ),

          // =====================================
          // CURVA DECORATIVA SUPERIOR
          // =====================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 29,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CurvaEvaluacionesSuperior(
                  color: _acento.withOpacity(
                    oscuro ? 0.15 : 0.13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // BLOQUE INFORMATIVO
  // =====================================

  Widget _espacioEvaluacion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: BrujulaColores.iconoFondo(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment_outlined,
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
                  'Tu espacio de evaluación',
                  style: _tarjetaTexto(15),
                ),
                const SizedBox(height: 5),
                Text(
                  'Selecciona una evaluación para '
                  'consultar sus preguntas.',
                  style: _cuerpo(12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // ENCABEZADO COMPLETO
  // =====================================

  Widget _encabezado(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezadoVisual(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            19,
            8,
            19,
            0,
          ),
          child: _espacioEvaluacion(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            19,
            26,
            19,
            14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Disponibles',
                  style: _titulo(18),
                ),
              ),
              Text(
                '$total',
                style: BrujulaTipografia.boton(
                  size: 12.5,
                ).copyWith(
                  color: _secundario,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================
  // NAVEGACIÓN AL CUESTIONARIO
  // =====================================

  void _abrirCuestionario(
    Map<String, dynamic> test,
  ) {
    final id = test['id'];
    final nombre = test['nombre']?.toString() ?? 'Evaluación';

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir la evaluación.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CuestionarioPage(
          testId: id,
          texto: nombre,
          authId: widget.authId,
        ),
      ),
    );
  }

  // =====================================
  // TARJETA DE CADA EVALUACIÓN
  // =====================================

  Widget _tarjetaEvaluacion(
    Map<String, dynamic> test,
  ) {
    final nombre = test['nombre']?.toString().trim() ?? '';

    final fecha = _fecha(
      test['fecha_creacion'],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        19,
        0,
        19,
        11,
      ),
      child: Material(
        color: _superficie,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirCuestionario(test),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _borde,
              ),
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
                    Icons.assignment_outlined,
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
                        nombre.isEmpty ? 'Sin nombre' : nombre,
                        style: _tarjetaTexto(15),
                      ),
                      if (fecha.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Publicada: $fecha',
                          style: _cuerpo(11.5),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _acento,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================
  // LISTA DE EVALUACIONES
  // =====================================

  Widget _listaEvaluaciones(
    List<Map<String, dynamic>> evaluaciones,
  ) {
    return RefreshIndicator(
      color: _acento,
      onRefresh: _actualizar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: 35,
        ),
        itemCount: evaluaciones.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _encabezado(
              evaluaciones.length,
            );
          }

          return _tarjetaEvaluacion(
            evaluaciones[index - 1],
          );
        },
      ),
    );
  }

  // =====================================
  // ESTADOS INFORMATIVOS
  // =====================================

  Widget _estadoInformativo({
    required IconData icono,
    required String titulo,
    required String descripcion,
    bool mostrarReintentar = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 29,
          ),
          decoration: BoxDecoration(
            color: _superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _borde,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _suave,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icono,
                  color: _acento,
                  size: 27,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: _titulo(16),
              ),
              const SizedBox(height: 9),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: _cuerpo(13),
              ),
              if (mostrarReintentar) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _actualizar,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Volver a intentar',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _acento,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =====================================
  // PANTALLA PRINCIPAL
  // =====================================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: BrujulaTipografia.aplicar(
        Theme.of(context),
      ),
      child: Scaffold(
        backgroundColor: _fondo,

        // Barra superior institucional.
        appBar: AppBar(
          backgroundColor: COLORBASE,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.texto,
            style: BrujulaTipografia.seccion(
              size: 17,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),

        body: SafeArea(
          child: Stack(
            children: [
              // Decoración inferior.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 90,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CurvaEvaluacionesInferior(
                      color: _acento.withOpacity(0.055),
                    ),
                  ),
                ),
              ),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: evaluacionesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: _acento,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _estadoInformativo(
                      icono: Icons.wifi_off_rounded,
                      titulo: 'No se pudieron cargar las evaluaciones',
                      descripcion:
                          'Comprueba tu conexión e inténtalo nuevamente.',
                      mostrarReintentar: true,
                    );
                  }

                  final evaluaciones = snapshot.data ?? [];

                  if (evaluaciones.isEmpty) {
                    return _estadoInformativo(
                      icono: Icons.assignment_outlined,
                      titulo: 'Sin evaluaciones disponibles',
                      descripcion: 'Las evaluaciones aparecerán aquí '
                          'cuando sean publicadas.',
                      mostrarReintentar: true,
                    );
                  }

                  return _listaEvaluaciones(
                    evaluaciones,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================
// CURVA SUPERIOR
// =====================================

class _CurvaEvaluacionesSuperior extends CustomPainter {
  final Color color;

  _CurvaEvaluacionesSuperior({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final curva = Path()
      ..moveTo(0, size.height * 0.52)
      ..cubicTo(
        size.width * 0.22,
        0,
        size.width * 0.48,
        size.height * 1.20,
        size.width * 0.72,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        0,
        size.width,
        size.height * 0.20,
      );

    canvas.drawPath(curva, pincel);
  }

  @override
  bool shouldRepaint(
    covariant _CurvaEvaluacionesSuperior oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

// =====================================
// CURVA INFERIOR
// =====================================

class _CurvaEvaluacionesInferior extends CustomPainter {
  final Color color;

  _CurvaEvaluacionesInferior({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final curva = Path()
      ..moveTo(
        size.width * 0.52,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.77,
        size.height * 0.30,
        size.width,
        size.height * 0.05,
      )
      ..lineTo(
        size.width,
        size.height,
      )
      ..close();

    canvas.drawPath(curva, pincel);
  }

  @override
  bool shouldRepaint(
    covariant _CurvaEvaluacionesInferior oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
