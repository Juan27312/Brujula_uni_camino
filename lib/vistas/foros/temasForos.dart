
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:brujula_uni/service/foroService.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:brujula_uni/vistas/foros/mensajesForo.dart';

class ForosPage extends StatefulWidget {
  final String text;
  final int userId;

  const ForosPage({
    super.key,
    required this.text,
    required this.userId,
  });

  @override
  State<ForosPage> createState() => _ForosPageState();
}

class _ForosPageState extends State<ForosPage> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _cargarTemas();
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

  Color get _destacado =>
      BrujulaColores.superficieDestacada(context);

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
    double altura = 1.5,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: peso,
      color: color ?? _texto,
      height: altura,
    );
  }

  // =====================================================
  // CONSULTAR TEMAS
  // =====================================================

  void _cargarTemas() {
    _itemsFuture = Foroservice.getTemasForos();
  }

  Future<void> _actualizarTemas() async {
    setState(_cargarTemas);

    try {
      await _itemsFuture;
    } catch (_) {
      // El estado de error se presenta en pantalla.
    }
  }

  // =====================================================
  // ABRIR UNA CONVERSACIÓN
  // =====================================================

  void _abrirTema(Map<String, dynamic> tema) {
    final id = tema['id'];

    if (id is! int) return;

    final titulo =
        (tema['titulo'] ?? 'Conversación').toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MensajesForo(
          itemId: id,
          texto: titulo,
          userId: widget.userId,
        ),
      ),
    );
  }

  // =====================================================
  // ENCABEZADO PRINCIPAL
  // =====================================================

  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        23,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal.
          Text(
            'Foros de la comunidad UNI',
            style: _jakarta(
              25,
              peso: FontWeight.w700,
              altura: 1.22,
            ),
          ),

          const SizedBox(height: 10),

          // Descripción breve del propósito.
          Text(
            'Comparte tus opiniones e intercambia ideas '
            'con otros estudiantes de la UNI.',
            style: _inter(
              14,
              color: _secundario,
              altura: 1.55,
            ),
          ),

          const SizedBox(height: 29),

          // Separación entre introducción y temas.
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: _acento,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Temas de conversación',
            style: _jakarta(
              18,
              peso: FontWeight.w700,
              altura: 1.3,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Explora los temas y participa en la conversación.',
            style: _inter(
              12.5,
              color: _secundario,
              altura: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TARJETA EDITORIAL DE CADA TEMA
  // =====================================================

  Widget _tarjetaTema(
    Map<String, dynamic> tema,
    int indice,
  ) {
    final titulo =
        (tema['titulo'] ?? 'Sin título').toString().trim();

    final descripcion =
        (tema['descripcion'] ?? '').toString().trim();

    final tituloVisible = titulo.isEmpty
        ? 'Tema de conversación'
        : titulo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: _superficie,
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _abrirTema(tema),
          borderRadius: BorderRadius.circular(13),
          splashColor: _acento.withValues(alpha: 0.07),
          highlightColor: _acento.withValues(alpha: 0.035),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _borde,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------
                // CONTENIDO DEL TEMA
                // -----------------------------------------

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    17,
                    18,
                    17,
                    17,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Identificación visual del tema.
                      Row(
                        children: [
                          Container(
                            width: 27,
                            height: 27,
                            decoration: BoxDecoration(
                              color: _destacado,
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                            child: Icon(
                              Icons.forum_outlined,
                              size: 16,
                              color: _acento,
                            ),
                          ),

                          const SizedBox(width: 9),

                          Text(
                            'TEMA DE CONVERSACIÓN',
                            style: _inter(
                              10,
                              peso: FontWeight.w600,
                              color: _secundario,
                              altura: 1.3,
                            ).copyWith(
                              letterSpacing: 0.55,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // La pregunta es el elemento
                      // de mayor importancia.
                      Text(
                        tituloVisible,
                        style: _jakarta(
                          17,
                          peso: FontWeight.w700,
                          altura: 1.38,
                        ),
                      ),

                      if (descripcion.isNotEmpty) ...[
                        const SizedBox(height: 10),

                        Text(
                          descripcion,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _inter(
                            13,
                            color: _secundario,
                            altura: 1.55,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // -----------------------------------------
                // ACCIÓN DE NAVEGACIÓN
                // -----------------------------------------

                Divider(
                  color: _borde,
                  height: 1,
                  thickness: 1,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Ver conversación',
                        style: _inter(
                          13,
                          peso: FontWeight.w600,
                          color: _acento,
                          altura: 1.3,
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                        color: _acento,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ESTADOS VACÍOS Y ERRORES
  // =====================================================

  Widget _mensajeEstado({
    required IconData icono,
    required String titulo,
    required String descripcion,
    bool reintentar = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 27,
        vertical: 43,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 37,
              color: _secundario,
            ),

            const SizedBox(height: 16),

            Text(
              titulo,
              textAlign: TextAlign.center,
              style: _jakarta(
                17,
                peso: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: _inter(
                13,
                color: _secundario,
                altura: 1.55,
              ),
            ),

            if (reintentar) ...[
              const SizedBox(height: 22),

              OutlinedButton.icon(
                onPressed: _actualizarTemas,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
                label: Text(
                  'Volver a intentar',
                  style: _inter(
                    13,
                    peso: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _acento,
                  side: BorderSide(
                    color: _borde,
                  ),
                  minimumSize: const Size(175, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // CONTENIDO PRINCIPAL
  // =====================================================

  Widget _contenidoTemas(
    List<Map<String, dynamic>> temas,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        bottom: 36,
      ),
      children: [
        _encabezado(),

        if (temas.isEmpty)
          _mensajeEstado(
            icono: Icons.forum_outlined,
            titulo: 'Todavía no hay conversaciones',
            descripcion:
                'Los nuevos temas estarán disponibles '
                'en esta sección.',
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              children: [
                for (int i = 0; i < temas.length; i++)
                  _tarjetaTema(temas[i], i),
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
    return Scaffold(
      backgroundColor: _fondo,

      // Se conserva la barra y el título enviados
      // por la navegación actual.
      appBar: AppBar(
        backgroundColor: BrujulaColores.rojoUNI,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: RefreshIndicator(
        color: _acento,
        onRefresh: _actualizarTemas,

        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: _acento,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  _encabezado(),

                  _mensajeEstado(
                    icono: Icons.wifi_off_outlined,
                    titulo: 'No se pudieron mostrar los temas',
                    descripcion:
                        'Compruebe su conexión e inténtelo nuevamente.',
                    reintentar: true,
                  ),
                ],
              );
            }

            final temas = snapshot.data ?? [];

            return _contenidoTemas(temas);
          },
        ),
      ),
    );
  }
}
