// src/lib/services/recuerdos.ts
import { invoke } from './tauri';

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

export const recuerdosService = {
  listar(): Promise<Recuerdo[]> {
    return invoke<Recuerdo[]>('listar_recuerdos');
  },
  obtener(id: string): Promise<Recuerdo | null> {
    return invoke<Recuerdo | null>('obtener_recuerdo', { id });
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