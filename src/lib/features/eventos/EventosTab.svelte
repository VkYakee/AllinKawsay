<!-- src/lib/features/eventos/EventosTab.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import EventoCard from './EventoCard.svelte';
  import { eventos } from '../../stores/eventos.svelte';
  import { router } from '../../stores/router.svelte';

  type Filtro = 'proximos' | 'pasados';
  let filtro = $state<Filtro>('proximos');

  onMount(() => {
    eventos.cargar();
  });

  const listaActual = $derived(filtro === 'proximos' ? eventos.proximos : eventos.pasados);

  function abrir(id: string) {
    router.go('evento', { id });
  }
</script>

<div class="px-5 py-6 pb-40 space-y-4">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
        Calendario
      </p>
      <h2 class="text-3xl font-black text-white tracking-tight mt-1">
        Eventos
      </h2>
    </div>
    <GlassIconButton icon="calendar" variant="gold" />
  </div>

  <!-- Toggle próximos / pasados -->
  <div class="glass glass-strong rounded-full p-1 flex">
    <button
      type="button"
      onclick={() => (filtro = 'proximos')}
      class="flex-1 h-11 rounded-full text-[12px] font-bold tracking-wider uppercase transition-all {filtro === 'proximos'
        ? 'bg-gradient-to-br from-granate to-granate-dark text-dorado shadow-md shadow-granate/40'
        : 'text-white/50'}"
    >
      Próximos
    </button>
    <button
      type="button"
      onclick={() => (filtro = 'pasados')}
      class="flex-1 h-11 rounded-full text-[12px] font-bold tracking-wider uppercase transition-all {filtro === 'pasados'
        ? 'bg-gradient-to-br from-granate to-granate-dark text-dorado shadow-md shadow-granate/40'
        : 'text-white/50'}"
    >
      Pasados
    </button>
  </div>

  <div class="flex items-center justify-between px-1">
    <p class="text-[10px] text-white/40 tracking-[0.2em] font-semibold uppercase">
      {listaActual.length} {listaActual.length === 1 ? 'evento' : 'eventos'}
    </p>
  </div>

  {#if eventos.loading}
    <div class="space-y-2">
      {#each Array(3) as _}
        <div class="glass rounded-2xl h-[88px] animate-pulse"></div>
      {/each}
    </div>
  {:else if listaActual.length === 0}
    <div class="glass rounded-2xl p-8 flex flex-col items-center text-center">
      <div class="w-16 h-16 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
        <Icon name="calendar" size={26} class="text-dorado/60" />
      </div>
      <p class="text-base font-bold text-white">
        {filtro === 'proximos' ? 'Sin eventos próximos' : 'Sin eventos pasados'}
      </p>
      <p class="text-xs text-white/50 mt-1">
        {filtro === 'proximos'
          ? 'Los nuevos eventos aparecerán aquí'
          : 'Aún no hay historial'}
      </p>
    </div>
  {:else}
    <div class="space-y-2">
      {#each listaActual as evento (evento.id)}
        <EventoCard {evento} onTap={() => abrir(evento.id)} />
      {/each}
    </div>
  {/if}
</div>