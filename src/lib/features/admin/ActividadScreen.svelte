<!-- src/lib/features/admin/ActividadScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import {
    actividadService,
    iconoActividad,
    fechaRelativa,
    type Actividad
  } from '../../services/actividad';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let actividades = $state<Actividad[]>([]);
  let loading = $state(true);

  onMount(() => {
    if (!session.isAdmin) { router.back(); return; }
    const unsub = actividadService.stream(
      (items) => { actividades = items; loading = false; },
      () => (loading = false),
      200
    );
    return unsub;
  });
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Admin</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Historial</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-3">
    <p class="text-[10px] text-white/40 tracking-[0.2em] font-bold uppercase px-1">
      {actividades.length} {actividades.length === 1 ? 'acción' : 'acciones'}
    </p>

    {#if loading}
      <div class="space-y-2">
        {#each Array(5) as _}
          <div class="glass rounded-2xl h-16 animate-pulse"></div>
        {/each}
      </div>
    {:else if actividades.length === 0}
      <GlassCard padding="xl">
        <div class="flex flex-col items-center text-center py-4">
          <div class="w-14 h-14 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
            <Icon name="clock" size={22} class="text-dorado/60" />
          </div>
          <p class="text-sm font-bold text-white">Sin actividad</p>
          <p class="text-xs text-white/50 mt-1">Las acciones admin aparecerán aquí</p>
        </div>
      </GlassCard>
    {:else}
      <div class="space-y-2">
        {#each actividades as a (a.id)}
          {@const meta = iconoActividad(a.accion)}
          <GlassCard padding="md">
            <div class="flex items-start gap-3">
              <div class="w-9 h-9 rounded-full bg-white/5 flex items-center justify-center shrink-0 {meta.color}">
                <Icon name={meta.icon} size={16} />
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm text-white font-medium leading-snug">{a.detalle}</p>
                <div class="flex items-center gap-1.5 mt-1">
                  <span class="text-[10px] text-dorado/70 font-semibold">{a.autor_nombre}</span>
                  <span class="text-[10px] text-white/30">·</span>
                  <span class="text-[10px] text-white/40">{fechaRelativa(a.fecha)}</span>
                </div>
              </div>
            </div>
          </GlassCard>
        {/each}
      </div>
    {/if}
  </div>
</div>