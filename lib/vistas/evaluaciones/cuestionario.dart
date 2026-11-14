import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:brujula_uni/service/evaluacionesService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class CuestionarioPage extends StatefulWidget {
  final int testId;
  final String texto;
  final int authId;

  const CuestionarioPage({
    super.key,
    required this.testId,
    required this.texto,
    required this.authId,
  });

  @override
  State<CuestionarioPage> createState() => _CuestionarioPageState();
}

class _CuestionarioPageState extends State<CuestionarioPage> {
  late Future<List<Map<String, dynamic>>> preguntasFuture;

  final Map<int, int> respuestasSeleccionadas = {};

  int _indiceActual = 0;
  int totalPuntaje = 0;

  bool cargandoResultado = false;
  bool _resultadoGuardado = false;
  bool _mostrarResultado = false;

  String? consejoFinal;
  String? linkFinal;
  String? img;
  String? doc;

  // =====================================================
  // COLORES UNI
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

    preguntasFuture = Evaluacionesservice.getPreguntas(widget.testId);
  }

  // =====================================================
  // UTILIDADES
  // =====================================================

  int? _id(dynamic valor) {
    if (valor is num) return valor.toInt();

    return int.tryParse(
      valor?.toString() ?? '',
    );
  }

  List<Map<String, dynamic>> _opciones(dynamic valor) {
    if (valor is! List) return [];

    return valor
        .whereType<Map>()
        .map(
          (opcion) => Map<String, dynamic>.from(opcion),
        )
        .toList();
  }

  int _respondidas(
    List<Map<String, dynamic>> preguntas,
  ) {
    return preguntas.where((pregunta) {
      final id = _id(pregunta['id']);

      return id != null && respuestasSeleccionadas.containsKey(id);
    }).length;
  }

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
  // SELECCIONAR RESPUESTA
  // =====================================================

  void _seleccionarRespuesta(
    int preguntaId,
    int opcionId,
  ) {
    if (cargandoResultado || _resultadoGuardado) {
      return;
    }

    setState(() {
      respuestasSeleccionadas[preguntaId] = opcionId;
    });
  }

  // =====================================================
  // CALCULAR PUNTAJE
  // =====================================================

  int _calcularPuntaje(
    List<Map<String, dynamic>> preguntas,
  ) {
    int total = 0;

    for (final pregunta in preguntas) {
      final preguntaId = _id(pregunta['id']);

      if (preguntaId == null) continue;

      final opcionSeleccionada = respuestasSeleccionadas[preguntaId];

      if (opcionSeleccionada == null) continue;

      final opciones = _opciones(pregunta['opcion_respuesta']);

      for (final opcion in opciones) {
        if (_id(opcion['id']) == opcionSeleccionada) {
          total += int.tryParse(
                opcion['puntaje']?.toString() ?? '',
              ) ??
              0;

          break;
        }
      }
    }

    return total;
  }

  // =====================================================
  // NAVEGACIÓN ENTRE PREGUNTAS
  // =====================================================

  void _anterior() {
    if (_indiceActual <= 0 || cargandoResultado) {
      return;
    }

    setState(() {
      _indiceActual--;
    });
  }

  void _siguiente(
    List<Map<String, dynamic>> preguntas,
  ) {
    if (cargandoResultado) return;

    final pregunta = preguntas[_indiceActual];

    final preguntaId = _id(pregunta['id']);

    if (preguntaId == null ||
        !respuestasSeleccionadas.containsKey(
          preguntaId,
        )) {
      _mensaje('Selecciona una respuesta para continuar.');
      return;
    }

    if (_indiceActual < preguntas.length - 1) {
      setState(() {
        _indiceActual++;
      });
    } else {
      _revisarFinalizacion(preguntas);
    }
  }

  // =====================================================
  // CONFIRMAR FINALIZACIÓN
  // =====================================================

  Future<void> _revisarFinalizacion(
    List<Map<String, dynamic>> preguntas,
  ) async {
    if (cargandoResultado || _resultadoGuardado) {
      return;
    }

    final respondidas = _respondidas(preguntas);

    if (respondidas < preguntas.length) {
      _mensaje(
        'Responde todas las preguntas antes de finalizar.',
      );
      return;
    }

    final confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: BrujulaColores.superficie(ctx),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Finalizar evaluación',
                style: BrujulaTipografia.seccion(
                  size: 18,
                ).copyWith(
                  color: BrujulaColores.texto(ctx),
                ),
              ),
              content: Text(
                'Has respondido todas las preguntas. '
                '¿Deseas guardar tus respuestas y consultar '
                'el resultado?',
                style: BrujulaTipografia.cuerpo(
                  size: 13,
                ).copyWith(
                  color: BrujulaColores.secundario(ctx),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Revisar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: BrujulaColores.rojoUNI,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Finalizar'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted || !confirmar) return;

    await _guardarResultado(preguntas);
  }

  // =====================================================
  // GUARDAR RESULTADO Y CONSULTAR CONSEJO
  // =====================================================

  Future<void> _guardarResultado(
    List<Map<String, dynamic>> preguntas,
  ) async {
    if (cargandoResultado || _resultadoGuardado) {
      return;
    }

    final puntaje = _calcularPuntaje(preguntas);

    setState(() {
      cargandoResultado = true;
    });

    try {
      final exito = await Evaluacionesservice.guardarResultado(
        usuarioId: widget.authId,
        testId: widget.testId,
        puntajeTotal: puntaje,
      );

      if (!mounted) return;

      if (!exito) {
        _mensaje(
          'No se pudo guardar el resultado. Intenta nuevamente.',
        );
        return;
      }

      // El resultado se guardó correctamente.
      // No se enviará otra vez desde esta pantalla.
      setState(() {
        totalPuntaje = puntaje;
        _resultadoGuardado = true;
        _mostrarResultado = true;
      });

      try {
        final consejo = await Evaluacionesservice.getConsejo(
          widget.testId,
          puntaje,
        );

        if (!mounted) return;

        setState(() {
          consejoFinal = consejo?['consejo']?.toString();

          linkFinal = consejo?['link']?.toString();

          img = consejo?['img']?.toString();

          doc = consejo?['doc']?.toString();
        });
      } catch (e) {
        debugPrint(
          'Error consultando recomendación: $e',
        );

        if (mounted) {
          _mensaje(
            'Resultado guardado. No se pudo cargar la recomendación.',
          );
        }
      }
    } catch (e) {
      debugPrint(
        'Error guardando evaluación: $e',
      );

      if (mounted && !_resultadoGuardado) {
        _mensaje(
          'No se pudo confirmar el resultado guardado.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          cargandoResultado = false;
        });
      }
    }
  }

  // =====================================================
  // DESCARGAR DOCUMENTO
  // =====================================================

  void _download(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      _mensaje('No se pudo descargar el documento.');
      return;
    }

    FileDownloader.downloadFile(
      url: url,
      name: 'doc.docx',
      onProgress: (fileName, progress) {
        debugPrint(
          'Descargando: ${progress.toStringAsFixed(0)}%',
        );
      },
      onDownloadCompleted: (path) {
        if (mounted) {
          _mensaje('Descarga completada.');
        }
      },
      onDownloadError: (error) {
        debugPrint(
          'Error descargando documento: $error',
        );

        if (mounted) {
          _mensaje(
            'No se pudo descargar el documento.',
          );
        }
      },
    );
  }

  // =====================================================
  // ABRIR ENLACE
  // =====================================================

  Future<void> _abrirLink(String url) async {
    try {
      final uri = Uri.tryParse(url);

      if (uri == null ||
          !['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty) {
        throw StateError('Enlace inválido');
      }

      final correcto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!correcto) {
        throw StateError('No se pudo abrir');
      }
    } catch (e) {
      debugPrint('Error abriendo enlace: $e');

      _mensaje('No se pudo abrir el enlace.');
    }
  }

  // =====================================================
  // REINTENTAR CONSULTA DE PREGUNTAS
  // =====================================================

  void _reintentar() {
    setState(() {
      _indiceActual = 0;

      preguntasFuture = Evaluacionesservice.getPreguntas(
        widget.testId,
      );
    });
  }

  // =====================================================
  // ENCABEZADO
  // =====================================================

  Widget _encabezadoCuestionario({
    required int total,
    required int respondidas,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EVALUACIÓN',
          style: BrujulaTipografia.etiqueta().copyWith(
            color: _acento,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          widget.texto,
          style: _principal(23),
        ),
        const SizedBox(height: 10),
        Text(
          'Lee cada pregunta y selecciona '
          'la respuesta que mejor corresponda.',
          style: _cuerpo(13),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Pregunta ${_indiceActual + 1} de $total',
                style: _titulo(13),
              ),
            ),
            Text(
              '$respondidas de $total respondidas',
              style: _cuerpo(11.5),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : respondidas / total,
            minHeight: 6,
            color: _acento,
            backgroundColor: _suave,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // OPCIÓN DE RESPUESTA
  // =====================================================

  Widget _opcionRespuesta({
    required int preguntaId,
    required Map<String, dynamic> opcion,
  }) {
    final opcionId = _id(opcion['id']);

    if (opcionId == null) {
      return const SizedBox.shrink();
    }

    final seleccionada = respuestasSeleccionadas[preguntaId] == opcionId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: seleccionada ? _suave : _superficie,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: cargandoResultado
              ? null
              : () {
                  _seleccionarRespuesta(
                    preguntaId,
                    opcionId,
                  );
                },
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: seleccionada ? _acento : _borde,
                width: seleccionada ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  seleccionada
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: seleccionada ? _acento : _secundario,
                  size: 22,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    opcion['respuesta']?.toString() ?? '',
                    style: BrujulaTipografia.cuerpo(
                      size: 13.5,
                    ).copyWith(
                      color: _texto,
                      fontWeight:
                          seleccionada ? FontWeight.w600 : FontWeight.w400,
                    ),
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
  // PREGUNTA ACTUAL
  // =====================================================

  Widget _preguntaActual(
    List<Map<String, dynamic>> preguntas,
  ) {
    final pregunta = preguntas[_indiceActual];

    final preguntaId = _id(pregunta['id']);

    final opciones = _opciones(
      pregunta['opcion_respuesta'],
    );

    final respondidas = _respondidas(preguntas);
    final esUltima = _indiceActual == preguntas.length - 1;

    final tieneRespuesta = preguntaId != null &&
        respuestasSeleccionadas.containsKey(
          preguntaId,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezadoCuestionario(
          total: preguntas.length,
          respondidas: respondidas,
        ),
        const SizedBox(height: 25),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _superficie,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _borde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PREGUNTA ${_indiceActual + 1}',
                style: BrujulaTipografia.etiqueta().copyWith(
                  color: _acento,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                pregunta['pregunta']?.toString() ?? '',
                style: _titulo(17),
              ),
              const SizedBox(height: 20),
              if (preguntaId == null || opciones.isEmpty)
                Text(
                  'No hay opciones disponibles '
                  'para esta pregunta.',
                  style: _cuerpo(13),
                )
              else
                ...opciones.map(
                  (opcion) => _opcionRespuesta(
                    preguntaId: preguntaId,
                    opcion: opcion,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        Row(
          children: [
            if (_indiceActual > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: cargandoResultado ? null : _anterior,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _acento,
                    side: BorderSide(color: _borde),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: cargandoResultado || !tieneRespuesta
                    ? null
                    : () => _siguiente(preguntas),
                style: FilledButton.styleFrom(
                  backgroundColor: BrujulaColores.rojoUNI,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: cargandoResultado
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        esUltima ? 'Finalizar evaluación' : 'Siguiente',
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =====================================================
  // MARKDOWN DE RECOMENDACIÓN
  // =====================================================

  MarkdownStyleSheet _markdown() {
    final cuerpo = BrujulaTipografia.cuerpo(
      size: 13.5,
    ).copyWith(
      color: _texto,
      height: 1.6,
    );

    return MarkdownStyleSheet(
      p: cuerpo,
      h1: _principal(20),
      h2: _titulo(18),
      h3: _titulo(16),
      strong: cuerpo.copyWith(
        fontWeight: FontWeight.w700,
      ),
      em: cuerpo.copyWith(
        fontStyle: FontStyle.italic,
      ),
      listBullet: cuerpo,
      a: cuerpo.copyWith(
        color: _acento,
        decoration: TextDecoration.underline,
      ),
    );
  }

  // =====================================================
  // TARJETA DE RECOMENDACIÓN
  // =====================================================

  Widget _recomendacion() {
    final tieneConsejo = (consejoFinal ?? '').trim().isNotEmpty;

    final tieneImagen = (img ?? '').trim().isNotEmpty;

    final tieneEnlace = (linkFinal ?? '').trim().isNotEmpty;

    final tieneDocumento = (doc ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: _acento,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tu recomendación',
                  style: _titulo(18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tieneImagen) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                img!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 140,
                    color: _suave,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: _secundario,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
          ],
          if (tieneConsejo)
            MarkdownBody(
              data: consejoFinal!,
              selectable: true,
              styleSheet: _markdown(),
            )
          else
            Text(
              'No hay una recomendación disponible '
              'para este resultado.',
              style: _cuerpo(13),
            ),
          if (tieneEnlace) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => _abrirLink(linkFinal!),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
              ),
              label: const Text(
                'Consultar recurso',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _acento,
                side: BorderSide(color: _borde),
              ),
            ),
          ],
          if (tieneDocumento) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _download(doc!),
              icon: const Icon(
                Icons.download_rounded,
                size: 19,
              ),
              label: const Text(
                'Descargar documento',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _acento,
                side: BorderSide(color: _borde),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // VISTA DE RESULTADOS
  // =====================================================

  Widget _vistaResultado() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        19,
        23,
        19,
        35,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _suave,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: _acento,
                size: 31,
              ),
              const SizedBox(height: 14),
              Text(
                'Evaluación finalizada',
                style: _principal(22),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu resultado se ha guardado correctamente.',
                style: _cuerpo(13),
              ),
              const SizedBox(height: 17),
              Text(
                'PUNTAJE OBTENIDO',
                style: BrujulaTipografia.etiqueta().copyWith(
                  color: _acento,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$totalPuntaje',
                style: _principal(32).copyWith(
                  color: _acento,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (cargandoResultado)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: CircularProgressIndicator(
                color: _acento,
              ),
            ),
          )
        else
          _recomendacion(),
        const SizedBox(height: 23),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          label: const Text(
            'Volver a evaluaciones',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _acento,
            side: BorderSide(color: _borde),
            minimumSize: const Size.fromHeight(47),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ESTADO DE ERROR
  // =====================================================

  Widget _errorPreguntas({
    required String titulo,
    required String descripcion,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              color: _acento,
              size: 34,
            ),
            const SizedBox(height: 15),
            Text(
              titulo,
              style: _titulo(16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: _cuerpo(13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: _reintentar,
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

  // =====================================================
  // PANTALLA PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !cargandoResultado,
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
            title: Text(
              widget.texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _titulo(17),
            ),
          ),
          body: SafeArea(
            child: _mostrarResultado
                ? _vistaResultado()
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: preguntasFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: _acento,
                          ),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return _errorPreguntas(
                          titulo: 'No se pudieron cargar las preguntas',
                          descripcion:
                              'Comprueba tu conexión e inténtalo nuevamente.',
                        );
                      }

                      final preguntas = snapshot.data!;

                      if (preguntas.isEmpty) {
                        return _errorPreguntas(
                          titulo: 'Sin preguntas disponibles',
                          descripcion:
                              'Esta evaluación todavía no tiene preguntas.',
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          19,
                          22,
                          19,
                          35,
                        ),
                        child: _preguntaActual(preguntas),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
