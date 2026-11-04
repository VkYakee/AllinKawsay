// src/lib/services/tauri.ts
const isTauri =
  typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;

export async function invoke<T>(
  cmd: string,
  args?: Record<string, unknown>
): Promise<T> {
  if (isTauri) {
    const { invoke: tauriInvoke } = await import('@tauri-apps/api/core');
    return tauriInvoke<T>(cmd, args);
  }
  return mockAudio<T>(cmd, args);
}

// ─── Mocks SOLO de audio (para desarrollo web) ───
const mockNotasZampona = [
  { id: 'fila7_1', nota: 'Do', fila: 7, posicion: 1 },
  { id: 'fila7_2', nota: 'Lab', fila: 7, posicion: 2 },
  { id: 'fila7_3', nota: 'Fa', fila: 7, posicion: 3 },
  { id: 'fila7_4', nota: 'Reb', fila: 7, posicion: 4 },
  { id: 'fila7_5', nota: 'Sib', fila: 7, posicion: 5 },
  { id: 'fila7_6', nota: 'Sol', fila: 7, posicion: 6 },
  { id: 'fila7_7', nota: 'Mib', fila: 7, posicion: 7 },
  { id: 'fila6_1', nota: 'Sib', fila: 6, posicion: 1 },
  { id: 'fila6_2', nota: 'Sol', fila: 6, posicion: 2 },
  { id: 'fila6_3', nota: 'Mib', fila: 6, posicion: 3 },
  { id: 'fila6_4', nota: 'Do', fila: 6, posicion: 4 },
  { id: 'fila6_5', nota: 'Lab', fila: 6, posicion: 5 },
  { id: 'fila6_6', nota: 'Fa', fila: 6, posicion: 6 }
];

let mockAudioEl: HTMLAudioElement | null = null;
let mockEstado = {
  cancion_id: null as string | null,
  reproduciendo: false,
  cargando: false,
  posicion_ms: 0,
  duracion_ms: 0
};
let mockTimer: ReturnType<typeof setInterval> | null = null;

async function mockAudio<T>(
  cmd: string,
  args?: Record<string, unknown>
): Promise<T> {
  switch (cmd) {
    case 'ping':
      return 'pong' as T;
    case 'app_version':
      return {
        name: 'Allin Kawsay',
        version: '3.0.0',
        platform: 'web-mock'
      } as T;
    case 'listar_notas_zampona':
      return mockNotasZampona as T;
    case 'tocar_nota':
      return undefined as T;

    case 'play_cancion': {
      const url = args?.url as string;
      const cancionId = args?.cancionId as string;
      if (!url) throw new Error('URL vacía');

      if (mockAudioEl) {
        mockAudioEl.pause();
        mockAudioEl = null;
      }
      if (mockTimer) {
        clearInterval(mockTimer);
        mockTimer = null;
      }

      const audio = new Audio(url);
      mockAudioEl = audio;
      mockEstado = {
        cancion_id: cancionId,
        reproduciendo: true,
        cargando: true,
        posicion_ms: 0,
        duracion_ms: 0
      };

      audio.addEventListener('loadedmetadata', () => {
        mockEstado.duracion_ms = Math.round(audio.duration * 1000);
        mockEstado.cargando = false;
      });

      audio.addEventListener('ended', () => {
        mockEstado.reproduciendo = false;
      });

      try {
        await audio.play();
        mockEstado.reproduciendo = true;
      } catch (e) {
        mockEstado.reproduciendo = false;
        throw new Error('No se pudo reproducir');
      }

      mockTimer = setInterval(() => {
        if (!mockAudioEl) return;
        mockEstado.posicion_ms = Math.round(mockAudioEl.currentTime * 1000);
        mockEstado.reproduciendo = !mockAudioEl.paused;
      }, 250);
      return undefined as T;
    }

    case 'pausar_cancion':
      mockAudioEl?.pause();
      mockEstado.reproduciendo = false;
      return undefined as T;

    case 'reanudar_cancion':
      await mockAudioEl?.play().catch(() => {});
      mockEstado.reproduciendo = true;
      return undefined as T;

    case 'detener_cancion':
      if (mockTimer) {
        clearInterval(mockTimer);
        mockTimer = null;
      }
      mockAudioEl?.pause();
      mockAudioEl = null;
      mockEstado = {
        cancion_id: null,
        reproduciendo: false,
        cargando: false,
        posicion_ms: 0,
        duracion_ms: 0
      };
      return undefined as T;

    case 'estado_reproductor':
      return { ...mockEstado } as T;

    default:
      throw new Error(`Comando no implementado en web: ${cmd}`);
  }
}