<!-- src/lib/features/admin/AgregarEvento.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import L from 'leaflet';
  import 'leaflet/dist/leaflet.css';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { eventosService, toLocalInputValue } from '../../services/eventos';
  import { eventos } from '../../stores/eventos.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  interface Props {
    id?: string;
  }

  let { id = '' }: Props = $props();

  const editando = $derived(id !== '');

  let titulo = $state('');
  let descripcion = $state('');
  let lugar = $state('');
  let fechaInput = $state(toLocalInputValue(new Date(Date.now() + 86400000)));
  let lat = $state<number | null>(null);
  let lng = $state<number | null>(null);

  let mapEl: HTMLDivElement | undefined = $state(undefined);
  let map: L.Map | null = null;
  let marker: L.Marker | null = null;

  let guardando = $state(false);
  let cargandoEdicion = $state(false);
  let error = $state('');

  onMount(async () => {
    if (editando) {
      cargandoEdicion = true;
      try {
        const existente = eventos.buscar(id) ?? await eventosService.obtener(id);
        if (!existente) {
          error = 'No se encontró este evento. Vuelve al calendario e inténtalo de nuevo.';
        } else {
          titulo = existente.titulo;
          descripcion = existente.descripcion;
          lugar = existente.lugar;
          fechaInput = toLocalInputValue(new Date(existente.fecha));
          lat = existente.lat;
          lng = existente.lng;
        }
      } catch (cause) {
        error = cause instanceof Error ? cause.message : 'No se pudo cargar el evento.';
      } finally {
        cargandoEdicion = false;
      }
    }
    initMap();
  });

  onDestroy(() => {
    map?.remove();
  });

  function initMap() {
    if (!mapEl || map) return;
    map = L.map(mapEl, {
      center: [lat ?? -15.4994, lng ?? -70.1333],
      zoom: lat ? 15 : 13,
      zoomControl: false,
      attributionControl: false
    });
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);

    if (lat !== null && lng !== null) setMarker(lat, lng);

    map.on('click', (e: L.LeafletMouseEvent) => {
      lat = Number(e.latlng.lat.toFixed(6));
      lng = Number(e.latlng.lng.toFixed(6));
      setMarker(lat, lng);
    });
  }

  function setMarker(la: number, ln: number) {
    if (!map) return;
    if (marker) map.removeLayer(marker);
    const icon = L.divIcon({
      className: '',
      html: '<div style="width:32px;height:32px;background:#8B1A2B;border:3px solid #F5D061;border-radius:50%;box-shadow:0 4px 20px rgba(0,0,0,0.6);"></div>',
      iconSize: [32, 32],
      iconAnchor: [16, 16]
    });
    marker = L.marker([la, ln], { icon }).addTo(map);
  }

  async function guardar() {
    error = '';
    if (cargandoEdicion) { error = 'Espera a que termine de cargar el evento.'; return; }
    if (!titulo.trim()) { error = 'El título es obligatorio'; return; }
    if (!fechaInput) { error = 'La fecha es obligatoria'; return; }
    const fecha = new Date(fechaInput);
    if (isNaN(fecha.getTime())) { error = 'Fecha inválida'; return; }

    guardando = true;
    try {
      const input = { titulo, descripcion, lugar, fecha, lat, lng };
      if (editando) {
        await eventosService.actualizar(id, input);
      } else {
        await eventosService.crear(
          input,
          session.user?.uid ?? '',
          session.user?.nombre ?? 'Admin'
        );
      }
      eventos.refrescar();
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
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">
          {editando ? 'Editar' : 'Nuevo'}
        </p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Evento</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-10 space-y-4">
    {#if cargandoEdicion}
      <div class="glass rounded-2xl border border-dorado/20 px-4 py-3 flex items-center gap-3"><div class="w-5 h-5 border-2 border-dorado border-t-transparent rounded-full animate-spin"></div><p class="text-xs text-white/70">Cargando los datos del evento…</p></div>
    {/if}
    <GlassInput bind:value={titulo} label="Título *" placeholder="Fiesta patronal" icon="calendar" />
    <GlassInput bind:value={lugar} label="Lugar" placeholder="Plaza de Armas, Juliaca" icon="map-pin" />

    <div class="flex flex-col gap-1.5">
      <label for="fecha-evento" class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1">
        Fecha y hora *
      </label>
      <div class="glass rounded-2xl border border-white/10">
        <div class="flex items-center gap-2 px-4 h-14">
          <Icon name="clock" size={18} class="text-dorado/80" />
          <input
            id="fecha-evento"
            type="datetime-local"
            bind:value={fechaInput}
            class="flex-1 bg-transparent outline-none text-[15px] text-white font-medium [color-scheme:dark]"
          />
        </div>
      </div>
    </div>

    <div class="flex flex-col gap-1.5">
      <label for="desc-evento" class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1">
        Descripción
      </label>
      <div class="glass rounded-2xl border border-white/10">
        <textarea
          id="desc-evento"
          bind:value={descripcion}
          rows="3"
          placeholder="Detalles del evento..."
          class="w-full bg-transparent outline-none text-[15px] text-white placeholder:text-white/30 font-medium p-4 resize-none"
        ></textarea>
      </div>
    </div>

    <GlassCard variant="default" padding="md">
      <div class="flex items-center justify-between mb-2">
        <p class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80">
          Ubicación (toca el mapa)
        </p>
        {#if lat !== null && lng !== null}
          <span class="text-[10px] text-white/50 font-mono tabular-nums">
            {lat.toFixed(4)}, {lng.toFixed(4)}
          </span>
        {:else}
          <span class="text-[10px] text-white/40">Sin marcar</span>
        {/if}
      </div>
      <div bind:this={mapEl} class="relative w-full h-[240px] rounded-2xl overflow-hidden bg-[#171412] border border-white/5"></div>
    </GlassCard>

    {#if error}
      <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{error}</p>
      </div>
    {/if}

    <GlassButton variant="primary" fullWidth icon="check" loading={guardando || cargandoEdicion} onTap={guardar}>
      {editando ? 'Guardar cambios' : 'Crear evento'}
    </GlassButton>
  </div>
</div>