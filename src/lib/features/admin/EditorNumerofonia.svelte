<!-- src/lib/features/admin/EditorNumerofonia.svelte -->
<script lang="ts">
  import type { Estrofa } from '../../services/canciones';

  interface Props {
    estrofas: Estrofa[];
    onCambio: (estrofas: Estrofa[]) => void;
  }

  let { estrofas = $bindable([]), onCambio }: Props = $props();

  function agregarEstrofa() {
    const nuevas = [...estrofas, { columnas: [], bis: false }];
    estrofas = nuevas;
    onCambio(nuevas);
  }

  function eliminarEstrofa(idx: number) {
    const nuevas = estrofas.filter((_, i) => i !== idx);
    estrofas = nuevas;
    onCambio(nuevas);
  }

  function toggleBis(idx: number) {
    const nuevas = estrofas.map((e, i) => i === idx ? { ...e, bis: !e.bis } : e);
    estrofas = nuevas;
    onCambio(nuevas);
  }

  function actualizarFilas(idx: number, fila: 6 | 7, texto: string) {
    const partes = texto.trim().split(/\s+/).filter((p) => p.length > 0);
    const estrofa = estrofas[idx];
    if (!estrofa) return;

    const maxCols = Math.max(estrofa.columnas.length, partes.length);
    const nuevasColumnas = [];
    for (let i = 0; i < maxCols; i++) {
      const actual = estrofa.columnas[i] ?? { nota6: '', nota7: '' };
      const nueva = { ...actual };
      if (fila === 7) nueva.nota7 = partes[i] ?? '';
      else nueva.nota6 = partes[i] ?? '';
      nuevasColumnas.push(nueva);
    }

    const nuevas = estrofas.map((e, i) =>
      i === idx ? { ...e, columnas: nuevasColumnas } : e
    );
    estrofas = nuevas;
    onCambio(nuevas);
  }

  function textoFila(idx: number, fila: 6 | 7): string {
    const estrofa = estrofas[idx];
    if (!estrofa) return '';
    return estrofa.columnas.map((c) => (fila === 7 ? c.nota7 : c.nota6)).join(' ');
  }
</script>

<div class="space-y-3">
  {#each estrofas as estrofa, idx (idx)}
    <div class="glass rounded-2xl border border-white/10 p-4 space-y-3">
      <div class="flex items-center gap-2">
        <span class="text-xs font-bold text-dorado">Estrofa {idx + 1}</span>
        <button
          type="button"
          onclick={() => toggleBis(idx)}
          class="text-[10px] px-2 py-0.5 rounded-full font-bold uppercase tracking-wider {estrofa.bis
            ? 'bg-dorado/30 text-dorado'
            : 'bg-white/5 text-white/40'}"
        >
          BIS
        </button>
        <div class="flex-1"></div>
        <button
          type="button"
          onclick={() => eliminarEstrofa(idx)}
          class="text-red-400 text-[11px] px-2 font-bold uppercase tracking-wider"
        >
          Eliminar
        </button>
      </div>

      <div>
        <label
          for={`fila7-${idx}`}
          class="text-[10px] font-bold text-dorado/70 uppercase tracking-wider block mb-1"
        >
          Fila 7 (arriba)
        </label>
        <input
          id={`fila7-${idx}`}
          type="text"
          value={textoFila(idx, 7)}
          oninput={(e) => actualizarFilas(idx, 7, (e.target as HTMLInputElement).value)}
          placeholder="1 2 3 4 5"
          class="w-full bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-sm text-white font-mono outline-none focus:border-dorado/50"
        />
      </div>

      <div>
        <label
          for={`fila6-${idx}`}
          class="text-[10px] font-bold text-dorado/70 uppercase tracking-wider block mb-1"
        >
          Fila 6 (abajo)
        </label>
        <input
          id={`fila6-${idx}`}
          type="text"
          value={textoFila(idx, 6)}
          oninput={(e) => actualizarFilas(idx, 6, (e.target as HTMLInputElement).value)}
          placeholder="5 6 7 6 5"
          class="w-full bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-sm text-white font-mono outline-none focus:border-dorado/50"
        />
      </div>
    </div>
  {/each}

  <button
    type="button"
    onclick={agregarEstrofa}
    class="w-full glass rounded-2xl border border-dorado/30 py-3 text-dorado text-sm font-bold active:scale-95 transition-transform"
  >
    + Agregar estrofa
  </button>
</div>