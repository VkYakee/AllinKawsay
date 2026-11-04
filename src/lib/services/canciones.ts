// src/lib/services/canciones.ts
import { orderBy } from 'firebase/firestore';
import {
  getCol,
  streamCol,
  getDocById,
  updateDocument,
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
  const letra = letrasRaw.length > 0
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
      : []
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
    return streamCol('canciones', mapCancion, (items) => {
      items.sort((a, b) => a.titulo.localeCompare(b.titulo));
      onData(items);
    }, onError, orderBy('titulo'));
  },

  async obtener(id: string): Promise<Cancion | null> {
    return getDocById('canciones', id, mapCancion);
  },

  async incrementarReproduccion(id: string): Promise<void> {
    const c = await getDocById<Cancion>('canciones', id, mapCancion);
    if (!c) return;
    await updateDocument('canciones', id, {
      reproducciones: c.reproducciones + 1
    });
  }
};