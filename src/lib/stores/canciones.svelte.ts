// src/lib/stores/canciones.svelte.ts
import { cancionesService, type Cancion } from '../services/canciones';

class CancionesStore {
  all = $state<Cancion[]>([]);
  loading = $state(false);
  loaded = $state(false);

  get ritmos(): string[] {
    const set = new Set<string>();
    for (const c of this.all) {
      if (c.ritmo.trim()) set.add(c.ritmo.trim());
    }
    return Array.from(set).sort();
  }

  async cargar() {
    if (this.loading || this.loaded) return;
    this.loading = true;
    try {
      this.all = await cancionesService.listar();
      this.loaded = true;
    } finally {
      this.loading = false;
    }
  }

  buscar(id: string): Cancion | undefined {
    return this.all.find((c) => c.id === id);
  }

  async refrescar() {
    this.loaded = false;
    await this.cargar();
  }
}

export const canciones = new CancionesStore();