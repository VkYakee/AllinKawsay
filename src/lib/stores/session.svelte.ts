// src/lib/stores/session.svelte.ts

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
    try {
      await new Promise((r) => setTimeout(r, 700));
      if (!email.includes('@') || password.length < 4) {
        throw new Error('Credenciales inválidas');
      }
      this.user = {
        uid: 'demo_' + Math.random().toString(36).slice(2, 10),
        nombre: email.split('@')[0],
        email,
        rol: 'admin',
        fotoUrl: ''
      };
    } finally {
      this.loading = false;
    }
  }

  async logout() {
    this.user = null;
  }
}

export const session = new Session();