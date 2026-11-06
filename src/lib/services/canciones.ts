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
  timings7?: number[];
  timings6?: number[];
}

export interface Estrofa {
  columnas: Columna[];
  bis: boolean;
}

export interface Letra {
  titulo: string;
  texto: string;
}

export interface Cancion {
  id: string;
  titulo: string;
  autor: string;
  tipo: string;
  ritmo: string;
  region: string;
  numerofonia: string;
  imagen_url: string;
  audio_url: string;
  video_url: string;
  descripcion: string;
  reproducciones: number;
  estrofas: Estrofa[];
  letra: string;
  letras: Letra[];
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
  letrasOriginales?: Letra[];
  tags: string[];
  categoriaId: string;
  estrofas: Estrofa[];
}

function asRecord(raw: unknown): Record<string, unknown> {
  return raw && typeof raw === 'object' ? raw as Record<string, unknown> : {};
}

function mapColumna(raw: unknown): Columna {
  const d = asRecord(raw);
  const timings = (value: unknown) => Array.isArray(value)
    ? value.filter((n): n is number => typeof n === 'number' && Number.isFinite(n)).map(Math.trunc)
    : [];
  return {
    nota7: typeof d.nota7 === 'string' ? d.nota7 : '',
    nota6: typeof d.nota6 === 'string' ? d.nota6 : '',
    timings7: timings(d.timings7),
    timings6: timings(d.timings6)
  };
}

/** Admite el esquema actual y los formatos históricos que leía el modelo Dart. */
function mapEstrofa(raw: unknown): Estrofa {
  const d = asRecord(raw);
  if (Array.isArray(d.columnas)) {
    return { columnas: d.columnas.map(mapColumna), bis: d.bis === true };
  }

  if (Array.isArray(d.eventos)) {
    const columnas: Columna[] = [];
    for (const rawEvent of d.eventos) {
      const event = asRecord(rawEvent);
      const tipo = typeof event.tipo === 'number' ? event.tipo : 1;
      const valor = typeof event.valor === 'string' ? event.valor : '';
      if (tipo === 2) {
      } else if (tipo === 0) {
        columnas.push({ nota7: valor, nota6: '' });
      } else {
        columnas.push({ nota7: '', nota6: valor });
      }
    }
    return { columnas, bis: d.bis === true };
  }

  if (Array.isArray(d.fila7) || Array.isArray(d.fila6)) {
    const arriba = Array.isArray(d.fila7) ? d.fila7 : [];
    const abajo = Array.isArray(d.fila6) ? d.fila6 : [];
    // El modelo Dart histórico concatenaba primero la fila 6 y después la 7.
    // Mantener ese orden evita desplazar partituras antiguas al migrarlas.
    const columnas: Columna[] = [
      ...abajo.filter((nota): nota is string => typeof nota === 'string')
        .map((nota) => ({ nota7: '', nota6: nota })),
      ...arriba.filter((nota): nota is string => typeof nota === 'string')
        .map((nota) => ({ nota7: nota, nota6: '' }))
    ];
    return { columnas, bis: d.bis === true };
  }

  if (typeof d.texto === 'string') {
    const columnas: Columna[] = [];
    let fila: 6 | 7 = 6;
    for (const match of d.texto.matchAll(/[0-9.]+|\/|\\/g)) {
      const token = match[0];
      if (token === '/') fila = 7;
      else if (token === '\\') fila = 6;
      else columnas.push(fila === 7
        ? { nota7: token, nota6: '' }
        : { nota7: '', nota6: token });
    }
    return { columnas, bis: d.bis === true };
  }

  return { columnas: [], bis: d.bis === true };
}

function mapCancion(id: string, data: FirestoreData): Cancion {
  const rawEstrofas = Array.isArray(data.estrofas)
    ? data.estrofas
    : Array.isArray(data.compases)
      ? data.compases
      : Array.isArray(data.numerofoniaEstructurada)
        ? data.numerofoniaEstructurada
        : [];
  let estrofas = rawEstrofas.map(mapEstrofa);

  // Algunos documentos antiguos solo guardan numerofonia como texto plano.
  if (estrofas.length === 0 && typeof data.numerofonia === 'string' && data.numerofonia.trim()) {
    estrofas = [mapEstrofa({ texto: data.numerofonia })];
  }

  const letrasRaw = Array.isArray(data.letras) ? data.letras : [];
  const letras: Letra[] = letrasRaw.map((raw) => {
    const part = asRecord(raw);
    return {
      titulo: typeof part.titulo === 'string' ? part.titulo : '',
      texto: typeof part.texto === 'string' ? part.texto : ''
    };
  }).filter((part) => part.texto.trim().length > 0);
  const letraDesdePartes = letras.map((part) => part.texto).join('\n\n')
  const letra = letraDesdePartes || (typeof data.letra === 'string' ? data.letra : '');

  return {
    id,
    titulo: typeof data.titulo === 'string' ? data.titulo : '',
    autor: typeof data.autor === 'string' ? data.autor : '',
    tipo: typeof data.tipo === 'string' ? data.tipo : 'original',
    ritmo: typeof data.ritmo === 'string' ? data.ritmo : '',
    region: typeof data.region === 'string' ? data.region : '',
    numerofonia: typeof data.numerofonia === 'string' ? data.numerofonia : '',
    imagen_url: typeof data.imagenUrl === 'string' ? data.imagenUrl : '',
    audio_url: typeof data.audioUrl === 'string' ? data.audioUrl : '',
    video_url: typeof data.videoUrl === 'string' ? data.videoUrl : '',
    descripcion: typeof data.descripcion === 'string' ? data.descripcion : '',
    reproducciones: typeof data.reproducciones === 'number' ? data.reproducciones : 0,
    estrofas,
    letra,
    letras,
    tags: Array.isArray(data.tags)
      ? data.tags.filter((tag): tag is string => typeof tag === 'string')
      : [],
    categoriaId: typeof data.categoriaId === 'string' ? data.categoriaId : ''
  };
}

export const cancionesService = {
  async listar(): Promise<Cancion[]> {
    return getCol('canciones', mapCancion);
  },

  stream(onData: (items: Cancion[]) => void, onError: (err: Error) => void): () => void {
    return streamCol('canciones', mapCancion, (items) => {
      items.sort((a, b) => a.titulo.localeCompare(b.titulo));
      onData(items);
    }, onError);
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
      tipo: 'original',
      ritmo: input.ritmo.trim(),
      region: input.region.trim(),
      descripcion: input.descripcion.trim(),
      imagenUrl: input.imagen_url,
      audioUrl: input.audio_url,
      videoUrl: input.video_url.trim(),
      letra: input.letra.trim(),
      letras: input.letra.trim() ? [{ titulo: '', texto: input.letra.trim() }] : [],
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
      letras: (() => {
        const original = input.letrasOriginales;
        const originalTexto = original?.map((part) => part.texto).join('\n\n').trim();
        return original && originalTexto === input.letra.trim()
          ? original
          : input.letra.trim() ? [{ titulo: '', texto: input.letra.trim() }] : [];
      })(),
      tags: input.tags,
      categoriaId: input.categoriaId,
      estrofas: input.estrofas,
      fechaEdicion: Timestamp.now()
    });
  },

  async eliminar(id: string): Promise<void> {
    await deleteDoc(doc(getFirebaseDb(), 'canciones', id));
  }
};
