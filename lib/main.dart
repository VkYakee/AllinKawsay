// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'models/usuario.dart';
import 'services/auth_service.dart';
import 'services/onesignal_service.dart';
import 'services/screen_security_service.dart';
import 'services/update_service.dart';
import 'services/usuario_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verificacion_pendiente_screen.dart';
import 'theme/colors.dart';
import 'theme/theme_provider.dart';
import 'widgets/dialogo_actualizacion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // MODO EDGE-TO-EDGE (Pantalla completa estilo iOS)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  await Firebase.initializeApp();

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.allinkawsay.app.channel.audio',
      androidNotificationChannelName: 'Reproducción de audio',
      androidNotificationOngoing: true,
      // 🎨 Mejora premium para la notificación del reproductor
      androidNotificationIcon: 'mipmap/ic_launcher', 
    );
  } catch (e) {
    debugPrint('⚠️ Error al inicializar audio background: $e');
  }

  await OneSignalService.init();
  await ThemeProvider.cargar();

  // ❌ SE ELIMINÓ LA PETICIÓN AUTOMÁTICA DE NOTIFICACIONES AQUÍ

  runApp(const SikurisApp());
}

class SikurisApp extends StatelessWidget {
  const SikurisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.mode,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Allin Kawsay',
          debugShowCheckedModeBanner: false,
          theme: _temaClaro(),
          darkTheme: _temaOscuro(),
          themeMode: modo,
          // TRANSICIONES HORIZONTALES ESTILO iOS
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
              child: child!,
            );
          },
          home: const _AuthGate(),
        );
      },
    );
  }
ThemeData _temaClaro() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF2F2F7), // Gris iOS
    colorScheme: const ColorScheme.light(
      primary: AppColors.granate,
      onPrimary: AppColors.dorado,
      secondary: AppColors.dorado,
      onSecondary: AppColors.negro,
      surface: AppColors.blanco,
      onSurface: AppColors.negro,
      outline: AppColors.dorado,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.dorado,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5),
      iconTheme: IconThemeData(color: AppColors.dorado),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.granate,
        foregroundColor: AppColors.dorado,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.granate),
      floatingLabelStyle: const TextStyle(color: AppColors.granate, fontWeight: FontWeight.bold),
      hintStyle: TextStyle(color: AppColors.negro.withOpacity(0.4)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.dorado, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.dorado.withOpacity(0.5), width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.negro,
      contentTextStyle: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.w500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.granate),
      contentTextStyle: TextStyle(fontSize: 15, color: AppColors.negro.withOpacity(0.8), height: 1.5),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      showDragHandle: false,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.dorado,
      unselectedLabelColor: Colors.white70,
      indicatorColor: AppColors.dorado,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
    ),
  );
}
  ThemeData _temaOscuro() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000), // Negro OLED
      colorScheme: const ColorScheme.dark(
        primary: AppColors.granate,
        onPrimary: AppColors.dorado,
        secondary: AppColors.dorado,
        onSecondary: AppColors.negro,
        surface: const Color(0xFF1A1A1A),
        onSurface: AppColors.textoOscuroClaro,
        outline: AppColors.dorado,
        error: Color(0xFFCF6679),
        onError: AppColors.negro,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
            color: AppColors.dorado,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5),
        iconTheme: IconThemeData(color: AppColors.dorado),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.granate,
          foregroundColor: AppColors.dorado,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.dorado),
        floatingLabelStyle: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: AppColors.textoOscuroMedio.withOpacity(0.6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.dorado, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.dorado.withOpacity(0.5), width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.granateOscuro,
        contentTextStyle: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dorado),
        contentTextStyle: TextStyle(fontSize: 15, color: AppColors.textoOscuroClaro.withOpacity(0.85), height: 1.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        showDragHandle: false,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.dorado,
        unselectedLabelColor: Colors.white54,
        indicatorColor: AppColors.dorado,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  static final DateTime _fechaCorteVerificacion = DateTime(2026, 10, 15, 0, 0, 0);

  StreamSubscription? _userSub;
  String? _ultimoRol;
  String? _ultimoUid;
  bool _chequeoUpdateYaHecho = false;

  @override
  void initState() {
    super.initState();
    _userSub = UsuarioService().miUsuario().listen((u) {
      final rol = u?.rol;
      if (rol == _ultimoRol) return;
      _ultimoRol = rol;

      if (rol == 'publico') {
        ScreenSecurityService.enable();
      } else {
        ScreenSecurityService.disable();
      }
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> _chequearActualizacion() async {
    if (_chequeoUpdateYaHecho) return;
    _chequeoUpdateYaHecho = true;

    try {
      final info = await UpdateService.hayActualizacion();
      if (info == null) return;
      if (!mounted) return;

      await DialogoActualizacion.mostrar(context, info);
    } catch (_) {}
  }

  void _syncOneSignal(String? uid) {
    if (uid == _ultimoUid) return;
    _ultimoUid = uid;
    if (uid != null) {
      OneSignalService.login(uid);
    } else {
      OneSignalService.logout();
    }
  }

  bool _necesitaVerificar(User user, Usuario? usuarioFirestore) {
    if (user.emailVerified) return false;

    final esGoogle = user.providerData.any((info) => info.providerId == 'google.com');
    if (esGoogle) return false;

    final creationTime = user.metadata.creationTime;
    if (creationTime != null) {
      if (creationTime.isBefore(_fechaCorteVerificacion)) return false;
      return true;
    }

    final fechaRegistro = usuarioFirestore?.fechaRegistro;
    if (fechaRegistro == null) return false;
    if (fechaRegistro.isBefore(_fechaCorteVerificacion)) return false;
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: VerificacionRefresh.notifier,
      builder: (context, _, __) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.negro,
                body: Center(child: CircularProgressIndicator(color: AppColors.dorado)),
              );
            }

            if (authSnap.hasData && authSnap.data != null) {
              final authUser = authSnap.data!;
              _syncOneSignal(authUser.uid);

              return StreamBuilder<Usuario?>(
                stream: UsuarioService().miUsuario(),
                builder: (context, userSnap) {
                  final u = userSnap.data;

                  if (_necesitaVerificar(authUser, u)) {
                    ScreenSecurityService.disable();
                    return VerificacionPendienteScreen(
                      email: authUser.email ?? 'tu correo',
                    );
                  }

                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      backgroundColor: AppColors.negro,
                      body: Center(child: CircularProgressIndicator(color: AppColors.dorado)),
                    );
                  }

                  if (u != null && u.baneado) {
                    return const CuentaSuspendidaScreen();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _chequearActualizacion();
                  });

                  return HomeScreen(
                    nombreUsuario: authUser.displayName ??
                        authUser.email?.split('@').first ??
                        'Usuario',
                  );
                },
              );
            }

            _syncOneSignal(null);
            ScreenSecurityService.disable();
            return const LoginScreen();
          },
        );
      },
    );
  }
}

class CuentaSuspendidaScreen extends StatelessWidget {
  const CuentaSuspendidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.15),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: const Icon(Icons.block, size: 60, color: Colors.red),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Cuenta suspendida',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dorado,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu acceso a la app fue suspendido por un administrador del grupo.\n\nSi crees que es un error, contactate con la directiva.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.dorado.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('CERRAR SESIÓN', style: TextStyle(letterSpacing: 1.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dorado,
                      side: const BorderSide(color: AppColors.dorado, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await AuthService().logout();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}