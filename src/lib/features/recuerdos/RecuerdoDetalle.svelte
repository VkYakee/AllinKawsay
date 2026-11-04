<!-- src/lib/features/recuerdos/RecuerdoDetalle.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import Lightbox from './Lightbox.svelte';
  import { recuerdosService, fechaLarga, type Recuerdo } from '../../services/recuerdos';
  import { notasService } from '../../services/notas';
  import { recuerdos } from '../../stores/recuerdos.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();

  let recuerdo = $state<Recuerdo | null>(null);
  let loading = $state(true);
  let lightboxAbierto = $state(false);
  let lightboxIdx = $state(0);

  let notaEditando = $state(false);
  let notaTexto = $state('');

  const notaGuardada = $derived(
    (session.user as any)?.notasPorRecuerdo?.[id] ?? ''
  );

  onMount(async () => {
    recuerdo = recuerdos.buscar(id) ?? (await recuerdosService.obtener(id));
    loading = false;
  });

  function abrirLightbox(i: number) {
    lightboxIdx = i;
    lightboxAbierto = true;
  }

  async function guardarNota() {
    if (!session.user) return;
    try {
      await notasService.guardar(session.user.uid, 'recuerdo', id, notaTexto);
      notaEditando = false;
    } catch {}
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Recuerdo</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">{recuerdo?.titulo ?? '...'}</p>
      </div>
    </div>
  </header>

  {#if loading}
    <div class="px-5 py-6 space-y-3">
      <div class="glass rounded-3xl h-64 animate-pulse"></div>
      <div class="glass rounded-3xl h-40 animate-pulse"></div>
    </div>
  {:else if !recuerdo}
    <div class="px-5 py-20 flex flex-col items-center text-center">
      <Icon name="alert-circle" size={48} class="text-red-400/60" />
      <p class="text-white/60 mt-4">Recuerdo no encontrado</p>
    </div>
  {:else}
    <div class="px-5 py-6 space-y-4 pb-40">
      <GlassCard variant="granate" padding="xl">
        <div class="flex items-center gap-2 mb-3">
          <div class="w-7 h-7 rounded-full bg-dorado/25 flex items-center justify-center">
            <Icon name="image" size={14} class="text-dorado" />
          </div>
          <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">
            {fechaLarga(recuerdo.fecha)}
          </p>
        </div>
        <h1 class="text-2xl font-black text-white tracking-tight leading-tight">{recuerdo.titulo}</h1>
        {#if recuerdo.descripcion}
          <p class="text-sm text-white/70 mt-3 leading-relaxed">{recuerdo.descripcion}</p>
        {/if}
        <div class="flex items-center gap-3 mt-4">
          {#if recuerdo.fotos.length > 0}
            <div class="flex items-center gap-1.5">
              <Icon name="image" size={12} class="text-dorado/80" />
              <span class="text-[11px] text-white/70 font-semibold">
                {recuerdo.fotos.length} {recuerdo.fotos.length === 1 ? 'foto' : 'fotos'}
              </span>
            </div>
          {/if}
          {#if recuerdo.videos.length > 0}
            <div class="flex items-center gap-1.5">
              <Icon name="play" size={12} class="text-dorado/80" fill />
              <span class="text-[11px] text-white/70 font-semibold">
                {recuerdo.videos.length} {recuerdo.videos.length === 1 ? 'video' : 'videos'}
              </span>
            </div>
          {/if}
        </div>
      </GlassCard>

      {#if recuerdo.fotos.length > 0}
        <div class="space-y-3">
          <div class="flex items-center gap-2 px-1">
            <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
              <Icon name="image" size={14} class="text-dorado" />
            </div>
            <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase">Fotos</h3>
          </div>
          <div style="column-count: 2; column-gap: 0.75rem;">
            {#each recuerdo.fotos as foto, i (foto)}
              <button
                type="button"
                onclick={() => abrirLightbox(i)}
                class="block w-full mb-3 rounded-2xl overflow-hidden active:scale-[0.97] transition-transform shadow-xl shadow-black/40"
                style="break-inside: avoid;"
              >
                <img src={foto} alt="Foto {i + 1}" class="w-full h-auto block" loading="lazy" />
              </button>
            {/each}
          </div>
        </div>
      {/if}

      {#if recuerdo.videos.length > 0}
        <div class="space-y-3">
          <div class="flex items-center gap-2 px-1">
            <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
              <Icon name="play" size={14} class="text-dorado" fill />
            </div>
            <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase">Videos</h3>
          </div>
          {#each recuerdo.videos as _, i (i)}
            <button type="button" class="relative w-full aspect-video rounded-2xl overflow-hidden bg-gradient-to-br from-granate to-granate-dark shadow-xl shadow-black/40 active:scale-[0.98] transition-transform">
              <div class="absolute inset-0 flex items-center justify-center">
                <div class="w-16 h-16 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 flex items-center justify-center">
                  <Icon name="play" size={28} class="text-dorado translate-x-0.5" fill />
                </div>
              </div>
              <div class="absolute bottom-3 left-3 glass rounded-xl px-2.5 py-1">
                <p class="text-[10px] text-dorado font-bold tracking-wider uppercase">Video {i + 1}</p>
              </div>
            </button>
          {/each}
        </div>
      {/if}

      {#if session.user}
        <div class="space-y-2">
          <div class="flex items-center gap-2 px-1">
            <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
              <Icon name="edit" size={14} class="text-dorado" />
            </div>
            <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase flex-1">Mi nota personal</h3>
            {#if !notaEditando}
              <button type="button" onclick={() => { notaTexto = notaGuardada; notaEditando = true; }} class="text-[10px] text-dorado/80 font-bold uppercase tracking-wider">
                Editar
              </button>
            {/if}
          </div>
          {#if notaEditando}
            <div class="glass rounded-2xl border border-white/10">
              <textarea
                bind:value={notaTexto}
                rows="3"
                placeholder="Solo la ves tú..."
                class="w-full bg-transparent outline-none text-sm text-white placeholder:text-white/30 p-4 resize-none"
              ></textarea>
            </div>
            <div class="flex gap-2">
              <div class="flex-1"><GlassButton variant="secondary" fullWidth onTap={() => (notaEditando = false)}>Cancelar</GlassButton></div>
              <div class="flex-1"><GlassButton variant="primary" fullWidth icon="check" onTap={guardarNota}>Guardar</GlassButton></div>
            </div>
          {:else}
            <GlassCard padding="md">
              <p class="text-sm text-white/85 whitespace-pre-line leading-relaxed">
                {notaGuardada || 'Sin nota personal. Toca Editar para añadir una.'}
              </p>
            </GlassCard>
          {/if}
        </div>
      {/if}

      <GlassCard padding="lg">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-dorado/20 flex items-center justify-center shrink-0">
            <Icon name="user" size={18} class="text-dorado" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[10px] text-dorado/70 tracking-[0.2em] font-bold uppercase">Subido por</p>
            <p class="text-sm font-bold text-white truncate mt-0.5">{recuerdo.creador_nombre || 'Admin'}</p>
          </div>
        </div>
      </GlassCard>
    </div>
  {/if}
</div>

{#if lightboxAbierto && recuerdo}
  <Lightbox fotos={recuerdo.fotos} indiceInicial={lightboxIdx} onCerrar={() => (lightboxAbierto = false)} />
{/if}