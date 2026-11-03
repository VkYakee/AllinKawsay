// src/lib/services/tauri.ts
// Wrapper del invoke() con fallback a mock para `vite dev` sin Tauri.

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

async function mockInvoke<T>(
  cmd: string,
  args?: Record<string, unknown>
): Promise<T> {
  await new Promise((r) => setTimeout(r, 250));

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

    default:
      throw new Error(`Comando desconocido: ${cmd}`);
  }
}