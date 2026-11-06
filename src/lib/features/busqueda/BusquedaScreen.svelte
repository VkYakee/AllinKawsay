<!-- src/lib/features/busqueda/BusquedaScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { canciones } from '../../stores/canciones.svelte';
  import { eventos } from '../../stores/eventos.svelte';
  import { recuerdos } from '../../stores/recuerdos.svelte';
  import { router } from '../../stores/router.svelte';

  let query = $state('');

  onMount(() => {
    canciones.cargar();
    eventos.cargar();
    recuerdos.cargar();
  });

  const q = $derived(query.trim().toLowerCase());

  const cancionesFiltradas = $derived(
    q.length < 2 ? [] : canciones.all.filter((c) =>
      c.titulo.toLowerCase().includes(q) ||
      c.autor.toLowerCase().includes(q) ||
      c.ritmo.toLowerCase().includes(q) ||
      c.region.toLowerCase().includes(q) ||
      c.tags.some((tag) => tag.toLowerCase().includes(q))
    )
  );

  const eventosFiltrados = $derived(
    q.length < 2 ? [] : eventos.all.filter((e) =>
      e.titulo.toLowerCase().includes(q) ||
      e.lugar.toLowerCase().includes(q) ||
      e.descripcion.toLowerCase().includes(q)
    )
  );

  const recuerdosFiltrados = $derived(
    q.length < 2 ? [] : recuerdos.all.filter((r) =>
      r.titulo.toLowerCase().includes(q) ||
      r.descripcion.toLowerCase().includes(q)
    )
  );

  const total = $derived(
    cancionesFiltradas.length + eventosFiltrados.length + recuerdosFiltrados.length
  );

  function abrir(tipo: 'cancion' | 'evento' | 'recuerdo', id: string) {
    router.go(tipo, { id });
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="glass flex-1 rounded-2xl border border-white/10">
        <div class="flex items-center gap-2 px-4 h-12">
          <Icon name="search" size={16} class="text-dorado/70" />
          <input
            bind:value={query}
            autofocus
            type="text"
            placeholder="Buscar en toda la app..."
            class="flex-1 bg-transparent outline-none text-sm text-white placeholder:text-white/30 font-medium"
          />
          {#if query}
            <button type="button" onclick={() => (query = '')} class="text-white/50">
              <Icon name="x" size={14} />
            </button>
          {/if}
        </div>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    {#if canciones.error || eventos.error || recuerdos.error}
      <div class="glass rounded-2xl border border-red-400/20 p-3 space-y-2">
        <p class="text-xs font-bold text-white">Algunos resultados pueden no estar disponibles</p>
        {#if canciones.error}<div class="flex items-center justify-between gap-2"><span class="text-[10px] text-white/50">Canciones: {canciones.error}</span><button type="button" onclick={() => canciones.refrescar()} class="text-[10px] text-dorado font-bold">Reintentar</button></div>{/if}
        {#if eventos.error}<div class="flex items-center justify-between gap-2"><span class="text-[10px] text-white/50">Eventos: {eventos.error}</span><button type="button" onclick={() => eventos.refrescar()} class="text-[10px] text-dorado font-bold">Reintentar</button></div>{/if}
        {#if recuerdos.error}<div class="flex items-center justify-between gap-2"><span class="text-[10px] text-white/50">Recuerdos: {recuerdos.error}</span><button type="button" onclick={() => recuerdos.refrescar()} class="text-[10px] text-dorado font-bold">Reintentar</button></div>{/if}
      </div>
    {/if}
    {#if q.length < 2}
      <div class="flex flex-col items-center text-center py-16">
        <div class="w-20 h-20 rounded-full bg-dorado/15 flex items-center justify-center mb-4">
          <Icon name="search" size={32} class="text-dorado/60" />
        </div>
        <p class="text-base font-bold text-white">Escribe para buscar</p>
        <p class="text-xs text-white/50 mt-1">Canciones, eventos y recuerdos</p>
      </div>
    {:else if total === 0}
      <div class="flex flex-col items-center text-center py-16">
        <div class="w-20 h-20 rounded-full bg-red-500/10 flex items-center justify-center mb-4">
          <Icon name="search" size={32} class="text-red-400/60" />
        </div>
        <p class="text-base font-bold text-white">Sin resultados</p>
        <p class="text-xs text-white/50 mt-1">No se encontró nada para "{query}"</p>
      </div>
    {:else}
      <p class="text-[10px] text-white/40 tracking-[0.2em] font-bold uppercase px-1">
        {total} {total === 1 ? 'resultado' : 'resultados'}
      </p>

      {#if cancionesFiltradas.length > 0}
        <div class="space-y-2">
          <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1">
            Canciones ({cancionesFiltradas.length})
          </h3>
          {#each cancionesFiltradas as c (c.id)}
            <GlassCard padding="md" onTap={() => abrir('cancion', c.id)}>
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
                  <Icon name="music" size={18} class="text-dorado" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-bold text-white truncate">{c.titulo}</p>
                  <p class="text-[11px] text-white/50 truncate">{c.ritmo} · {c.autor}</p>
                </div>
                <Icon name="chevron-right" size={16} class="text-dorado/50" />
              </div>
            </GlassCard>
          {/each}
        </div>
      {/if}

      {#if eventosFiltrados.length > 0}
        <div class="space-y-2">
          <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1">
            Eventos ({eventosFiltrados.length})
          </h3>
          {#each eventosFiltrados as e (e.id)}
            <GlassCard padding="md" onTap={() => abrir('evento', e.id)}>
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
                  <Icon name="calendar" size={18} class="text-dorado" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-bold text-white truncate">{e.titulo}</p>
                  <p class="text-[11px] text-white/50 truncate">{e.lugar}</p>
                </div>
                <Icon name="chevron-right" size={16} class="text-dorado/50" />
              </div>
            </GlassCard>
          {/each}
        </div>
      {/if}

      {#if recuerdosFiltrados.length > 0}
        <div class="space-y-2">
          <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1">
            Recuerdos ({recuerdosFiltrados.length})
          </h3>
          {#each recuerdosFiltrados as r (r.id)}
            <GlassCard padding="md" onTap={() => abrir('recuerdo', r.id)}>
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
                  <Icon name="image" size={18} class="text-dorado" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-bold text-white truncate">{r.titulo}</p>
                  <p class="text-[11px] text-white/50 truncate">{r.fotos.length} fotos</p>
                </div>
                <Icon name="chevron-right" size={16} class="text-dorado/50" />
              </div>
            </GlassCard>
          {/each}
        </div>
      {/if}
    {/if}
  </div>
</div>