import 'package:flutter/material.dart';

import 'package:brujula_uni/service/aparienciaService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class ConfiguracionPage extends StatefulWidget {
  final VoidCallback? cerrarSesion;

  const ConfiguracionPage({
    super.key,
    this.cerrarSesion,
  });

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final AparienciaService _apariencia = AparienciaService.instancia;

  bool _actualizando = false;

  @override
  void initState() {
    super.initState();
    _apariencia.addListener(_actualizar);
  }

  @override
  void dispose() {
    _apariencia.removeListener(_actualizar);
    super.dispose();
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _cambiar(ThemeMode modo) async {
    if (_actualizando || _apariencia.modo == modo) {
      return;
    }

    setState(() {
      _actualizando = true;
    });

    try {
      await _apariencia.cambiar(modo);
    } finally {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
    }
  }

  bool get _oscuro => Theme.of(context).brightness == Brightness.dark;

  ColorScheme get _esquema => Theme.of(context).colorScheme;

  Color get _fondo => Theme.of(context).scaffoldBackgroundColor;

  Color get _texto => _esquema.onSurface;

  Color get _secundario => _esquema.onSurfaceVariant;

  Color get _borde => _esquema.outlineVariant;

  Color get _superficie => _esquema.surface;

  Color get _acento => _esquema.primary;

  Widget _vistaPrevia(bool oscuro) {
    final fondo = oscuro ? const Color(0xFF191716) : const Color(0xFFF7F4EC);

    final superficie = oscuro ? const Color(0xFF282422) : Colors.white;

    final acento = oscuro ? const Color(0xFFD98A80) : const Color(0xFF7D1914);

    final linea = oscuro ? const Color(0xFF867C74) : const Color(0xFFD3CCC1);

    return Container(
      height: 93,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: oscuro ? const Color(0xFF403A37) : const Color(0xFFE9E3D6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 7,
            width: 29,
            decoration: BoxDecoration(
              color: acento,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: superficie,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 5,
            width: 42,
            decoration: BoxDecoration(
              color: linea,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcion({
    required String titulo,
    required ThemeMode modo,
    required IconData icono,
  }) {
    final seleccionado = _apariencia.modo == modo;
    final oscuro = modo == ThemeMode.dark;

    return Expanded(
      child: Material(
        color: seleccionado
            ? (_oscuro ? const Color(0xFF342D25) : const Color(0xFFEFE7D4))
            : _superficie,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: _actualizando ? null : () => _cambiar(modo),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: seleccionado ? _acento : _borde,
                width: seleccionado ? 1.6 : 1,
              ),
            ),
            child: Column(
              children: [
                _vistaPrevia(oscuro),
                const SizedBox(height: 12),
                Icon(
                  seleccionado ? Icons.check_circle_rounded : icono,
                  color: seleccionado ? _acento : _secundario,
                  size: 21,
                ),
                const SizedBox(height: 7),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: BrujulaTipografia.boton(
                    size: 13,
                  ).copyWith(
                    color: _texto,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _apartadoApariencia() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apariencia',
            style: BrujulaTipografia.seccion(
              size: 16,
            ).copyWith(
              color: _texto,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Elige cómo deseas visualizar Brújula UNI.',
            style: BrujulaTipografia.secundario(
              size: 12.5,
            ).copyWith(
              color: _secundario,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _opcion(
                titulo: 'Claro',
                modo: ThemeMode.light,
                icono: Icons.light_mode_outlined,
              ),
              const SizedBox(width: 12),
              _opcion(
                titulo: 'Oscuro',
                modo: ThemeMode.dark,
                icono: Icons.dark_mode_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _apartadoCuenta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUENTA',
          style: BrujulaTipografia.etiqueta().copyWith(
            color: _acento,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: _superficie,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.cerrarSesion,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: _borde),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: _acento,
                    size: 23,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Cerrar sesión',
                      style: BrujulaTipografia.tarjeta(
                        size: 14,
                      ).copyWith(
                        color: _texto,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _secundario,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: _fondo,
        foregroundColor: _texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Configuración',
          style: BrujulaTipografia.seccion(
            size: 18,
          ).copyWith(
            color: _texto,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            19,
            22,
            19,
            32,
          ),
          children: [
            Text(
              'TU EXPERIENCIA',
              style: BrujulaTipografia.etiqueta().copyWith(
                color: _acento,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hazla tuya.',
              style: BrujulaTipografia.principal(
                size: 25,
              ).copyWith(
                color: _texto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personaliza cómo utilizas Brújula UNI.',
              style: BrujulaTipografia.secundario(
                size: 13,
              ).copyWith(
                color: _secundario,
              ),
            ),
            const SizedBox(height: 27),
            _apartadoApariencia(),
            const SizedBox(height: 36),
            _apartadoCuenta(),
          ],
        ),
      ),
    );
  }
}
