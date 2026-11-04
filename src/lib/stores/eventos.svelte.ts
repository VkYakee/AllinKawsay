// src/lib/stores/eventos.svelte.ts
import { eventosService, esFuturo, type Evento } from '../services/eventos';

class EventosStore {
  all = $state<Evento[]>([]);
  loading = $state(false);
  loaded = $state(false);
  error = $state<string | null>(null);

  private unsubscribe: (() => void) | null = null;

  get proximos(): Evento[] {
    return this.all.filter((e) => esFuturo(e.fecha));
  }

  get pasados(): Evento[] {
    return this.all.filter((e) => !esFuturo(e.fecha)).reverse();
  }

  cargar() {
    if (this.loaded || this.loading) return;
    this.loading = true;
    this.error = null;
    this.unsubscribe = eventosService.stream(
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

  buscar(id: string): Evento | undefined {
    return this.all.find((e) => e.id === id);
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

export const eventos = new EventosStore();