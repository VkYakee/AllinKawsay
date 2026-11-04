<!-- src/lib/features/eventos/EventoDetalle.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import L from 'leaflet';
  import 'leaflet/dist/leaflet.css';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import {
    eventosService,
    fechaLarga,
    hora,
    esFuturo,
    type Evento
  } from '../../services/eventos';
  import { obtenerClima, type Clima } from '../../services/clima';
  import { notasService } from '../../services/notas';
  import { actividadService } from '../../services/actividad';
  import { eventos } from '../../stores/eventos.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();

  let evento = $state<Evento | null>(null);
  let loading = $state(true);
  let clima = $state<Clima | null>(null);

  let mapEl: HTMLDivElement | undefined = $state(undefined);
  let map: L.Map | null = null;

  let notaEditando = $state(false);
  let notaTexto = $state('');

  const notaGuardada = $derived(
    (session.user as any)?.notasPorEvento?.[id] ?? ''
  );

  onMount(async () => {
    evento = eventos.buscar(id) ?? (await eventosService.obtener(id));
    loading = false;
    if (evento && evento.lat !== null && evento.lng !== null) {
      setTimeout(() => initMap(evento!.lat!, evento!.lng!), 60);
      obtenerClima(evento.lat, evento.lng).then((c) => (clima = c));
    }
  });

  onDestroy(() => {
    map?.remove();
  });

  function initMap(lat: number, lng: number) {
    if (!mapEl || map) return;
    map = L.map(mapEl, {
      center: [lat, lng],
      zoom: 15,
      zoomControl: false,
      attributionControl: false,
      dragging: false,
      touchZoom: false,
      scrollWheelZoom: false,
      doubleClickZoom: false
    });
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
    const icon = L.divIcon({
      className: '',
      html: '<div style="width:36px;height:36px;background:#8B1A2B;border:3px solid #F5D061;border-radius:50%;box-shadow:0 4px 20px rgba(0,0,0,0.6);"></div>',
      iconSize: [36, 36],
      iconAnchor: [18, 18]
    });
    L.marker([lat, lng], { icon }).addTo(map);
  }

  const futuro = $derived(evento ? esFuturo(evento.fecha) : false);
  const tieneMapa = $derived(evento?.lat != null && evento?.lng != null);

  function abrirMaps() {
    if (!evento || evento.lat == null || evento.lng == null) return;
    const url = `https://www.google.com/maps/dir/?api=1&destination=${evento.lat},${evento.lng}`;
    window.open(url, '_blank');
  }

  async function guardarNota() {
    if (!session.user) return;
    try {
      await notasService.guardar(session.user.uid, 'evento', id, notaTexto);
      notaEditando = false;
    } catch {}
  }

  async function eliminar() {
    if (!evento) return;
    if (!confirm(`¿Eliminar "${evento.titulo}"? Esta acción no se puede deshacer.`)) return;
    try {
      await eventosService.eliminar(evento.id);
      await actividadService.registrar(
        'eliminar_evento',
        `Eliminó el evento "${evento.titulo}"`,
        session.user?.uid ?? '',
        session.displayName
      );
      eventos.refrescar();
      router.back();
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Error al eliminar');
    }
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Evento</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">{evento?.titulo ?? '...'}</p>
      </div>
      {#if session.isAdmin && evento}
        <GlassIconButton icon="edit" size="sm" onTap={() => router.go('editar-evento', { id: evento!.id })} />
        <GlassIconButton icon="trash" size="sm" onTap={eliminar} />
      {/if}
    </div>
  </header>

  {#if loading}
    <div class="px-5 py-6 space-y-3">
      <div class="glass rounded-3xl h-40 animate-pulse"></div>
      <div class="glass rounded-3xl h-56 animate-pulse"></div>
    </div>
  {:else if !evento}
    <div class="px-5 py-20 flex flex-col items-center text-center">
      <Icon name="alert-circle" size={48} class="text-red-400/60" />
      <p class="text-white/60 mt-4">Evento no encontrado</p>
    </div>
  {:else}
    <div class="px-5 py-6 space-y-4 pb-40">
      <GlassCard variant={futuro ? 'granate' : 'default'} padding="xl">
        <div class="flex items-center gap-2 mb-3">
          <div class="w-7 h-7 rounded-full bg-dorado/25 flex items-center justify-center">
            <Icon name={futuro ? 'calendar' : 'clock'} size={14} class="text-dorado" />
          </div>
          <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">
            {futuro ? 'Próximo evento' : 'Evento pasado'}
          </p>
        </div>
        <h1 class="text-2xl font-black text-white tracking-tight leading-tight">{evento.titulo}</h1>
        <div class="mt-4 space-y-2">
          <div class="flex items-center gap-2">
            <Icon name="calendar" size={14} class="text-dorado/80 shrink-0" />
            <span class="text-sm text-white/80 font-medium">{fechaLarga(evento.fecha)}</span>
          </div>
          <div class="flex items-center gap-2">
            <Icon name="clock" size={14} class="text-dorado/80 shrink-0" />
            <span class="text-sm text-white/80 font-medium">{hora(evento.fecha)}</span>
          </div>
          <div class="flex items-center gap-2">
            <Icon name="map-pin" size={14} class="text-dorado/80 shrink-0" />
            <span class="text-sm text-white/80 font-medium">{evento.lugar}</span>
          </div>
        </div>

        {#if clima}
          <div class="mt-4 glass rounded-2xl px-3 py-2 flex items-center gap-2 border border-white/10">
            <span class="text-2xl leading-none">{clima.icono}</span>
            <div class="flex-1">
              <p class="text-[11px] text-white/50 uppercase tracking-wider font-bold">Clima actual</p>
              <p class="text-sm text-white font-bold">{clima.temp}°C · {clima.descripcion}</p>
            </div>
          </div>
        {/if}
      </GlassCard>

      {#if evento.descripcion}
        <GlassCard padding="xl">
          <h3 class="text-[10px] font-bold text-dorado/70 tracking-[0.25em] uppercase mb-3">Descripción</h3>
          <p class="text-sm text-white/80 leading-relaxed whitespace-pre-line">{evento.descripcion}</p>
        </GlassCard>
      {/if}

      {#if tieneMapa}
        <GlassCard padding="lg">
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-[10px] font-bold text-dorado/70 tracking-[0.25em] uppercase">Ubicación</h3>
            <span class="text-[10px] text-white/40 font-mono tabular-nums">
              {evento.lat?.toFixed(4)}, {evento.lng?.toFixed(4)}
            </span>
          </div>
          <div bind:this={mapEl} class="relative w-full h-[200px] rounded-2xl overflow-hidden border border-white/5 bg-[#171412]"></div>
          <div class="mt-3">
            <GlassButton variant="primary" fullWidth icon="external-link" onTap={abrirMaps}>Cómo llegar</GlassButton>
          </div>
        </GlassCard>
      {/if}

      {#if session.user}
        <div class="space-y-2">
          <div class="flex items-center gap-2 px-1">
            <div class="w-7 h-7 rounded-full bg-dorado/15 flex items-center justify-center">
              <Icon name="edit" size={14} class="text-dorado" />
            </div>
            <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase flex-1">Mi nota personal</h3>
            {#if !notaEditando}
              <button type="button" onclick={() => { notaTexto = notaGuardada; notaEditando = true; }} class="text-[10px] text-dorado/80 font-bold uppercase tracking-wider">
                Editar
              </button>
            {/if}
          </div>
          {#if notaEditando}
            <div class="glass rounded-2xl border border-white/10">
              <textarea
                bind:value={notaTexto}
                rows="3"
                placeholder="Ej: llevar uniforme nuevo..."
                class="w-full bg-transparent outline-none text-sm text-white placeholder:text-white/30 p-4 resize-none"
              ></textarea>
            </div>
            <div class="flex gap-2">
              <div class="flex-1"><GlassButton variant="secondary" fullWidth onTap={() => (notaEditando = false)}>Cancelar</GlassButton></div>
              <div class="flex-1"><GlassButton variant="primary" fullWidth icon="check" onTap={guardarNota}>Guardar</GlassButton></div>
            </div>
          {:else}
            <GlassCard padding="md">
              <p class="text-sm text-white/85 whitespace-pre-line leading-relaxed">
                {notaGuardada || 'Sin nota personal. Toca Editar para añadir una.'}
              </p>
            </GlassCard>
          {/if}
        </div>
      {/if}

      <GlassCard padding="lg">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-dorado/20 flex items-center justify-center shrink-0">
            <Icon name="user" size={18} class="text-dorado" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[10px] text-dorado/70 tracking-[0.2em] font-bold uppercase">Organizado por</p>
            <p class="text-sm font-bold text-white truncate mt-0.5">{evento.creador_nombre || 'Admin'}</p>
          </div>
        </div>
      </GlassCard>
    </div>
  {/if}
</div>