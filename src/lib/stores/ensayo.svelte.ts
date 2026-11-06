// src/lib/stores/ensayo.svelte.ts
import {
  prepararEventos,
  type EnsayoPreparado,
  type EventoEnsayo
} from '../services/ensayo';

/**
 * Estado visual de Ensayo. El reloj y el audio pertenecen al reproductor
 * nativo; este store solo refleja su posición y nunca dispara muestras.
 */
class EnsayoStore {
  preparado = $state<EnsayoPreparado | null>(null);
  estado = $state<'idle' | 'playing' | 'paused' | 'finished'>('idle');
  velocidad = $state(1);
  offsetMs = $state(0);
  idxActual = $state(-1);
  brillando = $state<Set<string>>(new Set());
  cargando = $state(false);

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

  /** Sincroniza la visualización con una posición obtenida del reproductor. */
  actualizarPosicion(positionMs: number) {
    if (!this.preparado) return;
    this.offsetMs = Math.max(0, Number.isFinite(positionMs) ? positionMs : 0);
    const eventos = this.preparado.eventos;

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

    let activo = -1;
    for (let i = candidato; i >= 0; i--) {
      if (eventos[i].fin_ms > this.offsetMs) {
        activo = i;
        break;
      }
    }

    this.idxActual = activo;
    this.brillando = activo >= 0
      ? new Set([eventos[activo].nota_id])
      : new Set();

    if (this.preparado.duracion_total_ms > 0 &&
        this.offsetMs >= this.preparado.duracion_total_ms) {
      this.estado = 'finished';
    }
  }

  stop() {
    this.estado = 'idle';
    this.offsetMs = 0;
    this.idxActual = -1;
    this.brillando = new Set();
  }
}

export const ensayo = new EnsayoStore();
