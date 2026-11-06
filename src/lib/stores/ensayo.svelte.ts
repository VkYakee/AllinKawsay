// src/lib/stores/ensayo.svelte.ts
import {
  prepararEventos,
  type EnsayoPreparado,
  type EventoEnsayo
} from '../services/ensayo';
import { zamponaService } from '../services/zampona';

class EnsayoStore {
  preparado = $state<EnsayoPreparado | null>(null);
  estado = $state<'idle' | 'playing' | 'paused' | 'finished'>('idle');
  velocidad = $state(1);
  offsetMs = $state(0);
  idxActual = $state(-1);
  brillando = $state<Set<string>>(new Set());
  cargando = $state(false);

  private rafId: number | null = null;
  private lastTick = 0;

  get eventoActual(): EventoEnsayo | null {
    if (!this.preparado || this.idxActual < 0) return null;
    return this.preparado.eventos[this.idxActual] ?? null;
  }

  preparar(
    estrofas: Array<{
      columnas: Array<{ nota7: string; nota6: string }>;
      bis: boolean;
    }>,
    duracionNotaMs = 500
  ) {
    this.stop();
    this.cargando = true;
    try {
      this.preparado = prepararEventos(estrofas, duracionNotaMs);
    } finally {
      this.cargando = false;
    }
  }

  play() {
    if (!this.preparado || this.preparado.eventos.length === 0) return;
    if (this.estado === 'finished') {
      this.offsetMs = 0;
      this.idxActual = -1;
      this.brillando = new Set();
    }
    this.estado = 'playing';
    this.lastTick = performance.now();
    if (this.rafId !== null) cancelAnimationFrame(this.rafId);
    this.rafId = requestAnimationFrame(this.tick);
  }

  pause() {
    if (this.estado !== 'playing') return;
    this.estado = 'paused';
    if (this.rafId !== null) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
    this.brillando = new Set();
  }

  stop() {
    if (this.rafId !== null) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
    this.estado = 'idle';
    this.offsetMs = 0;
    this.idxActual = -1;
    this.brillando = new Set();
  }

  setVelocidad(v: number) {
    this.velocidad = Math.max(0.25, Math.min(2, v));
  }

  private tick = () => {
    if (this.estado !== 'playing' || !this.preparado) return;

    const now = performance.now();
    const delta = (now - this.lastTick) * this.velocidad;
    this.lastTick = now;
    this.offsetMs += delta;

    const eventos = this.preparado.eventos;
    const brillando = new Set<string>();

    // Encuentra el último evento cuyo inicio ya ocurrió en O(log n).
    let izquierda = 0;
    let derecha = eventos.length - 1;
    let candidato = -1;
    while (izquierda <= derecha) {
      const medio = (izquierda + derecha) >>> 1;
      if (eventos[medio].offset_ms <= this.offsetMs) {
        candidato = medio;
        izquierda = medio + 1;
      } else {
        derecha = medio - 1;
      }
    }

    // Si hay tiempos manuales solapados, retrocede solo hasta hallar un
    // intervalo activo. En el caso habitual se comprueba una sola celda.
    let activo = -1;
    for (let i = candidato; i >= 0; i--) {
      if (eventos[i].fin_ms > this.offsetMs) { activo = i; break; }
    }

    if (activo >= 0) {
      const ev = eventos[activo];
      brillando.add(ev.nota_id);
      if (activo !== this.idxActual) {
        this.idxActual = activo;
        zamponaService.tocar(ev.nota_id);
      }
    } else {
      this.idxActual = -1;
    }

    this.brillando = brillando;

    if (this.offsetMs >= this.preparado.duracion_total_ms) {
      this.estado = 'finished';
      this.brillando = new Set();
      this.rafId = null;
      return;
    }

    this.rafId = requestAnimationFrame(this.tick);
  };
}

export const ensayo = new EnsayoStore();