// src/lib/services/comentarios.ts
import {
  collection,
  addDoc,
  deleteDoc,
  doc,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  Timestamp
} from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

export interface Comentario {
  id: string;
  texto: string;
  autorUid: string;
  autorNombre: string;
  fecha: string;
}

function mapComentario(id: string, data: Record<string, unknown>): Comentario {
  const ts = data.fecha;
  let fecha = new Date().toISOString();
  if (ts instanceof Timestamp) fecha = ts.toDate().toISOString();
  else if (typeof ts === 'string') fecha = ts;

  return {
    id,
    texto: typeof data.texto === 'string' ? data.texto : '',
    autorUid: typeof data.autorUid === 'string' ? data.autorUid : '',
    autorNombre: typeof data.autorNombre === 'string' ? data.autorNombre : 'Anónimo',
    fecha
  };
}

export const comentariosService = {
  stream(
    cancionId: string,
    onData: (items: Comentario[]) => void,
    onError: (err: Error) => void
  ): () => void {
    const db = getFirebaseDb();
    const q = query(
      collection(db, 'canciones', cancionId, 'comentarios'),
      orderBy('fecha', 'asc')
    );
    return onSnapshot(
      q,
      (snap) => {
        onData(snap.docs.map((d) => mapComentario(d.id, d.data())));
      },
      (err) => onError(err as Error)
    );
  },

  async crear(
    cancionId: string,
    texto: string,
    autorUid: string,
    autorNombre: string
  ): Promise<void> {
    const db = getFirebaseDb();
    await addDoc(collection(db, 'canciones', cancionId, 'comentarios'), {
      texto: texto.trim(),
      autorUid,
      autorNombre,
      fecha: serverTimestamp()
    });
  },

  async eliminar(cancionId: string, comentarioId: string): Promise<void> {
    const db = getFirebaseDb();
    await deleteDoc(doc(db, 'canciones', cancionId, 'comentarios', comentarioId));
  }
};