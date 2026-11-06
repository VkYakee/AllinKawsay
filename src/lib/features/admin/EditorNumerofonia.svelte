<!-- Editor visual de numerofonía: cada tarjeta representa una columna de la partitura. -->
<script lang="ts">
  import type { Estrofa } from '../../services/canciones';

  interface Props {
    estrofas: Estrofa[];
    onCambio: (estrofas: Estrofa[]) => void;
  }

  let { estrofas = $bindable([]), onCambio }: Props = $props();
  let importacionAbierta = $state(false);
  let fila7Texto = $state('');
  let fila6Texto = $state('');

  function publicar(nuevas: Estrofa[]) {
    estrofas = nuevas;
    onCambio(nuevas);
  }

  function agregarEstrofa() {
    publicar([...estrofas, { columnas: [], bis: false }]);
  }

  function eliminarEstrofa(idx: number) {
    publicar(estrofas.filter((_, i) => i !== idx));
  }

  function toggleBis(idx: number) {
    publicar(estrofas.map((e, i) => i === idx ? { ...e, bis: !e.bis } : e));
  }

  function agregarColumna(idx: number) {
    publicar(estrofas.map((e, i) => i === idx
      ? { ...e, columnas: [...e.columnas, { nota7: '', nota6: '' }] }
      : e));
  }

  function eliminarColumna(estrofaIdx: number, columnaIdx: number) {
    publicar(estrofas.map((e, i) => i === estrofaIdx
      ? { ...e, columnas: e.columnas.filter((_, j) => j !== columnaIdx) }
      : e));
  }

  function actualizarCelda(estrofaIdx: number, columnaIdx: number, fila: 6 | 7, valor: string) {
    publicar(estrofas.map((e, i) => {
      if (i !== estrofaIdx) return e;
      const columnas = e.columnas.map((c, j) => j !== columnaIdx ? c : {
        ...c,
        ...(fila === 7 ? { nota7: valor } : { nota6: valor })
      });
      return { ...e, columnas };
    }));
  }

  function importarFilas(idx: number) {
    const arriba = fila7Texto.trim().split(/\s+/).filter(Boolean);
    const abajo = fila6Texto.trim().split(/\s+/).filter(Boolean);
    const cantidad = Math.max(arriba.length, abajo.length);
    const columnas = Array.from({ length: cantidad }, (_, i) => ({
      nota7: arriba[i] ?? '',
      nota6: abajo[i] ?? ''
    }));
    publicar(estrofas.map((e, i) => i === idx ? { ...e, columnas } : e));
    fila7Texto = '';
    fila6Texto = '';
    importacionAbierta = false;
  }

  function abrirImportacion(idx: number) {
    const estrofa = estrofas[idx];
    fila7Texto = estrofa.columnas.map(c => c.nota7).join(' ');
    fila6Texto = estrofa.columnas.map(c => c.nota6).join(' ');
    importacionAbierta = true;
  }
</script>

<div class="space-y-4">
  {#each estrofas as estrofa, idx (idx)}
    <section class="glass rounded-2xl border border-white/10 p-3 space-y-3">
      <header class="flex items-center gap-2">
        <div class="w-8 h-8 rounded-xl bg-dorado/15 flex items-center justify-center text-dorado text-xs font-black">{idx + 1}</div>
        <div class="flex-1 min-w-0">
          <h4 class="text-sm font-bold text-white">Parte {idx + 1}</h4>
          <p class="text-[10px] text-white/45">{estrofa.columnas.length} columnas</p>
        </div>
        <button type="button" onclick={() => toggleBis(idx)} aria-pressed={estrofa.bis}
          class="rounded-full px-3 py-2 text-[10px] font-black tracking-wider {estrofa.bis ? 'bg-dorado/20 text-dorado' : 'bg-white/5 text-white/45'}">BIS</button>
        <button type="button" onclick={() => eliminarEstrofa(idx)} aria-label="Eliminar parte {idx + 1}"
          class="w-9 h-9 rounded-xl bg-red-500/10 text-red-300 text-lg">×</button>
      </header>

      {#if estrofa.columnas.length === 0}
        <div class="rounded-xl border border-dashed border-white/15 p-5 text-center">
          <p class="text-xs text-white/60">Esta parte todavía no tiene notas.</p>
          <p class="text-[10px] text-white/35 mt-1">Agrega una columna o pega una secuencia.</p>
        </div>
      {:else}
        <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
          {#each estrofa.columnas as columna, colIdx (colIdx)}
            <div class="rounded-xl bg-black/20 border border-white/10 p-2 space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-[9px] uppercase tracking-wider text-white/40">Col. {colIdx + 1}</span>
                <button type="button" onclick={() => eliminarColumna(idx, colIdx)} aria-label="Eliminar columna {colIdx + 1}" class="text-white/35 px-2">×</button>
              </div>
              <label class="block">
                <span class="text-[9px] font-bold text-dorado/80">7 · Arriba</span>
                <input value={columna.nota7} oninput={(e) => actualizarCelda(idx, colIdx, 7, (e.currentTarget as HTMLInputElement).value)}
                  aria-label="Fila 7, columna {colIdx + 1}" placeholder="—" class="mt-1 w-full min-w-0 rounded-lg bg-white/5 border border-white/10 px-2 py-2 text-center text-sm font-mono text-white outline-none focus:border-dorado/60"/>
              </label>
              <label class="block">
                <span class="text-[9px] font-bold text-white/60">6 · Abajo</span>
                <input value={columna.nota6} oninput={(e) => actualizarCelda(idx, colIdx, 6, (e.currentTarget as HTMLInputElement).value)}
                  aria-label="Fila 6, columna {colIdx + 1}" placeholder="—" class="mt-1 w-full min-w-0 rounded-lg bg-white/5 border border-white/10 px-2 py-2 text-center text-sm font-mono text-white outline-none focus:border-dorado/60"/>
              </label>
            </div>
          {/each}
        </div>
      {/if}

      <div class="flex flex-wrap gap-2">
        <button type="button" onclick={() => agregarColumna(idx)} class="flex-1 rounded-xl bg-dorado/10 border border-dorado/20 py-3 text-xs font-bold text-dorado">+ Columna</button>
        <button type="button" onclick={() => abrirImportacion(idx)} class="flex-1 rounded-xl bg-white/5 border border-white/10 py-3 text-xs font-bold text-white/70">Pegar secuencia</button>
      </div>

      {#if importacionAbierta}
        <div class="rounded-xl bg-black/20 border border-white/10 p-3 space-y-2">
          <p class="text-xs font-bold text-white">Entrada rápida</p>
          <p class="text-[10px] text-white/45">Separa cada columna con espacios. Las posiciones vacías se conservan.</p>
          <label class="block text-[10px] text-dorado">Fila 7 · arriba
            <textarea bind:value={fila7Texto} rows="2" placeholder="1 2 3 4 5" class="mt-1 w-full rounded-lg bg-white/5 border border-white/10 p-2 text-sm font-mono text-white"></textarea>
          </label>
          <label class="block text-[10px] text-white/70">Fila 6 · abajo
            <textarea bind:value={fila6Texto} rows="2" placeholder="5 6 7 6 5" class="mt-1 w-full rounded-lg bg-white/5 border border-white/10 p-2 text-sm font-mono text-white"></textarea>
          </label>
          <div class="flex gap-2">
            <button type="button" onclick={() => importacionAbierta = false} class="flex-1 rounded-lg py-2 text-xs text-white/50">Cancelar</button>
            <button type="button" onclick={() => importarFilas(idx)} class="flex-1 rounded-lg bg-dorado/15 py-2 text-xs font-bold text-dorado">Aplicar columnas</button>
          </div>
        </div>
      {/if}
    </section>
  {/each}

  <button type="button" onclick={agregarEstrofa} class="w-full rounded-2xl border border-dashed border-dorado/30 py-4 text-sm font-bold text-dorado">
    + Agregar parte
  </button>
</div>