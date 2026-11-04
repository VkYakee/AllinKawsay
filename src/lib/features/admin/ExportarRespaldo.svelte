<!-- src/lib/features/admin/ExportarRespaldo.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { respaldoService } from '../../services/respaldo';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let conteo = $state<{
    canciones: number;
    eventos: number;
    recuerdos: number;
    usuarios: number;
    categorias: number;
  } | null>(null);

  let generando = $state(false);
  let jsonSize = $state(0);
  let jsonGenerado = $state(false);
  let error = $state('');

  onMount(async () => {
    if (!session.isAdmin) { router.back(); return; }
    try {
      conteo = await respaldoService.contar();
    } catch (e) {
      error = e instanceof Error ? e.message : 'Error al contar';
    }
  });

  async function generar() {
    generando = true;
    error = '';
    try {
      const json = await respaldoService.generar();
      jsonSize = new Blob([json]).size;
      respaldoService.descargar(json);
      jsonGenerado = true;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Error al generar respaldo';
    } finally {
      generando = false;
    }
  }

  function formatoBytes(b: number): string {
    if (b < 1024) return `${b} B`;
    if (b < 1048576) return `${(b / 1024).toFixed(1)} KB`;
    return `${(b / 1048576).toFixed(2)} MB`;
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Admin</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Respaldo</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    <GlassCard variant="granate" padding="xl">
      <div class="w-14 h-14 rounded-full bg-dorado/25 flex items-center justify-center mx-auto mb-4">
        <Icon name="download" size={26} class="text-dorado" />
      </div>
      <h2 class="text-lg font-black text-white text-center mb-1">Exportar respaldo</h2>
      <p class="text-xs text-white/60 text-center leading-relaxed">
        Descarga un archivo JSON con todo el contenido del grupo.
      </p>
    </GlassCard>

    {#if conteo}
      <GlassCard padding="lg">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase mb-3">Contenido actual</p>
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <span class="text-sm text-white/70 flex items-center gap-2">
              <Icon name="music" size={14} class="text-dorado" /> Canciones
            </span>
            <span class="text-sm font-bold text-white tabular-nums">{conteo.canciones}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-white/70 flex items-center gap-2">
              <Icon name="calendar" size={14} class="text-dorado" /> Eventos
            </span>
            <span class="text-sm font-bold text-white tabular-nums">{conteo.eventos}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-white/70 flex items-center gap-2">
              <Icon name="image" size={14} class="text-dorado" /> Recuerdos
            </span>
            <span class="text-sm font-bold text-white tabular-nums">{conteo.recuerdos}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-white/70 flex items-center gap-2">
              <Icon name="user" size={14} class="text-dorado" /> Usuarios
            </span>
            <span class="text-sm font-bold text-white tabular-nums">{conteo.usuarios}</span>
          </div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-white/70 flex items-center gap-2">
              <Icon name="grid" size={14} class="text-dorado" /> Categorías
            </span>
            <span class="text-sm font-bold text-white tabular-nums">{conteo.categorias}</span>
          </div>
        </div>
      </GlassCard>
    {/if}

    {#if jsonGenerado}
      <div class="glass rounded-2xl p-3 border border-emerald-500/40 flex items-center gap-2">
        <Icon name="check-circle" size={18} class="text-emerald-400 shrink-0" />
        <p class="text-xs text-emerald-300 flex-1">
          Respaldo descargado ({formatoBytes(jsonSize)})
        </p>
      </div>
    {/if}

    {#if error}
      <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{error}</p>
      </div>
    {/if}

    <GlassButton variant="primary" fullWidth icon="download" loading={generando} onTap={generar}>
      {jsonGenerado ? 'Descargar de nuevo' : 'Generar y descargar'}
    </GlassButton>

    <p class="text-[10px] text-white/30 text-center leading-relaxed px-4">
      El respaldo incluye todo el contenido de Firestore pero no las imágenes/audios de Cloudinary (esos viven en tu cuenta).
    </p>
  </div>
</div>