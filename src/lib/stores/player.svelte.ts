// src/lib/stores/player.svelte.ts
import { reproductorService } from '../services/reproductor';
import { compileScheduledSamples, validateSyncProject, type SyncProject } from '../domain/ensayo/sync-project';

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
  private pollInFlight = false;
  private syncProject: SyncProject | null = null;

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
      this.generation = (await reproductorService.estado()).generation;
    } else {
      await reproductorService.reanudar();
      this.playing = true;
      this.startPolling();
      this.generation = (await reproductorService.estado()).generation;
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

  async programarProyectoSync(project: SyncProject): Promise<number> {
    if (!this.current || project.songId !== this.current.id) throw new Error('Proyecto de sincronización no corresponde a canción activa.');
    this.syncProject = project;\n    const issues = validateSyncProject(project);
    if (issues.length) throw new Error('Proyecto de sincronización inválido: ' + issues[0].message);
    const compiled = compileScheduledSamples(project, 0, Math.max(0, Math.round(this.duracionMs * 1000)));
    await reproductorService.programarNotas(this.generation, compiled.map(event => ({ at_ms: event.atMs, sample_id: event.sampleId, event_id: event.eventId })));
    return compiled.length;
  }

  private async reprogramSync() {\n    if (!this.syncProject || !this.current || !this.playing || this.duracionMs <= 0) return;\n    try { await this.programarProyectoSync(this.syncProject); } catch (error) { console.warn('No se pudo reprogramar sincronización:', error); }\n  }\n\n  async stop() {
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
      if (this.pollInFlight) return;
      this.pollInFlight = true;
      try {
        const estado = await reproductorService.estado();
        // Una respuesta antigua no debe sobrescribir el estado de otra canción.
        if (this.current?.id !== estado.cancion_id) return;
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
      } finally {
        this.pollInFlight = false;
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