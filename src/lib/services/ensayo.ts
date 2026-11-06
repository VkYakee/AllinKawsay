// Adaptador de compatibilidad entre el dominio musical y la pantalla de Ensayo.
import {
  compilarLineaTiempo,
  type AjusteTiempoCelda,
  type EventoEnsayo as EventoDominio,
  type OpcionesLineaTiempo
} from '../domain/ensayo/timeline';

export interface EventoEnsayo {
  nota_id: string;
  estrofa_idx: number;
  columna_idx: number;
  es_fila7: boolean;
  offset_ms: number;
  fin_ms: number;
  repeticion: number;
}

export interface EnsayoPreparado {
  eventos: EventoEnsayo[];
  duracion_nota_ms: number;
  duracion_total_ms: number;
  bpm: number;
}

export interface OpcionesPreparacionEnsayo {
  bpm?: number;
  pulsosPorCelda?: number;
  repeticionesBis?: number;
  tiempos?: Readonly<Record<string, AjusteTiempoCelda>>;
}

function adaptarEvento(evento: EventoDominio): EventoEnsayo {
  return {
    nota_id: evento.notaId,
    estrofa_idx: evento.estrofaIndex,
    columna_idx: evento.columnaIndex,
    es_fila7: evento.fila === 7,
    offset_ms: evento.inicioMs,
    fin_ms: evento.finMs,
    repeticion: evento.repeticion
  };
}

export function prepararEventos(
  estrofas: Array<{
    columnas: Array<{ nota7: string; nota6: string }>;
    bis: boolean;
  }>,
  duracionNotaMs = 500,
  opciones: OpcionesPreparacionEnsayo = {}
): EnsayoPreparado {
  const bpm = opciones.bpm ?? 60_000 / duracionNotaMs;
  const opcionesDominio: OpcionesLineaTiempo = {
    bpm,
    pulsosPorCelda: opciones.pulsosPorCelda ?? 1,
    repeticionesBis: opciones.repeticionesBis,
    tiempos: opciones.tiempos
  };
  const linea = compilarLineaTiempo(estrofas, opcionesDominio);
  const eventos = linea.eventos.map(adaptarEvento);

  return {
    eventos,
    duracion_nota_ms: duracionNotaMs,
    duracion_total_ms: linea.duracionTotalMs,
    bpm: linea.bpm
  };
}
