import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get usuarioActual => _auth.currentUser;
  Stream<User?> get cambiosUsuario => _auth.authStateChanges();

  Future<User?> registrar(
      String email, String password, String nombre) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(nombre);
    await cred.user?.reload();

    // Creamos el doc con TODOS los campos que exige la regla.
    await _db.collection('usuarios').doc(cred.user!.uid).set({
      'nombre': nombre,
      'email': email,
      'rol': 'publico',
      'fotoUrl': '',
      'baneado': false,
      'favoritos': <String>[],
      'notasPorCancion': <String, String>{},
      'notasPorEvento': <String, String>{},
      'notasPorRecuerdo': <String, String>{},
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return _auth.currentUser;
  }

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Inicia sesión con Google.
  /// - Devuelve el User si todo va bien.
  /// - Devuelve null si el usuario cancela.
  /// - Crea automáticamente el doc en `usuarios/{uid}` la primera vez.
  Future<User?> loginConGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user;

    if (user != null) {
      await _asegurarDocumentoUsuario(user);
    }

    return user;
  }

  /// Crea el doc en Firestore si no existe (primer login con Google).
  /// Si ya existe, solo actualiza `fotoUrl` si estaba vacío.
  Future<void> _asegurarDocumentoUsuario(User user) async {
    final docRef = _db.collection('usuarios').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'nombre': user.displayName ?? 'Usuario',
        'email': user.email ?? '',
        'rol': 'publico',
        'fotoUrl': user.photoURL ?? '',
        'baneado': false,
        'favoritos': <String>[],
        'notasPorCancion': <String, String>{},
        'notasPorEvento': <String, String>{},
        'notasPorRecuerdo': <String, String>{},
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
    } else {
      final data = doc.data();
      if ((data?['fotoUrl'] ?? '').toString().isEmpty &&
          (user.photoURL ?? '').isNotEmpty) {
        await docRef.update({'fotoUrl': user.photoURL});
      }
    }
  }

  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }
}