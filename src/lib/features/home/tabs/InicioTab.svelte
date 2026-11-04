<!-- src/lib/features/home/tabs/InicioTab.svelte -->
<script lang="ts">
  import GlassCard from '../../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../../components/ui/GlassIconButton.svelte';
  import Icon from '../../../components/ui/Icon.svelte';
  import { session } from '../../../stores/session.svelte';
  import { player } from '../../../stores/player.svelte';
  import { canciones } from '../../../stores/canciones.svelte';
  import { router } from '../../../stores/router.svelte';

  const proximoEvento = {
    titulo: 'Fiesta Patronal',
    fecha: '15 de Octubre',
    hora: '19:00',
    lugar: 'Plaza de Armas, Juliaca'
  };

  let ultimas = $state([
    { id: 'c1', titulo: 'Adiós Conima', autor: 'Anónimo', ritmo: 'Huayño' },
    { id: 'c2', titulo: 'Aguila Negra', autor: 'Anónimo', ritmo: 'Huayño' },
    { id: 'c3', titulo: 'Fiesta de mi Pueblo', autor: 'Anónimo', ritmo: 'Carnaval' }
  ]);

  async function cargar() {
    if (canciones.all.length === 0) await canciones.cargar();
    if (canciones.all.length > 0) {
      ultimas = canciones.all.slice(0, 3).map((c) => ({
        id: c.id,
        titulo: c.titulo,
        autor: c.autor,
        ritmo: c.ritmo
      }));
    }
  }
  cargar();

  async function tocarCancion(c: (typeof ultimas)[number]) {
    const full = canciones.buscar(c.id);
    player.play({
      id: c.id,
      titulo: c.titulo,
      autor: c.autor,
      imagenUrl: full?.imagen_url ?? '',
      audioUrl: full?.audio_url ?? ''
    });
  }

  async function irEnsayo() {
    if (canciones.all.length === 0) {
      await canciones.cargar();
    }
    const primera = canciones.all[0];
    if (primera) router.go('ensayo', { id: primera.id });
  }
</script>

<div class="px-5 py-6 space-y-5 pb-40">
  <div class="flex items-center justify-between">
    <div class="min-w-0">
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">Bienvenido</p>
      <h2 class="text-3xl font-black text-white tracking-tight mt-1 truncate">
        Hola, {session.displayName} 👋
      </h2>
    </div>
    <div class="flex items-center gap-2 shrink-0">
      <GlassIconButton icon="search" onTap={() => router.go('buscar')} />
      <GlassIconButton icon="bell" variant="gold" />
    </div>
  </div>

  <GlassCard variant="granate" padding="xl" onTap={() => {}}>
    <div class="flex items-center gap-2 mb-3">
      <div class="w-7 h-7 rounded-full bg-dorado/25 flex items-center justify-center">
        <Icon name="calendar" size={14} class="text-dorado" />
      </div>
      <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">Próximo evento</p>
    </div>
    <h3 class="text-2xl font-black text-white tracking-tight leading-tight">{proximoEvento.titulo}</h3>
    <p class="text-sm text-white/70 mt-2 font-medium">{proximoEvento.fecha} · {proximoEvento.hora}</p>
    <div class="flex items-center gap-1 mt-1.5">
      <Icon name="map-pin" size={12} class="text-dorado/70" />
      <p class="text-xs text-white/50">{proximoEvento.lugar}</p>
    </div>
  </GlassCard>

  <div class="grid grid-cols-2 gap-3">
    <GlassCard variant="gold" padding="lg" onTap={() => router.go('zampona')}>
      <div class="w-10 h-10 rounded-full bg-dorado/25 flex items-center justify-center mb-3">
        <Icon name="piano" size={20} class="text-dorado" />
      </div>
      <p class="text-base font-bold text-dorado">Zampoña</p>
      <p class="text-[11px] text-white/50 mt-0.5">Toca en vivo</p>
    </GlassCard>
    <GlassCard variant="granate" padding="lg" onTap={irEnsayo}>
      <div class="w-10 h-10 rounded-full bg-dorado/25 flex items-center justify-center mb-3">
        <Icon name="play" size={20} class="text-dorado" />
      </div>
      <p class="text-base font-bold text-dorado">Ensayo</p>
      <p class="text-[11px] text-white/50 mt-0.5">Aprende paso a paso</p>
    </GlassCard>
  </div>

  <div class="grid grid-cols-2 gap-3">
    <GlassCard padding="lg" onTap={() => router.go('historia')}>
      <div class="w-10 h-10 rounded-full bg-dorado/15 flex items-center justify-center mb-3">
        <Icon name="star" size={20} class="text-dorado" fill />
      </div>
      <p class="text-base font-bold text-white">Historia</p>
      <p class="text-[11px] text-white/50 mt-0.5">Nuestra trayectoria</p>
    </GlassCard>
    <GlassCard padding="lg" onTap={() => router.go('compartir-app')}>
      <div class="w-10 h-10 rounded-full bg-dorado/15 flex items-center justify-center mb-3">
        <Icon name="share" size={20} class="text-dorado" />
      </div>
      <p class="text-base font-bold text-white">Compartir</p>
      <p class="text-[11px] text-white/50 mt-0.5">Invita al grupo</p>
    </GlassCard>
  </div>

  <div class="space-y-3 pt-1">
    <div class="flex items-center justify-between px-1">
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase">Últimas canciones</h3>
      <button type="button" onclick={() => router.go('home')} class="text-[10px] text-white/40 tracking-wider font-semibold uppercase active:scale-95 transition-transform">
        Ver todo →
      </button>
    </div>
    {#each ultimas as cancion (cancion.id)}
      <GlassCard padding="md" onTap={() => tocarCancion(cancion)}>
        <div class="flex items-center gap-3">
          <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shadow-md shadow-granate/30">
            <Icon name="music" size={20} class="text-dorado" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-bold text-white truncate">{cancion.titulo}</p>
            <p class="text-[11px] text-white/50 truncate mt-0.5">{cancion.ritmo}</p>
          </div>
          <Icon name="chevron-right" size={16} class="text-dorado/50 shrink-0" />
        </div>
      </GlassCard>
    {/each}
  </div>
</div>