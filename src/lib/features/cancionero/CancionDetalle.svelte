<!-- src/lib/features/cancionero/CancionDetalle.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import ComentariosSection from './ComentariosSection.svelte';
  import { cancionesService, type Cancion } from '../../services/canciones';
  import { notasService } from '../../services/notas';
  import { canciones } from '../../stores/canciones.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';
  import { player } from '../../stores/player.svelte';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();

  let cancion = $state<Cancion | null>(null);
  let loading = $state(true);
  let tabActivo = $state<'info' | 'letra' | 'comentarios'>('info');
  let notaEditando = $state(false);
  let notaTexto = $state('');

  onMount(async () => {
    cancion = canciones.buscar(id) ?? (await cancionesService.obtener(id));
    notaTexto = session.user ? (session.user as any).notaCancion?.(id) ?? '' : '';
    loading = false;
  });

  const notaGuardada = $derived(
    (session.user as any)?.notasPorCancion?.[id] ?? ''
  );

  async function tocarPlay() {
    if (!cancion) return;
    await player.play({
      id: cancion.id,
      titulo: cancion.titulo,
      autor: cancion.autor,
      imagenUrl: cancion.imagen_url,
      audioUrl: cancion.audio_url
    });
    if (cancion.audio_url) {
      await cancionesService.incrementarReproduccion(cancion.id);
      cancion.reproducciones += 1;
    }
  }

  async function guardarNota() {
    if (!session.user) return;
    try {
      await notasService.guardar(session.user.uid, 'cancion', id, notaTexto);
      notaEditando = false;
    } catch {}
  }

  const romanos = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Canción</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">{cancion?.titulo ?? '...'}</p>
      </div>
      {#if cancion}
        <GlassIconButton
          icon="share"
          size="sm"
          onTap={() => router.go('compartir-cancion', { id: cancion!.id })}
        />
      {/if}
    </div>
  </header>

  {#if loading}
    <div class="px-5 py-6 space-y-3">
      <div class="glass rounded-3xl h-40 animate-pulse"></div>
      <div class="glass rounded-3xl h-64 animate-pulse"></div>
    </div>
  {:else if !cancion}
    <div class="px-5 py-20 flex flex-col items-center text-center">
      <Icon name="alert-circle" size={48} class="text-red-400/60" />
      <p class="text-white/60 mt-4">Canción no encontrada</p>
    </div>
  {:else}
    <div class="px-5 py-6 pb-40 space-y-4">
      <!-- Hero -->
      <GlassCard variant="granate" padding="xl">
        <div class="flex items-start gap-4">
          <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40 shrink-0">
            <Icon name="music" size={28} class="text-granate-dark" />
          </div>
          <div class="flex-1 min-w-0">
            <h1 class="text-2xl font-black text-white tracking-tight leading-tight">{cancion.titulo}</h1>
            <p class="text-sm text-white/60 mt-1 truncate">{cancion.autor || 'Anónimo'}</p>
            <div class="flex flex-wrap items-center gap-1.5 mt-2">
              {#if cancion.ritmo}
                <span class="text-[10px] px-2 py-0.5 rounded-full bg-dorado/25 text-dorado font-bold tracking-wider uppercase">{cancion.ritmo}</span>
              {/if}
              {#if cancion.region}
                <span class="text-[10px] px-2 py-0.5 rounded-full bg-white/10 text-white/60 font-semibold tracking-wider">{cancion.region}</span>
              {/if}
            </div>
          </div>
        </div>

        {#if cancion.descripcion}
          <p class="text-xs text-white/60 mt-4 leading-relaxed">{cancion.descripcion}</p>
        {/if}

        <div class="flex items-center gap-2 mt-5">
          <div class="flex-1">
            <GlassButton variant="primary" fullWidth icon="play" onTap={tocarPlay}>Escuchar</GlassButton>
          </div>
        </div>

        <div class="flex items-center justify-center gap-1.5 mt-3">
          <Icon name="play" size={10} class="text-dorado/60" fill />
          <span class="text-[11px] text-white/40 font-semibold">{cancion.reproducciones} reproducciones</span>
        </div>
      </GlassCard>

      <!-- Tabs -->
      <div class="glass glass-strong rounded-full p-1 flex">
        <button
          type="button"
          onclick={() => (tabActivo = 'info')}
          class="flex-1 h-10 rounded-full text-[11px] font-bold tracking-wider uppercase transition-all {tabActivo === 'info'
            ? 'bg-gradient-to-br from-granate to-granate-dark text-dorado'
            : 'text-white/50'}"
        >
          Info
        </button>
        <button
          type="button"
          onclick={() => (tabActivo = 'letra')}
          class="flex-1 h-10 rounded-full text-[11px] font-bold tracking-wider uppercase transition-all {tabActivo === 'letra'
            ? 'bg-gradient-to-br from-granate to-granate-dark text-dorado'
            : 'text-white/50'}"
        >
          Letra
        </button>
        <button
          type="button"
          onclick={() => (tabActivo = 'comentarios')}
          class="flex-1 h-10 rounded-full text-[11px] font-bold tracking-wider uppercase transition-all {tabActivo === 'comentarios'
            ? 'bg-gradient-to-br from-granate to-granate-dark text-dorado'
            : 'text-white/50'}"
        >
          Comentarios
        </button>
      </div>

      {#if tabActivo === 'info'}
        <!-- Nota personal -->
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
                  rows="4"
                  placeholder="Ej: la toco con la 6 tapada..."
                  class="w-full bg-transparent outline-none text-sm text-white placeholder:text-white/30 p-4 resize-none"
                ></textarea>
              </div>
              <div class="flex gap-2">
                <div class="flex-1">
                  <GlassButton variant="secondary" fullWidth onTap={() => (notaEditando = false)}>Cancelar</GlassButton>
                </div>
                <div class="flex-1">
                  <GlassButton variant="primary" fullWidth icon="check" onTap={guardarNota}>Guardar</GlassButton>
                </div>
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

        <!-- Partitura -->
        {#if cancion.estrofas.length > 0}
          <div class="space-y-3">
            <div class="flex items-center gap-2 px-1">
              <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
                <Icon name="grid" size={14} class="text-dorado" />
              </div>
              <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase">Partitura</h3>
            </div>
            {#each cancion.estrofas as estrofa, idx}
              <GlassCard padding="lg">
                <div class="flex items-center justify-between mb-3">
                  <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">
                    Estrofa {romanos[idx] ?? idx + 1}
                  </p>
                  {#if estrofa.bis}
                    <div class="flex items-center gap-1 text-dorado">
                      <Icon name="refresh" size={12} />
                      <span class="text-[10px] font-bold tracking-wider">BIS</span>
                    </div>
                  {/if}
                </div>
                <div class="overflow-x-auto -mx-1 px-1">
                  <table class="border-collapse">
                    <tbody>
                      <tr>
                        <td class="px-2 h-10 text-[11px] font-black text-dorado bg-granate rounded-tl-lg w-8 text-center">7</td>
                        {#each estrofa.columnas as col}
                          <td class="px-2 h-10 text-center text-[15px] font-black text-white font-mono border-l border-white/10 min-w-[34px] tabular-nums">{col.nota7 || '·'}</td>
                        {/each}
                      </tr>
                      <tr>
                        <td class="px-2 h-10 text-[11px] font-black text-dorado bg-granate rounded-bl-lg w-8 text-center border-t border-white/10">6</td>
                        {#each estrofa.columnas as col}
                          <td class="px-2 h-10 text-center text-[15px] font-black text-white font-mono border-l border-t border-white/10 min-w-[34px] tabular-nums">{col.nota6 || '·'}</td>
                        {/each}
                      </tr>
                    </tbody>
                  </table>
                </div>
              </GlassCard>
            {/each}
          </div>
        {/if}

        {#if !cancion.estrofas.length && !cancion.letra}
          <GlassCard padding="xl">
            <div class="flex flex-col items-center text-center py-6">
              <div class="w-14 h-14 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
                <Icon name="info" size={22} class="text-dorado/60" />
              </div>
              <p class="text-sm font-bold text-white">Sin contenido</p>
              <p class="text-xs text-white/50 mt-1">Esta canción aún no tiene partitura ni letra</p>
            </div>
          </GlassCard>
        {/if}
      {/if}

      {#if tabActivo === 'letra'}
        {#if cancion.letra}
          <GlassCard padding="xl">
            <div class="whitespace-pre-line text-center text-[15px] leading-[1.8] text-white/85 italic font-medium">
              {cancion.letra}
            </div>
          </GlassCard>
        {:else}
          <GlassCard padding="xl">
            <div class="flex flex-col items-center text-center py-6">
              <div class="w-14 h-14 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
                <Icon name="info" size={22} class="text-dorado/60" />
              </div>
              <p class="text-sm font-bold text-white">Sin letra</p>
              <p class="text-xs text-white/50 mt-1">Esta canción aún no tiene letra registrada</p>
            </div>
          </GlassCard>
        {/if}
      {/if}

      {#if tabActivo === 'comentarios'}
        <ComentariosSection cancionId={cancion.id} />
      {/if}
    </div>
  {/if}
</div>