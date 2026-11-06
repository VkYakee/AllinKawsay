/**
 * Motor puro de línea de tiempo para el modo Ensayo.
 *
 * No depende de Svelte, del reproductor ni del DOM. Convierte la estructura
 * musical de Firestore en eventos deterministas que la interfaz puede seguir.
 * Las celdas se ejecutan en orden musical: fila 7 y después fila 6 por columna.
 */
export type FilaZampona = 6 | 7;

export interface ColumnaPartitura {
  nota7: string;
  nota6: string;
}

export interface EstrofaPartitura {
  columnas: readonly ColumnaPartitura[];
  bis: boolean;
}

export interface AjusteTiempoCelda {
  /** Tiempo absoluto dentro de la canción, en milisegundos. */
  inicioMs?: number;
  /** Duración de la indicación visual/nota, en milisegundos. */
  duracionMs?: number;
}

export interface OpcionesLineaTiempo {
  /** Pulsos por minuto usados cuando no existe un tiempo manual. */
  bpm?: number;
  /** Pulsos que dura cada celda con contenido. */
  pulsosPorCelda?: number;
  /** Número de ejecuciones totales de una estrofa marcada BIS. */
  repeticionesBis?: number;
  /** Ajustes manuales: clave "estrofa:columna:fila". */
  tiempos?: Readonly<Record<string, AjusteTiempoCelda>>;
}

export interface EventoEnsayo {
  id: string;
  notaId: string;
  estrofaIndex: number;
  columnaIndex: number;
  fila: FilaZampona;
  repeticion: number;
  inicioMs: number;
  duracionMs: number;
  finMs: number;
}

export interface LineaTiempoEnsayo {
  eventos: EventoEnsayo[];
  duracionTotalMs: number;
  bpm: number;
}

const claveCelda = (estrofa: number, columna: number, fila: FilaZampona) =>
  `${estrofa}:${columna}:${fila}`;

function normalizarNota(valor: string | null | undefined): string {
  const nota = (valor ?? '').trim();
  return nota === '.' || nota === '-' ? '' : nota;
}

/**
 * Compila la partitura en una línea de tiempo. BIS repite la estrofa completa
 * marcada, sin duplicar ni alterar los datos originales.
 */
export function compilarLineaTiempo(
  estrofas: readonly EstrofaPartitura[],
  opciones: OpcionesLineaTiempo = {}
): LineaTiempoEnsayo {
  const bpm = Number.isFinite(opciones.bpm) ? Math.min(240, Math.max(30, opciones.bpm!)) : 120;
  const pulsos = Number.isFinite(opciones.pulsosPorCelda)
    ? Math.min(8, Math.max(0.125, opciones.pulsosPorCelda!))
    : 1;
  const duracionBase = (60_000 / bpm) * pulsos;
  const repeticionesBis = Number.isInteger(opciones.repeticionesBis)
    ? Math.min(8, Math.max(1, opciones.repeticionesBis!))
    : 2;

  const eventos: EventoEnsayo[] = [];
  let cursorMs = 0;

  estrofas.forEach((estrofa, estrofaIndex) => {
    const totalPasadas = estrofa.bis ? repeticionesBis : 1;

    for (let repeticion = 0; repeticion < totalPasadas; repeticion++) {
      estrofa.columnas.forEach((columna, columnaIndex) => {
        const celdas: Array<{ fila: FilaZampona; nota: string }> = [
          { fila: 7, nota: normalizarNota(columna.nota7) },
          { fila: 6, nota: normalizarNota(columna.nota6) }
        ];

        for (const celda of celdas) {
          if (!celda.nota) continue;

          const ajuste = opciones.tiempos?.[claveCelda(estrofaIndex, columnaIndex, celda.fila)];
          const duracionMs = Number.isFinite(ajuste?.duracionMs) && ajuste!.duracionMs! > 0
            ? ajuste!.duracionMs!
            : duracionBase;
          const inicioMs = Number.isFinite(ajuste?.inicioMs) && ajuste!.inicioMs! >= 0
            ? ajuste!.inicioMs!
            : cursorMs;

          eventos.push({
            id: `${estrofaIndex}:${columnaIndex}:${celda.fila}:${repeticion}`,
            notaId: `fila${celda.fila}_${celda.nota}`,
            estrofaIndex,
            columnaIndex,
            fila: celda.fila,
            repeticion,
            inicioMs,
            duracionMs,
            finMs: inicioMs + duracionMs
          });
          cursorMs = Math.max(cursorMs, inicioMs + duracionMs);
        }
      });
    }
  });

  eventos.sort((a, b) => a.inicioMs - b.inicioMs || a.estrofaIndex - b.estrofaIndex ||
    a.columnaIndex - b.columnaIndex || b.fila - a.fila);

  return {
    eventos,
    duracionTotalMs: eventos.reduce((max, evento) => Math.max(max, evento.finMs), 0),
    bpm
  };
}

/** Busca el evento activo en O(log n), sin recorrer toda la partitura en cada frame. */
export function buscarEventoActivo(
  eventos: readonly EventoEnsayo[],
  tiempoMs: number
): EventoEnsayo | null {
  let izquierda = 0;
  let derecha = eventos.length - 1;
  let candidato = -1;

  while (izquierda <= derecha) {
    const medio = (izquierda + derecha) >>> 1;
    if (eventos[medio].inicioMs <= tiempoMs) {
      candidato = medio;
      izquierda = medio + 1;
    } else {
      derecha = medio - 1;
    }
  }

  if (candidato < 0) return null;
  const evento = eventos[candidato];
  return tiempoMs < evento.finMs ? evento : null;
}
