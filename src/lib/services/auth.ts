// src/lib/services/auth.ts
import { invoke } from './tauri';

export interface AuthUser {
  uid: string;
  nombre: string;
  email: string;
  rol: 'publico' | 'miembro' | 'admin' | 'dev';
  foto_url: string;
}

export const authService = {
  async login(email: string, password: string): Promise<AuthUser> {
    return invoke<AuthUser>('login', { payload: { email, password } });
  },

  async logout(): Promise<void> {
    await invoke<void>('logout');
  },

  async currentUser(): Promise<AuthUser | null> {
    return invoke<AuthUser | null>('current_user');
  }
};