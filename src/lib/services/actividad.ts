// src/lib/services/actividad.ts
import {
  collection,
  addDoc,
  onSnapshot,
  orderBy,
  query,
  limit,
  serverTimestamp,
  Timestamp
} from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

export interface Actividad {
  id: string;
  accion: string;
  detalle: string;
  autor_uid: string;
  autor_nombre: string;
  fecha: string;
}

function mapActividad(id: string, data: Record<string, unknown>): Actividad {
  let fecha = new Date().toISOString();
  const ts = data.fecha;
  if (ts instanceof Timestamp) fecha = ts.toDate().toISOString();
  else if (typeof ts === 'string') fecha = ts;

  return {
    id,
    accion: typeof data.accion === 'string' ? data.accion : '',
    detalle: typeof data.detalle === 'string' ? data.detalle : '',
    autor_uid: typeof data.autorUid === 'string' ? data.autorUid : '',
    autor_nombre: typeof data.autorNombre === 'string' ? data.autorNombre : 'Anónimo',
    fecha
  };
}

export const actividadService = {
  async registrar(
    accion: string,
    detalle: string,
    autorUid: string,
    autorNombre: string
  ): Promise<void> {
    try {
      const db = getFirebaseDb();
      await addDoc(collection(db, 'actividad'), {
        accion,
        detalle,
        autorUid,
        autorNombre,
        fecha: serverTimestamp()
      });
    } catch {
      // silencioso: la actividad no debe romper la app
    }
  },

  stream(
    onData: (items: Actividad[]) => void,
    onError: (err: Error) => void,
    limite = 200
  ): () => void {
    const db = getFirebaseDb();
    const q = query(
      collection(db, 'actividad'),
      orderBy('fecha', 'desc'),
      limit(limite)
    );
    return onSnapshot(
      q,
      (snap) => onData(snap.docs.map((d) => mapActividad(d.id, d.data()))),
      (err) => onError(err as Error)
    );
  }
};

export function iconoActividad(accion: string): { icon: string; color: string } {
  if (accion.includes('crear')) return { icon: 'plus', color: 'text-emerald-400' };
  if (accion.includes('editar')) return { icon: 'edit', color: 'text-dorado' };
  if (accion.includes('eliminar') || accion.includes('banear')) return { icon: 'trash', color: 'text-red-400' };
  if (accion.includes('rol')) return { icon: 'user', color: 'text-blue-400' };
  if (accion.includes('historia')) return { icon: 'star', color: 'text-dorado' };
  return { icon: 'info', color: 'text-white/50' };
}

export function fechaRelativa(iso: string): string {
  const d = new Date(iso);
  const ahora = new Date();
  const min = Math.floor((ahora.getTime() - d.getTime()) / 60000);
  if (min < 1) return 'Ahora';
  if (min < 60) return `Hace ${min} min`;
  const h = Math.floor(min / 60);
  if (h < 24) return `Hace ${h} h`;
  const dias = Math.floor(h / 24);
  if (dias < 7) return `Hace ${dias} d`;
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`;
}