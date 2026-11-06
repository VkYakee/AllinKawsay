<!-- src/lib/features/historia/EditarHistoriaScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { historiaService } from '../../services/historia';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let contenido = $state('');
  let loading = $state(true);
  let guardando = $state(false);
  let error = $state('');

  async function cargar() {
    loading = true;
    error = '';
    try {
      const h = await historiaService.obtener();
      contenido = h.contenido;
    } catch (e) {
      error = e instanceof Error ? e.message : 'No se pudo cargar la historia. Comprueba tu conexión.';
    } finally {
      loading = false;
    }
  }

  onMount(() => {
    void cargar();
  });

  async function guardar() {
    if (guardando || loading || error) return;
    guardando = true;
    error = '';
    try {
      await historiaService.guardar(contenido, session.displayName);
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
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Editar</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Historia del grupo</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    {#if loading}
      <div class="glass rounded-3xl h-64 animate-pulse"></div>
    {:else if error && !contenido}
      <div class="glass rounded-2xl border border-red-500/30 p-5 text-center">
        <Icon name="alert-circle" size={28} class="text-red-400 mx-auto mb-3" />
        <p class="text-sm font-bold text-white">No se pudo cargar el contenido</p>
        <p class="text-xs text-white/55 mt-2">{error}</p>
        <button class="mt-5 rounded-xl bg-dorado/15 border border-dorado/30 px-5 py-3 text-sm font-bold text-dorado" onclick={cargar}>
          Reintentar
        </button>
      </div>
    {:else}
      <div class="glass rounded-2xl border border-white/10 focus-within:border-dorado/40 transition-colors">
        <div class="flex items-center justify-between px-4 pt-3 text-[10px] text-white/40">
          <span>HISTORIA DEL CONJUNTO</span>
          <span>{contenido.length.toLocaleString('es-PE')} caracteres</span>
        </div>
        <textarea
          bind:value={contenido}
          rows="20"
          aria-label="Contenido de la historia del conjunto"
          placeholder="Escribe aquí la historia del grupo: orígenes, logros, anécdotas..."
          class="w-full bg-transparent outline-none text-[15px] leading-relaxed text-white placeholder:text-white/30 font-medium p-4 resize-y min-h-[280px]"
        ></textarea>
      </div>

      {#if error}
        <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
          <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
          <p class="text-xs text-red-300">{error}</p>
        </div>
      {/if}

      <GlassButton variant="primary" fullWidth icon="check" loading={guardando} onTap={guardar}>
        Guardar historia
      </GlassButton>
    {/if}
  </div>
</div>