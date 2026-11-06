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
  let sampleSeleccionado = $state('');
  let textoLetra = $state('');
  let seekPreview = $state(0);
  let seekDragging = $state(false);

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
    if (!seekDragging) seekPreview = player.posicionMs;
  });
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

  function desplazarTodoSync(deltaUs: number) {
    if (!syncProject) return;
    const minimo = syncProject.tracks.flatMap(t => t.events).reduce((min, ev) => Math.min(min, ev.atUs), Number.MAX_SAFE_INTEGER);
    if (minimo !== Number.MAX_SAFE_INTEGER && minimo + deltaUs < 0) return;
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(track => ({ ...track, events: track.events.map(ev => ({ ...ev, atUs: ev.atUs + deltaUs })) })), updatedAt: Date.now() };
    saveSyncProject(syncProject);
  }
  function agregarNotaSync() {
    if (!syncProject || !zampona.notas.length) return;
    const note = zampona.notas.find(n => n.id === sampleSeleccionado) ?? zampona.notas[0]; const track = syncProject.tracks.find(t => t.kind === 'zampona'); if (!track) return;
    const eventId = 'z-' + Date.now() + '-' + track.events.length;
    track.events = [...track.events, { id: eventId, kind: 'zampona-note', atUs: Math.round(player.posicionMs * 1000), sampleId: note.id, musicalEventId: eventId, gain: 0.8 }];
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function moverNotaSync(eventId: string, deltaUs: number) {
    if (!syncProject) return;
    const track = syncProject.tracks.find(t => t.kind === 'zampona'); if (!track) return;
    track.events = track.events.map(ev => ev.id === eventId ? { ...ev, atUs: Math.max(0, ev.atUs + deltaUs) } : ev);
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() };
    saveSyncProject(syncProject);
  }
  function eliminarNotaSync(eventId: string) {
    if (!syncProject) return;
    const track = syncProject.tracks.find(t => t.kind === 'zampona'); if (!track) return;
    track.events = track.events.filter(ev => ev.id !== eventId);
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() };
    saveSyncProject(syncProject);
  }
  function registrarCeldaTabla() {
    if (!syncProject || !ensayo.eventoActual) return;
    const ev = ensayo.eventoActual; const track = syncProject.tracks.find(t => t.kind === 'notation'); if (!track) return;
    const eventId = 't-' + Date.now(); track.events = [...track.events, { id: eventId, kind: 'notation-cell', atUs: Math.round(player.posicionMs * 1000), estrofaIndex: ev.estrofa_idx, columnaIndex: ev.columna_idx, fila: ev.es_fila7 ? 7 : 6, musicalEventId: eventId }];
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function ajustarCelda(eventId: string, deltaUs: number) {
    if (!syncProject) return; const track = syncProject.tracks.find(t => t.kind === 'notation'); if (!track) return;
    track.events = track.events.map(ev => ev.id === eventId ? { ...ev, atUs: Math.max(0, ev.atUs + deltaUs) } : ev); syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function borrarCelda(eventId: string) {
    if (!syncProject) return; const track = syncProject.tracks.find(t => t.kind === 'notation'); if (!track) return; track.events = track.events.filter(ev => ev.id !== eventId); syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function agregarMarcador() {
    if (!syncProject) return;
    const track = syncProject.tracks.find(t => t.kind === 'marker'); if (!track) return;
    const atUs = Math.round(player.posicionMs * 1000);
    track.events = [...track.events, { id: 'm-' + Date.now(), kind: 'section-marker', atUs, text: 'Marcador ' + (track.events.length + 1) }];
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function eliminarMarcador(eventId: string) {
    if (!syncProject) return;
    const track = syncProject.tracks.find(t => t.kind === 'marker'); if (!track) return;
    track.events = track.events.filter(ev => ev.id !== eventId);
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function agregarLineaLetra() {
    if (!syncProject || !textoLetra.trim()) return;
    const track = syncProject.tracks.find(t => t.kind === 'lyrics'); if (!track) return;
    track.events = [...track.events, { id: 'l-' + Date.now(), kind: 'lyric-line', atUs: Math.round(player.posicionMs * 1000), text: textoLetra.trim(), durationUs: 2500000 }];
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject); textoLetra = '';
  }
  function moverLetra(eventId: string, deltaUs: number) {
    if (!syncProject) return; const track = syncProject.tracks.find(t => t.kind === 'lyrics'); if (!track) return;
    track.events = track.events.map(ev => ev.id === eventId ? { ...ev, atUs: Math.max(0, ev.atUs + deltaUs) } : ev);
    syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  function eliminarLetra(eventId: string) {
    if (!syncProject) return; const track = syncProject.tracks.find(t => t.kind === 'lyrics'); if (!track) return;
    track.events = track.events.filter(ev => ev.id !== eventId); syncProject = { ...syncProject, tracks: syncProject.tracks.map(t => t.id === track.id ? track : t), updatedAt: Date.now() }; saveSyncProject(syncProject);
  }
  async function programarSync() {
    if (!syncProject || !player.current || player.current.id !== id) return;
    try { const count = await player.programarProyectoSync(syncProject); syncStorageError = 'Scheduler: ' + count + ' notas'; }
    catch (error) { syncStorageError = error instanceof Error ? error.message : 'Scheduler no disponible'; }
  }
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
      <section class="rounded-2xl border border-dorado/15 bg-black/20 p-3 space-y-2">
        <div class="flex items-center justify-between"><span class="text-xs font-bold text-white">Línea temporal</span><span class="text-[10px] text-white/55 tabular-nums">{(player.posicionMs / 1000).toFixed(2)} s / {(player.duracionMs / 1000).toFixed(2)} s</span></div>
        <input class="w-full accent-dorado" type="range" min="0" max={Math.max(1, player.duracionMs)} step="10" value={Math.min(seekPreview, player.duracionMs)} oninput={(e) => { seekDragging = true; seekPreview = Number((e.currentTarget as HTMLInputElement).value); }} onchange={(e) => { const value = Number((e.currentTarget as HTMLInputElement).value); seekDragging = false; void player.buscar(value); }} disabled={!player.current || player.current.id !== id || player.duracionMs <= 0} aria-label="Posición del audio" />
        <div class="flex items-center justify-between gap-2"><span class="text-[10px] text-white/45">Mover cursor y confirmar para buscar</span><button class="rounded-lg bg-dorado/15 px-3 py-2 text-xs text-dorado" onclick={agregarMarcador} disabled={!syncProject}>+ Marcador en cursor</button></div>
        <div class="space-y-1 max-h-20 overflow-y-auto">{#each (syncProject?.tracks.find(t => t.kind === 'marker')?.events ?? []) as ev}<div class="flex justify-between items-center text-[10px] text-white/60"><span>{ev.text} · {(ev.atUs / 1000000).toFixed(2)} s</span><button class="text-red-300 px-2" onclick={() => eliminarMarcador(ev.id)} aria-label="Eliminar marcador">×</button></div>{/each}</div>
      </section>
      <section class="rounded-2xl border border-dorado/20 bg-black/25 p-3 space-y-2">
        <div class="flex items-center justify-between"><span class="text-xs font-bold text-dorado">Editor de sincronización</span><span class="text-[10px] text-white/50">{syncProject?.tracks.find(t => t.kind === 'zampona')?.events.length ?? 0} notas</span></div>
        <div class="flex gap-2 flex-wrap"><button class="rounded-lg bg-white/10 px-2 py-2 text-xs text-white" onclick={() => desplazarTodoSync(-500000)}>Todo −0,5 s</button><button class="rounded-lg bg-white/10 px-2 py-2 text-xs text-white" onclick={() => desplazarTodoSync(500000)}>Todo +0,5 s</button><select class="rounded-lg bg-black/40 px-2 py-2 text-xs text-white max-w-40" bind:value={sampleSeleccionado}><option value="">Muestra (primera)</option>{#each zampona.notas as nota}<option value={nota.id}>{nota.nota} · F{nota.fila}</option>{/each}</select><button class="rounded-lg bg-dorado/15 px-3 py-2 text-xs text-dorado" onclick={agregarNotaSync} disabled={!syncProject || !zampona.notas.length}>+ Nota en cursor</button><button class="rounded-lg bg-white/10 px-3 py-2 text-xs text-white" onclick={() => { if (syncProject) saveSyncProject(syncProject); }}>Guardar</button><button class="rounded-lg bg-white/10 px-3 py-2 text-xs text-white" onclick={() => void programarSync()} disabled={!player.current || player.current.id !== id}>Programar notas</button></div>
        <div class="max-h-24 overflow-y-auto space-y-1">{#each (syncProject?.tracks.find(t => t.kind === 'zampona')?.events ?? []) as ev}<div class="flex items-center justify-between gap-2 text-[10px] text-white/60"><span class="truncate">{ev.sampleId} · {(ev.atUs / 1000000).toFixed(3)} s</span><div class="flex gap-1 shrink-0"><button class="px-1 rounded bg-white/10" onclick={() => moverNotaSync(ev.id, -50000)} aria-label="Mover 50 ms antes">−</button><button class="px-1 rounded bg-white/10" onclick={() => moverNotaSync(ev.id, 50000)} aria-label="Mover 50 ms después">+</button><button class="px-1 rounded bg-red-500/15 text-red-300" onclick={() => eliminarNotaSync(ev.id)} aria-label="Eliminar nota">×</button></div></div>{/each}</div>
      </section>
      <section class="rounded-2xl border border-dorado/15 bg-black/20 p-3 space-y-2">
        <div class="flex items-center justify-between"><span class="text-xs font-bold text-dorado">Sincronización de la tabla</span><span class="text-[10px] text-white/45">{syncProject?.tracks.find(t => t.kind === 'notation')?.events.length ?? 0} celdas</span></div>
        <div class="flex items-center justify-between gap-2"><span class="text-[10px] text-white/55">Registra la celda iluminada al tiempo actual del audio.</span><button class="rounded-lg bg-dorado/15 px-3 py-2 text-xs text-dorado" onclick={registrarCeldaTabla} disabled={!syncProject || !ensayo.eventoActual}>+ Registrar celda</button></div>
        <div class="max-h-24 overflow-y-auto space-y-1">{#each (syncProject?.tracks.find(t => t.kind === 'notation')?.events ?? []) as ev}<div class="flex items-center justify-between gap-2 text-[10px] text-white/60"><span>Est. {(ev.estrofaIndex ?? 0) + 1} · Col. {(ev.columnaIndex ?? 0) + 1} · F{ev.fila} · {(ev.atUs / 1000000).toFixed(3)} s</span><div class="flex gap-1"><button class="px-1 rounded bg-white/10" onclick={() => ajustarCelda(ev.id, -50000)} aria-label="Mover celda antes">−</button><button class="px-1 rounded bg-white/10" onclick={() => ajustarCelda(ev.id, 50000)} aria-label="Mover celda después">+</button><button class="px-1 rounded bg-red-500/15 text-red-300" onclick={() => borrarCelda(ev.id)} aria-label="Eliminar celda">×</button></div></div>{/each}</div>
      </section>
      <section class="rounded-2xl border border-dorado/15 bg-black/20 p-3 space-y-2">
        <div class="flex items-center justify-between"><span class="text-xs font-bold text-dorado">Sincronización de la letra</span><span class="text-[10px] text-white/45">{syncProject?.tracks.find(t => t.kind === 'lyrics')?.events.length ?? 0} líneas</span></div>
        <div class="flex gap-2"><input class="min-w-0 flex-1 rounded-lg bg-black/40 px-3 py-2 text-xs text-white placeholder:text-white/35" placeholder="Escribe la línea que se canta…" bind:value={textoLetra} /><button class="rounded-lg bg-dorado/15 px-3 py-2 text-xs text-dorado" onclick={agregarLineaLetra} disabled={!textoLetra.trim() || !syncProject}>Añadir</button></div>
        <div class="max-h-28 overflow-y-auto space-y-1">{#each (syncProject?.tracks.find(t => t.kind === 'lyrics')?.events ?? []) as ev}<div class="flex items-center justify-between gap-2 text-[10px] text-white/60"><span class="min-w-0 truncate">{ev.text} · {(ev.atUs / 1000000).toFixed(3)} s</span><div class="flex gap-1 shrink-0"><button class="px-1 rounded bg-white/10" onclick={() => moverLetra(ev.id, -100000)} aria-label="Mover letra antes">−</button><button class="px-1 rounded bg-white/10" onclick={() => moverLetra(ev.id, 100000)} aria-label="Mover letra después">+</button><button class="px-1 rounded bg-red-500/15 text-red-300" onclick={() => eliminarLetra(ev.id)} aria-label="Eliminar línea">×</button></div></div>{/each}</div>
      </section>
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