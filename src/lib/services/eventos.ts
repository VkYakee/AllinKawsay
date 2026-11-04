// src/lib/services/eventos.ts
import { Timestamp } from 'firebase/firestore';
import { getCol, streamCol, getDocById, type FirestoreData } from './firestore';

export interface Evento {
  id: string;
  titulo: string;
  descripcion: string;
  lugar: string;
  fecha: string;
  lat: number | null;
  lng: number | null;
  creado_por: string;
  creador_nombre: string;
}

function timestampToIso(ts: unknown): string {
  if (ts instanceof Timestamp) return ts.toDate().toISOString();
  if (typeof ts === 'string') return ts;
  return new Date().toISOString();
}

function mapEvento(id: string, data: FirestoreData): Evento {
  return {
    id,
    titulo: typeof data.titulo === 'string' ? data.titulo : '',
    descripcion: typeof data.descripcion === 'string' ? data.descripcion : '',
    lugar: typeof data.lugar === 'string' ? data.lugar : '',
    fecha: timestampToIso(data.fecha),
    lat: typeof data.lat === 'number' ? data.lat : null,
    lng: typeof data.lng === 'number' ? data.lng : null,
    creado_por: typeof data.creadoPor === 'string' ? data.creadoPor : '',
    creador_nombre:
      typeof data.creadorNombre === 'string' ? data.creadorNombre : ''
  };
}

export const eventosService = {
  async listar(): Promise<Evento[]> {
    return getCol('eventos', mapEvento);
  },

  stream(
    onData: (items: Evento[]) => void,
    onError: (err: Error) => void
  ): () => void {
    return streamCol('eventos', mapEvento, (items) => {
      items.sort((a, b) => a.fecha.localeCompare(b.fecha));
      onData(items);
    }, onError);
  },

  async obtener(id: string): Promise<Evento | null> {
    return getDocById('eventos', id, mapEvento);
  }
};

// ─── Utilidades de fecha ───
const MESES = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
const MESES_LARGO = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

export function parseFecha(iso: string): Date {
  return new Date(iso);
}

export function esFuturo(iso: string): boolean {
  return parseFecha(iso).getTime() >= Date.now();
}

export function diaNum(iso: string): number {
  return parseFecha(iso).getDate();
}

export function mesCorto(iso: string): string {
  return MESES[parseFecha(iso).getMonth()];
}

export function mesLargo(iso: string): string {
  return MESES_LARGO[parseFecha(iso).getMonth()];
}

export function hora(iso: string): string {
  const d = parseFecha(iso);
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

export function fechaLarga(iso: string): string {
  const d = parseFecha(iso);
  return `${d.getDate()} de ${mesLargo(iso)} de ${d.getFullYear()}`;
}