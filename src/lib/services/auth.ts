// src/lib/services/auth.ts
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  type User as FirebaseUser
} from 'firebase/auth';
import { getFirebaseAuth } from '../config/firebase';
import { getDocById } from './firestore';

export interface AuthUser {
  uid: string;
  nombre: string;
  email: string;
  rol: 'publico' | 'miembro' | 'admin' | 'dev';
  foto_url: string;
  baneado: boolean;
}

interface UsuarioFirestore {
  nombre?: string;
  email?: string;
  rol?: string;
  fotoUrl?: string;
  baneado?: boolean;
}

function mapUsuario(uid: string, data: UsuarioFirestore, emailAuth: string): AuthUser {
  return {
    uid,
    nombre: data.nombre ?? emailAuth.split('@')[0] ?? 'Usuario',
    email: data.email ?? emailAuth,
    rol: (data.rol as AuthUser['rol']) ?? 'publico',
    foto_url: data.fotoUrl ?? '',
    baneado: data.baneado === true
  };
}

async function cargarUsuarioFirestore(user: FirebaseUser): Promise<AuthUser> {
  const data = await getDocById<UsuarioFirestore>(
    'usuarios',
    user.uid,
    (_id, d) => d as UsuarioFirestore
  );

  if (!data) {
    // Primera vez que entra: crea doc mínimo si permitido por reglas.
    return {
      uid: user.uid,
      nombre: user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
      email: user.email ?? '',
      rol: 'publico',
      foto_url: user.photoURL ?? '',
      baneado: false
    };
  }

  return mapUsuario(user.uid, data, user.email ?? '');
}

export const authService = {
  async login(email: string, password: string): Promise<AuthUser> {
    const auth = getFirebaseAuth();
    const cred = await signInWithEmailAndPassword(auth, email.trim(), password);
    return cargarUsuarioFirestore(cred.user);
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
        } catch {
          resolve(null);
        }
      });
    });
  },

  onAuthChange(cb: (user: FirebaseUser | null) => void): () => void {
    return onAuthStateChanged(getFirebaseAuth(), cb);
  }
};