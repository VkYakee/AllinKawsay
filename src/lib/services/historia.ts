// src/lib/services/historia.ts
import { doc, getDoc, onSnapshot, setDoc, serverTimestamp, Timestamp } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

export interface Historia {
  contenido: string;
  actualizadoPor: string;
  fechaActualizacion: string | null;
}

const DOC_ID = 'principal';

function mapHistoria(id: string, data: Record<string, unknown>): Historia {
  const ts = data.fechaActualizacion;
  let fecha: string | null = null;
  if (ts instanceof Timestamp) fecha = ts.toDate().toISOString();
  else if (typeof ts === 'string') fecha = ts;

  return {
    contenido: typeof data.contenido === 'string' ? data.contenido : '',
    actualizadoPor: typeof data.actualizadoPor === 'string' ? data.actualizadoPor : '',
    fechaActualizacion: fecha
  };
}

export const historiaService = {
  async obtener(): Promise<Historia> {
    const db = getFirebaseDb();
    const snap = await getDoc(doc(db, 'historia', DOC_ID));
    if (!snap.exists()) {
      return { contenido: '', actualizadoPor: '', fechaActualizacion: null };
    }
    return mapHistoria(snap.id, snap.data() as Record<string, unknown>);
  },

  stream(
    onData: (h: Historia) => void,
    onError: (err: Error) => void
  ): () => void {
    const db = getFirebaseDb();
    return onSnapshot(
      doc(db, 'historia', DOC_ID),
      (snap) => {
        if (!snap.exists()) {
          onData({ contenido: '', actualizadoPor: '', fechaActualizacion: null });
          return;
        }
        onData(mapHistoria(snap.id, snap.data() as Record<string, unknown>));
      },
      (err) => onError(err as Error)
    );
  },

  async guardar(contenido: string, autor: string): Promise<void> {
    const db = getFirebaseDb();
    await setDoc(doc(db, 'historia', DOC_ID), {
      contenido: contenido.trim(),
      actualizadoPor: autor,
      fechaActualizacion: serverTimestamp()
    });
  }
};