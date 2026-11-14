import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import 'package:brujula_uni/service/perfilService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';
import 'package:brujula_uni/vistas/perfil/editarPerfil.dart';
import 'package:brujula_uni/vistas/perfil/configuracion.dart';

// =====================================================
// MI IDENTIDAD — BRÚJULA UNI
// =====================================================

class Perfil extends StatefulWidget {
  final int authId;
  final VoidCallback? cerrarSesion;

  const Perfil({
    super.key,
    required this.authId,
    this.cerrarSesion,
  });

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  late Future<Map<String, dynamic>?> _perfilFuture;

  bool _descargando = false;

  // ===================================================
  // PALETA INSTITUCIONAL
  // ===================================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _secundario => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _acento => BrujulaColores.acento(context);

  Color get _suave => BrujulaColores.superficieDestacada(context);

  Color get _bordeDestacado => BrujulaColores.bordeDestacado(context);

  // ===================================================
  // CICLO DE VIDA
  // ===================================================

  @override
  void initState() {
    super.initState();

    _perfilFuture = PerfilService.getPerfilUsuario(
      widget.authId,
    );
  }

  @override
  void didUpdateWidget(covariant Perfil oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.authId != widget.authId) {
      _actualizar();
    }
  }

  void _actualizar() {
    setState(() {
      _perfilFuture = PerfilService.getPerfilUsuario(
        widget.authId,
      );
    });
  }

  Future<void> _recargar() async {
    final futuro = PerfilService.getPerfilUsuario(
      widget.authId,
    );

    setState(() {
      _perfilFuture = futuro;
    });

    try {
      await futuro;
    } catch (e) {
      debugPrint('No se pudo recargar el perfil: $e');
    }
  }

  String _valor(dynamic dato, String defecto) {
    final texto = dato?.toString().trim() ?? '';

    return texto.isEmpty ? defecto : texto;
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
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ===================================================
  // NAVEGACIÓN
  // ===================================================

  Future<void> _editar() async {
    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => EditarPerfil(
          authId: widget.authId,
        ),
      ),
    );

    if (!mounted) return;

    if (actualizado == true) {
      _actualizar();
      _mensaje('Perfil actualizado correctamente.');
    }
  }

  Future<void> _configuracion() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ConfiguracionPage(
          cerrarSesion: widget.cerrarSesion,
        ),
      ),
    );
  }

  // ===================================================
  // CURRÍCULUM
  // ===================================================

  void _descargar(String url) {
    if (_descargando) return;

    setState(() {
      _descargando = true;
    });

    FileDownloader.downloadFile(
      url: url,
      name: 'cv.docx',
      onProgress: (nombre, progreso) {
        debugPrint(
          'Descargando CV: '
          '${progreso.toStringAsFixed(0)}%',
        );
      },
      onDownloadCompleted: (ruta) {
        if (!mounted) return;

        setState(() {
          _descargando = false;
        });

        _mensaje('CV descargado correctamente.');
      },
      onDownloadError: (error) {
        debugPrint('Error descargando CV: $error');

        if (!mounted) return;

        setState(() {
          _descargando = false;
        });

        _mensaje('No se pudo descargar el CV.');
      },
    );
  }

  // ===================================================
  // ESTILOS DE TEXTO
  // ===================================================

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

  TextStyle _estiloSecundario(double size) {
    return BrujulaTipografia.secundario(
      size: size,
    ).copyWith(
      color: _secundario,
    );
  }

  // ===================================================
  // AVATAR
  // ===================================================

  Widget _avatarVacio() {
    return Container(
      color: _suave,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        color: _acento,
        size: 43,
      ),
    );
  }

  Widget _avatar(String foto) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _bordeDestacado,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: foto.isEmpty
            ? _avatarVacio()
            : Image.network(
                foto,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => _avatarVacio(),
              ),
      ),
    );
  }

  // ===================================================
  // CABECERA
  // ===================================================

  Widget _cabecera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MI UNIVERSIDAD · MI CAMINO',
                style: BrujulaTipografia.etiqueta().copyWith(
                  color: _acento,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Mi identidad',
                style: _principal(27),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _configuracion,
          tooltip: 'Configuración',
          style: IconButton.styleFrom(
            backgroundColor: _superficie,
            side: BorderSide(
              color: _borde,
            ),
            minimumSize: const Size(44, 44),
          ),
          icon: Icon(
            Icons.settings_outlined,
            color: _acento,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ===================================================
  // IDENTIDAD DEL ESTUDIANTE
  // ===================================================

  Widget _identidad(Map<String, dynamic> perfil) {
    final nombres = _valor(
      perfil['nombres'],
      '',
    );

    final apellidos = _valor(
      perfil['apellidos'],
      '',
    );

    final nombreCompleto = '$nombres $apellidos'.trim();

    final nombre =
        nombreCompleto.isEmpty ? 'Mi perfil universitario' : nombreCompleto;

    final carrera = _valor(
      perfil['carrera'],
      'Carrera no especificada',
    );

    final foto = _valor(
      perfil['foto'],
      '',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatar(foto),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: _seccion(20),
              ),
              const SizedBox(height: 6),
              Text(
                carrera,
                style: _estiloSecundario(12.5),
              ),
              const SizedBox(height: 9),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _editar,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: _acento,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Editar mi perfil',
                          style: BrujulaTipografia.boton(
                            size: 12,
                          ).copyWith(
                            color: _acento,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================================================
  // TARJETAS DE IDENTIDAD
  // ===================================================

  Widget _tarjetaIdentidad({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required bool destacada,
    required VoidCallback accion,
  }) {
    return Expanded(
      child: Material(
        color: destacada ? _suave : _superficie,
        borderRadius: BorderRadius.circular(17),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: accion,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            height: 147,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: destacada ? _bordeDestacado : _borde,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icono,
                  color: _acento,
                  size: 24,
                ),
                const Spacer(),
                Text(
                  titulo,
                  style: _tarjeta(14),
                ),
                const SizedBox(height: 5),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _estiloSecundario(11.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================
  // BIOGRAFÍA
  // ===================================================

  Widget _biografia(String contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Un poco sobre mí',
            style: _seccion(16),
          ),
          const SizedBox(height: 10),
          Text(
            contenido,
            style: BrujulaTipografia.cuerpo(
              size: 13.5,
            ).copyWith(
              color: _secundario,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // PROYECTO PERSONAL
  // ===================================================

  Widget _proyectoPersonal(String contenido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MI PROYECTO PERSONAL',
          style: BrujulaTipografia.etiqueta().copyWith(
            color: _acento,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          contenido,
          style: BrujulaTipografia.cuerpo(
            size: 13,
          ).copyWith(
            color: _secundario,
          ),
        ),
      ],
    );
  }

  // ===================================================
  // CURRÍCULUM
  // ===================================================

  Widget _cv(String url) {
    return Material(
      color: _superficie,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _descargando ? null : () => _descargar(url),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borde,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: _acento,
                size: 24,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Mi currículum',
                  style: _tarjeta(14),
                ),
              ),
              if (_descargando)
                SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _acento,
                  ),
                )
              else
                Icon(
                  Icons.download_rounded,
                  color: _acento,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================
  // CONTENIDO PRINCIPAL
  // ===================================================

  Widget _contenido(Map<String, dynamic> perfil) {
    final biografia = _valor(
      perfil['biografia'],
      'Todavía no has registrado tu biografía.',
    );

    final proyecto = _valor(
      perfil['proyecto_vida'],
      'Explora tus objetivos y aspiraciones.',
    );

    final cv = _valor(
      perfil['url_cv'],
      '',
    );

    return RefreshIndicator(
      color: _acento,
      onRefresh: _recargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          19,
          22,
          19,
          32,
        ),
        children: [
          _cabecera(),
          const SizedBox(height: 28),
          _identidad(perfil),
          const SizedBox(height: 29),
          Row(
            children: [
              _tarjetaIdentidad(
                icono: Icons.fingerprint_rounded,
                titulo: 'Quién soy',
                descripcion: 'Biografía e intereses',
                destacada: false,
                accion: _editar,
              ),
              const SizedBox(width: 11),
              _tarjetaIdentidad(
                icono: Icons.explore_outlined,
                titulo: 'Hacia dónde voy',
                descripcion: 'Mi proyecto personal',
                destacada: true,
                accion: _editar,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _biografia(biografia),
          const SizedBox(height: 19),
          _proyectoPersonal(proyecto),
          if (cv.isNotEmpty) ...[
            const SizedBox(height: 19),
            _cv(cv),
          ],
        ],
      ),
    );
  }

  // ===================================================
  // ERROR Y CARGA
  // ===================================================

  Widget _estadoError({
    required String mensaje,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: _acento,
              size: 37,
            ),
            const SizedBox(height: 13),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: _seccion(16),
            ),
            const SizedBox(height: 13),
            TextButton.icon(
              onPressed: _actualizar,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Volver a intentar'),
              style: TextButton.styleFrom(
                foregroundColor: _acento,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // PANTALLA PRINCIPAL
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: BrujulaTipografia.aplicar(
        Theme.of(context),
      ),
      child: Scaffold(
        backgroundColor: _fondo,
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _perfilFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: _acento,
                ),
              );
            }

            if (snapshot.hasError) {
              return _estadoError(
                mensaje: 'No se pudo cargar tu perfil.',
              );
            }

            final perfil = snapshot.data;

            if (perfil == null) {
              return _estadoError(
                mensaje: 'Perfil no disponible.',
              );
            }

            return _contenido(perfil);
          },
        ),
      ),
    );
  }
}
