// src/lib/services/notas.ts
import { doc, updateDoc, deleteField } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

export type TipoNota = 'cancion' | 'evento' | 'recuerdo';

const CAMPO: Record<TipoNota, string> = {
  cancion: 'notasPorCancion',
  evento: 'notasPorEvento',
  recuerdo: 'notasPorRecuerdo'
};

export const notasService = {
  async guardar(uid: string, tipo: TipoNota, itemId: string, texto: string): Promise<void> {
    if (!uid) throw new Error('Sin sesión');
    const db = getFirebaseDb();
    const ref = doc(db, 'usuarios', uid);
    const campo = CAMPO[tipo];
    const limpio = texto.trim();

    if (!limpio) {
      await updateDoc(ref, { [`${campo}.${itemId}`]: deleteField() });
    } else {
      await updateDoc(ref, { [`${campo}.${itemId}`]: limpio });
    }
  },

  async eliminar(uid: string, tipo: TipoNota, itemId: string): Promise<void> {
    if (!uid) throw new Error('Sin sesión');
    const db = getFirebaseDb();
    const campo = CAMPO[tipo];
    await updateDoc(doc(db, 'usuarios', uid), {
      [`${campo}.${itemId}`]: deleteField()
    });
  }
};