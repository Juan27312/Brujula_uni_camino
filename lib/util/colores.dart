import 'package:flutter/material.dart';

// =====================================================
// IDENTIDAD INSTITUCIONAL
// =====================================================

// Se conserva para mantener la compatibilidad
// con los archivos existentes.
const Color COLORBASE = Color.fromARGB(255, 128, 18, 10);

// Rojo utilizado en la nueva identidad visual.
const Color ROJO_UNI = Color(0xFF7D1914);

class BrujulaColores {
  BrujulaColores._();

  // Identidad
  static const Color rojoUNI = ROJO_UNI;
  static const Color cremaUNI = Color(0xFFEFE7D4);
  static const Color doradoUNI = Color(0xFFE8D9AA);

  // Modo claro
  static const Color fondoClaro = Color(0xFFF7F4EC);
  static const Color superficieClara = Colors.white;
  static const Color textoClaro = Color(0xFF262525);
  static const Color secundarioClaro = Color(0xFF716C65);
  static const Color bordeClaro = Color(0xFFE9E3D6);
  static const Color destacadoClaro = Color(0xFFF3EDE0);

  // Modo oscuro
  static const Color fondoOscuro = Color(0xFF191716);
  static const Color superficieOscura = Color(0xFF282422);
  static const Color elevadaOscura = Color(0xFF342D25);
  static const Color textoOscuro = Color(0xFFF3EEE5);
  static const Color secundarioOscuro = Color(0xFFB9B2A9);
  static const Color bordeOscuro = Color(0xFF403A37);
  static const Color acentoOscuro = Color(0xFFD98A80);
  static const Color destacadoOscuro = Color(0xFF942C27);

  static bool esOscuro(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color fondo(BuildContext context) {
    return esOscuro(context) ? fondoOscuro : fondoClaro;
  }

  static Color superficie(BuildContext context) {
    return esOscuro(context) ? superficieOscura : superficieClara;
  }

  static Color superficieElevada(BuildContext context) {
    return esOscuro(context) ? elevadaOscura : cremaUNI;
  }

  static Color texto(BuildContext context) {
    return esOscuro(context) ? textoOscuro : textoClaro;
  }

  static Color secundario(BuildContext context) {
    return esOscuro(context) ? secundarioOscuro : secundarioClaro;
  }

  static Color borde(BuildContext context) {
    return esOscuro(context) ? bordeOscuro : bordeClaro;
  }

  static Color acento(BuildContext context) {
    return esOscuro(context) ? acentoOscuro : rojoUNI;
  }

  static Color destacado(BuildContext context) {
    return esOscuro(context) ? destacadoOscuro : rojoUNI;
  }

  static Color superficieDestacada(BuildContext context) {
    return esOscuro(context) ? elevadaOscura : destacadoClaro;
  }

  static Color iconoFondo(BuildContext context) {
    return esOscuro(context) ? elevadaOscura : const Color(0xFFF2ECE2);
  }

  static Color bordeDestacado(BuildContext context) {
    return esOscuro(context)
        ? const Color(0xFF594039)
        : const Color(0xFFE6D9CB);
  }
}
