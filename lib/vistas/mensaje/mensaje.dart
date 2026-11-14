import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:brujula_uni/service/mensajeService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class MensajeSemanalPage extends StatefulWidget {
  const MensajeSemanalPage({super.key});

  @override
  State<MensajeSemanalPage> createState() => _MensajeSemanalPageState();
}

class _MensajeSemanalPageState extends State<MensajeSemanalPage> {
  late Future<List<Map<String, dynamic>>> _mensajesFuture;

  // =====================================================
  // PALETA INSTITUCIONAL
  // =====================================================

  Color get _fondo => BrujulaColores.fondo(context);

  Color get _superficie => BrujulaColores.superficie(context);

  Color get _texto => BrujulaColores.texto(context);

  Color get _secundario => BrujulaColores.secundario(context);

  Color get _borde => BrujulaColores.borde(context);

  Color get _acento => BrujulaColores.acento(context);

  Color get _suave => BrujulaColores.superficieDestacada(context);

  // =====================================================
  // CICLO DE VIDA
  // =====================================================

  @override
  void initState() {
    super.initState();
    _mensajesFuture = mensajeService.getMensajeSemanal();
  }

  // =====================================================
  // ACTUALIZAR
  // =====================================================

  Future<void> _actualizar() async {
    final futuro = mensajeService.getMensajeSemanal();

    setState(() {
      _mensajesFuture = futuro;
    });

    try {
      await futuro;
    } catch (e) {
      debugPrint('Error actualizando mensajes semanales: $e');
    }
  }

  // =====================================================
  // TIPOGRAFÍA
  // =====================================================

  TextStyle _principal(double size) {
    return BrujulaTipografia.principal(
      size: size,
    ).copyWith(
      color: _texto,
    );
  }

  TextStyle _titulo(double size) {
    return BrujulaTipografia.seccion(
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

  // =====================================================
  // FORMATO DE FECHA
  // =====================================================

  String _fecha(dynamic valor) {
    if (valor == null) return '';

    final original = valor.toString().trim();

    if (original.isEmpty) return '';

    final fecha = DateTime.tryParse(original);

    if (fecha == null) {
      return original;
    }

    String dosDigitos(int numero) => numero.toString().padLeft(2, '0');

    return '${dosDigitos(fecha.day)}/'
        '${dosDigitos(fecha.month)}/'
        '${fecha.year}';
  }

  // =====================================================
  // ESTADO VACÍO O DE ERROR
  // =====================================================

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
            vertical: 30,
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _suave,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icono,
                  size: 28,
                  color: _acento,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                titulo,
                style: _titulo(17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 9),
              Text(
                descripcion,
                style: _cuerpo(13),
                textAlign: TextAlign.center,
              ),
              if (mostrarReintentar) ...[
                const SizedBox(height: 17),
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

  // =====================================================
  // IMAGEN DEL MENSAJE
  // =====================================================

  Widget _imagen(String url) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(17),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: _suave,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: _secundario,
                  size: 32,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, progreso) {
            if (progreso == null) return child;

            return Container(
              color: _suave,
              child: Center(
                child: CircularProgressIndicator(
                  color: _acento,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // ESTILO MARKDOWN
  // =====================================================

  MarkdownStyleSheet _estiloMarkdown() {
    final cuerpo = BrujulaTipografia.cuerpo(
      size: 13.5,
    ).copyWith(
      color: _texto,
      height: 1.65,
    );

    return MarkdownStyleSheet(
      p: cuerpo,
      h1: _principal(20),
      h2: _titulo(18),
      h3: _titulo(16),
      h4: _titulo(15),
      h5: _titulo(14),
      h6: _titulo(13),
      strong: cuerpo.copyWith(
        fontWeight: FontWeight.w700,
      ),
      em: cuerpo.copyWith(
        fontStyle: FontStyle.italic,
      ),
      listBullet: cuerpo,
      blockquote: cuerpo.copyWith(
        color: _secundario,
      ),
      blockquoteDecoration: BoxDecoration(
        color: _suave,
        borderRadius: BorderRadius.circular(9),
      ),
      a: cuerpo.copyWith(
        color: _acento,
        decoration: TextDecoration.underline,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _borde,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // TARJETA DE MENSAJE
  // =====================================================

  Widget _tarjetaMensaje(
    Map<String, dynamic> mensaje,
  ) {
    final titulo = mensaje['titulo']?.toString().trim() ?? '';

    final descripcion = mensaje['descripcion']?.toString() ?? '';

    final imagen = mensaje['img_url']?.toString().trim() ?? '';

    final fecha = _fecha(
      mensaje['fecha_publicacion'],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borde,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagen.isNotEmpty) _imagen(imagen),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              17,
              18,
              17,
              19,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      color: _acento,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'MENSAJE SEMANAL',
                      style: BrujulaTipografia.etiqueta().copyWith(
                        color: _acento,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  titulo.isEmpty ? 'Sin título' : titulo,
                  style: _titulo(19),
                ),
                if (descripcion.trim().isNotEmpty) ...[
                  const SizedBox(height: 13),
                  MarkdownBody(
                    data: descripcion,
                    selectable: true,
                    styleSheet: _estiloMarkdown(),
                  ),
                ],
                if (fecha.isNotEmpty) ...[
                  const SizedBox(height: 17),
                  Divider(
                    color: _borde,
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: _secundario,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Publicado: $fecha',
                        style: _cuerpo(11.5),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LISTADO PRINCIPAL
  // =====================================================

  Widget _listaMensajes(
    List<Map<String, dynamic>> mensajes,
  ) {
    return RefreshIndicator(
      color: _acento,
      onRefresh: _actualizar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          22,
          18,
          35,
        ),
        itemCount: mensajes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 23,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPLORAR',
                    style: BrujulaTipografia.etiqueta().copyWith(
                      color: _acento,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Mensaje Semanal',
                    style: _principal(26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Un espacio de reflexión e inspiración '
                    'para acompañar tu desarrollo personal '
                    'y universitario.',
                    style: _cuerpo(13),
                  ),
                ],
              ),
            );
          }

          return _tarjetaMensaje(
            mensajes[index - 1],
          );
        },
      ),
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
        appBar: AppBar(
          backgroundColor: _fondo,
          foregroundColor: _texto,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Mensaje Semanal',
            style: _titulo(17),
          ),
        ),
        body: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _mensajesFuture,
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
                  titulo: 'No se pudieron cargar los mensajes',
                  descripcion: 'Comprueba tu conexión e inténtalo nuevamente.',
                  mostrarReintentar: true,
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _estadoInformativo(
                  icono: Icons.auto_stories_outlined,
                  titulo: 'Sin mensajes disponibles',
                  descripcion: 'Los nuevos mensajes aparecerán aquí '
                      'cuando sean publicados.',
                  mostrarReintentar: true,
                );
              }

              return _listaMensajes(
                snapshot.data!,
              );
            },
          ),
        ),
      ),
    );
  }
}
