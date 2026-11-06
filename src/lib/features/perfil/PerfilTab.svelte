<!-- src/lib/features/perfil/PerfilTab.svelte -->
<script lang="ts">
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  const inicial = $derived(session.displayName.charAt(0).toUpperCase() || '?');
  let confirmandoLogout = $state(false);

  async function hacerLogout() {
    await session.logout();
    router.reset('login');
  }

  const rolLabel = $derived.by(() => {
    switch (session.user?.rol) {
      case 'dev': return 'Desarrollador';
      case 'admin': return 'Administrador';
      case 'miembro': return 'Miembro oficial';
      default: return 'Público';
    }
  });

  const rolColor = $derived.by(() => {
    switch (session.user?.rol) {
      case 'dev': return 'text-cyan-400';
      case 'admin': return 'text-dorado';
      case 'miembro': return 'text-emerald-400';
      default: return 'text-white/50';
    }
  });

  const menu = [
    { icon: 'search', titulo: 'Buscar', desc: 'Canciones, eventos, recuerdos', route: 'buscar' as const },
    { icon: 'star', titulo: 'Historia del grupo', desc: 'Nuestra trayectoria', route: 'historia' as const },
    { icon: 'share', titulo: 'Compartir app', desc: 'Invita a otros miembros', route: 'compartir-app' as const },
    { icon: 'download', titulo: 'Gestión de caché', desc: 'Liberar espacio', route: 'gestion-cache' as const }
  ];
</script>

<div class="px-5 py-6 pb-40 space-y-4">
  <div class="flex items-center justify-between">
    <div>
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">Mi cuenta</p>
      <h2 class="text-3xl font-black text-white tracking-tight mt-1">Perfil</h2>
    </div>
  </div>

  <GlassCard variant="granate" padding="xl">
    <div class="flex items-center gap-4">
      <div class="relative shrink-0">
        <div class="absolute inset-0 rounded-full bg-dorado blur-xl opacity-40"></div>
        <div class="relative w-20 h-20 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40 border-2 border-dorado/40">
          <span class="text-3xl font-black text-granate-dark">{inicial}</span>
        </div>
      </div>
      <div class="flex-1 min-w-0">
        <h3 class="text-xl font-black text-white truncate leading-tight">{session.displayName}</h3>
        <p class="text-xs text-white/60 truncate mt-1">{session.user?.email ?? ''}</p>
        <div class="inline-flex items-center gap-1.5 mt-2 px-2 py-0.5 rounded-full bg-white/10 border border-white/10">
          <span class="w-1.5 h-1.5 rounded-full {session.isAdmin ? 'bg-dorado' : 'bg-white/40'}"></span>
          <span class="text-[10px] font-bold tracking-wider uppercase {rolColor}">{rolLabel}</span>
        </div>
      </div>
    </div>
  </GlassCard>

  {#if session.isAdmin}
    <button
      type="button"
      onclick={() => router.go('admin')}
      class="w-full glass glass-gold rounded-3xl p-5 flex items-center gap-4 active:scale-[0.98] transition-transform text-left"
    >
      <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40 shrink-0">
        <Icon name="crown" size={22} class="text-granate-dark" />
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/80 tracking-[0.25em] font-bold uppercase">Panel de control</p>
        <p class="text-lg font-black text-dorado tracking-tight leading-tight mt-0.5">Administración</p>
        <p class="text-[11px] text-white/50 mt-0.5">Métricas, usuarios y contenido</p>
      </div>
      <Icon name="chevron-right" size={20} class="text-dorado/70 shrink-0" />
    </button>
  {/if}

  <section class="glass rounded-3xl p-5 border border-white/10">
    <p class="text-[10px] text-dorado tracking-[0.22em] font-bold uppercase">Tu espacio</p>
    <h3 class="text-lg font-black text-white mt-1">Tu cuenta está lista para participar</h3>
    <p class="text-xs text-white/50 mt-2 leading-relaxed">Consulta las canciones, acompaña las actividades y comparte los recuerdos del conjunto desde las pestañas inferiores.</p>
  </section>

  <div class="space-y-2">
    {#each menu as m}
      <GlassCard padding="md" onTap={() => router.go(m.route)}>
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-dorado/15 flex items-center justify-center shrink-0">
            <Icon name={m.icon} size={18} class="text-dorado" />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-bold text-white">{m.titulo}</p>
            <p class="text-[11px] text-white/50 mt-0.5">{m.desc}</p>
          </div>
          <Icon name="chevron-right" size={16} class="text-dorado/40" />
        </div>
      </GlassCard>
    {/each}
  </div>

  {#if !confirmandoLogout}
    <button
      type="button"
      onclick={() => (confirmandoLogout = true)}
      class="w-full glass rounded-full h-14 flex items-center justify-center gap-2 border border-red-500/30 text-red-300 font-bold tracking-[0.15em] text-sm uppercase active:scale-95 transition-transform"
    >
      <Icon name="log-out" size={18} />
      Cerrar sesión
    </button>
  {:else}
    <div class="glass rounded-3xl p-4 border border-red-500/40 space-y-3">
      <p class="text-center text-sm text-white/80 font-semibold">¿Seguro que quieres salir?</p>
      <div class="flex gap-2">
        <div class="flex-1"><GlassButton variant="secondary" fullWidth onTap={() => (confirmandoLogout = false)}>Cancelar</GlassButton></div>
        <div class="flex-1"><GlassButton variant="danger" fullWidth icon="log-out" onTap={hacerLogout}>Salir</GlassButton></div>
      </div>
    </div>
  {/if}

  <p class="text-center text-[10px] text-white/20 tracking-[0.25em] uppercase pt-2">Allin Kawsay · v3.0</p>
</div>