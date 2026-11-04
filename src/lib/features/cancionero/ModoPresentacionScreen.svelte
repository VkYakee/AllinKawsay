<!-- src/lib/features/cancionero/ModoPresentacionScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { cancionesService, type Cancion } from '../../services/canciones';
  import { canciones } from '../../stores/canciones.svelte';
  import { router } from '../../stores/router.svelte';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();

  let cancion = $state<Cancion | null>(null);
  let scale = $state(1);
  let translateX = $state(0);
  let translateY = $state(0);
  let startX = 0;
  let startY = 0;
  let startTransX = 0;
  let startTransY = 0;
  let dragging = false;

  onMount(async () => {
    cancion = canciones.buscar(id) ?? (await cancionesService.obtener(id));
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

  const romanos = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
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
    {#if cancion}
      <div
        class="w-full h-full flex items-center justify-center p-4"
        style="transform: scale({scale}) translate({translateX}px, {translateY}px); transition: {dragging
          ? 'none'
          : 'transform 0.15s ease'};"
      >
        <div class="space-y-8 max-w-full">
          <h1 class="text-3xl font-black text-dorado text-center tracking-tight">
            {cancion.titulo.toUpperCase()}
          </h1>
          {#if cancion.autor}
            <p class="text-base text-white/60 text-center italic">{cancion.autor}</p>
          {/if}

          {#each cancion.estrofas as estrofa, idx}
            <div class="space-y-2">
              <p class="text-center text-dorado/60 text-[10px] uppercase tracking-[0.25em] font-bold">
                Estrofa {romanos[idx] ?? idx + 1}
                {#if estrofa.bis}· BIS{/if}
              </p>
              <div class="flex justify-center">
                <div class="overflow-x-auto">
                  <table class="border-collapse">
                    <tbody>
                      <tr>
                        <td class="px-3 py-2 text-sm font-black text-dorado bg-granate rounded-tl-xl w-12 text-center">7</td>
                        {#each estrofa.columnas as col}
                          <td class="px-3 py-2 text-center text-2xl font-black text-white font-mono border-l border-white/10 min-w-[44px] tabular-nums">
                            {col.nota7 || '·'}
                          </td>
                        {/each}
                      </tr>
                      <tr>
                        <td class="px-3 py-2 text-sm font-black text-dorado bg-granate rounded-bl-xl w-12 text-center border-t border-white/10">6</td>
                        {#each estrofa.columnas as col}
                          <td class="px-3 py-2 text-center text-2xl font-black text-white font-mono border-l border-t border-white/10 min-w-[44px] tabular-nums">
                            {col.nota6 || '·'}
                          </td>
                        {/each}
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          {/each}
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