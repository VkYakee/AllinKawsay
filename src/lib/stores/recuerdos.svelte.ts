// src/lib/stores/recuerdos.svelte.ts
import { recuerdosService, type Recuerdo } from '../services/recuerdos';

class RecuerdosStore {
  all = $state<Recuerdo[]>([]);
  loading = $state(false);
  loaded = $state(false);

  async cargar() {
    if (this.loading || this.loaded) return;
    this.loading = true;
    try {
      this.all = await recuerdosService.listar();
      this.loaded = true;
    } finally {
      this.loading = false;
    }
  }

  buscar(id: string): Recuerdo | undefined {
    return this.all.find((r) => r.id === id);
  }
}

export const recuerdos = new RecuerdosStore();