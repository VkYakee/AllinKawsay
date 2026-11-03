<!-- src/lib/features/cancionero/CancioneroTab.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassChip from '../../components/ui/GlassChip.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import CancionCard from './CancionCard.svelte';
  import { canciones } from '../../stores/canciones.svelte';
  import { router } from '../../stores/router.svelte';

  let query = $state('');
  let ritmoActivo = $state('');

  onMount(() => {
    canciones.cargar();
  });

  const filtradas = $derived.by(() => {
    const q = query.trim().toLowerCase();
    return canciones.all.filter((c) => {
      const okQ =
        !q ||
        c.titulo.toLowerCase().includes(q) ||
        c.autor.toLowerCase().includes(q) ||
        c.ritmo.toLowerCase().includes(q) ||
        c.region.toLowerCase().includes(q);
      const okR = !ritmoActivo || c.ritmo === ritmoActivo;
      return okQ && okR;
    });
  });

  function abrir(id: string) {
    router.go('cancion', { id });
  }
</script>

<div class="px-5 py-6 pb-40 space-y-4">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
        Biblioteca
      </p>
      <h2 class="text-3xl font-black text-white tracking-tight mt-1">
        Cancionero
      </h2>
    </div>
    <GlassIconButton icon="filter" variant="gold" />
  </div>

  <!-- Buscador -->
  <div class="glass rounded-2xl border border-white/10 focus-within:border-dorado/50 transition-colors">
    <div class="flex items-center gap-2 px-4 h-14">
      <Icon name="search" size={18} class="text-dorado/60" />
      <input
        bind:value={query}
        type="text"
        placeholder="Buscar canción, autor o ritmo..."
        class="flex-1 bg-transparent outline-none text-[15px] text-white placeholder:text-white/30 font-medium"
      />
      {#if query}
        <button
          type="button"
          onclick={() => query = ''}
          class="text-white/40 active:scale-90 transition-transform"
        >
          <Icon name="x" size={16} />
        </button>
      {/if}
    </div>
  </div>

  <!-- Filtros por ritmo -->
  {#if canciones.ritmos.length > 0}
    <div class="flex gap-2 overflow-x-auto pb-1 -mx-5 px-5 scrollbar-hide">
      <GlassChip
        selected={ritmoActivo === ''}
        variant="granate"
        onTap={() => (ritmoActivo = '')}
      >
        Todos
      </GlassChip>
      {#each canciones.ritmos as ritmo}
        <GlassChip
          selected={ritmoActivo === ritmo}
          variant="granate"
          onTap={() => (ritmoActivo = ritmoActivo === ritmo ? '' : ritmo)}
        >
          {ritmo}
        </GlassChip>
      {/each}
    </div>
  {/if}

  <!-- Contador -->
  <div class="flex items-center justify-between px-1">
    <p class="text-[10px] text-white/40 tracking-[0.2em] font-semibold uppercase">
      {filtradas.length}
      {filtradas.length === 1 ? 'canción' : 'canciones'}
    </p>
    {#if ritmoActivo}
      <button
        type="button"
        onclick={() => (ritmoActivo = '')}
        class="text-[10px] text-dorado tracking-wider font-bold uppercase"
      >
        Limpiar filtro
      </button>
    {/if}
  </div>

  <!-- Lista -->
  {#if canciones.loading}
    <div class="space-y-2">
      {#each Array(4) as _}
        <div class="glass rounded-2xl h-[84px] animate-pulse"></div>
      {/each}
    </div>
  {:else if filtradas.length === 0}
    <GlassCard padding="xl">
      <div class="flex flex-col items-center text-center py-6">
        <div class="w-16 h-16 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
          <Icon name="search" size={26} class="text-dorado/60" />
        </div>
        <p class="text-base font-bold text-white">Sin resultados</p>
        <p class="text-xs text-white/50 mt-1">Prueba con otro término</p>
      </div>
    </GlassCard>
  {:else}
    <div class="space-y-2">
      {#each filtradas as cancion (cancion.id)}
        <CancionCard {cancion} onTap={() => abrir(cancion.id)} />
      {/each}
    </div>
  {/if}
</div>