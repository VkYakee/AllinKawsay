<!-- src/lib/features/eventos/EventoDetalle.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
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
  import { eventos } from '../../stores/eventos.svelte';
  import { router } from '../../stores/router.svelte';

  interface Props {
    id: string;
  }

  let { id }: Props = $props();

  let evento = $state<Evento | null>(null);
  let loading = $state(true);

  onMount(async () => {
    evento = eventos.buscar(id) ?? (await eventosService.obtener(id));
    loading = false;
  });

  const futuro = $derived(evento ? esFuturo(evento.fecha) : false);
  const tieneMapa = $derived(evento?.lat != null && evento?.lng != null);

  function abrirMaps() {
    if (!evento || evento.lat == null || evento.lng == null) return;
    const url = `https://www.google.com/maps/dir/?api=1&destination=${evento.lat},${evento.lng}`;
    window.open(url, '_blank');
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#0A0A0A]/80 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
          Evento
        </p>
        <p class="text-sm font-bold text-white truncate mt-0.5">
          {evento?.titulo ?? '...'}
        </p>
      </div>
      <GlassIconButton icon="share" size="sm" />
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
    <div class="px-5 py-6 space-y-5 pb-40">
      <!-- Hero -->
      <GlassCard variant={futuro ? 'granate' : 'default'} padding="xl">
        <div class="flex items-center gap-2 mb-3">
          <div class="w-7 h-7 rounded-full bg-dorado/20 flex items-center justify-center">
            <Icon name={futuro ? 'calendar' : 'clock'} size={14} class="text-dorado" />
          </div>
          <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">
            {futuro ? 'Próximo evento' : 'Evento pasado'}
          </p>
        </div>

        <h1 class="text-2xl font-black text-white tracking-tight leading-tight">
          {evento.titulo}
        </h1>

        <div class="mt-4 space-y-2">
          <div class="flex items-center gap-2">
            <Icon name="calendar" size={14} class="text-dorado/80 shrink-0" />
            <span class="text-sm text-white/80 font-medium">
              {fechaLarga(evento.fecha)}
            </span>
          </div>
          <div class="flex items-center gap-2">
            <Icon name="clock" size={14} class="text-dorado/80 shrink-0" />
            <span class="text-sm text-white/80 font-medium">
              {hora(evento.fecha)}
            </span>
          </div>
          <div class="flex items-center gap-2">
            <Icon name="map-pin" size={14} class="text-dorado/80 shrink-0" />
            <span class="text-sm text-white/80 font-medium">
              {evento.lugar}
            </span>
          </div>
        </div>
      </GlassCard>

      {#if evento.descripcion}
        <GlassCard padding="xl">
          <h3 class="text-[10px] font-bold text-dorado/70 tracking-[0.25em] uppercase mb-3">
            Descripción
          </h3>
          <p class="text-sm text-white/80 leading-relaxed whitespace-pre-line">
            {evento.descripcion}
          </p>
        </GlassCard>
      {/if}

      {#if tieneMapa}
        <GlassCard padding="lg">
          <div class="flex items-center justify-between mb-3">
            <h3 class="text-[10px] font-bold text-dorado/70 tracking-[0.25em] uppercase">
              Ubicación
            </h3>
            <span class="text-[10px] text-white/40 font-mono">
              {evento.lat?.toFixed(4)}, {evento.lng?.toFixed(4)}
            </span>
          </div>

          <!-- Mini-mapa decorativo con pin animado -->
          <div class="relative w-full h-[180px] rounded-2xl overflow-hidden bg-[#0F0F0F] border border-white/5">
            <svg viewBox="0 0 400 200" class="absolute inset-0 w-full h-full">
              <!-- Grid de calles -->
              <defs>
                <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                  <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(255,255,255,0.05)" stroke-width="1" />
                </pattern>
              </defs>
              <rect width="400" height="200" fill="url(#grid)" />
              <!-- Avenidas principales -->
              <path d="M 0 80 L 400 80" stroke="rgba(245,208,97,0.15)" stroke-width="6" />
              <path d="M 180 0 L 180 200" stroke="rgba(245,208,97,0.15)" stroke-width="6" />
              <path d="M 0 140 Q 200 120 400 160" stroke="rgba(245,208,97,0.10)" stroke-width="4" fill="none" />

              <!-- Pin -->
              <g transform="translate(200, 100)">
                <circle r="30" fill="rgba(245, 208, 97, 0.12)">
                  <animate attributeName="r" values="20;36;20" dur="2s" repeatCount="indefinite" />
                  <animate attributeName="opacity" values="0.5;0;0.5" dur="2s" repeatCount="indefinite" />
                </circle>
                <circle r="18" fill="rgba(139, 26, 43, 0.4)" />
                <circle r="12" fill="#8B1A2B" stroke="#F5D061" stroke-width="2" />
                <circle cx="-4" cy="-4" r="3" fill="rgba(255,255,255,0.5)" />
              </g>
            </svg>

            <!-- Overlay de coordenadas -->
            <div class="absolute bottom-3 left-3 glass rounded-xl px-3 py-1.5 flex items-center gap-1.5">
              <Icon name="map-pin" size={11} class="text-dorado" />
              <span class="text-[10px] text-white/80 font-semibold">Ubicación exacta</span>
            </div>
          </div>

          <div class="mt-3">
            <GlassButton
              variant="primary"
              fullWidth
              icon="external-link"
              onTap={abrirMaps}
            >
              Cómo llegar
            </GlassButton>
          </div>
        </GlassCard>
      {/if}

      <GlassCard padding="lg">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-dorado/15 flex items-center justify-center shrink-0">
            <Icon name="user" size={18} class="text-dorado" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[10px] text-dorado/60 tracking-[0.2em] font-bold uppercase">
              Organizado por
            </p>
            <p class="text-sm font-bold text-white truncate mt-0.5">
              {evento.creador_nombre || 'Admin'}
            </p>
          </div>
        </div>
      </GlassCard>
    </div>
  {/if}
</div>