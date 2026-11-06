// src/lib/services/categorias.ts
import { collection, doc, getDocs, limit, query, runTransaction, updateDoc, where, orderBy } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';
import {
  getCol,
  streamCol,
  addDocument,
  type FirestoreData
} from './firestore';

export interface Categoria {
  id: string;
  nombre: string;
  emoji: string;
  orden: number;
}

function mapCategoria(id: string, data: FirestoreData): Categoria {
  return {
    id,
    nombre: typeof data.nombre === 'string' ? data.nombre : '',
    emoji: typeof data.emoji === 'string' ? data.emoji : '📁',
    orden: typeof data.orden === 'number' ? data.orden : 0
  };
}

export const categoriasService = {
  stream(
    onData: (items: Categoria[]) => void,
    onError: (err: Error) => void
  ): () => void {
    return streamCol(
      'categorias',
      mapCategoria,
      (items) => {
        items.sort((a, b) => a.orden - b.orden || a.nombre.localeCompare(b.nombre));
        onData(items);
      },
      onError,
      orderBy('orden')
    );
  },

  async listar(): Promise<Categoria[]> {
    return getCol('categorias', mapCategoria, orderBy('orden'));
  },

  async crear(nombre: string, emoji: string, orden: number): Promise<void> {
    await addDocument('categorias', {
      nombre: nombre.trim(),
      emoji: emoji.trim() || '📁',
      orden
    });
  },

  async actualizar(id: string, nombre: string, emoji: string, orden: number): Promise<void> {
    await updateDoc(doc(getFirebaseDb(), 'categorias', id), {
      nombre: nombre.trim(),
      emoji: emoji.trim() || '📁',
      orden
    });
  },

  async eliminar(id: string): Promise<void> {
    const db = getFirebaseDb();
    const categoriaRef = doc(db, 'categorias', id);
    await runTransaction(db, async (transaction) => {
      // La comprobación y el borrado forman una única operación transaccional:
      // evita borrar la categoría entre la consulta y el delete.
      const asignadas = await transaction.get(
        query(collection(db, 'canciones'), where('categoriaId', '==', id), limit(1))
      );
      if (!asignadas.empty) {
        throw new Error('No se puede eliminar esta categoría porque todavía está asignada a una o más canciones. Reasigna esas canciones antes de eliminarla.');
      }
      transaction.delete(categoriaRef);
    });
  }
};