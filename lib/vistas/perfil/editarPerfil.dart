import 'package:flutter/material.dart';

import 'package:brujula_uni/service/perfilService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class EditarPerfil extends StatefulWidget {
  final int authId;

  const EditarPerfil({
    super.key,
    required this.authId,
  });

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _formKey = GlobalKey<FormState>();

  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _facultadController = TextEditingController();
  final _carreraController = TextEditingController();
  final _biografiaController = TextEditingController();
  final _proyectoController = TextEditingController();
  final _urlCVController = TextEditingController();
  final _fotoController = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _subiendoFoto = false;
  bool _subiendoCV = false;
  bool _permitirSalida = false;
  bool _confirmandoSalida = false;

  String? _error;
  Map<String, String> _original = {};

  // ==================================================
  // IDENTIDAD CROMÁTICA UNI
  // ==================================================

  Color get _fondo => BrujulaColores.fondo(context);
  Color get _superficie => BrujulaColores.superficie(context);
  Color get _texto => BrujulaColores.texto(context);
  Color get _gris => BrujulaColores.secundario(context);
  Color get _borde => BrujulaColores.borde(context);
  Color get _suave => BrujulaColores.superficieDestacada(context);
  Color get _acento => BrujulaColores.acento(context);

  bool get _ocupado => _guardando || _subiendoFoto || _subiendoCV;

  Map<String, String> get _valoresActuales => {
        'nombres': _nombresController.text,
        'apellidos': _apellidosController.text,
        'facultad': _facultadController.text,
        'carrera': _carreraController.text,
        'biografia': _biografiaController.text,
        'proyecto': _proyectoController.text,
        'cv': _urlCVController.text,
        'foto': _fotoController.text,
      };

  bool get _hayCambios {
    final actuales = _valoresActuales;

    for (final entrada in actuales.entries) {
      if (entrada.value != (_original[entrada.key] ?? '')) {
        return true;
      }
    }

    return false;
  }

  // ==================================================
  // CICLO DE VIDA
  // ==================================================

  @override
  void initState() {
    super.initState();

    for (final controller in [
      _nombresController,
      _apellidosController,
      _facultadController,
      _carreraController,
      _biografiaController,
      _proyectoController,
      _urlCVController,
      _fotoController,
    ]) {
      controller.addListener(_actualizarEstado);
    }

    _cargarPerfil();
  }

  void _actualizarEstado() {
    if (mounted && !_cargando) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _facultadController.dispose();
    _carreraController.dispose();
    _biografiaController.dispose();
    _proyectoController.dispose();
    _urlCVController.dispose();
    _fotoController.dispose();

    super.dispose();
  }

  String _valor(dynamic dato) {
    return dato?.toString() ?? '';
  }

  // ==================================================
  // TIPOGRAFÍA
  // ==================================================

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

  TextStyle _secundario(double size) {
    return BrujulaTipografia.secundario(
      size: size,
    ).copyWith(
      color: _gris,
    );
  }

  TextStyle _accion(double size) {
    return BrujulaTipografia.boton(
      size: size,
    ).copyWith(
      color: _acento,
    );
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
  // CARGAR PERFIL
  // ==================================================

  Future<void> _cargarPerfil() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final perfil = await PerfilService.getPerfilUsuario(widget.authId);

      if (!mounted) return;

      if (perfil == null) {
        setState(() {
          _error = 'No se encontró el perfil.';
          _cargando = false;
        });
        return;
      }

      _nombresController.text = _valor(perfil['nombres']);
      _apellidosController.text = _valor(perfil['apellidos']);
      _facultadController.text = _valor(perfil['facultad']);
      _carreraController.text = _valor(perfil['carrera']);
      _biografiaController.text = _valor(perfil['biografia']);
      _proyectoController.text = _valor(perfil['proyecto_vida']);
      _urlCVController.text = _valor(perfil['url_cv']);
      _fotoController.text = _valor(perfil['foto']);

      _original = Map<String, String>.from(
        _valoresActuales,
      );

      setState(() {
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando perfil: $e');

      if (!mounted) return;

      setState(() {
        _error = 'No se pudo cargar tu perfil.';
        _cargando = false;
      });
    }
  }

  // ==================================================
  // SALIR Y DESCARTAR CAMBIOS
  // ==================================================

  void _cerrarEditor([bool? actualizado]) {
    if (!mounted || _permitirSalida) return;

    setState(() {
      _permitirSalida = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(actualizado);
      }
    });
  }

  Future<void> _intentarSalir() async {
    if (_ocupado || _confirmandoSalida || _permitirSalida) {
      return;
    }

    if (!_hayCambios) {
      _cerrarEditor();
      return;
    }

    _confirmandoSalida = true;

    final descartar = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final texto = BrujulaColores.texto(ctx);
            final secundario = BrujulaColores.secundario(ctx);

            return AlertDialog(
              backgroundColor: BrujulaColores.superficie(ctx),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Cambios sin guardar',
                style: BrujulaTipografia.seccion(
                  size: 18,
                ).copyWith(
                  color: texto,
                ),
              ),
              content: Text(
                '¿Deseas salir sin guardar los cambios?',
                style: BrujulaTipografia.cuerpo(
                  size: 13.5,
                ).copyWith(
                  color: secundario,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: texto,
                  ),
                  child: const Text('Seguir editando'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: BrujulaColores.rojoUNI,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salir sin guardar'),
                ),
              ],
            );
          },
        ) ??
        false;

    _confirmandoSalida = false;

    if (!mounted) return;

    if (descartar) {
      _cerrarEditor();
    }
  }

  // ==================================================
  // FOTOGRAFÍA
  // ==================================================

  Widget _avatarPredeterminado() {
    return Container(
      color: _suave,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        color: _acento,
        size: 43,
      ),
    );
  }

  Widget _imagenPerfil() {
    final foto = _fotoController.text.trim();

    return Container(
      width: 83,
      height: 83,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: BrujulaColores.bordeDestacado(context),
          width: 1.4,
        ),
      ),
      child: ClipOval(
        child: foto.isEmpty
            ? _avatarPredeterminado()
            : Image.network(
                foto,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarPredeterminado(),
              ),
      ),
    );
  }

  Future<void> _subirFoto() async {
    if (_ocupado) return;

    setState(() {
      _subiendoFoto = true;
    });

    try {
      final url = await PerfilService.subirArchivo(
        bucket: 'imagen',
      );

      if (!mounted) return;

      if (url == null || url.trim().isEmpty) {
        return;
      }

      _fotoController.text = url.trim();

      _mensaje('Fotografía seleccionada.');
    } catch (e) {
      debugPrint('Error al subir fotografía: $e');

      _mensaje('No se pudo cargar la fotografía.');
    } finally {
      if (mounted) {
        setState(() {
          _subiendoFoto = false;
        });
      }
    }
  }

  void _quitarFoto() {
    if (_ocupado) return;

    _fotoController.clear();

    _mensaje(
      'Fotografía quitada. Guarda los cambios.',
    );
  }

  Future<void> _opcionesFotografia() async {
    if (_ocupado) return;

    final tieneFoto = _fotoController.text.trim().isNotEmpty;

    final seleccion = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: _superficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(23),
        ),
      ),
      builder: (ctx) {
        final texto = BrujulaColores.texto(ctx);
        final secundario = BrujulaColores.secundario(ctx);
        final acento = BrujulaColores.acento(ctx);

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              7,
              22,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fotografía de perfil',
                  style: BrujulaTipografia.seccion(
                    size: 19,
                  ).copyWith(
                    color: texto,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Elige cómo quieres mostrar tu imagen.',
                  style: BrujulaTipografia.secundario(
                    size: 12.5,
                  ).copyWith(
                    color: secundario,
                  ),
                ),
                const SizedBox(height: 17),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.add_a_photo_outlined,
                    color: acento,
                  ),
                  title: Text(
                    tieneFoto ? 'Cambiar fotografía' : 'Añadir fotografía',
                    style: BrujulaTipografia.tarjeta(
                      size: 14,
                    ).copyWith(
                      color: texto,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx, 'cambiar');
                  },
                ),
                if (tieneFoto)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: acento,
                    ),
                    title: Text(
                      'Quitar fotografía',
                      style: BrujulaTipografia.tarjeta(
                        size: 14,
                      ).copyWith(
                        color: texto,
                      ),
                    ),
                    subtitle: Text(
                      'Se mostrará el avatar predeterminado.',
                      style: BrujulaTipografia.secundario(
                        size: 11.5,
                      ).copyWith(
                        color: secundario,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx, 'quitar');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (seleccion == 'cambiar') {
      await _subirFoto();
    } else if (seleccion == 'quitar') {
      _quitarFoto();
    }
  }

  Widget _fotografiaPerfil() {
    final foto = _fotoController.text.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _ocupado ? null : _opcionesFotografia,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 7,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _imagenPerfil(),
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: BrujulaColores.rojoUNI,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _fondo,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 19),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fotografía de perfil',
                      style: _seccion(17),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      foto.isEmpty
                          ? 'Usas el avatar predeterminado'
                          : 'Personaliza tu imagen',
                      style: _secundario(12),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_subiendoFoto)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _acento,
                            ),
                          )
                        else
                          Icon(
                            Icons.edit_outlined,
                            color: _acento,
                            size: 16,
                          ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _subiendoFoto
                                ? 'Cargando'
                                : foto.isEmpty
                                    ? 'Añadir fotografía'
                                    : 'Gestionar fotografía',
                            style: _accion(13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _gris,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // CURRÍCULUM
  // ==================================================

  Future<void> _subirCV() async {
    if (_ocupado) return;

    setState(() {
      _subiendoCV = true;
    });

    try {
      // Conservamos el contrato del servicio actual.
      final url = await PerfilService.subirArchivo(
        bucket: 'imagen',
      );

      if (!mounted) return;

      if (url == null || url.trim().isEmpty) {
        return;
      }

      _urlCVController.text = url.trim();

      _mensaje('CV seleccionado.');
    } catch (e) {
      debugPrint('Error al subir CV: $e');

      _mensaje('No se pudo cargar el CV.');
    } finally {
      if (mounted) {
        setState(() {
          _subiendoCV = false;
        });
      }
    }
  }

  Widget _documentoCV() {
    final tieneCV = _urlCVController.text.trim().isNotEmpty;

    return Material(
      color: _suave,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _ocupado ? null : _subirCV,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: _acento,
                size: 25,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi currículum',
                      style: _tarjeta(14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tieneCV
                          ? 'Documento registrado'
                          : 'Sin documento registrado',
                      style: _secundario(12),
                    ),
                  ],
                ),
              ),
              if (_subiendoCV)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: _acento,
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.upload_file_rounded,
                  color: _acento,
                  size: 21,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // GUARDAR PERFIL
  // ==================================================

  Future<void> _guardarPerfil() async {
    if (_cargando || _ocupado || _error != null) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _guardando = true;
    });

    try {
      final success = await PerfilService.actualizarPerfilUsuario(
        authId: widget.authId,
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        facultad: _facultadController.text.trim(),
        carrera: _carreraController.text.trim(),
        biografia: _biografiaController.text.trim(),
        proyectoVida: _proyectoController.text.trim(),
        urlCV: _urlCVController.text.trim(),
        foto: _fotoController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        _cerrarEditor(true);
      } else {
        _mensaje('No se pudo actualizar el perfil.');
      }
    } catch (e) {
      debugPrint('Error al guardar perfil: $e');

      _mensaje('No se pudo actualizar el perfil.');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // ==================================================
  // FORMULARIO
  // ==================================================

  Widget _tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 11,
        bottom: 14,
      ),
      child: Text(
        titulo,
        style: _seccion(17),
      ),
    );
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    int maxLines = 1,
    int? maxLength,
    TextCapitalization capitalizacion = TextCapitalization.sentences,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 17,
      ),
      child: TextFormField(
        controller: controller,
        enabled: !_ocupado,
        maxLines: maxLines,
        maxLength: maxLength,
        textCapitalization: capitalizacion,
        cursorColor: _acento,
        style: BrujulaTipografia.cuerpo(
          size: 14,
        ).copyWith(
          color: _texto,
        ),
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: _secundario(12.5),
          floatingLabelStyle: _accion(12),
          counterStyle: _secundario(11),
          filled: true,
          fillColor: _superficie,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _borde,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _acento,
              width: 1.4,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _borde,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFC54A45),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFC54A45),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _datosPersonales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Datos personales y académicos'),
        Row(
          children: [
            Expanded(
              child: _campo(
                'Nombres',
                _nombresController,
                capitalizacion: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _campo(
                'Apellidos',
                _apellidosController,
                capitalizacion: TextCapitalization.words,
              ),
            ),
          ],
        ),
        _campo(
          'Facultad',
          _facultadController,
          capitalizacion: TextCapitalization.words,
        ),
        _campo(
          'Carrera profesional',
          _carreraController,
          capitalizacion: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _presentacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Mi presentación'),
        _campo(
          'Biografía',
          _biografiaController,
          maxLines: 5,
          maxLength: 1500,
        ),
        _campo(
          'Proyecto de vida',
          _proyectoController,
          maxLines: 5,
          maxLength: 2000,
        ),
      ],
    );
  }

  Widget _contenido() {
    return Form(
      key: _formKey,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          19,
          19,
          19,
          35,
        ),
        children: [
          _fotografiaPerfil(),
          const SizedBox(height: 14),
          Divider(color: _borde),
          _datosPersonales(),
          Divider(color: _borde),
          _presentacion(),
          const SizedBox(height: 12),
          _tituloSeccion('Documentos'),
          _documentoCV(),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // ==================================================
  // ERRORES
  // ==================================================

  Widget _estadoError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
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
              _error ?? 'No se pudo cargar tu perfil.',
              textAlign: TextAlign.center,
              style: _seccion(17),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: _cargarPerfil,
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

  // ==================================================
  // PANTALLA PRINCIPAL
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final guardarDisponible =
        !_cargando && !_ocupado && _error == null && _hayCambios;

    return PopScope<bool>(
      canPop: _permitirSalida,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _intentarSalir();
        }
      },
      child: Theme(
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
            leading: IconButton(
              onPressed: _intentarSalir,
              tooltip: 'Volver',
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            title: Text(
              'Editar perfil',
              style: _seccion(18),
            ),
            actions: [
              if (_guardando)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _acento,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: guardarDisponible ? _guardarPerfil : null,
                  style: TextButton.styleFrom(
                    foregroundColor: _acento,
                    disabledForegroundColor: _gris.withValues(alpha: 0.55),
                  ),
                  child: Text(
                    'Guardar',
                    style: BrujulaTipografia.boton(
                      size: 14,
                    ).copyWith(
                      color: guardarDisponible
                          ? _acento
                          : _gris.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: _cargando
                ? Center(
                    child: CircularProgressIndicator(
                      color: _acento,
                    ),
                  )
                : _error != null
                    ? _estadoError()
                    : _contenido(),
          ),
        ),
      ),
    );
  }
}
