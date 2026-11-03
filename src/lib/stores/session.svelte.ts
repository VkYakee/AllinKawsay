// src/lib/stores/session.svelte.ts
import { authService } from '../services/auth';

export interface UserSession {
  uid: string;
  nombre: string;
  email: string;
  rol: 'publico' | 'miembro' | 'admin' | 'dev';
  fotoUrl: string;
}

class Session {
  user = $state<UserSession | null>(null);
  loading = $state(false);
  error = $state<string | null>(null);

  get isLogged() {
    return this.user !== null;
  }

  get isAdmin() {
    return this.user?.rol === 'admin' || this.user?.rol === 'dev';
  }

  get displayName() {
    return this.user?.nombre ?? 'Usuario';
  }

  async login(email: string, password: string) {
    this.loading = true;
    this.error = null;
    try {
      const u = await authService.login(email, password);
      this.user = {
        uid: u.uid,
        nombre: u.nombre,
        email: u.email,
        rol: u.rol,
        fotoUrl: u.foto_url
      };
    } catch (e) {
      this.error = e instanceof Error ? e.message : 'Error al ingresar';
      throw e;
    } finally {
      this.loading = false;
    }
  }

  async logout() {
    await authService.logout();
    this.user = null;
  }

  async restore() {
    try {
      const u = await authService.currentUser();
      if (u) {
        this.user = {
          uid: u.uid,
          nombre: u.nombre,
          email: u.email,
          rol: u.rol,
          fotoUrl: u.foto_url
        };
      }
    } catch {
      this.user = null;
    }
  }
}

export const session = new Session();