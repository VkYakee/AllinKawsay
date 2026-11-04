// src/lib/stores/session.svelte.ts
import { authService, traducirErrorAuth } from '../services/auth';

export interface UserSession {
  uid: string;
  nombre: string;
  email: string;
  rol: 'publico' | 'miembro' | 'admin' | 'dev';
  fotoUrl: string;
  baneado: boolean;
  emailVerified: boolean;
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

  get needsVerification() {
    return this.user !== null && !this.user.emailVerified;
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
        fotoUrl: u.foto_url,
        baneado: u.baneado,
        emailVerified: u.email_verified
      };
    } catch (e) {
      this.error = traducirErrorAuth(e);
      throw e;
    } finally {
      this.loading = false;
    }
  }

  async registrar(email: string, password: string, nombre: string) {
    this.loading = true;
    this.error = null;
    try {
      const u = await authService.registrar(email, password, nombre);
      this.user = {
        uid: u.uid,
        nombre: u.nombre,
        email: u.email,
        rol: u.rol,
        fotoUrl: u.foto_url,
        baneado: u.baneado,
        emailVerified: u.email_verified
      };
    } catch (e) {
      this.error = traducirErrorAuth(e);
      throw e;
    } finally {
      this.loading = false;
    }
  }

  async reenviarVerificacion() {
    try {
      await authService.reenviarVerificacion();
    } catch (e) {
      this.error = traducirErrorAuth(e);
      throw e;
    }
  }

  async verificarEmail(): Promise<boolean> {
    try {
      const ok = await authService.recargarUsuario();
      if (this.user) this.user.emailVerified = ok;
      return ok;
    } catch {
      return false;
    }
  }

  async resetPassword(email: string) {
    this.loading = true;
    this.error = null;
    try {
      await authService.resetPassword(email);
    } catch (e) {
      this.error = traducirErrorAuth(e);
      throw e;
    } finally {
      this.loading = false;
    }
  }

  async logout() {
    try {
      await authService.logout();
    } finally {
      this.user = null;
    }
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
          fotoUrl: u.foto_url,
          baneado: u.baneado,
          emailVerified: u.email_verified
        };
      } else {
        this.user = null;
      }
    } catch {
      this.user = null;
    }
  }
}

export const session = new Session();