// src/lib/services/recuerdos.ts
import { Timestamp, deleteDoc, doc, updateDoc } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';
import {
  getCol,
  streamCol,
  getDocById,
  addDocument,
  type FirestoreData
} from './firestore';

export interface Recuerdo {
  id: string;
  titulo: string;
  descripcion: string;
  fotos: string[];
  videos: string[];
  fecha: string;
  creado_por: string;
  creador_nombre: string;
}

export interface RecuerdoInput {
  titulo: string;
  descripcion: string;
  fotos: string[];
  videos: string[];
  fecha: Date;
}

function timestampToIso(ts: unknown): string {
  if (ts instanceof Timestamp) return ts.toDate().toISOString();
  if (typeof ts === 'string') return ts;
  return new Date().toISOString();
}

function mapStringArray(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return raw.filter((x): x is string => typeof x === 'string');
}

function mapRecuerdo(id: string, data: FirestoreData): Recuerdo {
  return {
    id,
    titulo: typeof data.titulo === 'string' ? data.titulo : '',
    descripcion: typeof data.descripcion === 'string' ? data.descripcion : '',
    fotos: mapStringArray(data.fotos),
    videos: mapStringArray(data.videos),
    fecha: timestampToIso(data.fecha),
    creado_por: typeof data.creadoPor === 'string' ? data.creadoPor : '',
    creador_nombre:
      typeof data.creadorNombre === 'string' ? data.creadorNombre : ''
  };
}

export const recuerdosService = {
  async listar(): Promise<Recuerdo[]> {
    return getCol('recuerdos', mapRecuerdo);
  },

  stream(
    onData: (items: Recuerdo[]) => void,
    onError: (err: Error) => void
  ): () => void {
    return streamCol(
      'recuerdos',
      mapRecuerdo,
      (items) => {
        items.sort((a, b) => b.fecha.localeCompare(a.fecha));
        onData(items);
      },
      onError
    );
  },

  async obtener(id: string): Promise<Recuerdo | null> {
    return getDocById('recuerdos', id, mapRecuerdo);
  },

  async crear(input: RecuerdoInput, autorUid: string, autorNombre: string): Promise<string> {
    return addDocument('recuerdos', {
      titulo: input.titulo.trim(),
      descripcion: input.descripcion.trim(),
      fotos: input.fotos,
      videos: input.videos,
      fecha: Timestamp.fromDate(input.fecha),
      creadoPor: autorUid,
      creadorNombre: autorNombre,
      fechaCreacion: Timestamp.now()
    });
  },

  async actualizar(id: string, input: RecuerdoInput): Promise<void> {
    await updateDoc(doc(getFirebaseDb(), 'recuerdos', id), {
      titulo: input.titulo.trim(),
      descripcion: input.descripcion.trim(),
      fotos: input.fotos,
      videos: input.videos,
      fecha: Timestamp.fromDate(input.fecha),
      fechaEdicion: Timestamp.now()
    });
  },

  async eliminar(id: string): Promise<void> {
    await deleteDoc(doc(getFirebaseDb(), 'recuerdos', id));
  }
};

const MESES_LARGO = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

export function parseFecha(iso: string): Date {
  return new Date(iso);
}

export function fechaCorta(iso: string): string {
  const d = parseFecha(iso);
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`;
}

export function fechaLarga(iso: string): string {
  const d = parseFecha(iso);
  return `${d.getDate()} de ${MESES_LARGO[d.getMonth()]} de ${d.getFullYear()}`;
}