<!-- src/lib/features/admin/AgregarCancion.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import EditorNumerofonia from './EditorNumerofonia.svelte';
  import EditorLetra from './EditorLetra.svelte';
  import { cancionesService, type Estrofa, type Letra } from '../../services/canciones';
  import { categoriasService, type Categoria } from '../../services/categorias';
  import { canciones } from '../../stores/canciones.svelte';
  import { actividadService } from '../../services/actividad';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';
  import { subirAudioCancion, subirImagenCancion } from '../../services/cloudinary';

  interface Props {
    id?: string;
  }

  let { id = '' }: Props = $props();

  const editando = $derived(id !== '');

  let titulo = $state('');
  let autor = $state('');
  let ritmo = $state('');
  let region = $state('');
  let descripcion = $state('');
  let letra = $state('');
  let letrasOriginales = $state<Letra[]>([]);
  let tagsInput = $state('');
  let categoriaId = $state('');
  let categorias = $state<Categoria[]>([]);
  let errorCategorias = $state('');
  let imagenUrl = $state('');
  let audioUrl = $state('');
  let videoUrl = $state('');
  let estrofas = $state<Estrofa[]>([]);
  let paso = $state(0);
  const pasos = ['Datos', 'Partitura', 'Letra'];
  function avanzar() {
    if (guardando) return;
    error = '';
    if (cargandoEdicion) { error = 'Espera a que termine de cargar la canción.'; return; }
    if (paso === 0 && !titulo.trim()) { error = 'Primero escribe el nombre de la canción.'; return; }
    if (paso < pasos.length - 1) paso += 1;
  }
  function retroceder() { error = ''; if (paso > 0) paso -= 1; else router.back(); }

  let subiendoImagen = $state(false);
  let subiendoAudio = $state(false);
  let progresoImagen = $state(0);
  let progresoAudio = $state(0);
  let guardando = $state(false);
  let cargandoEdicion = $state(false);
  let error = $state('');

  function aplicarCancion(c: NonNullable<Awaited<ReturnType<typeof cancionesService.obtener>>>) {
    titulo = c.titulo;
    autor = c.autor;
    ritmo = c.ritmo;
    region = c.region;
    descripcion = c.descripcion;
    letra = c.letra;
    letrasOriginales = c.letras.map((parte) => ({ ...parte }));
    tagsInput = c.tags.join(', ');
    categoriaId = c.categoriaId;
    imagenUrl = c.imagen_url;
    audioUrl = c.audio_url;
    videoUrl = c.video_url;
    estrofas = c.estrofas.map((estrofa) => ({
      bis: estrofa.bis,
      columnas: estrofa.columnas.map((columna) => ({ ...columna }))
    }));
  }

  async function cargarCategorias() {
    errorCategorias = '';
    try {
      categorias = await categoriasService.listar();
    } catch (cause) {
      errorCategorias = cause instanceof Error ? cause.message : 'No se pudieron cargar las categorías.';
    }
  }

  onMount(async () => {
    await cargarCategorias();
    if (!editando) return;
    cargandoEdicion = true;
    try {
      const existente = canciones.buscar(id) ?? await cancionesService.obtener(id);
      if (!existente) {
        error = 'No se encontró esta canción. Vuelve al cancionero e inténtalo de nuevo.';
        return;
      }
      aplicarCancion(existente);
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'No se pudo cargar la canción para editar.';
    } finally {
      cargandoEdicion = false;
    }
  });

  async function subirImagen(e: Event) {
    const input = e.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    subiendoImagen = true;
    progresoImagen = 0;
    try {
      imagenUrl = await subirImagenCancion(file, (p) => (progresoImagen = p));
    } catch (err) {
      error = err instanceof Error ? err.message : 'Error al subir imagen';
    } finally {
      subiendoImagen = false;
      input.value = '';
    }
  }

  async function subirAudio(e: Event) {
    const input = e.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    subiendoAudio = true;
    progresoAudio = 0;
    try {
      audioUrl = await subirAudioCancion(file, (p) => (progresoAudio = p));
    } catch (err) {
      error = err instanceof Error ? err.message : 'Error al subir audio';
    } finally {
      subiendoAudio = false;
      input.value = '';
    }
  }

  async function registrarActividad(tipo: string, mensaje: string) {
    try {
      await actividadService.registrar(tipo, mensaje, session.user?.uid ?? '', session.displayName);
    } catch {
      // La canción ya fue guardada; un fallo secundario no debe provocar un alta duplicada.
      console.warn('No se pudo registrar la actividad de la canción.');
    }
  }

  async function guardar() {
    if (guardando) return;
    error = '';
    if (cargandoEdicion) { error = 'Espera a que termine de cargar la canción.'; return; }
    if (!titulo.trim()) { error = 'El título es obligatorio'; return; }
    if (subiendoImagen || subiendoAudio) { error = 'Espera a que terminen las subidas'; return; }

    guardando = true;
    try {
      const tags = tagsInput.split(',').map((t) => t.trim()).filter((t) => t.length > 0);
      const input = {
        titulo, autor, ritmo, region, descripcion, letra, letrasOriginales, tags, categoriaId,
        imagen_url: imagenUrl, audio_url: audioUrl, video_url: videoUrl,
        estrofas
      };

      if (editando) {
        await cancionesService.actualizar(id, input);
        await registrarActividad('editar_cancion', `Editó la canción "${titulo}"`);
      } else {
        await cancionesService.crear(input, session.user?.uid ?? '', session.user?.nombre ?? 'Admin');
        await registrarActividad('crear_cancion', `Creó la canción "${titulo}"`);
      }
      canciones.refrescar();
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
      <GlassIconButton icon="chevron-left" onTap={retroceder} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">
          {editando ? 'Editar' : 'Nueva'}
        </p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Canción</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-10 space-y-4">
    {#if cargandoEdicion}
      <div class="glass rounded-2xl border border-dorado/20 px-4 py-3 flex items-center gap-3"><div class="w-5 h-5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div><p class="text-xs text-white/70">Cargando los datos de la canción…</p></div>
    {/if}
    <div class="grid grid-cols-3 gap-2" aria-label="Progreso de canción">
      {#each pasos as nombre, indice}
        <button type="button" onclick={() => { if (!cargandoEdicion && !guardando && (indice < paso || (indice === 1 && titulo.trim()))) paso = indice; }} class="text-left space-y-2" aria-current={paso === indice ? 'step' : undefined}>
          <div class="h-1.5 rounded-full transition-colors duration-300 {indice <= paso ? 'bg-dorado' : 'bg-white/10'}"></div>
          <span class="text-[10px] font-bold {paso === indice ? 'text-dorado' : 'text-white/40'}">{indice + 1}. {nombre}</span>
        </button>
      {/each}
    </div>
    {#if paso === 0}
    <GlassCard padding="md" variant="gold">
      <p class="text-sm font-bold text-white">Empecemos por lo básico</p>
      <p class="text-xs text-white/60 mt-1">Añade los datos y archivos que identifican esta canción. Podrás completar la partitura y la letra después.</p>
    </GlassCard>
    <GlassInput bind:value={titulo} label="Título *" placeholder="Adiós Conima" icon="music" />
    <GlassInput bind:value={autor} label="Autor" placeholder="Anónimo" icon="user" />

    <div class="grid grid-cols-2 gap-3">
      <GlassInput bind:value={ritmo} label="Ritmo" placeholder="Huayño" />
      <GlassInput bind:value={region} label="Región" placeholder="Puno" />
    </div>

    <GlassInput bind:value={tagsInput} label="Tags" placeholder="tradicional, altiplano" icon="star" />

    <div class="space-y-1.5">
      <label for="categoria-cancion" class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1">Categoría</label>
      <select id="categoria-cancion" bind:value={categoriaId} class="w-full h-12 rounded-xl border border-white/10 bg-[#211D1A] px-4 text-sm text-white outline-none focus:border-dorado/50">
        <option value="">Sin categoría</option>
        {#each categorias as categoria (categoria.id)}
          <option value={categoria.id}>{categoria.emoji} {categoria.nombre}</option>
        {/each}
      </select>
      {#if errorCategorias}
        <div class="flex items-center justify-between gap-3 px-1">
          <p class="text-[11px] text-amber-200/80">{errorCategorias}. Puedes guardar sin asignar una categoría.</p>
          <button type="button" onclick={cargarCategorias} class="shrink-0 text-[11px] font-bold text-dorado">Reintentar</button>
        </div>
      {/if}
    </div>

    <GlassCard variant="default" padding="md">
      <p class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 mb-2">Imagen de portada</p>
      {#if imagenUrl}
        <div class="relative rounded-2xl overflow-hidden mb-2">
          <img src={imagenUrl} alt="Portada" class="w-full h-40 object-cover" />
          <button type="button" onclick={() => (imagenUrl = '')} aria-label="Quitar portada" class="absolute top-2 right-2 w-8 h-8 rounded-full bg-black/70 flex items-center justify-center text-white">
            <Icon name="x" size={14} />
          </button>
        </div>
      {/if}
      <label class="block">
        <input type="file" accept="image/*" onchange={subirImagen} class="hidden" disabled={subiendoImagen || cargandoEdicion || guardando} />
        <div class="glass rounded-xl h-12 flex items-center justify-center gap-2 border border-white/10 cursor-pointer active:scale-95 transition-transform">
          {#if subiendoImagen}
            <div class="w-5 h-5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div>
            <p class="text-[11px] text-dorado/80">{Math.round(progresoImagen * 100)}%</p>
          {:else}
            <Icon name="upload" size={16} class="text-dorado/70" />
            <p class="text-[11px] text-white/70">{imagenUrl ? 'Reemplazar portada' : 'Subir portada'}</p>
          {/if}
        </div>
      </label>
    </GlassCard>

    <GlassCard variant="default" padding="md">
      <p class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 mb-2">Audio (mp3/ogg)</p>
      {#if audioUrl}
        <div class="glass rounded-2xl p-3 flex items-center gap-2 border border-white/10 mb-2">
          <Icon name="volume" size={18} class="text-dorado" />
          <p class="text-xs text-white/80 flex-1 truncate">{audioUrl.split('/').pop()}</p>
          <button type="button" onclick={() => (audioUrl = '')} aria-label="Quitar audio" class="w-7 h-7 rounded-full bg-red-500/20 flex items-center justify-center text-red-300">
            <Icon name="x" size={12} />
          </button>
        </div>
      {/if}
      <label class="block">
        <input type="file" accept="audio/*" onchange={subirAudio} class="hidden" disabled={subiendoAudio || cargandoEdicion || guardando} />
        <div class="glass rounded-xl h-12 flex items-center justify-center gap-2 border border-white/10 cursor-pointer active:scale-95 transition-transform">
          {#if subiendoAudio}
            <div class="w-5 h-5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div>
            <p class="text-[11px] text-dorado/80">{Math.round(progresoAudio * 100)}%</p>
          {:else}
            <Icon name="upload" size={16} class="text-dorado/70" />
            <p class="text-[11px] text-white/70">{audioUrl ? 'Reemplazar audio' : 'Subir audio'}</p>
          {/if}
        </div>
      </label>
    </GlassCard>

    <GlassInput bind:value={videoUrl} label="Video YouTube" placeholder="https://youtu.be/..." icon="play" />

    <div class="flex flex-col gap-1.5">
      <label for="desc-cancion" class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1">
        Descripción
      </label>
      <div class="glass rounded-2xl border border-white/10">
        <textarea
          id="desc-cancion"
          bind:value={descripcion}
          rows="2"
          placeholder="Breve descripción..."
          class="w-full bg-transparent outline-none text-[15px] text-white placeholder:text-white/30 font-medium p-4 resize-none"
        ></textarea>
      </div>
    </div>

    {/if}

    {#if paso === 1}
    <GlassCard padding="md">
      <p class="text-sm font-bold text-white">Construyamos la partitura</p>
      <p class="text-xs text-white/60 mt-1">Organiza las notas en columnas. La fila 7 va arriba y la fila 6 abajo. Puedes guardar la canción y completar esta parte más adelante.</p>
    </GlassCard>
    <!-- Numerofonía -->
    <div class="space-y-2">
      <div class="flex items-center gap-2 px-1">
        <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
          <Icon name="grid" size={14} class="text-dorado" />
        </div>
        <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase">Numerofonía</h3>
      </div>
      <EditorNumerofonia bind:estrofas onCambio={() => {}} />
    </div>

    {/if}

    {#if paso === 2}
    <GlassCard padding="md">
      <p class="text-sm font-bold text-white">Añade la letra y revisa</p>
      <p class="text-xs text-white/60 mt-1">No necesitas completar todos los campos ahora. Puedes volver a editar la canción cuando quieras.</p>
    </GlassCard>
    <!-- Letra -->
    <div class="space-y-2">
      <div class="flex items-center gap-2 px-1">
        <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
          <Icon name="list" size={14} class="text-dorado" />
        </div>
        <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase">Letra</h3>
      </div>
      <EditorLetra bind:letra onCambio={() => {}} />
    </div>

    {/if}

    {#if error}
      <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{error}</p>
      </div>
    {/if}

    {#if paso < 2}
      <div class="flex gap-2">
        {#if paso > 0}<GlassButton variant="secondary" onTap={retroceder}>Atrás</GlassButton>{/if}
        <div class="flex-1"><GlassButton variant="primary" fullWidth icon="arrow-right" onTap={avanzar}>Continuar</GlassButton></div>
      </div>
    {:else}
      <div class="space-y-2">
        <GlassButton variant="secondary" fullWidth onTap={retroceder}>Volver a la partitura</GlassButton>
        <GlassButton variant="primary" fullWidth icon="check" loading={guardando || cargandoEdicion} onTap={guardar}>
          {editando ? 'Guardar cambios' : 'Crear canción'}
        </GlassButton>
      </div>
    {/if}
  </div>
</div>