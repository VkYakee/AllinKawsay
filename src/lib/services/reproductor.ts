// src/lib/services/reproductor.ts
import { invoke } from './tauri';

export interface EstadoReproductor {
  cancion_id: string | null;
  reproduciendo: boolean;
  cargando: boolean;
  posicion_ms: number;
  duracion_ms: number;
}

export const reproductorService = {
  play(cancionId: string, url: string): Promise<void> {
    return invoke<void>('play_cancion', { cancionId, url });
  },
  pausar(): Promise<void> {
    return invoke<void>('pausar_cancion');
  },
  reanudar(): Promise<void> {
    return invoke<void>('reanudar_cancion');
  },
  detener(): Promise<void> {
    return invoke<void>('detener_cancion');
  },
  estado(): Promise<EstadoReproductor> {
    return invoke<EstadoReproductor>('estado_reproductor');
  }
};