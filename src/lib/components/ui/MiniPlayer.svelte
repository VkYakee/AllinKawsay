<!-- src/lib/components/ui/MiniPlayer.svelte -->
<script lang="ts">
  import Icon from './Icon.svelte';
  import { player } from '../../stores/player.svelte';

  function fmt(ms: number): string {
    const totalSeg = Math.floor(ms / 1000);
    const m = Math.floor(totalSeg / 60).toString().padStart(2, '0');
    const s = (totalSeg % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  }
</script>

{#if player.isActive}
  <div
    class="fixed left-4 right-4 z-40 pointer-events-none"
    style="bottom: calc(95px + env(safe-area-inset-bottom, 0px));"
  >
    <div
      class="glass glass-strong rounded-2xl overflow-hidden shadow-2xl shadow-black/60 pointer-events-auto"
    >
      <!-- Barra de progreso superior -->
      <div class="h-0.5 bg-white/10 relative">
        <div
          class="h-full bg-gradient-to-r from-dorado to-dorado-dark"
          style="width: {player.progreso * 100}%; transition: width 250ms linear;"
        ></div>
      </div>

      <div class="px-3 py-2.5 flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0 shadow-md shadow-granate/40">
          <Icon name="music" size={18} class="text-dorado" />
        </div>

        <div class="flex-1 min-w-0">
          <p class="text-[13px] font-bold text-white truncate leading-tight">
            {player.current?.titulo}
          </p>
          <div class="flex items-center gap-2 mt-0.5">
            <p class="text-[11px] text-white/50 truncate">
              {player.current?.autor || 'Allin Kawsay'}
            </p>
            {#if player.duracionMs > 0}
              <span class="text-[10px] text-white/30 font-mono tabular-nums shrink-0">
                {fmt(player.posicionMs)} / {fmt(player.duracionMs)}
              </span>
            {/if}
          </div>
        </div>

        <button
          type="button"
          onclick={() => player.toggle()}
          class="w-9 h-9 rounded-full bg-dorado/15 flex items-center justify-center text-dorado active:scale-90 transition-transform shrink-0"
          disabled={player.loading}
        >
          {#if player.loading}
            <span class="w-3.5 h-3.5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></span>
          {:else}
            <Icon name={player.playing ? 'pause' : 'play'} size={16} fill />
          {/if}
        </button>

        <button
          type="button"
          onclick={() => player.stop()}
          class="w-9 h-9 rounded-full flex items-center justify-center text-white/40 active:scale-90 transition-transform shrink-0"
        >
          <Icon name="x" size={16} />
        </button>
      </div>
    </div>
  </div>
{/if}