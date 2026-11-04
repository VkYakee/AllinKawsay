// src/lib/services/usuarios.ts
import { doc, updateDoc, deleteField, serverTimestamp } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';
import { getCol, streamCol, type FirestoreData } from './firestore';

export type Rol = 'publico' | 'miembro' | 'admin' | 'dev';

export interface Usuario {
  uid: string;
  nombre: string;
  email: string;
  rol: Rol;
  foto_url: string;
  baneado: boolean;
  fecha_registro: string | null;
}

function mapUsuario(id: string, data: FirestoreData): Usuario {
  let fecha: string | null = null;
  const ts = data.fechaRegistro;
  if (ts && typeof ts === 'object' && 'toDate' in ts && typeof ts.toDate === 'function') {
    fecha = (ts.toDate() as Date).toISOString();
  } else if (typeof ts === 'string') {
    fecha = ts;
  }

  const rol = typeof data.rol === 'string' ? data.rol : 'publico';

  return {
    uid: id,
    nombre: typeof data.nombre === 'string' ? data.nombre : 'Sin nombre',
    email: typeof data.email === 'string' ? data.email : '',
    rol: (['publico', 'miembro', 'admin', 'dev'].includes(rol) ? rol : 'publico') as Rol,
    foto_url: typeof data.fotoUrl === 'string' ? data.fotoUrl : '',
    baneado: data.baneado === true,
    fecha_registro: fecha
  };
}

export const usuariosService = {
  stream(
    onData: (items: Usuario[]) => void,
    onError: (err: Error) => void
  ): () => void {
    return streamCol(
      'usuarios',
      mapUsuario,
      (items) => {
        items.sort((a, b) => a.nombre.localeCompare(b.nombre));
        onData(items);
      },
      onError
    );
  },

  async listar(): Promise<Usuario[]> {
    return getCol('usuarios', mapUsuario);
  },

  async cambiarRol(uid: string, rol: Rol): Promise<void> {
    await updateDoc(doc(getFirebaseDb(), 'usuarios', uid), { rol });
  },

  async banear(uid: string): Promise<void> {
    await updateDoc(doc(getFirebaseDb(), 'usuarios', uid), {
      baneado: true,
      rol: 'publico'
    });
  },

  async desbanear(uid: string): Promise<void> {
    await updateDoc(doc(getFirebaseDb(), 'usuarios', uid), { baneado: false });
  }
};

export function rolLabel(rol: Rol): string {
  switch (rol) {
    case 'dev': return 'Desarrollador';
    case 'admin': return 'Administrador';
    case 'miembro': return 'Miembro';
    default: return 'Público';
  }
}

export function rolColor(rol: Rol): string {
  switch (rol) {
    case 'dev': return 'text-cyan-400';
    case 'admin': return 'text-dorado';
    case 'miembro': return 'text-emerald-400';
    default: return 'text-white/50';
  }
}