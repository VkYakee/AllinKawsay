<!-- src/lib/features/admin/AgregarRecuerdo.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { recuerdosService, fechaLarga } from '../../services/recuerdos';
  import { recuerdos } from '../../stores/recuerdos.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';
  import { subirFotoRecuerdo, subirVideoRecuerdo } from '../../services/cloudinary';

  interface Props {
    id?: string;
  }

  let { id = '' }: Props = $props();

  const editando = $derived(id !== '');

  let titulo = $state('');
  let descripcion = $state('');
  let fechaInput = $state<string>(new Date().toISOString().slice(0, 10));
  let fotos = $state<string[]>([]);
  let videos = $state<string[]>([]);

  let subiendo = $state(false);
  let progreso = $state(0);
  let textoSubida = $state('');
  let guardando = $state(false);
  let cargandoEdicion = $state(false);
  let error = $state('');

  async function cargarRecuerdo() {
    if (!editando) return;
    cargandoEdicion = true;
    error = '';
    try {
      const existente = recuerdos.buscar(id) ?? await recuerdosService.obtener(id);
      if (!existente) {
        error = 'No se encontró este recuerdo. Vuelve a la galería e inténtalo de nuevo.';
        return;
      }
      titulo = existente.titulo;
      descripcion = existente.descripcion;
      fechaInput = existente.fecha.slice(0, 10);
      fotos = [...existente.fotos];
      videos = [...existente.videos];
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'No se pudo cargar el recuerdo.';
    } finally {
      cargandoEdicion = false;
    }
  }

  onMount(() => {
    void cargarRecuerdo();
  });

  async function subirFotos(e: Event) {
    if (subiendo || cargandoEdicion || guardando) return;
    const input = e.target as HTMLInputElement;
    const files = Array.from(input.files ?? []);
    if (files.length === 0) return;

    subiendo = true;
    error = '';
    try {
      for (let i = 0; i < files.length; i++) {
        textoSubida = `Foto ${i + 1} de ${files.length}`;
        progreso = 0;
        const url = await subirFotoRecuerdo(files[i], (p) => (progreso = p));
        fotos = [...fotos, url];
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'Error al subir fotos';
    } finally {
      subiendo = false;
      progreso = 0;
      textoSubida = '';
      input.value = '';
    }
  }

  async function subirVideos(e: Event) {
    if (subiendo || cargandoEdicion || guardando) return;
    const input = e.target as HTMLInputElement;
    const files = Array.from(input.files ?? []);
    if (files.length === 0) return;

    subiendo = true;
    error = '';
    try {
      for (let i = 0; i < files.length; i++) {
        textoSubida = `Video ${i + 1} de ${files.length}`;
        progreso = 0;
        const url = await subirVideoRecuerdo(files[i], (p) => (progreso = p));
        videos = [...videos, url];
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'Error al subir videos';
    } finally {
      subiendo = false;
      progreso = 0;
      textoSubida = '';
      input.value = '';
    }
  }

  async function guardar() {
    if (guardando) return;
    error = '';
    if (cargandoEdicion) { error = 'Espera a que termine de cargar el recuerdo.'; return; }
    if (!titulo.trim()) { error = 'El título es obligatorio'; return; }
    if (!fechaInput || Number.isNaN(new Date(`${fechaInput}T12:00:00`).getTime())) { error = 'La fecha del recuerdo no es válida.'; return; }
    if (subiendo) { error = 'Espera a que terminen las subidas'; return; }

    guardando = true;
    try {
      const fecha = new Date(fechaInput + 'T12:00:00');
      const input = { titulo, descripcion, fotos, videos, fecha };

      if (editando) {
        await recuerdosService.actualizar(id, input);
      } else {
        await recuerdosService.crear(
          input,
          session.user?.uid ?? '',
          session.user?.nombre ?? 'Admin'
        );
      }
      recuerdos.refrescar();
      router.back();
    } catch (e) {
      error = e instanceof Error ? e.message : 'Error al guardar';
    } finally {
      guardando = false;
    }
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">
          {editando ? 'Editar' : 'Nuevo'}
        </p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Recuerdo</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-10 space-y-4">
    {#if cargandoEdicion}
      <div class="glass rounded-2xl border border-dorado/20 px-4 py-3 flex items-center gap-3"><div class="w-5 h-5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div><p class="text-xs text-white/70">Cargando los datos del recuerdo…</p></div>
    {:else if editando && error && fotos.length === 0 && videos.length === 0 && !titulo}
      <div role="alert" class="glass rounded-2xl border border-red-500/30 p-4 flex items-center gap-3">
        <p class="text-xs text-red-200 flex-1">{error}</p>
        <button type="button" onclick={cargarRecuerdo} class="text-[11px] font-bold text-dorado">Reintentar</button>
      </div>
    {/if}
    <GlassInput bind:value={titulo} label="Título *" placeholder="Fiesta Patronal 2026" icon="image" />

    <div class="flex flex-col gap-1.5">
      <label for="fecha-recuerdo" class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1">
        Fecha
      </label>
      <div class="glass rounded-2xl border border-white/10">
        <div class="flex items-center gap-2 px-4 h-14">
          <Icon name="calendar" size={18} class="text-dorado/80" />
          <input
            id="fecha-recuerdo"
            type="date"
            bind:value={fechaInput}
            class="flex-1 bg-transparent outline-none text-[15px] text-white font-medium [color-scheme:dark]"
          />
        </div>
      </div>
    </div>

    <div class="flex flex-col gap-1.5">
      <label for="desc-recuerdo" class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1">
        Descripción
      </label>
      <div class="glass rounded-2xl border border-white/10">
        <textarea
          id="desc-recuerdo"
          bind:value={descripcion}
          rows="3"
          placeholder="Cuéntanos sobre este recuerdo..."
          class="w-full bg-transparent outline-none text-[15px] text-white placeholder:text-white/30 font-medium p-4 resize-none"
        ></textarea>
      </div>
    </div>

    <!-- Fotos -->
    <GlassCard variant="default" padding="md">
      <div class="flex items-center justify-between mb-2">
        <p class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80">
          Fotos ({fotos.length})
        </p>
        <label class="cursor-pointer">
          <input type="file" accept="image/*" multiple onchange={subirFotos} class="hidden" disabled={subiendo || cargandoEdicion || guardando} />
          <div class="glass-gold rounded-full px-3 py-1 border border-dorado/40 text-dorado text-[11px] font-bold">
            + Añadir
          </div>
        </label>
      </div>
      {#if fotos.length > 0}
        <div class="grid grid-cols-3 gap-1.5">
          {#each fotos as foto, i (foto)}
            <div class="relative aspect-square rounded-xl overflow-hidden">
              <img src={foto} alt="Foto {i + 1}" class="w-full h-full object-cover" />
              <button
                type="button"
                disabled={subiendo || guardando}
                aria-label="Quitar foto"
                onclick={() => (fotos = fotos.filter((_, j) => j !== i))}
                class="absolute top-1 right-1 w-6 h-6 rounded-full bg-black/70 flex items-center justify-center text-white"
              >
                <Icon name="x" size={11} />
              </button>
            </div>
          {/each}
        </div>
      {:else}
        <p class="text-[11px] text-white/40 text-center py-4">Aún no hay fotos</p>
      {/if}
    </GlassCard>

    <!-- Videos -->
    <GlassCard variant="default" padding="md">
      <div class="flex items-center justify-between mb-2">
        <p class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80">
          Videos ({videos.length})
        </p>
        <label class="cursor-pointer">
          <input type="file" accept="video/*" multiple onchange={subirVideos} class="hidden" disabled={subiendo} />
          <div class="glass-gold rounded-full px-3 py-1 border border-dorado/40 text-dorado text-[11px] font-bold">
            + Añadir
          </div>
        </label>
      </div>
      {#if videos.length > 0}
        <div class="space-y-1.5">
          {#each videos as _, i (i)}
            <div class="glass rounded-xl px-3 py-2 flex items-center gap-2 border border-white/10">
              <Icon name="play" size={14} class="text-dorado" fill />
              <p class="text-xs text-white/80 flex-1">Video {i + 1}</p>
              <button
                type="button"
                disabled={subiendo || guardando}
                aria-label="Quitar video"
                onclick={() => (videos = videos.filter((_, j) => j !== i))}
                class="w-6 h-6 rounded-full bg-red-500/20 flex items-center justify-center text-red-300"
              >
                <Icon name="x" size={11} />
              </button>
            </div>
          {/each}
        </div>
      {:else}
        <p class="text-[11px] text-white/40 text-center py-4">Aún no hay videos</p>
      {/if}
    </GlassCard>

    {#if subiendo}
      <div class="glass rounded-2xl p-3 border border-dorado/30 flex items-center gap-2">
        <div class="w-5 h-5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div>
        <p class="text-xs text-dorado flex-1">{textoSubida}</p>
        <span class="text-xs text-dorado font-bold tabular-nums">{Math.round(progreso * 100)}%</span>
      </div>
    {/if}

    {#if error}
      <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{error}</p>
      </div>
    {/if}

    <GlassButton variant="primary" fullWidth icon="check" loading={guardando || cargandoEdicion} onTap={guardar}>
      {editando ? 'Guardar cambios' : 'Crear recuerdo'}
    </GlassButton>
  </div>
</div>