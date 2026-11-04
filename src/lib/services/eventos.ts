// src/lib/services/eventos.ts
import { invoke } from './tauri';

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

export const eventosService = {
  listar(): Promise<Evento[]> {
    return invoke<Evento[]>('listar_eventos');
  },
  obtener(id: string): Promise<Evento | null> {
    return invoke<Evento | null>('obtener_evento', { id });
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

export function anio(iso: string): number {
  return parseFecha(iso).getFullYear();
}

export function hora(iso: string): string {
  const d = parseFecha(iso);
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
}

export function fechaLarga(iso: string): string {
  const d = parseFecha(iso);
  return `${d.getDate()} de ${mesLargo(iso)} de ${d.getFullYear()}`;
}