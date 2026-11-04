<!-- src/lib/features/recuerdos/RecuerdoCard.svelte -->
<script lang="ts">
  import Icon from '../../components/ui/Icon.svelte';
  import { fechaCorta, type Recuerdo } from '../../services/recuerdos';

  interface Props {
    recuerdo: Recuerdo;
    onTap: () => void;
  }

  let { recuerdo, onTap }: Props = $props();

  const portada = $derived(recuerdo.fotos[0] ?? '');

  // Alturas variadas para efecto masonry
  const altura = $derived.by(() => {
    const n = recuerdo.id.charCodeAt(1) || 0;
    return n % 3 === 0 ? 220 : n % 3 === 1 ? 280 : 320;
  });
</script>

<button
  type="button"
  onclick={onTap}
  class="relative w-full rounded-3xl overflow-hidden active:scale-[0.98] transition-transform text-left shadow-2xl shadow-black/50"
  style="height: {altura}px;"
>
  {#if portada}
    <img
      src={portada}
      alt={recuerdo.titulo}
      class="absolute inset-0 w-full h-full object-cover"
      loading="lazy"
    />
  {:else}
    <div class="absolute inset-0 bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center">
      <Icon name="image" size={48} class="text-dorado/40" />
    </div>
  {/if}

  <!-- Gradient overlay -->
  <div class="absolute inset-0 bg-gradient-to-t from-black/95 via-black/40 to-transparent"></div>

  <!-- Contenido -->
  <div class="absolute inset-x-0 bottom-0 p-4">
    <p class="text-[10px] text-dorado/80 tracking-[0.25em] font-bold uppercase mb-1">
      {fechaCorta(recuerdo.fecha)}
    </p>
    <h3 class="text-lg font-black text-white tracking-tight leading-tight line-clamp-2">
      {recuerdo.titulo}
    </h3>

    <div class="flex items-center gap-3 mt-2">
      {#if recuerdo.fotos.length > 0}
        <div class="flex items-center gap-1">
          <Icon name="image" size={12} class="text-dorado" />
          <span class="text-[11px] text-white/80 font-semibold">
            {recuerdo.fotos.length}
          </span>
        </div>
      {/if}
      {#if recuerdo.videos.length > 0}
        <div class="flex items-center gap-1">
          <Icon name="play" size={12} class="text-dorado" fill />
          <span class="text-[11px] text-white/80 font-semibold">
            {recuerdo.videos.length}
          </span>
        </div>
      {/if}
    </div>
  </div>
</button>