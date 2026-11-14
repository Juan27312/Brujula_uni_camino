import 'package:flutter/material.dart';
import 'package:brujula_uni/service/itemService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:brujula_uni/vistas/item1/subItem.dart';
import 'package:brujula_uni/vistas/perfil/perfil.dart';

class ItemMenusPage extends StatefulWidget {
  final int authId;
  final int itemId;
  final String texto;

  const ItemMenusPage({
    super.key,
    required this.itemId,
    required this.authId,
    required this.texto,
  });

  @override
  State<ItemMenusPage> createState() => _ItemMenusPageState();
}

class _ItemMenusPageState extends State<ItemMenusPage> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _itemsFuture = ItemService.getItems(widget.itemId);
  }

  void _reintentar() {
    setState(_cargar);
  }

  // =====================================
  // ILUSTRACIONES POR SECCIÓN
  // =====================================

  String get _ilustracionSeccion {
    final titulo = widget.texto.toLowerCase();

    if (titulo.contains('inspiraci')) {
      return 'assets/ilustraciones/inspiracion.png';
    }

    if (titulo.contains('personal')) {
      return 'assets/ilustraciones/desarrollo_personal.png';
    }

    if (titulo.contains('académico') || titulo.contains('academico')) {
      return 'assets/ilustraciones/desarrollo_academico.png';
    }

    if (titulo.contains('profesional')) {
      return 'assets/ilustraciones/desarrollo_profesional.png';
    }

    return 'assets/ilustraciones/inspiracion.png';
  }

  // =====================================
  // INTRODUCCIÓN DE CADA SECCIÓN
  // =====================================

  String get _introduccion {
    final titulo = widget.texto.toLowerCase();

    if (titulo.contains('inspiraci')) {
      return 'Descubre recursos académicos y herramientas '
          'de orientación para impulsar tu formación en la UNI.';
    }

    if (titulo.contains('personal')) {
      return 'Descubre oportunidades para fortalecer '
          'tus capacidades y crecer como persona.';
    }

    if (titulo.contains('académico') || titulo.contains('academico')) {
      return 'Explora conocimientos y recursos '
          'que acompañan tu formación universitaria.';
    }

    if (titulo.contains('profesional')) {
      return 'Fortalece tus competencias, descubre '
          'oportunidades y construye tu futuro profesional.';
    }

    return 'Explora recursos y oportunidades '
        'para acompañar tu formación integral.';
  }

  // =====================================
  // ÍCONOS DE LAS OPCIONES
  // =====================================

  IconData _icono(String titulo) {
    final t = titulo.toLowerCase();

    if (t.contains('plan de estudio')) {
      return Icons.menu_book_outlined;
    }
    if (t.contains('crédito') || t.contains('credito')) {
      return Icons.bar_chart_rounded;
    }
    if (t.contains('calendario')) {
      return Icons.calendar_month_outlined;
    }
    if (t.contains('artículo') || t.contains('articulo')) {
      return Icons.article_outlined;
    }
    if (t.contains('ponencia') || t.contains('congreso')) {
      return Icons.groups_outlined;
    }
    if (t.contains('habilidad')) {
      return Icons.psychology_outlined;
    }
    if (t.contains('reglamento')) {
      return Icons.gavel_outlined;
    }
    if (t.contains('trámite') || t.contains('tramite')) {
      return Icons.assignment_outlined;
    }
    if (t.contains('biblioteca')) {
      return Icons.local_library_outlined;
    }
    if (t.contains('mensaje')) {
      return Icons.campaign_outlined;
    }
    if (t.contains('consulta')) {
      return Icons.forum_outlined;
    }
    if (t.contains('red de estudiantes')) {
      return Icons.people_outline_rounded;
    }
    if (t.contains('perfil')) {
      return Icons.person_outline_rounded;
    }

    return Icons.auto_stories_outlined;
  }

  // =====================================
  // DESCRIPCIONES DE LAS OPCIONES
  // =====================================

  String _descripcion(String titulo) {
    final t = titulo.toLowerCase();

    if (t.contains('plan de estudio')) {
      return 'Conoce la estructura de tu carrera, '
          'cursos y requisitos.';
    }
    if (t.contains('crédito') || t.contains('credito')) {
      return 'Consulta información sobre tu avance académico.';
    }
    if (t.contains('calendario')) {
      return 'Consulta las fechas importantes del ciclo académico.';
    }
    if (t.contains('artículo') || t.contains('articulo')) {
      return 'Explora publicaciones y conocimientos de interés.';
    }
    if (t.contains('ponencia') || t.contains('congreso')) {
      return 'Descubre encuentros y espacios académicos.';
    }
    if (t.contains('habilidad')) {
      return 'Fortalece capacidades para tu desarrollo integral.';
    }
    if (t.contains('reglamento')) {
      return 'Conoce las disposiciones de la vida universitaria.';
    }
    if (t.contains('trámite') || t.contains('tramite')) {
      return 'Encuentra orientación sobre gestiones académicas.';
    }
    if (t.contains('biblioteca')) {
      return 'Accede a recursos y materiales para aprender.';
    }
    if (t.contains('mensaje')) {
      return 'Conoce las novedades y comunicaciones disponibles.';
    }
    if (t.contains('consulta')) {
      return 'Encuentra información y orientación.';
    }
    if (t.contains('red de estudiantes')) {
      return 'Explora espacios de participación estudiantil.';
    }
    if (t.contains('perfil')) {
      return 'Consulta tu información personal.';
    }

    return 'Descubre los contenidos de esta sección.';
  }

  // =====================================
  // NAVEGACIÓN ORIGINAL
  // =====================================

  void _abrirSubItem(Map<String, dynamic> item) {
    final id = item['id'];

    if (id is! num) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubItemPage(
          item_Id: id.toInt(),
          texto: item['descripcion']?.toString() ?? 'Sin descripción',
          item_Padre: widget.itemId,
          authId: widget.authId,
        ),
      ),
    );
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Perfil(
          authId: widget.authId,
        ),
      ),
    );
  }

  // =====================================
  // ENCABEZADO CON ILUSTRACIÓN
  // =====================================

  Widget _encabezado() {
    final fondo = BrujulaColores.fondo(context);
    final acento = BrujulaColores.acento(context);
    final secundario = BrujulaColores.secundario(context);
    final oscuro = BrujulaColores.esOscuro(context);

    return SizedBox(
      height: 206,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Ilustración específica de la sección.
          Positioned(
            right: -25,
            top: 5,
            width: 205,
            height: 165,
            child: IgnorePointer(
              child: Opacity(
                opacity: oscuro ? 0.38 : 0.65,
                child: Image.asset(
                  _ilustracionSeccion,
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

          // Degradado para proteger la lectura.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      fondo,
                      fondo.withOpacity(0.99),
                      fondo.withOpacity(0.94),
                      fondo.withOpacity(0.30),
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
                    color: BrujulaColores.superficieDestacada(context),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'EXPLORA TU RUTA',
                    style: BrujulaTipografia.etiqueta(
                      color: acento,
                    ).copyWith(
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  widget.texto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: BrujulaTipografia.principal(
                    size: 27,
                    color: BrujulaColores.texto(context),
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 310,
                  ),
                  child: Text(
                    _introduccion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: BrujulaTipografia.cuerpo(
                      size: 13,
                      color: secundario,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Curva decorativa superior.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 29,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CurvaSuperiorPainter(
                  color: acento.withOpacity(
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
  // TARJETAS COMPACTAS
  // =====================================

  Widget _tarjeta({
    required String titulo,
    required VoidCallback onTap,
  }) {
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
                  color: BrujulaColores.iconoFondo(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _icono(titulo),
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
                        color: texto,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _descripcion(titulo),
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

  Widget _opciones(
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      children: [
        for (final item in items) ...[
          _tarjeta(
            titulo: item['descripcion']?.toString() ?? 'Sin descripción',
            onTap: () => _abrirSubItem(item),
          ),
          const SizedBox(height: 11),
        ],

        // Se conserva el acceso especial a Perfil.
        if (widget.itemId == 2) ...[
          _tarjeta(
            titulo: 'Perfil',
            onTap: _abrirPerfil,
          ),
          const SizedBox(height: 11),
        ],
      ],
    );
  }

  // =====================================
  // CARGA VISUAL INTEGRADA
  // =====================================

  Widget _cargando() {
    final superficie = BrujulaColores.superficie(context);
    final borde = BrujulaColores.borde(context);
    final suave = BrujulaColores.iconoFondo(context);

    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          Container(
            height: 84,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: superficie,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borde),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: suave,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 11,
                        width: 132,
                        decoration: BoxDecoration(
                          color: suave,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: suave.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
        ],
      ],
    );
  }

  // =====================================
  // ERROR DE CARGA
  // =====================================

  Widget _error() {
    final acento = BrujulaColores.acento(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 30,
            color: acento,
          ),
          const SizedBox(height: 12),
          Text(
            'No pudimos cargar los contenidos.',
            textAlign: TextAlign.center,
            style: BrujulaTipografia.seccion(
              size: 16,
              color: BrujulaColores.texto(context),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _reintentar,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: TextButton.styleFrom(
              foregroundColor: acento,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty && widget.itemId != 2) {
      return Text(
        'Todavía no hay contenidos disponibles '
        'en esta sección.',
        style: BrujulaTipografia.cuerpo(
          size: 13,
          color: BrujulaColores.secundario(context),
        ),
      );
    }

    return _opciones(items);
  }

  // =====================================
  // PANTALLA PRINCIPAL
  // =====================================

  @override
  Widget build(BuildContext context) {
    final fondo = BrujulaColores.fondo(context);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: Text(
          widget.texto,
          style: BrujulaTipografia.seccion(
            size: 17,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: COLORBASE,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => Navigator.pop(context),
        ),
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
                  painter: _CurvaInferiorPainter(
                    color: BrujulaColores.acento(context).withOpacity(0.055),
                  ),
                ),
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _encabezado(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        19,
                        8,
                        19,
                        30,
                      ),
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? _cargando()
                          : snapshot.hasError
                              ? _error()
                              : _contenido(
                                  snapshot.data ?? [],
                                ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================
// CURVA DECORATIVA SUPERIOR
// =====================================

class _CurvaSuperiorPainter extends CustomPainter {
  final Color color;

  _CurvaSuperiorPainter({
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
    covariant _CurvaSuperiorPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

// =====================================
// CURVA DECORATIVA INFERIOR
// =====================================

class _CurvaInferiorPainter extends CustomPainter {
  final Color color;

  _CurvaInferiorPainter({
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
    covariant _CurvaInferiorPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}
