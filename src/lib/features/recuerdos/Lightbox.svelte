<!-- src/lib/features/recuerdos/Lightbox.svelte -->
<script lang="ts">
  import Icon from '../../components/ui/Icon.svelte';

  interface Props {
    fotos: string[];
    indiceInicial: number;
    onCerrar: () => void;
  }

  let { fotos, indiceInicial, onCerrar }: Props = $props();

  let idx = $state(indiceInicial);
  let startX = 0;
  let deltaX = $state(0);
  let arrastrando = $state(false);

  const total = $derived(fotos.length);
  const puedePrev = $derived(idx > 0);
  const puedeNext = $derived(idx < total - 1);

  function prev() {
    if (puedePrev) idx--;
  }

  function next() {
    if (puedeNext) idx++;
  }

  function onDown(e: PointerEvent) {
    startX = e.clientX;
    arrastrando = true;
  }

  function onMove(e: PointerEvent) {
    if (!arrastrando) return;
    deltaX = e.clientX - startX;
  }

  function onUp() {
    if (!arrastrando) return;
    arrastrando = false;
    if (deltaX < -60 && puedeNext) idx++;
    else if (deltaX > 60 && puedePrev) idx--;
    deltaX = 0;
  }

  function onKey(e: KeyboardEvent) {
    if (e.key === 'Escape') onCerrar();
    if (e.key === 'ArrowLeft') prev();
    if (e.key === 'ArrowRight') next();
  }
</script>

<svelte:window on:keydown={onKey} />

<div
  class="fixed inset-0 z-[100] bg-black/98 backdrop-blur-xl flex flex-col"
  role="dialog"
  aria-modal="true"
>
  <!-- Header -->
  <div class="flex items-center justify-between px-5 pt-3 pb-3 border-b border-white/5" style="padding-top: calc(0.75rem + env(safe-area-inset-top, 0px));">
    <button
      type="button"
      onclick={onCerrar}
      class="glass w-10 h-10 rounded-full flex items-center justify-center text-dorado active:scale-90 transition-transform"
    >
      <Icon name="x" size={18} />
    </button>
    <p class="text-[11px] text-white/60 tracking-[0.25em] font-bold uppercase tabular-nums">
      {idx + 1} / {total}
    </p>
    <div class="w-10 h-10"></div>
  </div>

  <!-- Imagen -->
  <div
    class="flex-1 relative flex items-center justify-center overflow-hidden select-none touch-none"
    onpointerdown={onDown}
    onpointermove={onMove}
    onpointerup={onUp}
    onpointercancel={onUp}
    role="presentation"
  >
    <img
      src={fotos[idx]}
      alt="Foto {idx + 1}"
      class="max-w-full max-h-full object-contain"
      style="transform: translateX({deltaX}px); transition: {arrastrando ? 'none' : 'transform 300ms cubic-bezier(0.25, 1, 0.5, 1)'};"
      draggable="false"
    />

    {#if puedePrev}
      <button
        type="button"
        onclick={prev}
        class="absolute left-2 top-1/2 -translate-y-1/2 glass w-11 h-11 rounded-full flex items-center justify-center text-dorado active:scale-90 transition-transform"
      >
        <Icon name="chevron-left" size={20} />
      </button>
    {/if}

    {#if puedeNext}
      <button
        type="button"
        onclick={next}
        class="absolute right-2 top-1/2 -translate-y-1/2 glass w-11 h-11 rounded-full flex items-center justify-center text-dorado active:scale-90 transition-transform"
      >
        <Icon name="chevron-right" size={20} />
      </button>
    {/if}
  </div>

  <!-- Thumbnails -->
  {#if total > 1}
    <div class="px-5 pb-4 pt-2 flex gap-2 overflow-x-auto scrollbar-hide" style="padding-bottom: calc(1rem + env(safe-area-inset-bottom, 0px));">
      {#each fotos as foto, i}
        <button
          type="button"
          onclick={() => (idx = i)}
          class="shrink-0 w-14 h-14 rounded-xl overflow-hidden border-2 transition-all {i === idx
            ? 'border-dorado'
            : 'border-transparent opacity-50'}"
        >
          <img src={foto} alt="Miniatura {i + 1}" class="w-full h-full object-cover" loading="lazy" />
        </button>
      {/each}
    </div>
  {/if}
</div>