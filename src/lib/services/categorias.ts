// src/lib/services/categorias.ts
import { doc, deleteDoc, updateDoc, orderBy } from 'firebase/firestore';
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
    await deleteDoc(doc(getFirebaseDb(), 'categorias', id));
  }
};