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

// ─── Mock para desarrollo en navegador ───
let mockUser: unknown = null;

const mockCanciones = [
  {
    id: 'c1',
    titulo: 'Adiós Conima',
    autor: 'Anónimo',
    ritmo: 'Huayño',
    region: 'Puno',
    imagen_url: '',
    audio_url: '',
    video_url: '',
    descripcion: 'Huayño tradicional del altiplano peruano.',
    reproducciones: 342,
    estrofas: [
      {
        columnas: [
          { nota7: '1', nota6: '5' },
          { nota7: '2', nota6: '6' },
          { nota7: '3', nota6: '7' },
          { nota7: '3', nota6: '6' },
          { nota7: '2', nota6: '5' }
        ],
        bis: false
      },
      {
        columnas: [
          { nota7: '5', nota6: '2' },
          { nota7: '6', nota6: '3' },
          { nota7: '7', nota6: '4' },
          { nota7: '6', nota6: '3' }
        ],
        bis: false
      }
    ],
    letra:
      'Adiós Conima, tierra querida,\ndonde he pasado mi juventud.\nAdiós Conima, tierra querida,\nno te olvidaré jamás.',
    tags: ['tradicional', 'altiplano']
  },
  {
    id: 'c2',
    titulo: 'Aguila Negra',
    autor: 'Anónimo',
    ritmo: 'Huayño',
    region: 'Cusco',
    imagen_url: '',
    audio_url: '',
    video_url: '',
    descripcion: 'Huayño clásico del repertorio de sikuris.',
    reproducciones: 218,
    estrofas: [
      {
        columnas: [
          { nota7: '3', nota6: '7' },
          { nota7: '2', nota6: '6' },
          { nota7: '1', nota6: '5' },
          { nota7: '2', nota6: '6' },
          { nota7: '3', nota6: '7' }
        ],
        bis: false
      }
    ],
    letra:
      'Águila negra que vas volando,\nllévame lejos de este lugar.\nÁguila negra que vas volando,\nllévame al cielo, quiero soñar.',
    tags: ['tradicional']
  },
  {
    id: 'c3',
    titulo: 'Fiesta de mi Pueblo',
    autor: 'Anónimo',
    ritmo: 'Carnaval',
    region: 'Juliaca',
    imagen_url: '',
    audio_url: '',
    video_url: '',
    descripcion: 'Carnaval juliaqueño, ritmo festivo y colorido.',
    reproducciones: 156,
    estrofas: [
      {
        columnas: [
          { nota7: '1', nota6: '4' },
          { nota7: '2', nota6: '5' },
          { nota7: '3', nota6: '6' }
        ],
        bis: false
      },
      {
        columnas: [
          { nota7: '6', nota6: '3' },
          { nota7: '5', nota6: '2' },
          { nota7: '4', nota6: '1' }
        ],
        bis: false
      }
    ],
    letra:
      'En la fiesta de mi pueblo\ntodos bailan sin parar.\nEn la fiesta de mi pueblo\nhay que alegría sin igual.',
    tags: ['carnaval', 'juliaca']
  },
  {
    id: 'c4',
    titulo: 'Qhapaq Qolla',
    autor: 'Anónimo',
    ritmo: 'Qhapaq Qolla',
    region: 'Puno',
    imagen_url: '',
    audio_url: '',
    video_url: '',
    descripcion: 'Danza ritual de los comerciantes del altiplano.',
    reproducciones: 501,
    estrofas: [
      {
        columnas: [
          { nota7: '2', nota6: '6' },
          { nota7: '3', nota6: '7' },
          { nota7: '4', nota6: '1' },
          { nota7: '5', nota6: '2' },
          { nota7: '6', nota6: '3' }
        ],
        bis: false
      }
    ],
    letra:
      'Qhapaq Qolla, señor de las alturas,\nguía mi camino con tu bendición.\nQhapaq Qolla, señor de las alturas,\nprotege a mi pueblo con tu bendición.',
    tags: ['ritual', 'qhapaq']
  },
  {
    id: 'c5',
    titulo: 'Sikuri de la Noche',
    autor: 'Anónimo',
    ritmo: 'Sikuri',
    region: 'Arequipa',
    imagen_url: '',
    audio_url: '',
    video_url: '',
    descripcion: 'Sikuri moderno con ritmo hipnótico.',
    reproducciones: 89,
    estrofas: [
      {
        columnas: [
          { nota7: '7', nota6: '4' },
          { nota7: '6', nota6: '3' },
          { nota7: '5', nota6: '2' }
        ],
        bis: false
      }
    ],
    letra:
      'Bajo la luna del altiplano\nlos sikuris tocan sin cesar.\nBajo la luna del altiplano\nsu música nos hace soñar.',
    tags: ['sikuri', 'moderno']
  }
];

async function mockInvoke<T>(
  cmd: string,
  args?: Record<string, unknown>
): Promise<T> {
  await new Promise((r) => setTimeout(r, 200));

  switch (cmd) {
    case 'ping':
      return 'pong' as T;
    case 'app_version':
      return {
        name: 'Allin Kawsay',
        version: '3.0.0',
        platform: 'web-mock'
      } as T;
    case 'login': {
      const payload = args?.payload as { email: string; password: string };
      if (!payload.email.includes('@') || payload.password.length < 4) {
        throw new Error('Credenciales inválidas');
      }
      const user = {
        uid: 'demo_' + Math.random().toString(36).slice(2, 10),
        nombre: payload.email.split('@')[0],
        email: payload.email,
        rol: 'admin',
        foto_url: ''
      };
      mockUser = user;
      return user as T;
    }
    case 'logout':
      mockUser = null;
      return undefined as T;
    case 'current_user':
      return mockUser as T;
    case 'listar_canciones':
      return mockCanciones as T;
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
    default:
      throw new Error(`Comando desconocido: ${cmd}`);
  }
}