<!-- src/lib/features/home/tabs/InicioTab.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../../components/ui/GlassIconButton.svelte';
  import Icon from '../../../components/ui/Icon.svelte';
  import { session } from '../../../stores/session.svelte';
  import { canciones } from '../../../stores/canciones.svelte';
  import { eventos } from '../../../stores/eventos.svelte';
  import { router } from '../../../stores/router.svelte';

  interface Props {
    onOpenCancionero: () => void;
    onOpenEventos: () => void;
  }

  let { onOpenCancionero, onOpenEventos }: Props = $props();

  onMount(() => {
    if (!canciones.loaded) canciones.cargar();
    if (!eventos.loaded) eventos.cargar();
  });

  const cancionesInicio = $derived(canciones.all.slice(0, 3));
  const proximoEvento = $derived(eventos.proximos[0] ?? null);

  function fechaEvento(iso: string): string {
    const date = new Date(iso);
    return new Intl.DateTimeFormat('es-PE', {
      weekday: 'long',
      day: 'numeric',
      month: 'long'
    }).format(date);
  }

  function horaEvento(iso: string): string {
    return new Intl.DateTimeFormat('es-PE', {
      hour: '2-digit',
      minute: '2-digit'
    }).format(new Date(iso));
  }


  function irEnsayo() {
    if (!canciones.loaded) {
      canciones.cargar();
      onOpenCancionero();
      return;
    }
    const primera = canciones.all.find((song) => song.estrofas.length > 0) ?? canciones.all[0];
    if (primera) router.go('ensayo', { id: primera.id });
    else onOpenCancionero();
  }
</script>

<div class="px-5 py-6 space-y-6 pb-40">
  <header class="flex items-center justify-between gap-3">
    <div class="min-w-0">
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">Allin Kawsay · Música y comunidad</p>
      <h1 class="text-3xl font-black text-white tracking-tight mt-1 truncate">
        Hola, {session.displayName} 👋
      </h1>
      <p class="text-xs text-white/45 mt-1">Sigamos compartiendo nuestra música.</p>
    </div>
    <div class="flex items-center gap-2 shrink-0">
      <GlassIconButton icon="search" onTap={() => router.go('buscar')} />
      <GlassIconButton icon="calendar" variant="gold" onTap={onOpenEventos} />
    </div>
  </header>

  <section class="space-y-3">
    <div class="flex items-center justify-between px-1">
      <p class="text-[10px] text-dorado tracking-[0.22em] font-bold uppercase">Agenda del conjunto</p>
      <button type="button" onclick={onOpenEventos} class="text-[10px] text-white/45 font-semibold uppercase tracking-wider">Ver eventos</button>
    </div>
    {#if eventos.loading && !eventos.loaded}
      <div class="glass rounded-3xl h-36 animate-pulse"></div>
    {:else if proximoEvento}
      <button type="button" onclick={() => router.go('evento', { id: proximoEvento.id })} class="w-full text-left glass glass-granate rounded-3xl p-5 border border-dorado/20 active:scale-[0.99] transition-transform">
        <div class="flex items-center gap-2 mb-3">
          <span class="w-8 h-8 rounded-full bg-dorado/15 flex items-center justify-center"><Icon name="calendar" size={16} class="text-dorado" /></span>
          <span class="text-[10px] text-dorado tracking-[0.2em] font-bold uppercase">Próxima actividad</span>
          <span class="ml-auto text-[10px] text-white/45">Ver detalle ↗</span>
        </div>
        <h2 class="text-2xl font-black text-white leading-tight">{proximoEvento.titulo}</h2>
        <p class="text-sm text-dorado/90 mt-2 capitalize">{fechaEvento(proximoEvento.fecha)} · {horaEvento(proximoEvento.fecha)}</p>
        {#if proximoEvento.lugar}
          <p class="text-xs text-white/55 mt-1 flex items-center gap-1"><Icon name="map-pin" size={12} />{proximoEvento.lugar}</p>
        {/if}
      </button>
    {:else}
      <div class="glass rounded-3xl p-5 border border-white/10 flex items-center gap-4">
        <div class="w-11 h-11 rounded-2xl bg-dorado/10 flex items-center justify-center shrink-0"><Icon name="calendar" size={20} class="text-dorado/70" /></div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-bold text-white">Todavía no hay actividades próximas</p>
          <p class="text-xs text-white/45 mt-1">Cuando se publique un evento, aparecerá aquí.</p>
        </div>
        <button type="button" onclick={onOpenEventos} class="text-dorado text-xs font-bold">Ver</button>
      </div>
    {/if}
  </section>

  <section class="grid grid-cols-2 gap-3">
    <GlassCard variant="gold" padding="lg" onTap={() => router.go('zampona')}>
      <div class="w-11 h-11 rounded-2xl bg-dorado/20 flex items-center justify-center mb-4"><Icon name="music" size={21} class="text-dorado" /></div>
      <p class="text-base font-bold text-dorado">Mini zampoña</p>
      <p class="text-[11px] text-white/50 mt-1">Explora y practica notas</p>
    </GlassCard>
    <GlassCard variant="granate" padding="lg" onTap={irEnsayo}>
      <div class="w-11 h-11 rounded-2xl bg-dorado/20 flex items-center justify-center mb-4"><Icon name="play" size={21} class="text-dorado" /></div>
      <p class="text-base font-bold text-white">Modo ensayo</p>
      <p class="text-[11px] text-white/55 mt-1">Practica con el cancionero</p>
    </GlassCard>
  </section>

  <section class="space-y-3">
    <div class="flex items-center justify-between px-1">
      <div>
        <p class="text-[10px] text-dorado tracking-[0.22em] font-bold uppercase">Biblioteca musical</p>
        <h2 class="text-xl font-black text-white mt-1">Explora el cancionero</h2>
      </div>
      <button type="button" onclick={onOpenCancionero} class="text-xs text-dorado font-bold">Ver todo →</button>
    </div>
    {#if canciones.loading && !canciones.loaded}
      <div class="space-y-2">{#each Array(3) as _}<div class="glass rounded-2xl h-[76px] animate-pulse"></div>{/each}</div>
    {:else if cancionesInicio.length > 0}
      <div class="space-y-2">
        {#each cancionesInicio as cancion (cancion.id)}
          <GlassCard padding="md" onTap={() => router.go('cancion', { id: cancion.id })}>
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
                <Icon name="music" size={20} class="text-dorado" />
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-white truncate">{cancion.titulo}</p>
                <p class="text-[11px] text-white/45 truncate mt-1">{cancion.autor || 'Autor no registrado'} · {cancion.ritmo || 'Ritmo por definir'}</p>
              </div>
              <Icon name="chevron-right" size={16} class="text-dorado/50" />
            </div>
          </GlassCard>
        {/each}
      </div>
    {:else}
      <div class="glass rounded-3xl p-6 text-center">
        <Icon name="music" size={26} class="text-dorado/60 mx-auto mb-2" />
        <p class="text-sm font-bold text-white">El cancionero está esperando sus primeras canciones</p>
        <p class="text-xs text-white/45 mt-1">Las partituras y melodías aparecerán aquí.</p>
        <button type="button" onclick={onOpenCancionero} class="mt-3 text-xs text-dorado font-bold">Abrir cancionero</button>
      </div>
    {/if}
  </section>

  <section class="glass rounded-3xl p-5 border border-white/10">
    <div class="flex items-center gap-3">
      <div class="w-11 h-11 rounded-2xl bg-dorado/10 flex items-center justify-center"><Icon name="user" size={20} class="text-dorado" /></div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-bold text-white">Nuestra historia sigue creciendo</p>
        <p class="text-xs text-white/45 mt-1">Revisa recuerdos, eventos y actividades del conjunto.</p>
      </div>
    </div>
    <div class="grid grid-cols-2 gap-2 mt-4">
      <button type="button" onclick={() => router.go('historia')} class="rounded-xl bg-white/5 py-3 text-xs font-bold text-white/75">Historia del grupo</button>
      <button type="button" onclick={() => router.go('compartir-app')} class="rounded-xl bg-white/5 py-3 text-xs font-bold text-white/75">Compartir Allin Kawsay</button>
    </div>
  </section>
</div>