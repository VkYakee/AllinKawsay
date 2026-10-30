// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio_background/just_audio_background.dart';

// Core
import 'core/design/app_theme.dart';
import 'core/design/colors.dart';
import 'core/design/motion.dart';
import 'core/design/tokens.dart';
import 'core/design/typography.dart';

// Modelos y Servicios (Viejos, se irán migrando)
import 'models/usuario.dart';
import 'services/auth_service.dart';
import 'services/onesignal_service.dart';
import 'services/screen_security_service.dart';
import 'services/update_service.dart';
import 'services/usuario_service.dart';
import 'theme/theme_provider.dart'; // Lo mantenemos por ahora

// Pantallas
import 'features/auth/screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verificacion_pendiente_screen.dart';
import 'widgets/dialogo_actualizacion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  } catch (e) {
    debugPrint('⚠️ Error al inicializar audio background: $e');
  }

  await OneSignalService.init();
  await ThemeProvider.cargar();

  runApp(const AllinKawsayApp());
}

class AllinKawsayApp extends StatelessWidget {
  const AllinKawsayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.mode,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Allin Kawsay',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: modo,
          themeAnimationDuration: AppMotion.normal,
          themeAnimationCurve: AppMotion.easeOut,
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
                backgroundColor: AppColors.fondoOscuro,
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
                    return VerificacionPendienteScreen(email: authUser.email ?? 'tu correo');
                  }

                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      backgroundColor: AppColors.fondoOscuro,
                      body: Center(child: CircularProgressIndicator(color: AppColors.dorado)),
                    );
                  }

                  if (u != null && u.baneado) {
                    return const _CuentaSuspendidaScreen();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _chequearActualizacion();
                  });

                  return HomeScreen(
                    nombreUsuario: authUser.displayName ?? authUser.email?.split('@').first ?? 'Usuario',
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

// Movemos la pantalla de cuenta suspendida aquí para mantener el main limpio
class _CuentaSuspendidaScreen extends StatelessWidget {
  const _CuentaSuspendidaScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Sp.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.15),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: const Icon(Icons.block, size: 60, color: Colors.red),
                ),
                const SizedBox(height: Sp.xxxl),
                Text('Cuenta suspendida', style: AppText.h2.copyWith(color: AppColors.dorado)),
                const SizedBox(height: Sp.lg),
                Text(
                  'Tu acceso a la app fue suspendido por un administrador del grupo.\n\nSi crees que es un error, contactate con la directiva.',
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(color: AppColors.textDarkSecundario, height: 1.6),
                ),
                const SizedBox(height: Sp.huge),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('CERRAR SESIÓN', style: TextStyle(letterSpacing: 1.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dorado,
                      side: const BorderSide(color: AppColors.dorado, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
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