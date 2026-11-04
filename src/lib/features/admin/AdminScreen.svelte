<!-- src/lib/features/admin/AdminScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { admin } from '../../stores/admin.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';
  import { rolLabel, rolColor } from '../../services/admin';

  onMount(() => {
    if (!session.isAdmin) {
      router.back();
      return;
    }
    admin.cargar();
  });

  const accesos = [
    { icon: 'user', titulo: 'Usuarios', desc: 'Gestionar miembros y roles', color: 'from-granate to-granate-dark' },
    { icon: 'music', titulo: 'Canciones', desc: 'Añadir y editar contenido', color: 'from-granate to-granate-dark' },
    { icon: 'calendar', titulo: 'Eventos', desc: 'Programar presentaciones', color: 'from-granate to-granate-dark' },
    { icon: 'image', titulo: 'Recuerdos', desc: 'Subir fotos y videos', color: 'from-granate to-granate-dark' }
  ];
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#0A0A0A]/80 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/60 tracking-[0.25em] font-bold uppercase">
          Panel
        </p>
        <p class="text-sm font-bold text-white truncate mt-0.5">
          Administración
        </p>
      </div>
      <GlassIconButton icon="refresh" size="sm" onTap={() => admin.cargar()} />
    </div>
  </header>

  <div class="px-5 py-6 space-y-5 pb-20">
    <!-- Bienvenida -->
    <GlassCard variant="gold" padding="xl">
      <div class="flex items-center gap-2 mb-2">
        <div class="w-7 h-7 rounded-full bg-dorado/20 flex items-center justify-center">
          <Icon name="crown" size={14} class="text-dorado" />
        </div>
        <p class="text-[10px] text-dorado tracking-[0.25em] font-bold uppercase">
          {rolLabel(session.user?.rol ?? 'admin')}
        </p>
      </div>
      <h1 class="text-2xl font-black text-white tracking-tight leading-tight">
        Hola, {session.displayName}
      </h1>
      <p class="text-xs text-white/60 mt-2">
        Bienvenido al panel de control del grupo
      </p>
    </GlassCard>

    {#if admin.error}
      <div class="glass rounded-2xl p-4 border border-red-500/30 flex items-center gap-3">
        <Icon name="alert-circle" size={20} class="text-red-400 shrink-0" />
        <p class="text-sm text-red-300">{admin.error}</p>
      </div>
    {/if}

    <!-- Stats -->
    <div>
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1 mb-3">
        Métricas
      </h3>

      {#if admin.loading || !admin.stats}
        <div class="grid grid-cols-2 gap-2">
          {#each Array(4) as _}
            <div class="glass rounded-2xl h-24 animate-pulse"></div>
          {/each}
        </div>
      {:else}
        <div class="grid grid-cols-2 gap-2">
          <GlassCard padding="md">
            <div class="flex items-center gap-2 mb-2">
              <Icon name="music" size={14} class="text-dorado" />
              <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">
                Canciones
              </p>
            </div>
            <p class="text-2xl font-black text-white leading-none">
              {admin.stats.total_canciones}
            </p>
          </GlassCard>

          <GlassCard padding="md">
            <div class="flex items-center gap-2 mb-2">
              <Icon name="calendar" size={14} class="text-dorado" />
              <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">
                Eventos
              </p>
            </div>
            <p class="text-2xl font-black text-white leading-none">
              {admin.stats.total_eventos}
            </p>
          </GlassCard>

          <GlassCard padding="md">
            <div class="flex items-center gap-2 mb-2">
              <Icon name="image" size={14} class="text-dorado" />
              <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">
                Recuerdos
              </p>
            </div>
            <p class="text-2xl font-black text-white leading-none">
              {admin.stats.total_recuerdos}
            </p>
          </GlassCard>

          <GlassCard padding="md">
            <div class="flex items-center gap-2 mb-2">
              <Icon name="play" size={14} class="text-dorado" fill />
              <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">
                Reproducciones
              </p>
            </div>
            <p class="text-2xl font-black text-white leading-none">
              {admin.stats.total_reproducciones}
            </p>
          </GlassCard>
        </div>

        <div class="grid grid-cols-2 gap-2 mt-2">
          <GlassCard padding="md">
            <div class="flex items-center gap-2 mb-2">
              <Icon name="image" size={14} class="text-dorado" />
              <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">
                Fotos
              </p>
            </div>
            <p class="text-2xl font-black text-white leading-none">
              {admin.stats.total_fotos}
            </p>
          </GlassCard>

          <GlassCard padding="md">
            <div class="flex items-center gap-2 mb-2">
              <Icon name="volume" size={14} class="text-dorado" />
              <p class="text-[9px] text-white/50 tracking-wider font-bold uppercase">
                Con audio
              </p>
            </div>
            <p class="text-2xl font-black text-white leading-none">
              {admin.stats.total_audios}
            </p>
          </GlassCard>
        </div>
      {/if}
    </div>

    <!-- Accesos rápidos -->
    <div>
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1 mb-3">
        Gestión
      </h3>
      <div class="grid grid-cols-2 gap-2">
        {#each accesos as a}
          <GlassCard padding="md" onTap={() => {}}>
            <div class="w-10 h-10 rounded-xl bg-dorado/15 flex items-center justify-center mb-2">
              <Icon name={a.icon} size={18} class="text-dorado" />
            </div>
            <p class="text-sm font-bold text-white">{a.titulo}</p>
            <p class="text-[10px] text-white/50 mt-0.5 leading-tight">{a.desc}</p>
          </GlassCard>
        {/each}
      </div>
    </div>

    <!-- Usuarios -->
    <div>
      <h3 class="text-[11px] font-bold text-dorado tracking-[0.25em] uppercase px-1 mb-3">
        Usuarios ({admin.usuarios.length})
      </h3>

      {#if admin.loading}
        <div class="space-y-2">
          {#each Array(3) as _}
            <div class="glass rounded-2xl h-16 animate-pulse"></div>
          {/each}
        </div>
      {:else}
        <div class="space-y-2">
          {#each admin.usuarios as u (u.uid)}
            <GlassCard padding="md">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
                  <span class="text-sm font-black text-dorado">
                    {u.nombre.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-1.5">
                    <p class="text-sm font-bold text-white truncate">
                      {u.nombre}
                    </p>
                    {#if u.baneado}
                      <span class="shrink-0 text-[8px] px-1.5 py-0.5 rounded-full bg-red-500/20 text-red-300 font-bold uppercase tracking-wider">
                        Suspendido
                      </span>
                    {/if}
                  </div>
                  <p class="text-[11px] text-white/40 truncate mt-0.5">
                    {u.email}
                  </p>
                  <p class="text-[9px] font-bold tracking-wider uppercase mt-1 {rolColor(u.rol)}">
                    {rolLabel(u.rol)}
                  </p>
                </div>
              </div>
            </GlassCard>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</div>