// src/lib/stores/admin.svelte.ts
import {
  adminService,
  type AdminStats,
  type UsuarioResumen
} from '../services/admin';

class AdminStore {
  stats = $state<AdminStats | null>(null);
  usuarios = $state<UsuarioResumen[]>([]);
  loading = $state(false);
  error = $state<string | null>(null);

  async cargar() {
    if (this.loading) return;
    this.loading = true;
    this.error = null;
    try {
      const [s, u] = await Promise.all([
        adminService.stats(),
        adminService.usuarios()
      ]);
      this.stats = s;
      this.usuarios = u;
    } catch (e) {
      this.error = e instanceof Error ? e.message : 'Error al cargar admin';
    } finally {
      this.loading = false;
    }
  }

  reset() {
    this.stats = null;
    this.usuarios = [];
    this.error = null;
  }
}

export const admin = new AdminStore();