// src/lib/services/admin.ts
import { invoke } from './tauri';

export interface AdminStats {
  total_canciones: number;
  total_eventos: number;
  total_recuerdos: number;
  total_reproducciones: number;
  total_fotos: number;
  total_audios: number;
}

export interface UsuarioResumen {
  uid: string;
  nombre: string;
  email: string;
  rol: 'publico' | 'miembro' | 'admin' | 'dev';
  foto_url: string;
  baneado: boolean;
}

export const adminService = {
  stats(): Promise<AdminStats> {
    return invoke<AdminStats>('admin_stats');
  },
  usuarios(): Promise<UsuarioResumen[]> {
    return invoke<UsuarioResumen[]>('admin_usuarios');
  }
};

export function rolLabel(rol: string): string {
  switch (rol) {
    case 'dev': return 'Desarrollador';
    case 'admin': return 'Administrador';
    case 'miembro': return 'Miembro';
    default: return 'Público';
  }
}

export function rolColor(rol: string): string {
  switch (rol) {
    case 'dev': return 'text-cyan-400';
    case 'admin': return 'text-dorado';
    case 'miembro': return 'text-emerald-400';
    default: return 'text-white/50';
  }
}