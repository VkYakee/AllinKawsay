<!-- src/lib/features/ensayo/EnsayoScreen.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import ZamponaCanvas from '../zampona/ZamponaCanvas.svelte';
  import PartituraView from './PartituraView.svelte';
  import { ensayo } from '../../stores/ensayo.svelte';
  import { player } from '../../stores/player.svelte';
  import { zampona } from '../../stores/zampona.svelte';
  import { canciones } from '../../stores/canciones.svelte';
  import { router } from '../../stores/router.svelte';
  import type { NotaZampona } from '../../services/zampona';
  import { getOrCreateSyncProject, saveSyncProject } from '../../services/ensayo-sync-storage';
  import type { SyncProject } from '../../domain/ensayo/sync-project';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();
  let syncProject = $state<SyncProject | null>(null);
  let syncStorageError = $state('');

  onMount(() => {
    zampona.cargar();
    canciones.cargar();
  });

  $effect(() => {
    if (!canciones.buscar(id) || syncProject?.songId === id) return;
    try { const project = getOrCreateSyncProject(id); saveSyncProject(project); syncProject = project; syncStorageError = ''; }
    catch (error) { syncStorageError = error instanceof Error ? error.message : 'No se pudo guardar'; }
  });

  // Cuando las canciones estén listas, prepara el ensayo
  $effect(() => {
    const c = canciones.buscar(id);
    if (c && !ensayo.preparado && !ensayo.cargando) {
      ensayo.preparar(c.estrofas);
    }
  });

  onDestroy(() => {
    ensayo.stop();
    if (player.current?.id === id) void player.stop();
    zampona.soltarTodo();
  });

  const cancion = $derived(canciones.buscar(id));

  const estrofaActual = $derived.by(() => {
    if (!cancion) return null;
    const ev = ensayo.eventoActual;
    if (!ev) return cancion.estrofas[0] ?? null;
    return cancion.estrofas[ev.estrofa_idx] ?? null;
  });

  const celdaActiva = $derived.by(() => {
    const ev = ensayo.eventoActual;
    if (!ev) return null;
    return { columna: ev.columna_idx, esFila7: ev.es_fila7 };
  });

  const estrofaNum = $derived((ensayo.eventoActual?.estrofa_idx ?? 0) + 1);

  const progreso = $derived(
    player.duracionMs > 0
      ? Math.min(100, (player.posicionMs / player.duracionMs) * 100)
      : 0
  );

  // La partitura sigue el reloj consultado al reproductor nativo.
  $effect(() => {
    if (player.current?.id !== id) return;
    ensayo.actualizarPosicion(player.posicionMs);
    ensayo.velocidad = player.velocidad;
    ensayo.estado = player.playing
      ? 'playing'
      : player.duracionMs > 0 && player.posicionMs >= player.duracionMs
        ? 'finished'
        : player.posicionMs > 0 ? 'paused' : 'idle';
  });

  async function iniciarEnsayo() {
    if (!cancion?.audio_url) return;
    if (player.current?.id === id) {
      if (player.duracionMs > 0 && player.posicionMs >= player.duracionMs) {
        await player.buscar(0);
      }
      await player.toggle();
      return;
    }
    await player.play({
      id: cancion.id,
      titulo: cancion.titulo,
      autor: cancion.autor,
      imagenUrl: cancion.imagen_url,
      audioUrl: cancion.audio_url
    });
  }

  async function detenerEnsayo() {
    if (player.current?.id === id) await player.stop();
    ensayo.stop();
  }

  function handleZamponaTap(nota: NotaZampona) {
    zampona.tocar(nota);
    if (navigator.vibrate) navigator.vibrate(15);
  }
</script>

<div class="app-background min-h-dvh flex flex-col">
  <header class="px-5 pt-3 pb-3 flex items-center gap-3">
    <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
    <div class="flex-1 min-w-0">
      <p class="text-[10px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
        Modo Ensayo
      </p>
      <h1 class="text-xl font-black text-white tracking-tight truncate mt-0.5">
        {cancion?.titulo ?? 'Cargando...'}
      </h1>
    </div>
  </header>

  <div class="flex-1 flex flex-col px-4 gap-3 pb-6 overflow-y-auto">
    {#if canciones.loading && !cancion}
      <div class="flex-1 flex items-center justify-center">
        <div class="w-8 h-8 border-2 border-dorado/60 border-t-transparent rounded-full animate-spin"></div>
      </div>
    {:else if !cancion}
      <div class="flex-1 flex flex-col items-center justify-center text-center px-6">
        <div class="w-16 h-16 rounded-full bg-red-500/10 flex items-center justify-center mb-3">
          <Icon name="alert-circle" size={26} class="text-red-400/70" />
        </div>
        <p class="text-base font-bold text-white">Canción no encontrada</p>
        <p class="text-xs text-white/50 mt-1">Puede que se haya eliminado</p>
      </div>
    {:else if !ensayo.preparado || ensayo.preparado.eventos.length === 0}
      <div class="flex-1 flex flex-col items-center justify-center text-center px-6">
        <div class="w-16 h-16 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
          <Icon name="info" size={26} class="text-dorado/60" />
        </div>
        <p class="text-base font-bold text-white">Sin partitura</p>
        <p class="text-xs text-white/50 mt-1">
          Esta canción aún no tiene numerofonía grabada.
        </p>
      </div>
    {:else}
      <div class="rounded-xl border border-dorado/15 bg-black/20 px-3 py-2 flex items-center justify-between gap-2">
        <span class="text-[10px] text-white/55">Sincronización independiente</span>
        <span class="text-[10px] font-semibold text-dorado/80">{syncStorageError || (syncProject ? "Proyecto local listo · v1" : "Preparando…")}</span>
      </div>
      <div class="pt-1">
        {#if estrofaActual}
          <PartituraView estrofa={estrofaActual} {celdaActiva} numero={estrofaNum} />
        {/if}
      </div>

      <div class="glass glass-strong rounded-3xl p-2">
        <ZamponaCanvas
          notas={zampona.notas}
          brillando={ensayo.brillando}
          onTap={handleZamponaTap}
        />
      </div>

      <div class="px-1">
        <div class="h-1 rounded-full bg-white/10 overflow-hidden">
          <div
            class="h-full bg-gradient-to-r from-dorado to-dorado-dark"
            style="width: {progreso}%; transition: width 80ms linear;"
          ></div>
        </div>
      </div>

      <div class="flex items-center justify-center gap-2 pt-1">
        <GlassIconButton
          icon="refresh"
          size="sm"
          onTap={() => void detenerEnsayo()}
        />

        {#if ensayo.estado === 'playing'}
          <GlassButton variant="primary" icon="pause" onTap={() => void player.toggle()}>
            Pausa
          </GlassButton>
        {:else}
          <GlassButton variant="primary" icon="play" onTap={() => void iniciarEnsayo()}>
            {ensayo.estado === 'finished' ? 'Reiniciar' : 'Play'}
          </GlassButton>
        {/if}

        <div class="glass rounded-full pl-3 pr-2 h-11 flex items-center gap-2">
          <Icon name="zap" size={13} class="text-dorado/70" />
          <span class="text-[11px] font-bold text-dorado tabular-nums min-w-[32px] text-center">
            {ensayo.velocidad.toFixed(2)}x
          </span>
          <input
            type="range"
            min="0.5"
            max="2"
            step="0.25"
            value={player.velocidad}
            oninput={(e) =>
              void player.setVelocidad(parseFloat((e.target as HTMLInputElement).value))}
            class="w-20 accent-dorado"
          />
        </div>
      </div>
    {/if}
  </div>
</div>