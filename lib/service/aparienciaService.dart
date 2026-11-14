import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AparienciaService extends ChangeNotifier {
  AparienciaService._();

  static final AparienciaService instancia = AparienciaService._();

  static const String _clave = 'brujula_apariencia';

  ThemeMode _modo = ThemeMode.light;

  ThemeMode get modo => _modo;

  bool get esOscuro => _modo == ThemeMode.dark;

  Future<void> cargar() async {
    try {
      final preferencias = await SharedPreferences.getInstance();

      final guardado = preferencias.getString(_clave);

      // Las preferencias anteriores "system" se
      // convierten automáticamente a modo claro.
      final nuevoModo = guardado == 'dark' ? ThemeMode.dark : ThemeMode.light;

      if (_modo != nuevoModo) {
        _modo = nuevoModo;
        notifyListeners();
      }

      if (guardado != 'light' && guardado != 'dark') {
        await preferencias.setString(
          _clave,
          'light',
        );
      }
    } catch (e) {
      debugPrint('Error cargando apariencia: $e');

      if (_modo != ThemeMode.light) {
        _modo = ThemeMode.light;
        notifyListeners();
      }
    }
  }

  Future<void> cambiar(ThemeMode nuevoModo) async {
    // El modo Sistema ya no se utiliza.
    final seleccionado =
        nuevoModo == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;

    if (_modo == seleccionado) {
      return;
    }

    _modo = seleccionado;
    notifyListeners();

    try {
      final preferencias = await SharedPreferences.getInstance();

      await preferencias.setString(
        _clave,
        seleccionado == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      debugPrint('Error guardando apariencia: $e');
    }
  }
}
