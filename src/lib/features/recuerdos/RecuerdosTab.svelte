<!-- src/lib/features/recuerdos/RecuerdosTab.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import RecuerdoCard from './RecuerdoCard.svelte';
  import { recuerdos } from '../../stores/recuerdos.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  onMount(() => {
    recuerdos.cargar();
  });

  function abrir(id: string) {
    router.go('recuerdo', { id });
  }
</script>

<div class="px-5 py-6 pb-40 space-y-4">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">Galería</p>
      <h2 class="text-3xl font-black text-white tracking-tight mt-1">Recuerdos</h2>
    </div>
    {#if session.isAdmin}
      <button
        type="button"
        onclick={() => router.go('agregar-recuerdo')}
        class="w-11 h-11 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40 active:scale-90 transition-transform"
      >
        <Icon name="plus" size={22} class="text-granate-dark" />
      </button>
    {/if}
  </div>

  <div class="flex items-center justify-between px-1">
    <p class="text-[10px] text-white/40 tracking-[0.2em] font-semibold uppercase">
      {recuerdos.all.length}
      {recuerdos.all.length === 1 ? 'momento' : 'momentos'}
    </p>
  </div>

  {#if recuerdos.loading && !recuerdos.loaded}
    <div class="grid grid-cols-2 gap-3">
      {#each Array(4) as _}
        <div class="glass rounded-3xl h-[260px] animate-pulse"></div>
      {/each}
    </div>
  {:else if recuerdos.error}
    <div class="glass rounded-2xl p-6 border border-red-400/20 text-center">
      <Icon name="alert-circle" size={24} class="text-red-300 mx-auto mb-3" />
      <p class="text-sm font-bold text-white">No pudimos cargar los recuerdos</p>
      <p class="text-xs text-white/50 mt-1">{recuerdos.error}</p>
      <button type="button" onclick={() => recuerdos.refrescar()} class="mt-4 rounded-full bg-dorado/15 px-4 py-2 text-xs font-bold text-dorado">Intentar de nuevo</button>
    </div>
  {:else if recuerdos.all.length === 0}
    <div class="glass rounded-2xl p-8 flex flex-col items-center text-center">
      <div class="w-16 h-16 rounded-full bg-dorado/15 flex items-center justify-center mb-3">
        <Icon name="image" size={26} class="text-dorado/60" />
      </div>
      <p class="text-base font-bold text-white">Sin recuerdos aún</p>
      <p class="text-xs text-white/50 mt-1">
        {session.isAdmin ? 'Toca + para subir fotos' : 'Los recuerdos aparecerán aquí'}
      </p>
    </div>
  {:else}
    <div style="column-count: 2; column-gap: 0.75rem;">
      {#each recuerdos.all as recuerdo (recuerdo.id)}
        <div class="mb-3" style="break-inside: avoid;">
          <RecuerdoCard {recuerdo} onTap={() => abrir(recuerdo.id)} />
        </div>
      {/each}
    </div>
  {/if}
</div>