// src/lib/stores/player.svelte.ts
import { reproductorService } from '../services/reproductor';

export interface Track {
  id: string;
  titulo: string;
  autor: string;
  imagenUrl: string;
  audioUrl: string;
}

class Player {
  current = $state<Track | null>(null);
  playing = $state(false);
  loading = $state(false);
  posicionMs = $state(0);
  duracionMs = $state(0);
  velocidad = $state(1);
  generation = $state(0);

  private pollTimer: ReturnType<typeof setInterval> | null = null;

  get isActive() {
    return this.current !== null;
  }

  get progreso() {
    if (this.duracionMs <= 0) return 0;
    return Math.min(1, this.posicionMs / this.duracionMs);
  }

  async play(track: Track) {
    if (this.current?.id === track.id) {
      await this.toggle();
      return;
    }

    if (!track.audioUrl) {
      // Canción sin audio: solo actualiza UI
      this.current = track;
      this.playing = false;
      this.posicionMs = 0;
      this.duracionMs = 0;
      return;
    }

    this.current = track;
    this.loading = true;
    this.posicionMs = 0;
    this.duracionMs = 0;

    try {
      await reproductorService.play(track.id, track.audioUrl);
      this.playing = true;
      this.startPolling();
    } catch (e) {
      console.error('Error reproduciendo:', e);
      this.playing = false;
    } finally {
      this.loading = false;
    }
  }

  async toggle() {
    if (!this.current) return;
    if (this.playing) {
      await reproductorService.pausar();
      this.playing = false;
      this.stopPolling();
    } else {
      await reproductorService.reanudar();
      this.playing = true;
      this.startPolling();
    }
  }

  async buscar(positionMs: number) {
    await reproductorService.buscar(positionMs);
    this.posicionMs = Math.max(0, Math.min(this.duracionMs || positionMs, positionMs));
    const estado = await reproductorService.estado();
    this.generation = estado.generation;
  }

  async setVelocidad(speed: number) {
    await reproductorService.setVelocidad(speed);
    this.velocidad = Math.max(0.25, Math.min(2, speed));
    const estado = await reproductorService.estado();
    this.generation = estado.generation;
  }

  async stop() {
    await reproductorService.detener();
    this.current = null;
    this.playing = false;
    this.loading = false;
    this.posicionMs = 0;
    this.duracionMs = 0;
    this.stopPolling();
  }

  private startPolling() {
    this.stopPolling();
    this.pollTimer = setInterval(async () => {
      try {
        const estado = await reproductorService.estado();
        this.playing = estado.reproduciendo;
        this.posicionMs = estado.posicion_ms;
        this.duracionMs = estado.duracion_ms;
        this.velocidad = estado.velocidad;
        this.generation = estado.generation;

        // Si el backend dice que terminó y no hay progreso, limpia el estado
        if (
          !estado.reproduciendo &&
          estado.duracion_ms > 0 &&
          estado.posicion_ms >= estado.duracion_ms
        ) {
          // Deja la canción "terminada" pero no la elimines
        }
      } catch {
        // silencioso
      }
    }, 250);
  }

  private stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
  }
}

export const player = new Player();