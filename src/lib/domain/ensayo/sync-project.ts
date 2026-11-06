/**
 * Modelo puro del proyecto de sincronización de Ensayo.
 * No depende de Svelte, Tauri, DOM ni del reproductor.
 *
 * Los tiempos se guardan en microsegundos enteros respecto al inicio del audio.
 * La canción y su audio son referencias de solo lectura.
 */

export const SYNC_SCHEMA_VERSION = 1 as const;
export type SyncTrackKind = 'notation' | 'lyrics' | 'zampona' | 'marker';
export type SyncEventKind =
  | 'notation-cell'
  | 'lyric-line'
  | 'lyric-word'
  | 'lyric-syllable'
  | 'zampona-note'
  | 'section-marker';

export interface SyncEvent {
  id: string;
  kind: SyncEventKind;
  /** Tiempo absoluto relativo al inicio del audio, en microsegundos. */
  atUs: number;
  /** Duración visual/acústica opcional; no altera el archivo de audio. */
  durationUs?: number;
  /** Identidad compartida cuando tabla y zampoña representan la misma nota. */
  musicalEventId?: string;
  estrofaIndex?: number;
  columnaIndex?: number;
  fila?: 6 | 7;
  text?: string;
  sampleId?: string;
  parentId?: string;
  gain?: number;
}

export interface SyncTrack {
  id: string;
  kind: SyncTrackKind;
  enabled: boolean;
  muted?: boolean;
  events: SyncEvent[];
}

export interface SyncRegion {
  id: string;
  label: string;
  startUs: number;
  endUs: number;
  loop: boolean;
}

export interface SyncProject {
  id: string;
  songId: string;
  schemaVersion: typeof SYNC_SCHEMA_VERSION;
  updatedAt: number;
  tracks: SyncTrack[];
  regions: SyncRegion[];
}

export interface SyncValidationIssue {
  path: string;
  message: string;
}

const isSafeTime = (value: number): boolean =>
  Number.isSafeInteger(value) && value >= 0;

export function validateSyncProject(project: SyncProject): SyncValidationIssue[] {
  const issues: SyncValidationIssue[] = [];
  if (!project.id.trim()) issues.push({ path: 'id', message: 'El proyecto necesita un id.' });
  if (!project.songId.trim()) issues.push({ path: 'songId', message: 'Falta la canción de referencia.' });
  if (project.schemaVersion !== SYNC_SCHEMA_VERSION) {
    issues.push({ path: 'schemaVersion', message: 'Versión de esquema no compatible.' });
  }

  const trackIds = new Set<string>();
  const eventIds = new Set<string>();
  const regionIds = new Set<string>();
  for (const [trackIndex, track] of project.tracks.entries()) {
    const trackPath = `tracks[${trackIndex}]`;
    if (!track.id.trim() || trackIds.has(track.id)) {
      issues.push({ path: `${trackPath}.id`, message: 'Id de pista vacío o duplicado.' });
    }
    trackIds.add(track.id);

    for (const [eventIndex, event] of track.events.entries()) {
      const path = `${trackPath}.events[${eventIndex}]`;
      if (!event.id.trim() || eventIds.has(event.id)) {
        issues.push({ path: `${path}.id`, message: 'Id de evento vacío o duplicado.' });
      }
      eventIds.add(event.id);
      if (!isSafeTime(event.atUs)) {
        issues.push({ path: `${path}.atUs`, message: 'El tiempo debe ser un entero no negativo en microsegundos.' });
      }
      if (event.durationUs !== undefined && !isSafeTime(event.durationUs)) {
        issues.push({ path: `${path}.durationUs`, message: 'La duración debe ser un entero no negativo.' });
      }
      if (event.durationUs !== undefined && isSafeTime(event.atUs) && isSafeTime(event.durationUs) && !Number.isSafeInteger(event.atUs + event.durationUs)) {
        issues.push({ path: `${path}.durationUs`, message: 'El final del evento excede el rango seguro.' });
      }
      if (track.kind === 'zampona' && event.kind === 'zampona-note' && (!event.sampleId || !event.sampleId.trim())) {
        issues.push({ path: `${path}.sampleId`, message: 'La nota de zampoña necesita una muestra válida.' });
      }
      if (event.gain !== undefined && (!Number.isFinite(event.gain) || event.gain < 0 || event.gain > 1)) {
        issues.push({ path: `${path}.gain`, message: 'La ganancia debe estar entre 0 y 1.' });
      }
      if (track.kind === 'notation' && event.kind !== 'notation-cell') {
        issues.push({ path: `${path}.kind`, message: 'Tipo de evento incompatible con pista de tabla.' });
      }
      if (track.kind === 'lyrics' && !event.kind.startsWith('lyric-')) {
        issues.push({ path: `${path}.kind`, message: 'Tipo de evento incompatible con pista de letra.' });
      }
      if (track.kind === 'zampona' && event.kind !== 'zampona-note') {
        issues.push({ path: `${path}.kind`, message: 'Tipo de evento incompatible con pista de zampoña.' });
      }
      if (event.fila !== undefined && event.fila !== 6 && event.fila !== 7) {
        issues.push({ path: `${path}.fila`, message: 'La fila debe ser 6 o 7.' });
      }
    }
  }

  for (const [index, region] of project.regions.entries()) {
    if (!region.id.trim() || regionIds.has(region.id)) issues.push({ path: `regions[${index}].id`, message: 'Id de región vacío o duplicado.' });
    regionIds.add(region.id);
    if (!isSafeTime(region.startUs) || !isSafeTime(region.endUs) || region.endUs <= region.startUs) {
      issues.push({ path: `regions[${index}]`, message: 'El rango debe tener inicio y fin válidos, con fin posterior al inicio.' });
    }
  }
  return issues;
}

/** Devuelve eventos ordenados sin mutar el proyecto fuente. */
export function orderedEvents(events: readonly SyncEvent[]): SyncEvent[] {
  return [...events].sort((a, b) => a.atUs - b.atUs || a.id.localeCompare(b.id));
}

/** Devuelve todos los eventos visualmente activos; soporta solapamientos reales. */
export function activeEventsAt(events: readonly SyncEvent[], timeUs: number): SyncEvent[] {
  if (!Number.isSafeInteger(timeUs) || timeUs < 0) return [];
  return events.filter((event) => {
    if (event.atUs > timeUs) return false;
    if (event.durationUs === undefined || event.durationUs === 0) return event.atUs === timeUs;
    return event.atUs + event.durationUs > timeUs;
  });
}

/** Desplaza un grupo conservando exactamente sus intervalos relativos. */
export function shiftEvents(
  events: readonly SyncEvent[],
  deltaUs: number
): SyncEvent[] {
  if (!Number.isSafeInteger(deltaUs)) throw new RangeError('El desplazamiento debe ser un entero en microsegundos.');
  const earliest = events.reduce((min, event) => Math.min(min, event.atUs), Number.MAX_SAFE_INTEGER);
  if (events.length > 0 && earliest + deltaUs < 0) {
    throw new RangeError('El desplazamiento dejaría un evento antes del inicio del audio.');
  }
  return events.map((event) => ({ ...event, atUs: event.atUs + deltaUs }));
}

/** Actualiza el tiempo de un evento sin modificar otros eventos. */
export function setEventTime(
  events: readonly SyncEvent[],
  eventId: string,
  atUs: number
): SyncEvent[] {
  if (!isSafeTime(atUs)) throw new RangeError('El tiempo debe ser un entero no negativo.');
  let found = false;
  const updated = events.map((event) => {
    if (event.id !== eventId) return event;
    found = true;
    return { ...event, atUs };
  });
  if (!found) throw new Error(`No existe el evento ${eventId}.`);
  return updated;
}

/** Crea una estructura vacía sin tocar la canción ni sus datos existentes. */
export function createSyncProject(id: string, songId: string, now = Date.now()): SyncProject {
  return {
    id,
    songId,
    schemaVersion: SYNC_SCHEMA_VERSION,
    updatedAt: now,
    tracks: [
      { id: 'tabla', kind: 'notation', enabled: true, events: [] },
      { id: 'letra', kind: 'lyrics', enabled: true, events: [] },
      { id: 'zampona', kind: 'zampona', enabled: true, muted: false, events: [] },
      { id: 'marcadores', kind: 'marker', enabled: true, events: [] }
    ],
    regions: []
  };
}


/** Contrato neutral del scheduler: offsets absolutos en milisegundos del audio. */
export interface ScheduledSample {
  atMs: number;
  sampleId: string;
  eventId: string;
  musicalEventId?: string;
}

/**
 * Compila únicamente notas habilitadas/no silenciadas dentro de una ventana.
 * El backend debe validar generation y comparar atMs contra el reloj nativo.
 * No usa timers ni reloj del navegador.
 */
export function compileScheduledSamples(
  project: SyncProject,
  fromUs: number,
  untilUs: number
): ScheduledSample[] {
  if (!isSafeTime(fromUs) || !isSafeTime(untilUs) || untilUs < fromUs) {
    throw new RangeError('Ventana temporal inválida.');
  }
  const track = project.tracks.find((item) => item.kind === 'zampona');
  if (!track || !track.enabled || track.muted) return [];

  const compiled = orderedEvents(track.events)
    .filter((event) =>
      event.kind === 'zampona-note' &&
      event.sampleId &&
      event.atUs >= fromUs &&
      event.atUs <= untilUs
    )
    .map((event) => ({
      atMs: Math.round(event.atUs / 1000),
      sampleId: event.sampleId!,
      eventId: event.id,
      musicalEventId: event.musicalEventId
    }));
  // Evita payloads enormes que bloqueen el hilo de comandos nativo.
  if (compiled.length > 4096) throw new RangeError('La ventana contiene más de 4096 notas; reduzca el rango.');
  return compiled;
}
