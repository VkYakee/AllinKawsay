// src/lib/stores/zampona.svelte.ts
import {
  zamponaService,
  type NotaZampona,
  type ModoZampona
} from '../services/zampona';

class ZamponaStore {
  notas = $state<NotaZampona[]>([]);
  brillando = $state<Set<string>>(new Set());
  modo = $state<ModoZampona>('sostenido');
  loading = $state(false);
  loaded = $state(false);

  private sostenidoTimers = new Map<string, ReturnType<typeof setTimeout>>();

  async cargar() {
    if (this.loading || this.loaded) return;
    this.loading = true;
    try {
      this.notas = await zamponaService.listar();
      this.loaded = true;
    } finally {
      this.loading = false;
    }
  }

  async tocar(nota: NotaZampona) {
    const previo = this.sostenidoTimers.get(nota.id);
    if (previo) clearTimeout(previo);

    this.brillando = new Set([...this.brillando, nota.id]);
    await zamponaService.tocar(nota.id);

    if (this.modo === 'sostenido') {
      const t = setTimeout(() => this.soltar(nota.id), 350);
      this.sostenidoTimers.set(nota.id, t);
    }
  }

  soltar(id: string) {
    const t = this.sostenidoTimers.get(id);
    if (t) {
      clearTimeout(t);
      this.sostenidoTimers.delete(id);
    }
    if (!this.brillando.has(id)) return;
    const nuevo = new Set(this.brillando);
    nuevo.delete(id);
    this.brillando = nuevo;
  }

  cambiarModo(modo: ModoZampona) {
    this.modo = modo;
    if (modo === 'sostenido') {
      for (const t of this.sostenidoTimers.values()) clearTimeout(t);
      this.sostenidoTimers.clear();
    }
  }

  soltarTodo() {
    for (const t of this.sostenidoTimers.values()) clearTimeout(t);
    this.sostenidoTimers.clear();
    this.brillando = new Set();
  }
}

export const zampona = new ZamponaStore();