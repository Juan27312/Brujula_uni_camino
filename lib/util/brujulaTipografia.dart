import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrujulaTipografia {
  BrujulaTipografia._();

  static const Color textoPrincipal = Color(0xFF252B34);
  static const Color textoSecundario = Color(0xFF697483);
  static const Color institucional = Color(0xFF7D0E0E);

  static TextStyle principal({
    double size = 26,
    Color color = textoPrincipal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: -0.65,
      color: color,
    );
  }

  static TextStyle seccion({
    double size = 18,
    Color color = textoPrincipal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.35,
      color: color,
    );
  }

  static TextStyle tarjeta({
    double size = 14,
    Color color = textoPrincipal,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: -0.15,
      color: color,
    );
  }

  static TextStyle cuerpo({
    double size = 13,
    Color color = textoPrincipal,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: color,
    );
  }

  static TextStyle secundario({
    double size = 12,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: textoSecundario,
    );
  }

  static TextStyle boton({
    double size = 13,
    Color color = institucional,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: color,
    );
  }

  static TextStyle etiqueta({
    Color color = institucional,
  }) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0.35,
      color: color,
    );
  }

  static ThemeData aplicar(ThemeData base) {
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ),
      primaryTextTheme: GoogleFonts.interTextTheme(
        base.primaryTextTheme,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
