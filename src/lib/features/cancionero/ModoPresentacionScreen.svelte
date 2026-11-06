<!-- src/lib/features/cancionero/ModoPresentacionScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import PartituraView from '../ensayo/PartituraView.svelte';
  import { cancionesService, type Cancion } from '../../services/canciones';
  import { canciones } from '../../stores/canciones.svelte';
  import { router } from '../../stores/router.svelte';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();

  let cancion = $state<Cancion | null>(null);
  let cargando = $state(true);
  let errorCarga = $state('');
  let scale = $state(1);
  let translateX = $state(0);
  let translateY = $state(0);
  let startX = 0;
  let startY = 0;
  let startTransX = 0;
  let startTransY = 0;
  let dragging = false;

  onMount(async () => {
    try {
      cancion = canciones.buscar(id) ?? (await cancionesService.obtener(id));
      if (!cancion) errorCarga = 'No se encontró esta canción.';
    } catch (cause) {
      errorCarga = cause instanceof Error ? cause.message : 'No se pudo cargar la partitura.';
    } finally {
      cargando = false;
    }
  });

  function zoom(e: WheelEvent) {
    e.preventDefault();
    const delta = e.deltaY < 0 ? 0.1 : -0.1;
    scale = Math.max(0.5, Math.min(3, scale + delta));
  }

  function onPointerDown(e: PointerEvent) {
    if (scale <= 1) return;
    dragging = true;
    startX = e.clientX;
    startY = e.clientY;
    startTransX = translateX;
    startTransY = translateY;
  }

  function onPointerMove(e: PointerEvent) {
    if (!dragging) return;
    translateX = startTransX + (e.clientX - startX);
    translateY = startTransY + (e.clientY - startY);
  }

  function onPointerUp() {
    dragging = false;
  }

  function reset() {
    scale = 1;
    translateX = 0;
    translateY = 0;
  }

</script>

<div
  class="fixed inset-0 z-[100] bg-black flex flex-col"
  onwheel={zoom}
  onpointerdown={onPointerDown}
  onpointermove={onPointerMove}
  onpointerup={onPointerUp}
  onpointercancel={onPointerUp}
  role="presentation"
>
  <div
    class="flex items-center gap-3 px-4 py-3 border-b border-white/10"
    style="padding-top: calc(0.75rem + env(safe-area-inset-top, 0px));"
  >
    <button
      type="button"
      onclick={() => router.back()}
      class="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-dorado"
    >
      <Icon name="x" size={20} />
    </button>
    <div class="flex-1 min-w-0">
      <p class="text-[10px] text-dorado/70 uppercase tracking-wider font-bold">Modo presentación</p>
      <p class="text-sm text-white font-bold truncate">{cancion?.titulo ?? ''}</p>
    </div>
    <button
      type="button"
      onclick={reset}
      class="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-dorado"
    >
      <Icon name="refresh" size={16} />
    </button>
  </div>

  <div class="flex-1 overflow-hidden touch-none" role="presentation">
    {#if cargando}
      <div class="h-full flex flex-col items-center justify-center gap-3"><div class="w-7 h-7 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div><p class="text-xs text-white/50">Cargando partitura…</p></div>
    {:else if !cancion}
      <div class="h-full flex flex-col items-center justify-center text-center px-6"><Icon name="alert-circle" size={32} class="text-red-300 mb-3" /><p class="text-sm font-bold text-white">No se pudo abrir la partitura</p><p class="text-xs text-white/50 mt-1">{errorCarga || 'Canción no encontrada'}</p></div>
    {:else}
      <div
        class="w-full h-full overflow-y-auto flex flex-col items-center justify-start p-4"
        style="transform: scale({scale}) translate({translateX}px, {translateY}px); transform-origin: center top; transition: {dragging ? 'none' : 'transform 0.15s ease'};"
      >
        <div class="w-full max-w-3xl space-y-5">
          <h1 class="text-3xl font-black text-dorado text-center tracking-tight">
            {cancion.titulo.toUpperCase()}
          </h1>
          {#if cancion.autor}
            <p class="text-base text-white/60 text-center italic">{cancion.autor}</p>
          {/if}
          {#if cancion.estrofas.length > 0}
            {#each cancion.estrofas as estrofa, idx}
              <PartituraView {estrofa} numero={idx + 1} />
            {/each}
          {:else}
            <div class="rounded-2xl border border-dashed border-white/15 p-8 text-center"><Icon name="grid" size={28} class="text-dorado/60 mx-auto mb-2" /><p class="text-sm font-bold text-white">Esta canción aún no tiene partitura</p></div>
          {/if}
        </div>
      </div>
    {/if}
  </div>

  <div
    class="px-4 py-3 border-t border-white/10 text-center"
    style="padding-bottom: calc(0.75rem + env(safe-area-inset-bottom, 0px));"
  >
    <p class="text-[10px] text-white/30 uppercase tracking-wider">
      Scroll para zoom · Arrastra para mover
    </p>
  </div>
</div>