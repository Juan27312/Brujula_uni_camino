
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brujula_uni/service/brujulaConexionService.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    final correoLimpio = correo.trim();

    // Validar que se haya ingresado el correo.
    if (correoLimpio.isEmpty) {
      return {
        'success': false,
        'message': 'Ingresa tu correo electrónico.',
      };
    }

    // Comprobar que el correo tenga un formato válido.
    final formatoCorreo = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!formatoCorreo.hasMatch(correoLimpio)) {
      return {
        'success': false,
        'message':
            'Verifica que tu correo electrónico esté escrito correctamente.',
      };
    }

    // Validar que se haya ingresado la contraseña.
    if (password.isEmpty) {
      return {
        'success': false,
        'message': 'Ingresa tu contraseña.',
      };
    }

    // Limpiar la sesión anterior de Mi Camino.
    BrujulaConexionService.instancia.cerrarSesion();

    try {
      // Verificar los datos de acceso.
      final respuesta = await supabase.auth.signInWithPassword(
        email: correoLimpio,
        password: password,
      );

      final usuario = respuesta.user;

      if (usuario == null) {
        return {
          'success': false,
          'message':
              'No pudimos verificar tus datos. '
              'Revisa tu correo y contraseña.',
        };
      }

      // Identificar el perfil del estudiante.
      final perfil = await supabase
          .from('perfiles_estudiante')
          .select('id, auth_id')
          .eq('auth_uid', usuario.id)
          .maybeSingle();

      final cuentaAnterior = perfil?['auth_id'];

      if (cuentaAnterior is! num ||
          cuentaAnterior.toInt() <= 0) {
        await supabase.auth.signOut();

        return {
          'success': false,
          'message':
              'Tu cuenta aún no está habilitada. '
              'Comunícate con el responsable del programa.',
        };
      }

      // Establecer la sesión de Mi Camino.
      bool sesionDatosActiva = false;

      try {
        await BrujulaConexionService.instancia
            .iniciarSesionConAuth();

        sesionDatosActiva =
            BrujulaConexionService.instancia.tieneSesion;
      } catch (_) {
        sesionDatosActiva = false;
      }

      return {
        'success': true,
        'id': cuentaAnterior.toInt(),
        'message': 'Bienvenido a Brújula UNI.',
        'sesionDatosActiva': sesionDatosActiva,
      };
    } on AuthException catch (error) {
      if (error.code == 'email_not_confirmed') {
        return {
          'success': false,
          'message':
              'Confirma tu correo electrónico para continuar.',
        };
      }

      if (error.statusCode == '429' ||
          error.code == 'over_request_rate_limit') {
        return {
          'success': false,
          'message':
              'Por seguridad, espera unos minutos '
              'antes de intentarlo nuevamente.',
        };
      }

      if (error.code == 'invalid_credentials') {
        return {
          'success': false,
          'message':
              'No pudimos verificar tus datos. '
              'Revisa tu correo y contraseña.',
        };
      }

      return {
        'success': false,
        'message':
            'No pudimos iniciar sesión. '
            'Intenta nuevamente.',
      };
    } catch (_) {
      return {
        'success': false,
        'message':
            'No pudimos establecer la conexión. '
            'Intenta nuevamente.',
      };
    }
  }
}
