<!-- src/lib/features/ensayo/PartituraView.svelte -->
<script lang="ts">
  import type { Estrofa } from '../../services/canciones';

  interface Props {
    estrofa: Estrofa;
    celdaActiva?: { columna: number; esFila7: boolean } | null;
    numero: number;
  }

  let { estrofa, celdaActiva = null, numero }: Props = $props();
</script>

<div class="glass rounded-2xl p-3 sm:p-4 min-w-0">
  <div class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase mb-2">
    Estrofa {numero}
  </div>
  {#if estrofa.columnas.length > 0}
    <table class="w-full table-fixed border-collapse">
      <colgroup>
        <col style="width: 1.75rem" />
        {#each estrofa.columnas as _}
          <col />
        {/each}
      </colgroup>
      <tbody>
        <tr>
          <th scope="row" class="h-10 sm:h-11 text-[10px] sm:text-[11px] font-black text-dorado bg-granate rounded-tl-lg text-center">
            7
          </th>
          {#each estrofa.columnas as col, i}
            {@const activa = celdaActiva !== null && celdaActiva.columna === i && celdaActiva.esFila7}
            <td
              class="h-10 sm:h-11 px-0.5 text-center text-[clamp(0.55rem,2.5vw,1rem)] font-black font-mono border-l border-white/10 tabular-nums transition-colors duration-150 {activa ? 'text-dorado bg-dorado/20 shadow-[inset_0_0_12px_rgba(245,208,97,0.35)]' : 'text-white/85'}"
            >
              <span class="block break-all leading-tight">{col.nota7 || '·'}</span>
            </td>
          {/each}
        </tr>
        <tr>
          <th scope="row" class="h-10 sm:h-11 text-[10px] sm:text-[11px] font-black text-dorado bg-granate rounded-bl-lg text-center border-t border-white/10">
            6
          </th>
          {#each estrofa.columnas as col, i}
            {@const activa = celdaActiva !== null && celdaActiva.columna === i && !celdaActiva.esFila7}
            <td
              class="h-10 sm:h-11 px-0.5 text-center text-[clamp(0.55rem,2.5vw,1rem)] font-black font-mono border-l border-t border-white/10 tabular-nums transition-colors duration-150 {activa ? 'text-dorado bg-dorado/20 shadow-[inset_0_0_12px_rgba(245,208,97,0.35)]' : 'text-white/85'}"
            >
              <span class="block break-all leading-tight">{col.nota6 || '·'}</span>
            </td>
          {/each}
        </tr>
      </tbody>
    </table>
  {:else}
    <p class="rounded-xl border border-dashed border-white/10 px-3 py-6 text-center text-xs text-white/45">
      Esta parte todavía no tiene columnas de numerofonía.
    </p>
  {/if}
</div>