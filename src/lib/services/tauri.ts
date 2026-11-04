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
  return mockInvoke<T>(cmd, args);
}

let mockUser: unknown = null;

const mockReproductor = {
  cancion_id: null as string | null,
  reproduciendo: false,
  cargando: false,
  posicion_ms: 0,
  duracion_ms: 0
};
let mockTimer: ReturnType<typeof setInterval> | null = null;

const mockCanciones = [
  { id: 'c1', titulo: 'Adiós Conima', autor: 'Anónimo', ritmo: 'Huayño', region: 'Puno', imagen_url: '', audio_url: 'https://download.samplelib.com/mp3/sample-6s.mp3', video_url: '', descripcion: 'Huayño tradicional del altiplano peruano.', reproducciones: 342, estrofas: [{ columnas: [{ nota7: '1', nota6: '5' }, { nota7: '2', nota6: '6' }, { nota7: '3', nota6: '7' }, { nota7: '3', nota6: '6' }, { nota7: '2', nota6: '5' }], bis: false }, { columnas: [{ nota7: '5', nota6: '2' }, { nota7: '6', nota6: '3' }, { nota7: '7', nota6: '4' }, { nota7: '6', nota6: '3' }], bis: false }], letra: 'Adiós Conima, tierra querida,\ndonde he pasado mi juventud.\nAdiós Conima, tierra querida,\nno te olvidaré jamás.', tags: ['tradicional', 'altiplano'] },
  { id: 'c2', titulo: 'Aguila Negra', autor: 'Anónimo', ritmo: 'Huayño', region: 'Cusco', imagen_url: '', audio_url: '', video_url: '', descripcion: 'Huayño clásico del repertorio de sikuris.', reproducciones: 218, estrofas: [{ columnas: [{ nota7: '3', nota6: '7' }, { nota7: '2', nota6: '6' }, { nota7: '1', nota6: '5' }, { nota7: '2', nota6: '6' }, { nota7: '3', nota6: '7' }], bis: false }], letra: 'Águila negra que vas volando,\nllévame lejos de este lugar.\nÁguila negra que vas volando,\nllévame al cielo, quiero soñar.', tags: ['tradicional'] },
  { id: 'c3', titulo: 'Fiesta de mi Pueblo', autor: 'Anónimo', ritmo: 'Carnaval', region: 'Juliaca', imagen_url: '', audio_url: '', video_url: '', descripcion: 'Carnaval juliaqueño, ritmo festivo y colorido.', reproducciones: 156, estrofas: [{ columnas: [{ nota7: '1', nota6: '4' }, { nota7: '2', nota6: '5' }, { nota7: '3', nota6: '6' }], bis: false }, { columnas: [{ nota7: '6', nota6: '3' }, { nota7: '5', nota6: '2' }, { nota7: '4', nota6: '1' }], bis: false }], letra: 'En la fiesta de mi pueblo\ntodos bailan sin parar.\nEn la fiesta de mi pueblo\nhay que alegría sin igual.', tags: ['carnaval', 'juliaca'] },
  { id: 'c4', titulo: 'Qhapaq Qolla', autor: 'Anónimo', ritmo: 'Qhapaq Qolla', region: 'Puno', imagen_url: '', audio_url: '', video_url: '', descripcion: 'Danza ritual de los comerciantes del altiplano.', reproducciones: 501, estrofas: [{ columnas: [{ nota7: '2', nota6: '6' }, { nota7: '3', nota6: '7' }, { nota7: '4', nota6: '1' }, { nota7: '5', nota6: '2' }, { nota7: '6', nota6: '3' }], bis: false }], letra: 'Qhapaq Qolla, señor de las alturas,\nguía mi camino con tu bendición.\nQhapaq Qolla, señor de las alturas,\nprotege a mi pueblo con tu bendición.', tags: ['ritual', 'qhapaq'] },
  { id: 'c5', titulo: 'Sikuri de la Noche', autor: 'Anónimo', ritmo: 'Sikuri', region: 'Arequipa', imagen_url: '', audio_url: '', video_url: '', descripcion: 'Sikuri moderno con ritmo hipnótico.', reproducciones: 89, estrofas: [{ columnas: [{ nota7: '7', nota6: '4' }, { nota7: '6', nota6: '3' }, { nota7: '5', nota6: '2' }], bis: false }], letra: 'Bajo la luna del altiplano\nlos sikuris tocan sin cesar.\nBajo la luna del altiplano\nsu música nos hace soñar.', tags: ['sikuri', 'moderno'] }
];

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

const mockEventos = [
  { id: 'e1', titulo: 'Fiesta Patronal', descripcion: 'Presentación central del grupo en la fiesta patronal de Juliaca. Traer instrumentos y uniforme completo.', lugar: 'Plaza de Armas, Juliaca', fecha: '2026-10-15T19:00:00', lat: -15.4994, lng: -70.1333, creado_por: 'admin', creador_nombre: 'Directiva' },
  { id: 'e2', titulo: 'Aniversario del Grupo', descripcion: 'Celebración por el aniversario del C.I.A.C. Allin Kawsay. Cena de confraternidad y presentación especial.', lugar: 'Local institucional, Juliaca', fecha: '2026-11-02T18:30:00', lat: -15.4985, lng: -70.132, creado_por: 'admin', creador_nombre: 'Directiva' },
  { id: 'e3', titulo: 'Concurso Regional de Sikuris', descripcion: 'Participación en el concurso regional. Ensayo general el día anterior a las 20:00.', lugar: 'Coliseo Cerrado, Puno', fecha: '2026-12-08T16:00:00', lat: -15.8402, lng: -70.0199, creado_por: 'admin', creador_nombre: 'Directiva' },
  { id: 'e4', titulo: 'Ensayo General — Aniversario', descripcion: 'Ensayo obligatorio previo al aniversario. Repaso de todo el repertorio.', lugar: 'Local institucional', fecha: '2026-09-20T20:00:00', lat: null, lng: null, creado_por: 'admin', creador_nombre: 'Directiva' }
];

const foto = (s: string) => `https://picsum.photos/seed/${s}/800/600`;
const fotoV = (s: string) => `https://picsum.photos/seed/${s}/600/800`;

const mockRecuerdos = [
  { id: 'r1', titulo: 'Fiesta Patronal 2025', descripcion: 'Presentación inolvidable en la plaza de armas. El público no dejaba de aplaudir.', fotos: [foto('allin_fp1'), fotoV('allin_fp2'), foto('allin_fp3'), fotoV('allin_fp4'), foto('allin_fp5')], videos: ['demo_video_1'], fecha: '2025-10-15T20:00:00', creado_por: 'admin', creador_nombre: 'Directiva' },
  { id: 'r2', titulo: 'Aniversario 2024', descripcion: 'Noche de confraternidad y música. Los fundadores nos acompañaron.', fotos: [foto('allin_an1'), foto('allin_an2'), fotoV('allin_an3'), foto('allin_an4')], videos: [], fecha: '2024-11-02T19:30:00', creado_por: 'admin', creador_nombre: 'Directiva' },
  { id: 'r3', titulo: 'Ensayo en el local', descripcion: 'Preparativos para el concurso regional. Mucho esfuerzo y dedicación.', fotos: [fotoV('allin_en1'), foto('allin_en2'), foto('allin_en3')], videos: [], fecha: '2024-08-20T21:00:00', creado_por: 'admin', creador_nombre: 'Directiva' }
];

const mockUsuarios = [
  { uid: 'u1', nombre: 'Directiva Allin Kawsay', email: 'directiva@allinkawsay.pe', rol: 'admin', foto_url: '', baneado: false },
  { uid: 'u2', nombre: 'María Quispe', email: 'maria@allinkawsay.pe', rol: 'miembro', foto_url: '', baneado: false },
  { uid: 'u3', nombre: 'José Mamani', email: 'jose@allinkawsay.pe', rol: 'miembro', foto_url: '', baneado: false },
  { uid: 'u4', nombre: 'Rosa Ticona', email: 'rosa@allinkawsay.pe', rol: 'publico', foto_url: '', baneado: false },
  { uid: 'u5', nombre: 'Carlos Apaza', email: 'carlos@example.com', rol: 'publico', foto_url: '', baneado: true }
];

async function mockInvoke<T>(
  cmd: string,
  args?: Record<string, unknown>
): Promise<T> {
  await new Promise((r) => setTimeout(r, 100));
  switch (cmd) {
    case 'ping': return 'pong' as T;
    case 'app_version': return { name: 'Allin Kawsay', version: '3.0.0', platform: 'web-mock' } as T;
    case 'login': {
      const payload = args?.payload as { email: string; password: string };
      if (!payload.email.includes('@') || payload.password.length < 4) throw new Error('Credenciales inválidas');
      const user = { uid: 'demo_' + Math.random().toString(36).slice(2, 10), nombre: payload.email.split('@')[0], email: payload.email, rol: 'admin', foto_url: '' };
      mockUser = user;
      return user as T;
    }
    case 'logout': mockUser = null; return undefined as T;
    case 'current_user': return mockUser as T;
    case 'listar_canciones': return mockCanciones as T;
    case 'obtener_cancion': {
      const id = args?.id as string;
      return (mockCanciones.find((c) => c.id === id) ?? null) as T;
    }
    case 'incrementar_reproduccion': {
      const id = args?.id as string;
      const c = mockCanciones.find((c) => c.id === id);
      if (!c) throw new Error('Canción no encontrada');
      c.reproducciones += 1;
      return c.reproducciones as T;
    }
    case 'listar_notas_zampona': return mockNotasZampona as T;
    case 'tocar_nota': return undefined as T;
    case 'preparar_ensayo': {
      const cancionId = args?.id as string;
      const c = mockCanciones.find((c) => c.id === cancionId);
      if (!c) throw new Error('Canción no encontrada');
      const dur = 500;
      const eventos: Array<{ nota_id: string; estrofa_idx: number; columna_idx: number; es_fila7: boolean; offset_ms: number }> = [];
      let offset = 0;
      for (let ei = 0; ei < c.estrofas.length; ei++) {
        const est = c.estrofas[ei];
        for (let ci = 0; ci < est.columnas.length; ci++) {
          const col = est.columnas[ci];
          const n7 = col.nota7.trim();
          const n6 = col.nota6.trim();
          if (n7 && n7 !== '.') { eventos.push({ nota_id: `fila7_${n7}`, estrofa_idx: ei, columna_idx: ci, es_fila7: true, offset_ms: offset }); offset += dur; }
          if (n6 && n6 !== '.') { eventos.push({ nota_id: `fila6_${n6}`, estrofa_idx: ei, columna_idx: ci, es_fila7: false, offset_ms: offset }); offset += dur; }
        }
      }
      return { cancion_id: c.id, titulo: c.titulo, eventos, duracion_nota_ms: dur, duracion_total_ms: offset } as T;
    }
    case 'listar_eventos': {
      const lista = [...mockEventos].sort((a, b) => a.fecha.localeCompare(b.fecha));
      return lista as T;
    }
    case 'obtener_evento': {
      const id = args?.id as string;
      return (mockEventos.find((e) => e.id === id) ?? null) as T;
    }
    case 'listar_recuerdos': {
      const lista = [...mockRecuerdos].sort((a, b) => b.fecha.localeCompare(a.fecha));
      return lista as T;
    }
    case 'obtener_recuerdo': {
      const id = args?.id as string;
      return (mockRecuerdos.find((r) => r.id === id) ?? null) as T;
    }
    case 'admin_stats': {
      const totalReproducciones = mockCanciones.reduce((s, c) => s + c.reproducciones, 0);
      const totalFotos = mockRecuerdos.reduce((s, r) => s + r.fotos.length, 0);
      const totalAudios = mockCanciones.filter((c) => c.audio_url !== '').length;
      return { total_canciones: mockCanciones.length, total_eventos: mockEventos.length, total_recuerdos: mockRecuerdos.length, total_reproducciones: totalReproducciones, total_fotos: totalFotos, total_audios: totalAudios } as T;
    }
    case 'admin_usuarios': return mockUsuarios as T;

    // ─── Reproductor mock ───
    case 'play_cancion': {
      const cancionId = args?.cancionId as string;
      mockReproductor.cancion_id = cancionId;
      mockReproductor.cargando = false;
      mockReproductor.reproduciendo = true;
      mockReproductor.posicion_ms = 0;
      mockReproductor.duracion_ms = 6000;
      if (mockTimer) clearInterval(mockTimer);
      mockTimer = setInterval(() => {
        if (!mockReproductor.reproduciendo) return;
        mockReproductor.posicion_ms += 250;
        if (mockReproductor.posicion_ms >= mockReproductor.duracion_ms) {
          mockReproductor.posicion_ms = mockReproductor.duracion_ms;
          mockReproductor.reproduciendo = false;
          if (mockTimer) { clearInterval(mockTimer); mockTimer = null; }
        }
      }, 250);
      return undefined as T;
    }
    case 'pausar_cancion':
      mockReproductor.reproduciendo = false;
      return undefined as T;
    case 'reanudar_cancion':
      if (mockReproductor.cancion_id) mockReproductor.reproduciendo = true;
      return undefined as T;
    case 'detener_cancion':
      if (mockTimer) { clearInterval(mockTimer); mockTimer = null; }
      mockReproductor.cancion_id = null;
      mockReproductor.reproduciendo = false;
      mockReproductor.cargando = false;
      mockReproductor.posicion_ms = 0;
      mockReproductor.duracion_ms = 0;
      return undefined as T;
    case 'estado_reproductor':
      return { ...mockReproductor } as T;

    default:
      throw new Error(`Comando desconocido: ${cmd}`);
  }
}