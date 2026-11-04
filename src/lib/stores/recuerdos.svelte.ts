// src/lib/stores/recuerdos.svelte.ts
import { recuerdosService, type Recuerdo } from '../services/recuerdos';

class RecuerdosStore {
  all = $state<Recuerdo[]>([]);
  loading = $state(false);
  loaded = $state(false);
  error = $state<string | null>(null);

  private unsubscribe: (() => void) | null = null;

  cargar() {
    if (this.loaded || this.loading) return;
    this.loading = true;
    this.error = null;
    this.unsubscribe = recuerdosService.stream(
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

  buscar(id: string): Recuerdo | undefined {
    return this.all.find((r) => r.id === id);
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

export const recuerdos = new RecuerdosStore();