// src/lib/services/canciones.ts
import { Timestamp, deleteDoc, doc, updateDoc } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';
import {
  getCol,
  streamCol,
  getDocById,
  addDocument,
  type FirestoreData
} from './firestore';

export interface Columna {
  nota7: string;
  nota6: string;
}

export interface Estrofa {
  columnas: Columna[];
  bis: boolean;
}

export interface Cancion {
  id: string;
  titulo: string;
  autor: string;
  ritmo: string;
  region: string;
  imagen_url: string;
  audio_url: string;
  video_url: string;
  descripcion: string;
  reproducciones: number;
  estrofas: Estrofa[];
  letra: string;
  tags: string[];
  categoriaId: string;
}

export interface CancionInput {
  titulo: string;
  autor: string;
  ritmo: string;
  region: string;
  descripcion: string;
  imagen_url: string;
  audio_url: string;
  video_url: string;
  letra: string;
  tags: string[];
  estrofas: Estrofa[];
}

function mapColumna(raw: unknown): Columna {
  const d = (raw ?? {}) as Record<string, unknown>;
  return {
    nota7: typeof d.nota7 === 'string' ? d.nota7 : '',
    nota6: typeof d.nota6 === 'string' ? d.nota6 : ''
  };
}

function mapEstrofa(raw: unknown): Estrofa {
  const d = (raw ?? {}) as Record<string, unknown>;
  const columnas = Array.isArray(d.columnas) ? d.columnas.map(mapColumna) : [];
  return { columnas, bis: d.bis === true };
}

function mapCancion(id: string, data: FirestoreData): Cancion {
  const estrofasRaw = Array.isArray(data.estrofas) ? data.estrofas : [];
  const letrasRaw = Array.isArray(data.letras) ? data.letras : [];
  const letra =
    letrasRaw.length > 0
      ? letrasRaw
          .map((l) => {
            const obj = (l ?? {}) as Record<string, unknown>;
            return typeof obj.texto === 'string' ? obj.texto : '';
          })
          .filter((t) => t.trim().length > 0)
          .join('\n\n')
      : typeof data.letra === 'string'
        ? data.letra
        : '';

  return {
    id,
    titulo: typeof data.titulo === 'string' ? data.titulo : '',
    autor: typeof data.autor === 'string' ? data.autor : '',
    ritmo: typeof data.ritmo === 'string' ? data.ritmo : '',
    region: typeof data.region === 'string' ? data.region : '',
    imagen_url: typeof data.imagenUrl === 'string' ? data.imagenUrl : '',
    audio_url: typeof data.audioUrl === 'string' ? data.audioUrl : '',
    video_url: typeof data.videoUrl === 'string' ? data.videoUrl : '',
    descripcion: typeof data.descripcion === 'string' ? data.descripcion : '',
    reproducciones:
      typeof data.reproducciones === 'number' ? data.reproducciones : 0,
    estrofas: estrofasRaw.map(mapEstrofa),
    letra,
    tags: Array.isArray(data.tags)
      ? data.tags.filter((t): t is string => typeof t === 'string')
      : [],
    categoriaId: typeof data.categoriaId === 'string' ? data.categoriaId : ''
  };
}

export const cancionesService = {
  async listar(): Promise<Cancion[]> {
    return getCol('canciones', mapCancion);
  },

  stream(
    onData: (items: Cancion[]) => void,
    onError: (err: Error) => void
  ): () => void {
    return streamCol(
      'canciones',
      mapCancion,
      (items) => {
        items.sort((a, b) => a.titulo.localeCompare(b.titulo));
        onData(items);
      },
      onError
    );
  },

  async obtener(id: string): Promise<Cancion | null> {
    return getDocById('canciones', id, mapCancion);
  },

  async incrementarReproduccion(id: string): Promise<void> {
    const c = await getDocById<Cancion>('canciones', id, mapCancion);
    if (!c) return;
    await updateDoc(doc(getFirebaseDb(), 'canciones', id), {
      reproducciones: c.reproducciones + 1
    });
  },

  async crear(input: CancionInput, autorUid: string, autorNombre: string): Promise<string> {
    return addDocument('canciones', {
      titulo: input.titulo.trim(),
      autor: input.autor.trim(),
      ritmo: input.ritmo.trim(),
      region: input.region.trim(),
      descripcion: input.descripcion.trim(),
      imagenUrl: input.imagen_url,
      audioUrl: input.audio_url,
      videoUrl: input.video_url.trim(),
      letra: input.letra.trim(),
      letras: input.letra.trim()
        ? [{ titulo: '', texto: input.letra.trim() }]
        : [],
      tags: input.tags,
      categoriaId: input.categoriaId,
      estrofas: input.estrofas,
      reproducciones: 0,
      creadoPor: autorUid,
      creadorNombre: autorNombre,
      fechaCreacion: Timestamp.now()
    });
  },

  async actualizar(id: string, input: CancionInput): Promise<void> {
    await updateDoc(doc(getFirebaseDb(), 'canciones', id), {
      titulo: input.titulo.trim(),
      autor: input.autor.trim(),
      ritmo: input.ritmo.trim(),
      region: input.region.trim(),
      descripcion: input.descripcion.trim(),
      imagenUrl: input.imagen_url,
      audioUrl: input.audio_url,
      videoUrl: input.video_url.trim(),
      letra: input.letra.trim(),
      letras: input.letra.trim()
        ? [{ titulo: '', texto: input.letra.trim() }]
        : [],
      tags: input.tags,
      estrofas: input.estrofas,
      fechaEdicion: Timestamp.now()
    });
  },

  async eliminar(id: string): Promise<void> {
    await deleteDoc(doc(getFirebaseDb(), 'canciones', id));
  }
};