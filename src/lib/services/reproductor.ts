// src/lib/services/reproductor.ts
import { invoke } from './tauri';

export interface NotaProgramada { at_ms: number; sample_id: string; event_id: string; }

export interface EstadoReproductor {
  cancion_id: string | null;
  reproduciendo: boolean;
  cargando: boolean;
  posicion_ms: number;
  duracion_ms: number;
  velocidad: number;
  generation: number;
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
  buscar(positionMs: number): Promise<void> {
    return invoke<void>('buscar_cancion', { positionMs: Math.max(0, Math.round(positionMs)) });
  },
  setVelocidad(speed: number): Promise<void> {
    const bounded = Math.max(0.25, Math.min(2, speed));
    return invoke<void>('velocidad_cancion', { speed: bounded });
  },
  programarNotas(generation: number, events: NotaProgramada[]): Promise<void> {
    if (events.length > 4096) return Promise.reject(new Error('Máximo 4096 notas por lote'));
    return invoke<void>('programar_notas', { generation, events });
  },
  detener(): Promise<void> {
    return invoke<void>('detener_cancion');
  },
  estado(): Promise<EstadoReproductor> {
    return invoke<EstadoReproductor>('estado_reproductor');
  }
};