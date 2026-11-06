<!-- src/lib/features/perfil/GestionCache.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { contarArchivosCache, limpiarCache } from '../../services/cache';
  import { router } from '../../stores/router.svelte';

  let archivos = $state(0);
  let cargando = $state(true);
  let limpiando = $state(false);
  let archivosEliminados = $state<number | null>(null);
  let error = $state('');

  async function cargar() {
    cargando = true;
    error = '';
    try {
      archivos = await contarArchivosCache();
    } catch (e) {
      error = e instanceof Error ? e.message : 'No se pudo consultar el almacenamiento temporal.';
    } finally {
      cargando = false;
    }
  }

  onMount(cargar);

  async function limpiar() {
    if (limpiando || cargando || !confirm('¿Limpiar archivos temporales de la aplicación?')) return;
    limpiando = true;
    archivosEliminados = null;
    error = '';
    try {
      archivosEliminados = await limpiarCache();
      await cargar();
    } catch (e) {
      error = e instanceof Error ? e.message : 'No se pudieron limpiar los archivos temporales.';
    } finally {
      limpiando = false;
    }
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Ajustes</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Gestión de caché</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    <GlassCard variant="granate" padding="xl">
      <div class="w-14 h-14 rounded-full bg-dorado/25 flex items-center justify-center mx-auto mb-4">
        <Icon name="download" size={26} class="text-dorado" />
      </div>
      <h2 class="text-lg font-black text-white text-center mb-1">Caché de archivos</h2>
      <p class="text-xs text-white/60 text-center leading-relaxed">
        Archivos temporales técnicos de la aplicación. La descarga y conservación sin conexión de canciones, imágenes y videos todavía no está implementada en esta versión.
      </p>
      <p class="text-2xl font-black text-dorado text-center mt-4">
        {cargando ? 'Consultando…' : `${archivos} ${archivos === 1 ? 'archivo' : 'archivos'}`}
      </p>
    </GlassCard>

    {#if archivosEliminados !== null}
      <div class="glass rounded-2xl p-3 border border-emerald-500/40 flex items-center gap-2">
        <Icon name="check-circle" size={18} class="text-emerald-400 shrink-0" />
        <p class="text-xs text-emerald-300 flex-1">Se eliminaron {archivosEliminados} archivos temporales.</p>
      </div>
    {/if}
    {#if error}
      <div role="alert" class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={18} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300 flex-1">{error}</p>
        <button type="button" onclick={cargar} class="text-xs font-bold text-dorado">Reintentar</button>
      </div>
    {/if}

    <GlassButton variant="danger" fullWidth icon="trash" loading={limpiando} onTap={limpiar}>
      Limpiar caché
    </GlassButton>

    <p class="text-[10px] text-white/30 text-center leading-relaxed px-4">
      Esta acción solo elimina archivos temporales con el prefijo interno de la aplicación. No borra canciones ni multimedia de Firebase o Cloudinary.
    </p>
  </div>
</div>
