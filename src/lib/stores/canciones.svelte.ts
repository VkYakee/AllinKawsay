// src/lib/stores/canciones.svelte.ts
import { cancionesService, type Cancion } from '../services/canciones';

class CancionesStore {
  all = $state<Cancion[]>([]);
  loading = $state(false);
  loaded = $state(false);
  error = $state<string | null>(null);

  private unsubscribe: (() => void) | null = null;

  get ritmos(): string[] {
    const set = new Set<string>();
    for (const c of this.all) {
      if (c.ritmo.trim()) set.add(c.ritmo.trim());
    }
    return Array.from(set).sort();
  }

  cargar() {
    if (this.loaded || this.loading) return;
    this.loading = true;
    this.error = null;
    this.unsubscribe = cancionesService.stream(
      (items) => {
        this.all = items;
        this.loaded = true;
        this.loading = false;
      },
      (err) => {
        this.error = err.message;
        this.loading = false;
      }
    );
  }

  buscar(id: string): Cancion | undefined {
    return this.all.find((c) => c.id === id);
  }

  refrescar() {
    this.detener();
    this.loaded = false;
    this.cargar();
  }

  detener() {
    this.unsubscribe?.();
    this.unsubscribe = null;
  }
}

export const canciones = new CancionesStore();