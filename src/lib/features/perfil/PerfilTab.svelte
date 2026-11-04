<!-- src/lib/features/perfil/PerfilTab.svelte -->
<script lang="ts">
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  const inicial = $derived(
    session.displayName.charAt(0).toUpperCase() || '?'
  );

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
</script>

<div class="px-5 py-6 pb-40 space-y-4">
  <!-- Header -->
  <div class="flex items-center justify-between">
    <div>
      <p class="text-[11px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
        Mi cuenta
      </p>
      <h2 class="text-3xl font-black text-white tracking-tight mt-1">
        Perfil
      </h2>
    </div>
    <GlassIconButton icon="settings" variant="gold" />
  </div>

  <!-- Tarjeta de usuario -->
  <GlassCard variant="granate" padding="xl">
    <div class="flex items-center gap-4">
      <div class="relative shrink-0">
        <div class="absolute inset-0 rounded-full bg-dorado blur-xl opacity-40"></div>
        <div class="relative w-20 h-20 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40 border-2 border-dorado/40">
          <span class="text-3xl font-black text-granate-dark">
            {inicial}
          </span>
        </div>
      </div>
      <div class="flex-1 min-w-0">
        <h3 class="text-xl font-black text-white truncate leading-tight">
          {session.displayName}
        </h3>
        <p class="text-xs text-white/60 truncate mt-1">
          {session.user?.email ?? ''}
        </p>
        <div class="inline-flex items-center gap-1.5 mt-2 px-2 py-0.5 rounded-full bg-white/10 border border-white/10">
          <span class="w-1.5 h-1.5 rounded-full {session.isAdmin ? 'bg-dorado' : 'bg-white/40'}"></span>
          <span class="text-[10px] font-bold tracking-wider uppercase {rolColor}">
            {rolLabel}
          </span>
        </div>
      </div>
    </div>
  </GlassCard>

  <!-- Admin panel (solo si es admin) -->
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
        <p class="text-[10px] text-dorado/80 tracking-[0.25em] font-bold uppercase">
          Panel de control
        </p>
        <p class="text-lg font-black text-dorado tracking-tight leading-tight mt-0.5">
          Administración
        </p>
        <p class="text-[11px] text-white/50 mt-0.5">
          Métricas, usuarios y contenido
        </p>
      </div>
      <Icon name="chevron-right" size={20} class="text-dorado/70 shrink-0" />
    </button>
  {/if}

  <!-- Stats -->
  <div class="grid grid-cols-3 gap-2">
    <GlassCard padding="md">
      <div class="flex flex-col items-center text-center">
        <div class="w-9 h-9 rounded-full bg-dorado/15 flex items-center justify-center mb-2">
          <Icon name="heart" size={16} class="text-dorado" fill />
        </div>
        <p class="text-xl font-black text-white leading-none">0</p>
        <p class="text-[9px] text-white/40 tracking-wider font-bold uppercase mt-1">
          Favoritos
        </p>
      </div>
    </GlassCard>

    <GlassCard padding="md">
      <div class="flex flex-col items-center text-center">
        <div class="w-9 h-9 rounded-full bg-dorado/15 flex items-center justify-center mb-2">
          <Icon name="play" size={16} class="text-dorado" fill />
        </div>
        <p class="text-xl font-black text-white leading-none">0</p>
        <p class="text-[9px] text-white/40 tracking-wider font-bold uppercase mt-1">
          Escuchadas
        </p>
      </div>
    </GlassCard>

    <GlassCard padding="md">
      <div class="flex flex-col items-center text-center">
        <div class="w-9 h-9 rounded-full bg-dorado/15 flex items-center justify-center mb-2">
          <Icon name="star" size={16} class="text-dorado" fill />
        </div>
        <p class="text-xl font-black text-white leading-none">0</p>
        <p class="text-[9px] text-white/40 tracking-wider font-bold uppercase mt-1">
          Logros
        </p>
      </div>
    </GlassCard>
  </div>

  <!-- Menú -->
  <div class="space-y-2">
    <GlassCard padding="md" onTap={() => {}}>
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-dorado/15 flex items-center justify-center shrink-0">
          <Icon name="user" size={18} class="text-dorado" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-white">Editar perfil</p>
          <p class="text-[11px] text-white/50 mt-0.5">Nombre, foto y datos</p>
        </div>
        <Icon name="chevron-right" size={16} class="text-dorado/40" />
      </div>
    </GlassCard>

    <GlassCard padding="md" onTap={() => {}}>
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-dorado/15 flex items-center justify-center shrink-0">
          <Icon name="bell" size={18} class="text-dorado" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-white">Notificaciones</p>
          <p class="text-[11px] text-white/50 mt-0.5">Eventos y novedades</p>
        </div>
        <Icon name="chevron-right" size={16} class="text-dorado/40" />
      </div>
    </GlassCard>

    <GlassCard padding="md" onTap={() => {}}>
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-dorado/15 flex items-center justify-center shrink-0">
          <Icon name="share" size={18} class="text-dorado" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-white">Compartir app</p>
          <p class="text-[11px] text-white/50 mt-0.5">Invita a otros miembros</p>
        </div>
        <Icon name="chevron-right" size={16} class="text-dorado/40" />
      </div>
    </GlassCard>

    <GlassCard padding="md" onTap={() => {}}>
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-dorado/15 flex items-center justify-center shrink-0">
          <Icon name="info" size={18} class="text-dorado" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-white">Acerca de</p>
          <p class="text-[11px] text-white/50 mt-0.5">Versión 3.0 · Rust Edition</p>
        </div>
        <Icon name="chevron-right" size={16} class="text-dorado/40" />
      </div>
    </GlassCard>
  </div>

  <!-- Logout -->
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
      <p class="text-center text-sm text-white/80 font-semibold">
        ¿Seguro que quieres salir?
      </p>
      <div class="flex gap-2">
        <div class="flex-1">
          <GlassButton
            variant="secondary"
            fullWidth
            onTap={() => (confirmandoLogout = false)}
          >
            Cancelar
          </GlassButton>
        </div>
        <div class="flex-1">
          <GlassButton
            variant="danger"
            fullWidth
            icon="log-out"
            onTap={hacerLogout}
          >
            Salir
          </GlassButton>
        </div>
      </div>
    </div>
  {/if}

  <p class="text-center text-[10px] text-white/20 tracking-[0.25em] uppercase pt-2">
    Allin Kawsay · v3.0
  </p>
</div>