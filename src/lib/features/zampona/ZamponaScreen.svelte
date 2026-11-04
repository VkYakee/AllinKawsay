<!-- src/lib/features/zampona/ZamponaScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassChip from '../../components/ui/GlassChip.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import ZamponaCanvas from './ZamponaCanvas.svelte';
  import { zampona } from '../../stores/zampona.svelte';
  import type { NotaZampona } from '../../services/zampona';
  import { router } from '../../stores/router.svelte';

  onMount(() => {
    zampona.cargar();
    return () => zampona.soltarTodo();
  });

  function handleTap(nota: NotaZampona) {
    zampona.tocar(nota);
    if (navigator.vibrate) navigator.vibrate(20);
  }

  function handleRelease(nota: NotaZampona) {
    if (zampona.modo === 'pulsado') zampona.soltar(nota.id);
  }
</script>

<div class="app-background min-h-dvh flex flex-col">
  <header class="px-5 pt-3 pb-3 flex items-center gap-3">
    <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
    <div class="flex-1 min-w-0">
      <p class="text-[10px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
        Instrumento
      </p>
      <h1 class="text-xl font-black text-dorado tracking-tight truncate mt-0.5">
        Zampoña
      </h1>
    </div>
    <GlassIconButton icon="sparkles" variant="gold" size="sm" />
  </header>

  <div class="flex-1 flex flex-col items-center justify-center px-4">
    <div class="glass glass-strong rounded-[32px] p-5 w-full max-w-md shadow-2xl shadow-black/60">
      {#if zampona.loading || !zampona.loaded}
        <div class="h-[260px] flex items-center justify-center">
          <div class="w-8 h-8 border-2 border-dorado/60 border-t-transparent rounded-full animate-spin"></div>
        </div>
      {:else}
        <ZamponaCanvas
          notas={zampona.notas}
          brillando={zampona.brillando}
          onTap={handleTap}
          onRelease={handleRelease}
        />
      {/if}
    </div>

    <div class="mt-5 flex items-center gap-2 text-[10px] text-white/40 tracking-[0.2em] uppercase font-semibold">
      <Icon name="volume" size={12} class="text-dorado/60" />
      <span>Toca las cañas para sonar</span>
    </div>
  </div>

  <div class="px-5 pb-10 pt-4">
    <div class="flex items-center justify-center gap-3">
      <GlassChip
        selected={zampona.modo === 'sostenido'}
        variant="granate"
        icon={zampona.modo === 'sostenido' ? 'check' : undefined}
        onTap={() => zampona.cambiarModo('sostenido')}
      >
        Sostenido
      </GlassChip>
      <GlassChip
        selected={zampona.modo === 'pulsado'}
        variant="granate"
        icon={zampona.modo === 'pulsado' ? 'check' : undefined}
        onTap={() => zampona.cambiarModo('pulsado')}
      >
        Pulsado
      </GlassChip>
    </div>

    <p class="text-center text-[10px] text-white/30 tracking-[0.15em] mt-3 uppercase">
      {zampona.modo === 'sostenido'
        ? 'La nota suena 350 ms'
        : 'La nota suena mientras tocas'}
    </p>
  </div>
</div>