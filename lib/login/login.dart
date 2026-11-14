
import 'package:flutter/material.dart';

import 'package:brujula_uni/service/loginService.dart';
import 'package:brujula_uni/util/brujulaTipografia.dart';
import 'package:brujula_uni/util/colores.dart';

class Login extends StatefulWidget {
  final void Function(int id) onLoginSuccess;

  const Login({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

  bool _loading = false;
  bool _isPasswordVisible = false;

  // ==========================================
  // IDENTIDAD VISUAL
  // ==========================================

  bool get _oscuro => BrujulaColores.esOscuro(context);

  Color get _fondo => BrujulaColores.fondo(context);

  Color get _superficie => BrujulaColores.superficie(context);

  Color get _texto => BrujulaColores.texto(context);

  Color get _secundario => BrujulaColores.secundario(context);

  Color get _borde => BrujulaColores.borde(context);

  Color get _acento => BrujulaColores.acento(context);

  Color get _colorAviso => _oscuro
      ? const Color(0xFFFFB4AB)
      : const Color(0xFFB3261E);

  // ==========================================
  // VALIDACIÓN DE LOS CAMPOS
  // ==========================================

  bool _validarCampos() {
    final correo = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailError;
    String? passwordError;

    if (correo.isEmpty) {
      emailError = 'Ingresa tu correo electrónico.';
    } else {
      final formatoCorreo = RegExp(
        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
      );

      if (!formatoCorreo.hasMatch(correo)) {
        emailError =
            'Verifica que tu correo esté escrito correctamente.';
      }
    }

    if (password.isEmpty) {
      passwordError = 'Ingresa tu contraseña.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _errorMessage = null;
    });

    return emailError == null && passwordError == null;
  }

  void _limpiarAvisoCorreo() {
    if (_emailError != null || _errorMessage != null) {
      setState(() {
        _emailError = null;
        _errorMessage = null;
      });
    }
  }

  void _limpiarAvisoPassword() {
    if (_passwordError != null || _errorMessage != null) {
      setState(() {
        _passwordError = null;
        _errorMessage = null;
      });
    }
  }

  // ==========================================
  // INICIO DE SESIÓN
  // ==========================================

  Future<void> _login() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    if (!_validarCampos()) {
      return;
    }

    final correo = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        correo,
        password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final id = result['id'];

        if (id is! num) {
          setState(() {
            _errorMessage =
                'No pudimos identificar tu cuenta. '
                'Intenta nuevamente.';
          });
          return;
        }

        // Se conserva la navegación actual.
        widget.onLoginSuccess(id.toInt());
        return;
      }

      final mensaje = result['message']?.toString() ??
          'No pudimos iniciar sesión. Intenta nuevamente.';

      setState(() {
        _errorMessage = mensaje;
      });
    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage =
            'No pudimos iniciar sesión. Intenta nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // ENCABEZADO INSTITUCIONAL
  // ==========================================

  Widget _encabezado() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/LogoUNI1.png',
            height: 145,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'BRÚJULA UNI',
          textAlign: TextAlign.center,
          style: BrujulaTipografia.principal(
            size: 29,
          ).copyWith(
            color: _acento,
            letterSpacing: 0.7,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Acompañando tu formación integral',
          textAlign: TextAlign.center,
          style: BrujulaTipografia.cuerpo(
            size: 13.5,
          ).copyWith(
            color: _secundario,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BANNER INSTITUCIONAL
  // ==========================================

  Widget _banner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _oscuro ? 0.20 : 0.07,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/bannerFIM.jpg',
          height: 185,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ==========================================
  // CAMPOS DEL FORMULARIO
  // ==========================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onChanged,
    String? errorText,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization capitalization =
        TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      autocorrect: false,
      enableSuggestions: !isPassword,
      textInputAction:
          isPassword ? TextInputAction.done : TextInputAction.next,
      onChanged: (_) => onChanged(),
      onFieldSubmitted: isPassword
          ? (_) => _login()
          : (_) => FocusScope.of(context).nextFocus(),
      style: BrujulaTipografia.cuerpo(
        size: 14,
      ).copyWith(
        color: _texto,
      ),
      cursorColor: _acento,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: BrujulaTipografia.cuerpo(
          size: 11.5,
        ).copyWith(
          color: _colorAviso,
          height: 1.35,
        ),
        labelStyle: BrujulaTipografia.secundario(
          size: 12.5,
        ).copyWith(
          color: _secundario,
        ),
        floatingLabelStyle: BrujulaTipografia.boton(
          size: 12,
        ).copyWith(
          color: _acento,
        ),
        prefixIcon: Icon(
          icon,
          color: _acento,
          size: 21,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: _borde,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: _acento,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: _borde,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: _colorAviso,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: _colorAviso,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // AVISO DISCRETO DE ACCESO
  // ==========================================

  Widget _mensajeError() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _colorAviso,
            size: 17,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              _errorMessage!,
              style: BrujulaTipografia.cuerpo(
                size: 12,
              ).copyWith(
                color: _colorAviso,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTÓN INGRESAR
  // ==========================================

  Widget _botonIngresar() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: FilledButton(
        onPressed: _loading ? null : _login,
        style: FilledButton.styleFrom(
          backgroundColor: BrujulaColores.rojoUNI,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              BrujulaColores.rojoUNI.withValues(
            alpha: 0.80,
          ),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'INGRESAR',
                style: BrujulaTipografia.boton(
                  size: 14,
                  color: Colors.white,
                ).copyWith(
                  letterSpacing: 0.7,
                ),
              ),
      ),
    );
  }

  // ==========================================
  // PANTALLA PRINCIPAL
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: BrujulaTipografia.aplicar(
        Theme.of(context),
      ),
      child: Scaffold(
        backgroundColor: _fondo,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 25,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _encabezado(),

                    const SizedBox(height: 24),

                    _banner(),

                    const SizedBox(height: 27),

                    // CORREO ELECTRÓNICO
                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      onChanged: _limpiarAvisoCorreo,
                    ),

                    const SizedBox(height: 13),

                    // CONTRASEÑA
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      errorText: _passwordError,
                      onChanged: _limpiarAvisoPassword,
                      suffixIcon: IconButton(
                        tooltip: _isPasswordVisible
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible =
                                !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _secundario,
                          size: 21,
                        ),
                      ),
                    ),

                    // MENSAJE GENERAL DISCRETO
                    _mensajeError(),

                    const SizedBox(height: 23),

                    _botonIngresar(),

                    const SizedBox(height: 24),

                    Text(
                      'v.3',
                      style: BrujulaTipografia.secundario(
                        size: 11,
                      ).copyWith(
                        color: _secundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
