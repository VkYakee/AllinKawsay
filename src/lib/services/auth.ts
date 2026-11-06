// src/lib/services/auth.ts
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  createUserWithEmailAndPassword,
  sendEmailVerification,
  sendPasswordResetEmail,
  updateProfile,
  type User as FirebaseUser
} from 'firebase/auth';
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';
import { getFirebaseAuth, getFirebaseDb } from '../config/firebase';
import { getDocById } from './firestore';

export interface AuthUser {
  uid: string;
  nombre: string;
  email: string;
  rol: 'publico' | 'miembro' | 'admin' | 'dev';
  foto_url: string;
  baneado: boolean;
  email_verified: boolean;
}

interface UsuarioFirestore {
  nombre?: string;
  email?: string;
  rol?: string;
  fotoUrl?: string;
  baneado?: boolean;
}

function normalizarRol(rol: unknown): AuthUser['rol'] {
  return rol === 'miembro' || rol === 'admin' || rol === 'dev' || rol === 'publico'
    ? rol
    : 'publico';
}

function mapUsuario(
  uid: string,
  data: UsuarioFirestore,
  emailAuth: string,
  emailVerified: boolean
): AuthUser {
  return {
    uid,
    nombre: data.nombre ?? emailAuth.split('@')[0] ?? 'Usuario',
    email: data.email ?? emailAuth,
    rol: normalizarRol(data.rol),
    foto_url: data.fotoUrl ?? '',
    baneado: data.baneado === true,
    email_verified: emailVerified
  };
}

async function cargarUsuarioFirestore(user: FirebaseUser): Promise<AuthUser> {
  const data = await getDocById<UsuarioFirestore>(
    'usuarios',
    user.uid,
    (_id, d) => d as UsuarioFirestore
  );

  if (!data) {
    return {
      uid: user.uid,
      nombre: user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
      email: user.email ?? '',
      rol: 'publico',
      foto_url: user.photoURL ?? '',
      baneado: false,
      email_verified: user.emailVerified
    };
  }

  return mapUsuario(user.uid, data, user.email ?? '', user.emailVerified);
}

export const authService = {
  async login(email: string, password: string): Promise<AuthUser> {
    const auth = getFirebaseAuth();
    const cred = await signInWithEmailAndPassword(auth, email.trim(), password);
    return cargarUsuarioFirestore(cred.user);
  },

  async registrar(
    email: string,
    password: string,
    nombre: string
  ): Promise<AuthUser> {
    const auth = getFirebaseAuth();
    const cred = await createUserWithEmailAndPassword(
      auth,
      email.trim(),
      password
    );

    await updateProfile(cred.user, { displayName: nombre });

    // Crear documento en Firestore
    const db = getFirebaseDb();
    await setDoc(doc(db, 'usuarios', cred.user.uid), {
      nombre: nombre.trim(),
      email: email.trim(),
      rol: 'publico',
      fotoUrl: '',
      baneado: false,
      favoritos: [],
      notasPorCancion: {},
      notasPorEvento: {},
      notasPorRecuerdo: {},
      fechaRegistro: serverTimestamp()
    });

    // Enviar email de verificación (usa el SMTP de Resend que configuraste
    // o el genérico de Firebase)
    try {
      await sendEmailVerification(cred.user);
    } catch (e) {
      console.warn('No se pudo enviar verificación:', e);
    }

    return {
      uid: cred.user.uid,
      nombre: nombre.trim(),
      email: email.trim(),
      rol: 'publico',
      foto_url: '',
      baneado: false,
      email_verified: false
    };
  },

  async reenviarVerificacion(): Promise<void> {
    const auth = getFirebaseAuth();
    if (!auth.currentUser) throw new Error('No hay sesión activa');
    await sendEmailVerification(auth.currentUser);
  },

  async recargarUsuario(): Promise<boolean> {
    const auth = getFirebaseAuth();
    if (!auth.currentUser) return false;
    await auth.currentUser.reload();
    return auth.currentUser.emailVerified;
  },

  async resetPassword(email: string): Promise<void> {
    const auth = getFirebaseAuth();
    await sendPasswordResetEmail(auth, email.trim());
  },

  async logout(): Promise<void> {
    const auth = getFirebaseAuth();
    await signOut(auth);
  },

  async currentUser(): Promise<AuthUser | null> {
    const auth = getFirebaseAuth();
    return new Promise((resolve) => {
      const unsub = onAuthStateChanged(auth, async (user) => {
        unsub();
        if (!user) {
          resolve(null);
          return;
        }
        try {
          resolve(await cargarUsuarioFirestore(user));
        } catch (error) {
          // Un fallo temporal de Firestore no significa que Firebase Auth haya
          // perdido la sesión. Se conserva el acceso básico sin privilegios.
          console.warn('No se pudo leer el perfil de Firestore; se restaura como usuario público:', error);
          resolve(mapUsuario(user.uid, {}, user.email ?? '', user.emailVerified));
        }
      });
    });
  },

  onAuthChange(cb: (user: FirebaseUser | null) => void): () => void {
    return onAuthStateChanged(getFirebaseAuth(), cb);
  }
};

export function traducirErrorAuth(e: unknown): string {
  const code =
    typeof e === 'object' && e !== null && 'code' in e
      ? String((e as { code: unknown }).code)
      : '';

  switch (code) {
    case 'auth/invalid-email':
      return 'El email no es válido';
    case 'auth/user-not-found':
      return 'No existe una cuenta con ese email';
    case 'auth/wrong-password':
    case 'auth/invalid-credential':
      return 'Email o contraseña incorrectos';
    case 'auth/email-already-in-use':
      return 'Ese email ya está registrado';
    case 'auth/weak-password':
      return 'La contraseña debe tener al menos 6 caracteres';
    case 'auth/too-many-requests':
      return 'Demasiados intentos. Espera unos minutos';
    case 'auth/network-request-failed':
      return 'Sin conexión a internet';
    default:
      return 'Error al autenticar. Intenta de nuevo';
  }
}