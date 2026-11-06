<!-- src/lib/features/admin/GestionUsuarios.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import {
    usuariosService,
    rolLabel,
    rolColor,
    type Usuario,
    type Rol
  } from '../../services/usuarios';
  import { actividadService } from '../../services/actividad';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let usuarios = $state<Usuario[]>([]);
  let loading = $state(true);
  let filtro = $state<'todos' | 'activos' | 'baneados'>('activos');
  let query = $state('');
  let error = $state('');

  onMount(() => {
    if (!session.isAdmin) { router.back(); return; }
    const unsub = usuariosService.stream(
      (items) => { usuarios = items; loading = false; error = ''; },
      (cause) => {
        loading = false;
        error = cause instanceof Error ? cause.message : 'No se pudieron cargar los usuarios.';
      }
    );
    return unsub;
  });

  const filtrados = $derived.by(() => {
    let lista = usuarios;
    if (filtro === 'activos') lista = lista.filter((u) => !u.baneado);
    if (filtro === 'baneados') lista = lista.filter((u) => u.baneado);
    const q = query.trim().toLowerCase();
    if (q.length > 0) {
      lista = lista.filter((u) =>
        u.nombre.toLowerCase().includes(q) ||
        u.email.toLowerCase().includes(q)
      );
    }
    return lista;
  });

  async function cambiarRol(u: Usuario, nuevoRol: Rol) {
    if (u.uid === session.user?.uid) return;
    error = '';
    try {
      await usuariosService.cambiarRol(u.uid, nuevoRol);
      await actividadService.registrar(
        'cambiar_rol',
        `Cambió el rol de ${u.nombre} a ${rolLabel(nuevoRol)}`,
        session.user?.uid ?? '',
        session.displayName
      );
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'No se pudo cambiar el rol.';
    }
  }

  async function banear(u: Usuario) {
    if (!confirm(`¿Suspender a ${u.nombre}?`)) return;
    error = '';
    try {
      await usuariosService.banear(u.uid);
      await actividadService.registrar(
        'banear_usuario',
        `Suspendió a ${u.nombre}`,
        session.user?.uid ?? '',
        session.displayName
      );
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'No se pudo suspender al usuario.';
    }
  }

  async function desbanear(u: Usuario) {
    error = '';
    try {
      await usuariosService.desbanear(u.uid);
      await actividadService.registrar(
        'desbanear_usuario',
        `Reactivó a ${u.nombre}`,
        session.user?.uid ?? '',
        session.displayName
      );
    } catch (cause) {
      error = cause instanceof Error ? cause.message : 'No se pudo reactivar al usuario.';
    }
  }

  function inicial(n: string): string {
    return n.trim().charAt(0).toUpperCase() || '?';
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Admin</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Usuarios</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    {#if error}
      <div role="alert" class="rounded-xl border border-red-400/20 bg-red-500/10 px-4 py-3 text-xs text-red-200">{error}</div>
    {/if}
    <div class="glass rounded-2xl border border-white/10">
      <div class="flex items-center gap-2 px-4 h-12">
        <Icon name="search" size={16} class="text-dorado/70" />
        <input
          bind:value={query}
          type="text"
          placeholder="Buscar por nombre o email..."
          class="flex-1 bg-transparent outline-none text-sm text-white placeholder:text-white/30 font-medium"
        />
      </div>
    </div>

    <div class="glass glass-strong rounded-full p-1 flex">
      {#each [{ k: 'activos', l: 'Activos' }, { k: 'baneados', l: 'Suspendidos' }, { k: 'todos', l: 'Todos' }] as opt}
        <button
          type="button"
          onclick={() => (filtro = opt.k as typeof filtro)}
          class="flex-1 h-10 rounded-full text-[11px] font-bold tracking-wider uppercase transition-all {filtro === opt.k
            ? 'bg-gradient-to-br from-granate to-granate-dark text-dorado'
            : 'text-white/50'}"
        >
          {opt.l}
        </button>
      {/each}
    </div>

    <p class="text-[10px] text-white/40 tracking-[0.2em] font-bold uppercase px-1">
      {filtrados.length} {filtrados.length === 1 ? 'usuario' : 'usuarios'}
    </p>

    {#if loading}
      <div class="space-y-2">
        {#each Array(4) as _}
          <div class="glass rounded-2xl h-20 animate-pulse"></div>
        {/each}
      </div>
    {:else if filtrados.length === 0}
      <GlassCard padding="xl">
        <div class="flex flex-col items-center text-center py-4">
          <div class="w-14 h-14 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
            <Icon name="user" size={22} class="text-dorado/60" />
          </div>
          <p class="text-sm font-bold text-white">Sin usuarios</p>
          <p class="text-xs text-white/50 mt-1">No hay usuarios que coincidan</p>
        </div>
      </GlassCard>
    {:else}
      <div class="space-y-2">
        {#each filtrados as u (u.uid)}
          <GlassCard padding="md">
            <div class="flex items-start gap-3">
              <div class="w-11 h-11 rounded-full bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
                <span class="text-base font-black text-dorado">{inicial(u.nombre)}</span>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                  <p class="text-sm font-bold text-white truncate">{u.nombre}</p>
                  {#if u.baneado}
                    <span class="text-[8px] px-1.5 py-0.5 rounded-full bg-red-500/20 text-red-300 font-bold uppercase tracking-wider">
                      Suspendido
                    </span>
                  {/if}
                  {#if u.uid === session.user?.uid}
                    <span class="text-[8px] px-1.5 py-0.5 rounded-full bg-dorado/20 text-dorado font-bold uppercase tracking-wider">
                      Tú
                    </span>
                  {/if}
                </div>
                <p class="text-[11px] text-white/40 truncate mt-0.5">{u.email}</p>
                <p class="text-[9px] font-bold tracking-wider uppercase mt-1 {rolColor(u.rol)}">
                  {rolLabel(u.rol)}
                </p>
              </div>

              {#if u.uid !== session.user?.uid}
                <div class="shrink-0">
                  <select
                    value={u.rol}
                    onchange={(e) => cambiarRol(u, (e.target as HTMLSelectElement).value as Rol)}
                    class="bg-white/5 border border-white/10 rounded-xl px-2 py-1.5 text-[11px] text-white font-bold outline-none [color-scheme:dark]"
                  >
                    <option value="publico">Público</option>
                    <option value="miembro">Miembro</option>
                    <option value="admin">Admin</option>
                    {#if session.user?.rol === 'dev'}
                      <option value="dev">Dev</option>
                    {/if}
                  </select>
                </div>
              {/if}
            </div>

            {#if u.uid !== session.user?.uid}
              <div class="mt-2 flex justify-end">
                {#if u.baneado}
                  <button
                    type="button"
                    onclick={() => desbanear(u)}
                    class="text-[11px] px-3 py-1 rounded-full bg-emerald-500/15 text-emerald-400 font-bold uppercase tracking-wider active:scale-95 transition-transform"
                  >
                    Reactivar
                  </button>
                {:else}
                  <button
                    type="button"
                    onclick={() => banear(u)}
                    class="text-[11px] px-3 py-1 rounded-full bg-red-500/15 text-red-400 font-bold uppercase tracking-wider active:scale-95 transition-transform"
                  >
                    Suspender
                  </button>
                {/if}
              </div>
            {/if}
          </GlassCard>
        {/each}
      </div>
    {/if}
  </div>
</div>