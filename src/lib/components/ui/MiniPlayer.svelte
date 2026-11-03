<!-- src/lib/components/ui/MiniPlayer.svelte -->
<script lang="ts">
  import Icon from './Icon.svelte';
  import { player } from '../../stores/player.svelte';
</script>

{#if player.isActive}
  <div
    class="fixed left-4 right-4 z-40 pointer-events-none"
    style="bottom: calc(95px + env(safe-area-inset-bottom, 0px));"
  >
    <div
      class="glass glass-strong rounded-2xl px-3 py-2.5 flex items-center gap-3 shadow-2xl shadow-black/60 pointer-events-auto"
    >
      <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0 shadow-md shadow-granate/40">
        <Icon name="music" size={18} class="text-dorado" />
      </div>

      <div class="flex-1 min-w-0">
        <p class="text-[13px] font-bold text-white truncate leading-tight">
          {player.current?.titulo}
        </p>
        <p class="text-[11px] text-white/50 truncate mt-0.5">
          {player.current?.autor || 'Allin Kawsay'}
        </p>
      </div>

      <button
        type="button"
        onclick={() => player.toggle()}
        class="w-9 h-9 rounded-full bg-dorado/15 flex items-center justify-center text-dorado active:scale-90 transition-transform shrink-0"
      >
        <Icon name={player.playing ? 'pause' : 'play'} size={16} fill />
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
{/if}