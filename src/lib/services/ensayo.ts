// src/lib/services/ensayo.ts
import { invoke } from './tauri';

export interface EventoEnsayo {
  nota_id: string;
  estrofa_idx: number;
  columna_idx: number;
  es_fila7: boolean;
  offset_ms: number;
}

export interface EnsayoPreparado {
  cancion_id: string;
  titulo: string;
  eventos: EventoEnsayo[];
  duracion_nota_ms: number;
  duracion_total_ms: number;
}

export const ensayoService = {
  preparar(cancionId: string): Promise<EnsayoPreparado> {
    return invoke<EnsayoPreparado>('preparar_ensayo', { id: cancionId });
  }
};