<!-- src/lib/features/admin/AdminScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { canciones } from '../../stores/canciones.svelte';
  import { eventos } from '../../stores/eventos.svelte';
  import { recuerdos } from '../../stores/recuerdos.svelte';
  import { router } from '../../stores/router.svelte';

  onMount(() => {
    if (!session.isAdmin) { router.back(); return; }
    canciones.cargar();
    eventos.cargar();
    recuerdos.cargar();
  });

  const totalReproducciones = $derived(
    canciones.all.reduce((s, c) => s + c.reproducciones, 0)
  );
  const totalFotos = $derived(
    recuerdos.all.reduce((s, r) => s + r.fotos.length, 0)
  );

  const accionesCrear = [
    { icon: 'plus', titulo: 'Nuevo evento', desc: 'Programar presentación', route: 'agregar-evento' as const },
    { icon: 'music', titulo: 'Nueva canción', desc: 'Añadir al cancionero', route: 'agregar-cancion' as const },
    { icon: 'image', titulo: 'Nuevo recuerdo', desc: 'Subir fotos y videos', route: 'agregar-recuerdo' as const }
  ];

  const accionesGestion = [
    { icon: 'user', titulo: 'Usuarios', desc: 'Roles y suspensiones', route: 'gestion-usuarios' as const },
    { icon: 'grid', titulo: 'Categorías', desc: 'Organizar el cancionero', route: 'gestion-categorias' as const },
    { icon: 'clock', titulo: 'Historial', desc: 'Actividad del grupo', route: 'actividad' as const },
    { icon: 'download', titulo: 'Respaldo', desc: 'Exportar a JSON', route: 'exportar-respaldo' as const }
  ];
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Panel</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Administración</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 space-y-5 pb-10">
    <GlassCard variant="gold" padding="xl">
      <div class="flex items-center gap-2 mb-2">
        <div class="w-7 h-7 rounded-full bg-dorado/25 flex items-center justify-center">
          <Icon name="crown" size={14} class="text-dorado" />
        </div>
        <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">Administrador</p>
      </div>
      <h1 class="text-2xl font-black text-white tracking-tight leading-tight">
        Hola, {session.displayName}
      </h1>
      <p class="text-xs text-white/60 mt-2">Panel de control del grupo</p>
    </GlassCard>

    <div>
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1 mb-3">
        Métricas
      </h3>
      <div class="grid grid-cols-2 gap-2">
        <GlassCard padding="md">
          <div class="flex items-center gap-2 mb-2">
            <Icon name="music" size={14} class="text-dorado" />
            <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">Canciones</p>
          </div>
          <p class="text-2xl font-black text-white leading-none">{canciones.all.length}</p>
        </GlassCard>
        <GlassCard padding="md">
          <div class="flex items-center gap-2 mb-2">
            <Icon name="calendar" size={14} class="text-dorado" />
            <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">Eventos</p>
          </div>
          <p class="text-2xl font-black text-white leading-none">{eventos.all.length}</p>
        </GlassCard>
        <GlassCard padding="md">
          <div class="flex items-center gap-2 mb-2">
            <Icon name="image" size={14} class="text-dorado" />
            <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">Recuerdos</p>
          </div>
          <p class="text-2xl font-black text-white leading-none">{recuerdos.all.length}</p>
        </GlassCard>
        <GlassCard padding="md">
          <div class="flex items-center gap-2 mb-2">
            <Icon name="play" size={14} class="text-dorado" fill />
            <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">Plays</p>
          </div>
          <p class="text-2xl font-black text-white leading-none">{totalReproducciones}</p>
        </GlassCard>
      </div>
      <div class="mt-2">
        <GlassCard padding="md">
          <div class="flex items-center gap-2 mb-2">
            <Icon name="image" size={14} class="text-dorado" />
            <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">Fotos totales</p>
          </div>
          <p class="text-2xl font-black text-white leading-none">{totalFotos}</p>
        </GlassCard>
      </div>
    </div>

    <div>
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1 mb-3">
        Crear contenido
      </h3>
      <div class="space-y-2">
        {#each accionesCrear as a}
          <GlassCard padding="md" onTap={() => router.go(a.route)}>
            <div class="flex items-center gap-3">
              <div class="w-11 h-11 rounded-2xl bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shrink-0 shadow-lg shadow-dorado/40">
                <Icon name={a.icon} size={20} class="text-granate-dark" />
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-white">{a.titulo}</p>
                <p class="text-[11px] text-white/50 mt-0.5">{a.desc}</p>
              </div>
              <Icon name="chevron-right" size={16} class="text-dorado/50" />
            </div>
          </GlassCard>
        {/each}
      </div>
    </div>

    <div>
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1 mb-3">
        Gestión
      </h3>
      <div class="space-y-2">
        {#each accionesGestion as a}
          <GlassCard padding="md" onTap={() => router.go(a.route)}>
            <div class="flex items-center gap-3">
              <div class="w-11 h-11 rounded-2xl bg-white/5 flex items-center justify-center shrink-0">
                <Icon name={a.icon} size={20} class="text-dorado" />
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-white">{a.titulo}</p>
                <p class="text-[11px] text-white/50 mt-0.5">{a.desc}</p>
              </div>
              <Icon name="chevron-right" size={16} class="text-dorado/50" />
            </div>
          </GlassCard>
        {/each}
      </div>
    </div>
  </div>
</div>