<!-- src/lib/features/cancionero/CompartirCancionScreen.svelte -->
<script lang="ts">
  import { toPng } from 'html-to-image';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import type { Cancion } from '../../services/canciones';
  import { router } from '../../stores/router.svelte';

  interface Props {
    cancion: Cancion;
  }

  let { cancion }: Props = $props();

  let cardEl: HTMLDivElement | undefined = $state(undefined);
  let generando = $state(false);
  let error = $state('');

  async function generarImagen() {
    if (!cardEl || generando) return;
    generando = true;
    error = '';
    try {
      const dataUrl = await toPng(cardEl, {
        pixelRatio: 2,
        backgroundColor: '#12100F',
        cacheBust: true
      });

      // Convertir data URL a blob y compartir
      const res = await fetch(dataUrl);
      const blob = await res.blob();
      const file = new File([blob], `allin_kawsay_${cancion.titulo.replace(/\s+/g, '_')}.png`, { type: 'image/png' });

      if (navigator.canShare && navigator.canShare({ files: [file] })) {
        await navigator.share({
          files: [file],
          title: cancion.titulo,
          text: `${cancion.titulo} - Allin Kawsay`
        });
      } else {
        // Fallback: descargar
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = file.name;
        a.click();
        URL.revokeObjectURL(url);
      }
    } catch (e) {
      error = e instanceof Error ? e.message : 'Error generando imagen';
    } finally {
      generando = false;
    }
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Compartir</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">{cancion.titulo}</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    <!-- Tarjeta capturable -->
    <div bind:this={cardEl} class="rounded-3xl overflow-hidden shadow-2xl" style="background: linear-gradient(135deg, #4A0D18 0%, #8B1A2B 50%, #12100F 100%);">
      <div class="p-6 space-y-4">
        <div class="flex items-center gap-3">
          <div class="w-12 h-12 rounded-full flex items-center justify-center" style="background: linear-gradient(135deg, #F5D061, #C89B29);">
            <span class="text-granate-dark font-black text-lg">AK</span>
          </div>
          <div>
            <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">Allin Kawsay</p>
            <p class="text-[9px] text-white/60 tracking-wider">C.I.A.C. · Juliaca · Perú</p>
          </div>
        </div>

        <div class="border-t border-dorado/30 pt-4">
          <p class="text-[10px] text-dorado/80 tracking-[0.2em] font-bold uppercase mb-2">
            {cancion.ritmo || 'Canción'}
          </p>
          <h1 class="text-2xl font-black text-white leading-tight mb-1">
            {cancion.titulo}
          </h1>
          <p class="text-sm text-white/70 italic">{cancion.autor || 'Anónimo'}</p>
        </div>

        {#if cancion.letra}
          <div class="border-t border-dorado/30 pt-4">
            <p class="text-[10px] text-dorado/80 tracking-[0.2em] font-bold uppercase mb-2">
              Letra
            </p>
            <div class="text-[13px] leading-[1.7] text-white/85 whitespace-pre-line italic">
              {cancion.letra.slice(0, 400)}{cancion.letra.length > 400 ? '...' : ''}
            </div>
          </div>
        {/if}

        <div class="border-t border-dorado/30 pt-3 flex items-center justify-between">
          <p class="text-[9px] text-white/50 tracking-wider">Comparte la música</p>
          <p class="text-[9px] text-dorado tracking-wider font-bold">ALLIN KAWSAY v3.0</p>
        </div>
      </div>
    </div>

    {#if error}
      <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{error}</p>
      </div>
    {/if}

    <GlassButton variant="primary" fullWidth icon="share" loading={generando} onTap={generarImagen}>
      Compartir imagen
    </GlassButton>
  </div>
</div>