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

<div class="glass rounded-2xl p-4 overflow-x-auto">
  <div class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase mb-2">
    Estrofa {numero}
  </div>
  <table class="border-collapse mx-auto">
    <tbody>
      <tr>
        <td class="px-2 h-11 text-[11px] font-black text-dorado bg-granate rounded-tl-lg w-8 text-center">
          7
        </td>
        {#each estrofa.columnas as col, i}
          {@const activa = celdaActiva !== null && celdaActiva.columna === i && celdaActiva.esFila7}
          <td
            class="px-2 h-11 text-center text-[16px] font-black font-mono border-l border-white/10 min-w-[36px] tabular-nums transition-all duration-150 {activa ? 'text-dorado bg-dorado/20 shadow-[inset_0_0_15px_rgba(245,208,97,0.4)]' : 'text-white/85'}"
          >
            {col.nota7 || '·'}
          </td>
        {/each}
      </tr>
      <tr>
        <td class="px-2 h-11 text-[11px] font-black text-dorado bg-granate rounded-bl-lg w-8 text-center border-t border-white/10">
          6
        </td>
        {#each estrofa.columnas as col, i}
          {@const activa = celdaActiva !== null && celdaActiva.columna === i && !celdaActiva.esFila7}
          <td
            class="px-2 h-11 text-center text-[16px] font-black font-mono border-l border-t border-white/10 min-w-[36px] tabular-nums transition-all duration-150 {activa ? 'text-dorado bg-dorado/20 shadow-[inset_0_0_15px_rgba(245,208,97,0.4)]' : 'text-white/85'}"
          >
            {col.nota6 || '·'}
          </td>
        {/each}
      </tr>
    </tbody>
  </table>
</div>