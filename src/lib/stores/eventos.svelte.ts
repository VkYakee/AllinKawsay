// src/lib/stores/eventos.svelte.ts
import { eventosService, esFuturo, type Evento } from '../services/eventos';

class EventosStore {
  all = $state<Evento[]>([]);
  loading = $state(false);
  loaded = $state(false);

  get proximos(): Evento[] {
    return this.all.filter((e) => esFuturo(e.fecha));
  }

  get pasados(): Evento[] {
    return this.all.filter((e) => !esFuturo(e.fecha)).reverse();
  }

  async cargar() {
    if (this.loading || this.loaded) return;
    this.loading = true;
    try {
      this.all = await eventosService.listar();
      this.loaded = true;
    } finally {
      this.loading = false;
    }
  }

  buscar(id: string): Evento | undefined {
    return this.all.find((e) => e.id === id);
  }
}

export const eventos = new EventosStore();