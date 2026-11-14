
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:brujula_uni/service/itemService.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

const Color _texto = Color(0xFF252B34);
const Color _secundario = Color(0xFF697483);
const Color _fondo = Color(0xFFF7F7F6);
const Color _dorado = Color(0xFFE6A100);
const Color _linea = Color(0xFFE8E8E6);

// ==================================================
// LISTADO DE PUBLICACIONES
// ==================================================

class SubItemPage extends StatefulWidget {
  final int item_Id;
  final int item_Padre;
  final String texto;
  final int authId;

  const SubItemPage({
    super.key,
    required this.item_Id,
    required this.item_Padre,
    required this.texto,
    required this.authId,
  });

  @override
  State<SubItemPage> createState() => _SubItemPageState();
}

class _SubItemPageState extends State<SubItemPage> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = ItemService.getSubItemsPorItem(
      widget.item_Id,
      widget.item_Padre,
      widget.authId,
    );
  }

  String _fecha(String? valor) {
    if (valor == null || valor.isEmpty) return '';

    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(valor).toLocal());
    } catch (_) {
      return '';
    }
  }

  Future<void> _abrirPublicacion(
    Map<String, dynamic> publicacion,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DetallePublicacionPage(
          publicacion: publicacion,
          authId: widget.authId,
          itemPadre: widget.item_Padre,
        ),
      ),
    );

    if (!mounted) return;

    // Actualizar datos de valoraciones al regresar.
    setState(() {
      _itemsFuture = ItemService.getSubItemsPorItem(
        widget.item_Id,
        widget.item_Padre,
        widget.authId,
      );
    });
  }

  Widget _imagenPublicacion(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 108,
        height: 102,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 108,
          height: 102,
          color: const Color(0xFFECEDEC),
          child: const Icon(
            Icons.image_outlined,
            color: _secundario,
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(Map<String, dynamic> publicacion) {
    final titulo = publicacion['titulo']?.toString() ?? '';
    final subtitulo = publicacion['subtitulo']?.toString() ?? '';
    final imagen = publicacion['img']?.toString() ?? '';
    final fecha = _fecha(
      publicacion['fecha_publicacion']?.toString(),
    );

    final cantidad = (publicacion['totalValoraciones'] as num?)?.toInt() ?? 0;
    final promedio =
        (publicacion['promedioValoraciones'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _abrirPublicacion(publicacion),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagen.isNotEmpty) ...[
                      _imagenPublicacion(imagen),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fecha.isNotEmpty)
                            Text(
                              fecha,
                              style: const TextStyle(
                                color: _secundario,
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(height: 5),
                          Text(
                            titulo,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _texto,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          if (subtitulo.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              subtitulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _secundario,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                const Divider(height: 1, color: _linea),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Icon(
                      cantidad > 0
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: cantidad > 0 ? _dorado : _secundario,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cantidad > 0
                          ? '${promedio.toStringAsFixed(1)}/5'
                          : 'Sin valoraciones',
                      style: const TextStyle(
                        color: _secundario,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Leer publicación',
                      style: TextStyle(
                        color: COLORBASE,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: COLORBASE,
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: COLORBASE,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.texto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: COLORBASE,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudieron cargar las publicaciones.',
              ),
            );
          }

          final publicaciones = snapshot.data ?? [];

          if (publicaciones.isEmpty) {
            return const Center(
              child: Text('No hay publicaciones disponibles.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
            children: [
              Text(
                '${publicaciones.length} ${publicaciones.length == 1 ? 'publicación disponible' : 'publicaciones disponibles'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: _secundario,
                ),
              ),
              const SizedBox(height: 16),
              ...publicaciones.map(_tarjeta),
            ],
          );
        },
      ),
    );
  }
}

// ==================================================
// DETALLE DE PUBLICACIÓN
// ==================================================

class _DetallePublicacionPage extends StatefulWidget {
  final Map<String, dynamic> publicacion;
  final int authId;
  final int itemPadre;

  const _DetallePublicacionPage({
    required this.publicacion,
    required this.authId,
    required this.itemPadre,
  });

  @override
  State<_DetallePublicacionPage> createState() =>
      _DetallePublicacionPageState();
}

class _DetallePublicacionPageState extends State<_DetallePublicacionPage> {
  late Map<String, dynamic> _publicacion;

  final TextEditingController _comentarioController = TextEditingController();

  YoutubePlayerController? _videoController;

  late Future<List<Map<String, dynamic>>> _comentariosFuture;

  int? _idPerfil;
  bool _guardandoValoracion = false;
  bool _enviandoComentario = false;

  @override
  void initState() {
    super.initState();

    _publicacion = Map<String, dynamic>.from(
      widget.publicacion,
    );

    _comentariosFuture = ItemService.getComentarios(
      subItemId: _idPublicacion,
      itemPadre: widget.itemPadre,
    );

    _cargarPerfil();
  }

  int get _idPublicacion => (_publicacion['id'] as num).toInt();

  Future<void> _cargarPerfil() async {
    try {
      final id = await ItemService.obtenerIdPerfil(
        widget.authId,
      );

      if (!mounted) return;

      setState(() => _idPerfil = id);
    } catch (e) {
      debugPrint('Error al obtener perfil: $e');
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _mensaje(String texto, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : COLORBASE,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _fecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(fecha).toLocal());
    } catch (_) {
      return '';
    }
  }

  String _fechaComentario(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '';

    try {
      final valor = fecha.trim();
      final tieneZona = RegExp(
        r'(Z|[+-]\d{2}(:?\d{2})?)$',
        caseSensitive: false,
      ).hasMatch(valor);

      // Las fechas sin zona de fecha_comentario se guardan en UTC.
      final fechaUtc = DateTime.parse(
        tieneZona ? valor : '${valor}Z',
      );

      return DateFormat('dd/MM/yyyy HH:mm').format(fechaUtc.toLocal());
    } catch (_) {
      return '';
    }
  }

  String? _youtubeId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|shorts\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );

    return regex.firstMatch(url)?.group(1);
  }

  Future<void> _abrirEnlace(String url) async {
    try {
      final uri = Uri.tryParse(url);

      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        _mensaje('Enlace no válido', error: true);
        return;
      }

      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto) {
        _mensaje('No se pudo abrir el enlace', error: true);
      }
    } catch (_) {
      _mensaje('No se pudo abrir el enlace', error: true);
    }
  }

  void _descargar(String url) {
    FileDownloader.downloadFile(
      url: url,
      name: 'doc.docx',
      onDownloadCompleted: (_) {
        _mensaje('Descargado correctamente');
      },
      onDownloadError: (_) {
        _mensaje(
          'No se pudo descargar el archivo',
          error: true,
        );
      },
    );
  }

  // ==========================================
  // VALORACIONES
  // ==========================================

  Future<void> _guardarValoracion(int nuevaValoracion) async {
    if (_guardandoValoracion) return;

    final anterior = (_publicacion['miValoracion'] as num?)?.toInt() ?? 0;

    if (anterior == nuevaValoracion) return;

    setState(() => _guardandoValoracion = true);

    final guardado = await ItemService.guardarValoracion(
      subItemId: _idPublicacion,
      authId: widget.authId,
      itemPadre: widget.itemPadre,
      valoracion: nuevaValoracion,
    );

    if (!mounted) return;

    setState(() {
      _guardandoValoracion = false;

      if (guardado) {
        final cantidad =
            (_publicacion['totalValoraciones'] as num?)?.toInt() ?? 0;

        final suma =
            (_publicacion['sumaValoraciones'] as num?)?.toDouble() ?? 0.0;

        final nuevaCantidad = cantidad + (anterior == 0 ? 1 : 0);

        final nuevaSuma = suma - anterior + nuevaValoracion;

        _publicacion['miValoracion'] = nuevaValoracion;
        _publicacion['totalValoraciones'] = nuevaCantidad;
        _publicacion['sumaValoraciones'] = nuevaSuma;
        _publicacion['promedioValoraciones'] =
            nuevaCantidad > 0 ? nuevaSuma / nuevaCantidad : 0.0;
      }
    });

    _mensaje(
      guardado
          ? 'Valoración guardada correctamente'
          : 'No se pudo guardar la valoración',
      error: !guardado,
    );
  }

  Widget _valoraciones() {
    final seleccion = (_publicacion['miValoracion'] as num?)?.toInt() ?? 0;

    final cantidad = (_publicacion['totalValoraciones'] as num?)?.toInt() ?? 0;

    final promedio =
        (_publicacion['promedioValoraciones'] as num?)?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué tan útil te resultó este contenido?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _texto,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tu valoración',
          style: TextStyle(
            fontSize: 12,
            color: _secundario,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ...List.generate(5, (index) {
              final numero = index + 1;

              return Semantics(
                label: '$numero de 5 estrellas',
                button: true,
                selected: numero == seleccion,
                child: InkWell(
                  onTap: _guardandoValoracion
                      ? null
                      : () => _guardarValoracion(numero),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 44,
                    height: 48,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          numero <= seleccion
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          key: ValueKey(numero <= seleccion),
                          color: numero <= seleccion
                              ? _dorado
                              : Colors.grey.shade400,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            if (seleccion > 0)
              Text(
                '$seleccion/5',
                style: const TextStyle(
                  color: _texto,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          _guardandoValoracion
              ? 'Guardando valoración...'
              : seleccion == 0
                  ? 'Selecciona de 1 a 5 estrellas'
                  : 'Puedes modificar tu valoración',
          style: const TextStyle(
            fontSize: 12,
            color: _secundario,
          ),
        ),
        const SizedBox(height: 18),
        const Divider(color: _linea),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Promedio de estudiantes',
                style: TextStyle(
                  color: _secundario,
                  fontSize: 13,
                ),
              ),
            ),
            if (cantidad > 0) ...[
              const Icon(
                Icons.star_rounded,
                color: _dorado,
                size: 19,
              ),
              const SizedBox(width: 4),
              Text(
                '${promedio.toStringAsFixed(1)}/5',
                style: const TextStyle(
                  color: _texto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else
              const Text(
                'Sin valoraciones',
                style: TextStyle(
                  color: _secundario,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        if (cantidad > 0) ...[
          const SizedBox(height: 5),
          Text(
            '$cantidad ${cantidad == 1 ? 'valoración recibida' : 'valoraciones recibidas'}',
            style: const TextStyle(
              color: _secundario,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // COMENTARIOS
  // ==========================================

  void _actualizarComentarios() {
    if (!mounted) return;

    setState(() {
      _comentariosFuture = ItemService.getComentarios(
        subItemId: _idPublicacion,
        itemPadre: widget.itemPadre,
      );
    });
  }

  Future<void> _enviarComentario() async {
    if (_enviandoComentario) return;

    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviandoComentario = true);

    final guardado = await ItemService.agregarComentario(
      subItemId: _idPublicacion,
      itemPadre: widget.itemPadre,
      authId: widget.authId,
      comentario: texto,
    );

    if (!mounted) return;

    setState(() => _enviandoComentario = false);

    if (guardado) {
      _comentarioController.clear();
      _actualizarComentarios();
      _mensaje('Comentario enviado correctamente');
    } else {
      _mensaje(
        'No se pudo enviar el comentario',
        error: true,
      );
    }
  }

  Future<void> _eliminarComentario(int id) async {
    final eliminado = await ItemService.eliminarComentario(
      idComentario: id,
      itemPadre: widget.itemPadre,
    );

    if (!mounted) return;

    if (eliminado) {
      _actualizarComentarios();
    } else {
      _mensaje(
        'No se pudo eliminar el comentario',
        error: true,
      );
    }
  }

  Widget _seccionComentarios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentarios',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _texto,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _comentarioController,
          minLines: 1,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Escribe un comentario...',
            filled: true,
            fillColor: _fondo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _enviandoComentario
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: COLORBASE,
                    ),
                    onPressed: _enviarComentario,
                  ),
          ),
        ),
        const SizedBox(height: 18),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _comentariosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final comentarios = snapshot.data ?? [];

            if (comentarios.isEmpty) {
              return const Text(
                'Sin comentarios aún.',
                style: TextStyle(
                  fontSize: 13,
                  color: _secundario,
                  fontStyle: FontStyle.italic,
                ),
              );
            }

            return Column(
              children: comentarios.map((comentario) {
                final perfil = comentario['perfiles_estudiante'];

                String nombre = 'Estudiante';

                if (perfil is Map) {
                  nombre =
                      '${perfil['nombres'] ?? ''} ${perfil['apellidos'] ?? ''}'
                          .trim();
                }

                final propio = _idPerfil != null &&
                    comentario['estudiante_id'] == _idPerfil;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: const Color(0xFFF1E7E5),
                        child: Text(
                          nombre.isNotEmpty ? nombre[0].toUpperCase() : 'E',
                          style: const TextStyle(
                            color: COLORBASE,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              comentario['comentario']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _fechaComentario(
                                comentario['fecha_comentario']?.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: _secundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (propio)
                        IconButton(
                          tooltip: 'Eliminar comentario',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _eliminarComentario(
                            (comentario['id'] as num).toInt(),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // VIDEO
  // ==========================================

  Widget _video(String url) {
    final id = _youtubeId(url);

    if (id == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _videoController == null
          ? InkWell(
              onTap: () {
                setState(() {
                  _videoController = YoutubePlayerController(
                    initialVideoId: id,
                    flags: const YoutubePlayerFlags(
                      autoPlay: true,
                      mute: false,
                    ),
                  );
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    'https://img.youtube.com/vi/$id/hqdefault.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 62,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          : YoutubePlayer(
              controller: _videoController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: COLORBASE,
            ),
    );
  }

  // ==========================================
  // LECTURA COMPLETA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final titulo = _publicacion['titulo']?.toString() ?? '';
    final subtitulo = _publicacion['subtitulo']?.toString() ?? '';
    final descripcion = _publicacion['descripcion']?.toString() ?? '';
    final imagen = _publicacion['img']?.toString() ?? '';
    final fuente = _publicacion['fuente']?.toString() ?? '';
    final enlace = _publicacion['link']?.toString() ?? '';
    final archivo = _publicacion['archivo']?.toString() ?? '';
    final video = _publicacion['video']?.toString() ?? '';

    final fecha = _fecha(
      _publicacion['fecha_publicacion']?.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _texto,
        elevation: 0,
        title: const Text(
          'Publicación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            36,
          ),
          children: [
            if (fecha.isNotEmpty)
              Text(
                fecha,
                style: const TextStyle(
                  color: _secundario,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: _texto,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.22,
              ),
            ),
            if (subtitulo.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: _secundario,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
            if (imagen.isNotEmpty) ...[
              const SizedBox(height: 21),
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  imagen,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: _fondo,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: _secundario,
                    ),
                  ),
                ),
              ),
            ],
            if (descripcion.isNotEmpty) ...[
              const SizedBox(height: 24),
              MarkdownBody(
                data: descripcion,
                selectable: true,
                onTapLink: (texto, href, titulo) {
                  if (href != null) {
                    _abrirEnlace(href);
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 15,
                    color: _texto,
                    height: 1.6,
                  ),
                  h1: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  blockSpacing: 13,
                  listIndent: 22,
                ),
              ),
            ],
            if (fuente.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Fuente: $fuente',
                style: const TextStyle(
                  fontSize: 12,
                  color: _secundario,
                ),
              ),
            ],
            if (enlace.isNotEmpty) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _abrirEnlace(enlace),
                icon: const Icon(
                  Icons.open_in_new,
                  size: 18,
                ),
                label: const Text('Abrir enlace'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: COLORBASE,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(
                    color: COLORBASE,
                  ),
                ),
              ),
            ],
            if (archivo.isNotEmpty) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _descargar(archivo),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Descargar documento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: COLORBASE,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
            if (_youtubeId(video) != null) ...[
              const SizedBox(height: 24),
              _video(video),
            ],
            const SizedBox(height: 28),
            const Divider(color: _linea),
            const SizedBox(height: 20),
            _valoraciones(),
            const SizedBox(height: 26),
            const Divider(color: _linea),
            const SizedBox(height: 20),
            _seccionComentarios(),
          ],
        ),
      ),
    );
  }
}
