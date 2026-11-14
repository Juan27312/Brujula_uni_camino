import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:brujula_uni/service/evidenciasService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class EvidenciasActividadPage extends StatefulWidget {
  final int actividadId;
  final String actividadTitulo;

  const EvidenciasActividadPage({
    super.key,
    required this.actividadId,
    required this.actividadTitulo,
  });

  @override
  State<EvidenciasActividadPage> createState() =>
      _EvidenciasActividadPageState();
}

class _EvidenciasActividadPageState extends State<EvidenciasActividadPage> {
  final _servicio = EvidenciasService.instancia;

  List<Map<String, dynamic>> _evidencias = [];

  bool _cargando = true;
  bool _ocupado = false;
  String? _error;

  // ==================================================
  // IDENTIDAD VISUAL UNI
  // ==================================================

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
    ).copyWith(color: _texto);
  }

  TextStyle _titulo(double size) {
    return BrujulaTipografia.seccion(
      size: size,
    ).copyWith(color: _texto);
  }

  TextStyle _cuerpo(double size) {
    return BrujulaTipografia.cuerpo(
      size: size,
    ).copyWith(color: _secundario);
  }

  TextStyle _tarjetaTexto(double size) {
    return BrujulaTipografia.tarjeta(
      size: size,
    ).copyWith(color: _texto);
  }

  // ==================================================
  // CICLO DE VIDA
  // ==================================================

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // ==================================================
  // MENSAJES
  // ==================================================

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

  // ==================================================
  // CARGAR EVIDENCIAS
  // ==================================================

  Future<void> _cargar() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await _servicio.listar(
        widget.actividadId,
      );

      if (!mounted) return;

      setState(() {
        _evidencias = datos;
      });
    } catch (e) {
      debugPrint('Error cargando evidencias: $e');

      if (!mounted) return;

      setState(() {
        _error = 'No se pudieron cargar las evidencias.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // ==================================================
  // ADJUNTAR ARCHIVO
  // ==================================================

  Future<void> _adjuntarArchivo() async {
    if (_ocupado || _cargando) return;

    setState(() {
      _ocupado = true;
    });

    try {
      final guardado = await _servicio.seleccionarYSubir(
        actividadId: widget.actividadId,
      );

      if (!mounted) return;

      if (guardado) {
        await _cargar();

        if (!mounted) return;

        if (_error == null) {
          _mensaje('Guardado correctamente.');
        } else {
          _mensaje(
            'Archivo guardado. No se pudo actualizar la lista.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error adjuntando evidencia: $e');

      _mensaje('No se pudo adjuntar el archivo.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // ==================================================
  // AGREGAR ENLACE
  // ==================================================

  Future<void> _agregarEnlace() async {
    if (_ocupado || _cargando) return;

    final titulo = TextEditingController();
    final enlace = TextEditingController();
    final formulario = GlobalKey<FormState>();

    final datos = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        final texto = BrujulaColores.texto(ctx);
        final secundario = BrujulaColores.secundario(ctx);
        final acento = BrujulaColores.acento(ctx);
        final superficie = BrujulaColores.superficie(ctx);

        return Theme(
          data: BrujulaTipografia.aplicar(
            Theme.of(ctx),
          ),
          child: AlertDialog(
            backgroundColor: superficie,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'Añadir enlace',
              style: BrujulaTipografia.seccion(
                size: 18,
              ).copyWith(color: texto),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registra un enlace que respalde '
                      'la actividad realizada.',
                      style: BrujulaTipografia.cuerpo(
                        size: 12.5,
                      ).copyWith(color: secundario),
                    ),
                    const SizedBox(height: 17),
                    TextFormField(
                      controller: titulo,
                      maxLength: 200,
                      textCapitalization: TextCapitalization.sentences,
                      style: BrujulaTipografia.cuerpo(
                        size: 14,
                      ).copyWith(color: texto),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la evidencia',
                        labelStyle: TextStyle(
                          color: secundario,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: acento,
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: acento,
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
                    const SizedBox(height: 13),
                    TextFormField(
                      controller: enlace,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      style: BrujulaTipografia.cuerpo(
                        size: 14,
                      ).copyWith(color: texto),
                      decoration: InputDecoration(
                        labelText: 'Enlace HTTPS',
                        hintText: 'https://...',
                        labelStyle: TextStyle(
                          color: secundario,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: acento,
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: acento,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (valor) {
                        final uri = Uri.tryParse(
                          valor?.trim() ?? '',
                        );

                        if (uri == null ||
                            uri.scheme != 'https' ||
                            uri.host.isEmpty) {
                          return 'Ingresa un enlace HTTPS válido.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: secundario,
                ),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (formulario.currentState!.validate()) {
                    Navigator.pop(ctx, {
                      'titulo': titulo.text.trim(),
                      'enlace': enlace.text.trim(),
                    });
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
      titulo.dispose();
      enlace.dispose();
    });

    if (!mounted || datos == null || _ocupado) return;

    setState(() {
      _ocupado = true;
    });

    try {
      await _servicio.agregarEnlace(
        actividadId: widget.actividadId,
        titulo: datos['titulo']!,
        enlace: datos['enlace']!,
      );

      if (!mounted) return;

      await _cargar();

      if (!mounted) return;

      if (_error == null) {
        _mensaje('Guardado correctamente.');
      } else {
        _mensaje(
          'Enlace guardado. No se pudo actualizar la lista.',
        );
      }
    } catch (e) {
      debugPrint('Error guardando enlace: $e');
      _mensaje('No se pudo guardar el enlace.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // ==================================================
  // ABRIR EVIDENCIA
  // ==================================================

  Future<void> _abrir(
    Map<String, dynamic> evidencia,
  ) async {
    if (_ocupado) return;

    try {
      final id = (evidencia['id'] as num).toInt();
      final url = await _servicio.obtenerUrl(id);
      final uri = Uri.tryParse(url);

      if (uri == null ||
          !await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          )) {
        throw StateError('No se pudo abrir la URL.');
      }
    } catch (e) {
      debugPrint('Error abriendo evidencia: $e');
      _mensaje('No se pudo abrir la evidencia.');
    }
  }

  // ==================================================
  // ELIMINAR EVIDENCIA
  // ==================================================

  Future<void> _eliminar(
    Map<String, dynamic> evidencia,
  ) async {
    if (_ocupado) return;

    final confirmar = await showDialog<bool>(
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
                  'Eliminar evidencia',
                  style: BrujulaTipografia.seccion(
                    size: 18,
                  ).copyWith(
                    color: BrujulaColores.texto(ctx),
                  ),
                ),
                content: Text(
                  '¿Deseas eliminar esta evidencia?',
                  style: BrujulaTipografia.cuerpo(
                    size: 13,
                  ).copyWith(
                    color: BrujulaColores.secundario(ctx),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx, false);
                    },
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx, true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: BrujulaColores.rojoUNI,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;

    if (!confirmar || !mounted) return;

    setState(() {
      _ocupado = true;
    });

    try {
      await _servicio.eliminar(
        (evidencia['id'] as num).toInt(),
      );

      if (!mounted) return;

      await _cargar();

      if (!mounted) return;

      if (_error == null) {
        _mensaje('Evidencia eliminada.');
      } else {
        _mensaje(
          'Evidencia eliminada. No se pudo actualizar la lista.',
        );
      }
    } catch (e) {
      debugPrint('Error eliminando evidencia: $e');
      _mensaje('No se pudo eliminar la evidencia.');
    } finally {
      if (mounted) {
        setState(() {
          _ocupado = false;
        });
      }
    }
  }

  // ==================================================
  // ENCABEZADO DE LA ACTIVIDAD
  // ==================================================

  Widget _encabezadoActividad() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _suave,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt_rounded,
                color: _acento,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ACTIVIDAD',
                style: BrujulaTipografia.etiqueta().copyWith(
                  color: _acento,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            widget.actividadTitulo,
            style: _principal(19),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí puedes reunir los documentos '
            'y enlaces relacionados con esta actividad.',
            style: _cuerpo(12.5),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // ACCIONES PARA REGISTRAR EVIDENCIAS
  // ==================================================

  Widget _accionesRegistro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Añadir evidencia',
          style: _titulo(18),
        ),
        const SizedBox(height: 7),
        Text(
          'Selecciona cómo deseas respaldar tu actividad.',
          style: _cuerpo(12.5),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _ocupado || _cargando ? null : _adjuntarArchivo,
            icon: _ocupado
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.attach_file_rounded,
                    size: 20,
                  ),
            label: Text(
              _ocupado ? 'Procesando...' : 'Adjuntar archivo',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: BrujulaColores.rojoUNI,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Center(
          child: TextButton.icon(
            onPressed: _ocupado || _cargando ? null : _agregarEnlace,
            icon: const Icon(
              Icons.link_rounded,
              size: 19,
            ),
            label: const Text('O añadir un enlace'),
            style: TextButton.styleFrom(
              foregroundColor: _acento,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Formatos indicados: PDF, Word e imágenes. '
          'Límite indicado: 50 MB.',
          style: _cuerpo(11),
        ),
      ],
    );
  }

  // ==================================================
  // TARJETA DE EVIDENCIA
  // ==================================================

  Widget _tarjeta(Map<String, dynamic> evidencia) {
    final esArchivo = evidencia['tipo'] == 'archivo';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _superficie,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: _ocupado ? null : () => _abrir(evidencia),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _borde),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: _suave,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    esArchivo ? Icons.description_outlined : Icons.link_rounded,
                    color: _acento,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evidencia['titulo']?.toString() ?? '',
                        style: _tarjetaTexto(13.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        esArchivo ? 'Documento adjunto' : 'Enlace registrado',
                        style: _cuerpo(11.5),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !_ocupado,
                  tooltip: 'Opciones de evidencia',
                  color: _superficie,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: _secundario,
                    size: 21,
                  ),
                  onSelected: (accion) {
                    if (accion == 'abrir') {
                      _abrir(evidencia);
                    } else if (accion == 'eliminar') {
                      _eliminar(evidencia);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'abrir',
                      child: Text('Abrir'),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
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

  // ==================================================
  // ESTADO VACÍO
  // ==================================================

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _suave,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 27,
              color: _acento,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'Aún no hay evidencias',
            style: _titulo(15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando adjuntes un archivo o registres '
            'un enlace, aparecerá aquí.',
            style: _cuerpo(12.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================================================
  // LISTADO
  // ==================================================

  Widget _listaEvidencias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Evidencias registradas',
                style: _titulo(18),
              ),
            ),
            if (_evidencias.isNotEmpty)
              Text(
                '${_evidencias.length}',
                style: BrujulaTipografia.boton(
                  size: 13,
                ).copyWith(
                  color: _secundario,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (_error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _superficie,
              border: Border.all(color: _borde),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _error!,
                  style: _tarjetaTexto(13),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _ocupado ? null : _cargar,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Volver a intentar'),
                  style: TextButton.styleFrom(
                    foregroundColor: _acento,
                  ),
                ),
              ],
            ),
          ),
        ] else if (_evidencias.isEmpty)
          _estadoVacio()
        else
          ..._evidencias.map(_tarjeta),
      ],
    );
  }

  // ==================================================
  // PANTALLA PRINCIPAL
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: BrujulaTipografia.aplicar(Theme.of(context)),
      child: Scaffold(
        backgroundColor: _fondo,
        appBar: AppBar(
          backgroundColor: _fondo,
          foregroundColor: _texto,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Evidencias',
            style: _titulo(17),
          ),
        ),
        body: SafeArea(
          child: _cargando
              ? Center(
                  child: CircularProgressIndicator(
                    color: _acento,
                  ),
                )
              : RefreshIndicator(
                  color: _acento,
                  onRefresh: _cargar,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      19,
                      20,
                      19,
                      35,
                    ),
                    children: [
                      _encabezadoActividad(),
                      const SizedBox(height: 27),
                      _accionesRegistro(),
                      const SizedBox(height: 25),
                      Divider(color: _borde),
                      const SizedBox(height: 17),
                      _listaEvidencias(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
