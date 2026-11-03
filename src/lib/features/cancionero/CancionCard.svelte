<!-- src/lib/features/cancionero/CancionCard.svelte -->
<script lang="ts">
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import type { Cancion } from '../../services/canciones';

  interface Props {
    cancion: Cancion;
    onTap: () => void;
  }

  let { cancion, onTap }: Props = $props();
</script>

<GlassCard padding="md" {onTap}>
  <div class="flex items-center gap-3">
    <div class="relative shrink-0">
      <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shadow-md shadow-granate/40">
        <Icon name="music" size={22} class="text-dorado" />
      </div>
      {#if cancion.estrofas.length > 0}
        <div class="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-dorado flex items-center justify-center shadow-sm">
          <Icon name="grid" size={11} class="text-granate-dark" stroke={2.5} />
        </div>
      {/if}
    </div>

    <div class="flex-1 min-w-0">
      <p class="text-[15px] font-bold text-white truncate leading-tight">
        {cancion.titulo}
      </p>
      <div class="flex items-center gap-1.5 mt-1">
        <span class="text-[10px] font-bold text-dorado/80 tracking-wider uppercase">
          {cancion.ritmo || 'Sin ritmo'}
        </span>
        {#if cancion.region}
          <span class="w-0.5 h-0.5 rounded-full bg-white/30"></span>
          <span class="text-[10px] text-white/40 tracking-wider truncate">
            {cancion.region}
          </span>
        {/if}
      </div>
    </div>

    <div class="flex flex-col items-end shrink-0 gap-0.5">
      <div class="flex items-center gap-1">
        <Icon name="play" size={10} class="text-dorado/60" fill />
        <span class="text-[11px] text-white/50 font-semibold tabular-nums">
          {cancion.reproducciones}
        </span>
      </div>
      <Icon name="chevron-right" size={14} class="text-dorado/40" />
    </div>
  </div>
</GlassCard>