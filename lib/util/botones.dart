import 'package:flutter/material.dart';

import 'package:brujula_uni/colores.dart' show COLORLETRA;
import 'package:brujula_uni/util/colores.dart' show COLORBASE;
import 'package:brujula_uni/util/brujulaTipografia.dart';

class BotonOpcion extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotonOpcion({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: COLORBASE,
          foregroundColor: COLORLETRA,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: BrujulaTipografia.boton(
            size: 14,
            color: COLORLETRA,
          ),
        ),
      ),
    );
  }
}
