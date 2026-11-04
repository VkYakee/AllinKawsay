// src/lib/services/zampona.ts
import { invoke } from './tauri';

export interface NotaZampona {
  id: string;
  nota: string;
  fila: number;
  posicion: number;
}

export type ModoZampona = 'sostenido' | 'pulsado';

export const zamponaService = {
  listar(): Promise<NotaZampona[]> {
    return invoke<NotaZampona[]>('listar_notas_zampona');
  },
  async tocar(id: string): Promise<void> {
    await invoke<void>('tocar_nota', { id });
  }
};