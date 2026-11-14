import 'package:intl/intl.dart';

String formatearFecha(String fechaIso) {
  try {
    // Las fechas de mensaje_foro se almacenan
    // como hora UTC, sin indicador de zona horaria.
    final texto = fechaIso.trim();

    if (texto.isEmpty) {
      return 'Fecha inválida';
    }

    // Interpretar la fecha recibida como UTC.
    final fechaUtc = DateTime.parse(
      texto.endsWith('Z') || RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(texto)
          ? texto
          : '${texto}Z',
    );

    // Convertir a la zona horaria del celular.
    final fechaLocal = fechaUtc.toLocal();

    return DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(fechaLocal);
  } catch (_) {
    return 'Fecha inválida';
  }
}
