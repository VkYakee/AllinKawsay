// src/lib/services/canciones.ts
import { invoke } from './tauri';

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

export const cancionesService = {
  listar(): Promise<Cancion[]> {
    return invoke<Cancion[]>('listar_canciones');
  },
  obtener(id: string): Promise<Cancion | null> {
    return invoke<Cancion | null>('obtener_cancion', { id });
  },
  incrementarReproduccion(id: string): Promise<number> {
    return invoke<number>('incrementar_reproduccion', { id });
  }
};