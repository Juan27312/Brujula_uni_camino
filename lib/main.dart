import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:brujula_uni/login/login.dart';
import 'package:brujula_uni/service/aparienciaService.dart';
import 'package:brujula_uni/service/brujulaConexionService.dart';
import 'package:brujula_uni/util/tiempoDeUso.dart';
import 'package:brujula_uni/vistas/Bienvenida.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// =====================================================
// IDENTIDAD CROMÁTICA DE BRÚJULA UNI
// =====================================================

// Modo claro
const Color _fondoClaro = Color(0xFFF7F4EC);
const Color _superficieClara = Color(0xFFFFFFFF);
const Color _textoClaro = Color(0xFF262525);
const Color _secundarioClaro = Color(0xFF716C65);
const Color _bordeClaro = Color(0xFFE9E3D6);

const Color _rojoUNI = Color(0xFF7D1914);
const Color _cremaUNI = Color(0xFFEFE7D4);

// Modo oscuro
const Color _fondoOscuro = Color(0xFF191716);
const Color _superficieOscura = Color(0xFF282422);
const Color _superficieElevada = Color(0xFF342D25);
const Color _textoOscuro = Color(0xFFF3EEE5);
const Color _secundarioOscuro = Color(0xFFB9B2A9);
const Color _bordeOscuro = Color(0xFF403A37);

const Color _rojoOscuroInteractivo = Color(0xFFD98A80);

// =====================================================
// TEMA CLARO
// =====================================================

ThemeData _crearTemaClaro() {
  final esquema = ColorScheme.fromSeed(
    seedColor: _rojoUNI,
    brightness: Brightness.light,
  ).copyWith(
    primary: _rojoUNI,
    onPrimary: Colors.white,
    primaryContainer: _cremaUNI,
    onPrimaryContainer: _rojoUNI,
    surface: _superficieClara,
    onSurface: _textoClaro,
    onSurfaceVariant: _secundarioClaro,
    surfaceContainerLow: _fondoClaro,
    surfaceContainer: _cremaUNI,
    surfaceContainerHigh: const Color(0xFFE8DECE),
    outline: const Color(0xFFC8BFB3),
    outlineVariant: _bordeClaro,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: esquema,
    scaffoldBackgroundColor: _fondoClaro,
    appBarTheme: const AppBarTheme(
      backgroundColor: _fondoClaro,
      foregroundColor: _textoClaro,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _superficieClara,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: _bordeClaro,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _bordeClaro,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: _rojoUNI,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _superficieClara,
      labelStyle: const TextStyle(
        color: _secundarioClaro,
      ),
      floatingLabelStyle: const TextStyle(
        color: _rojoUNI,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _bordeClaro,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _rojoUNI,
          width: 1.5,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _rojoUNI,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _rojoUNI,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _rojoUNI,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _superficieClara,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: _superficieClara,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

// =====================================================
// TEMA OSCURO
// =====================================================

ThemeData _crearTemaOscuro() {
  final esquema = ColorScheme.fromSeed(
    seedColor: _rojoOscuroInteractivo,
    brightness: Brightness.dark,
  ).copyWith(
    primary: _rojoOscuroInteractivo,
    onPrimary: _fondoOscuro,
    primaryContainer: _superficieElevada,
    onPrimaryContainer: _textoOscuro,
    surface: _superficieOscura,
    onSurface: _textoOscuro,
    onSurfaceVariant: _secundarioOscuro,
    surfaceContainerLow: _fondoOscuro,
    surfaceContainer: _superficieOscura,
    surfaceContainerHigh: _superficieElevada,
    outline: const Color(0xFF6B605A),
    outlineVariant: _bordeOscuro,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: esquema,
    scaffoldBackgroundColor: _fondoOscuro,
    appBarTheme: const AppBarTheme(
      backgroundColor: _fondoOscuro,
      foregroundColor: _textoOscuro,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _superficieOscura,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: _bordeOscuro,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _bordeOscuro,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: _rojoOscuroInteractivo,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _superficieOscura,
      labelStyle: const TextStyle(
        color: _secundarioOscuro,
      ),
      floatingLabelStyle: const TextStyle(
        color: _rojoOscuroInteractivo,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _bordeOscuro,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _rojoOscuroInteractivo,
          width: 1.5,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _rojoOscuroInteractivo,
        foregroundColor: _fondoOscuro,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _rojoOscuroInteractivo,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _rojoOscuroInteractivo,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _superficieOscura,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: _superficieOscura,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

// =====================================================
// BARRAS DEL SISTEMA ANDROID
// =====================================================

SystemUiOverlayStyle _estiloSistema(bool oscuro) {
  return SystemUiOverlayStyle(
    // En edge-to-edge el contenido puede aparecer
    // detrás de las barras del sistema.
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: oscuro ? Brightness.light : Brightness.dark,
    statusBarBrightness: oscuro ? Brightness.dark : Brightness.light,

    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness:
        oscuro ? Brightness.light : Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  );
}

// =====================================================
// INICIALIZACIÓN
// =====================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // Recuperar la preferencia antes de iniciar.
  await AparienciaService.instancia.cargar();

  await Supabase.initialize(
    url: 'https://qwaoqfecspqrwggkhddr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6'
        'InF3YW9xZmVjc3BxcndnZ2toZGRyIiwicm9sZSI6'
        'ImFub24iLCJpYXQiOjE3NTc2MjY0MDIsImV4cCI6'
        'MjA3MzIwMjQwMn0.'
        'OBIz5jiM5H7WGkPOilQLrFvfwwvLf4r8aUFiexCyl0o',
  );

  runApp(const Main());
}

// =====================================================
// APLICACIÓN
// =====================================================

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int? userId;

  final AparienciaService _apariencia = AparienciaService.instancia;

  @override
  void initState() {
    super.initState();
    _apariencia.addListener(_actualizarApariencia);
  }

  @override
  void dispose() {
    _apariencia.removeListener(_actualizarApariencia);
    super.dispose();
  }

  void _actualizarApariencia() {
    if (mounted) {
      setState(() {});
    }
  }

  void _iniciarSesion(int id) {
    if (!mounted) return;

    setState(() {
      userId = id;
    });
  }

  void _cerrarSesion() {
    if (!mounted || userId == null) return;

    BrujulaConexionService.instancia.cerrarSesion();

    setState(() {
      userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final idActual = userId;
    final oscuro = _apariencia.modo == ThemeMode.dark;

    final aplicacion = MaterialApp(
      key: ValueKey(
        idActual == null ? 'brujula-login' : 'brujula-estudiante-$idActual',
      ),
      debugShowCheckedModeBanner: false,

      theme: _crearTemaClaro(),
      darkTheme: _crearTemaOscuro(),

      // Nunca depender del tema de Android.
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,

      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _estiloSistema(oscuro),
          child: ColoredBox(
            color: oscuro ? _fondoOscuro : _fondoClaro,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },

      home: idActual == null
          ? Login(
              onLoginSuccess: _iniciarSesion,
            )
          : BienvenidaPage(
              key: ValueKey('bienvenida-$idActual'),
              userId: idActual,
              onCerrarSesion: _cerrarSesion,
            ),
    );

    return idActual == null
        ? aplicacion
        : AppLifecycleManager(
            key: ValueKey(
              'tiempo-de-uso-$idActual',
            ),
            userId: idActual,
            child: aplicacion,
          );
  }
}
