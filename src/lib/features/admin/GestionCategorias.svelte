<!-- src/lib/features/admin/GestionCategorias.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { categoriasService, type Categoria } from '../../services/categorias';
  import { actividadService } from '../../services/actividad';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let categorias = $state<Categoria[]>([]);
  let loading = $state(true);
  let modalAbierto = $state(false);
  let editando = $state<Categoria | null>(null);

  let fNombre = $state('');
  let fEmoji = $state('📁');
  let fOrden = $state(0);
  let guardando = $state(false);

  onMount(() => {
    if (!session.isAdmin) { router.back(); return; }
    const unsub = categoriasService.stream(
      (items) => { categorias = items; loading = false; },
      () => (loading = false)
    );
    return unsub;
  });

  function abrirNueva() {
    editando = null;
    fNombre = '';
    fEmoji = '📁';
    fOrden = categorias.length;
    modalAbierto = true;
  }

  function abrirEditar(c: Categoria) {
    editando = c;
    fNombre = c.nombre;
    fEmoji = c.emoji;
    fOrden = c.orden;
    modalAbierto = true;
  }

  async function guardar() {
    if (!fNombre.trim() || guardando) return;
    guardando = true;
    try {
      if (editando) {
        await categoriasService.actualizar(editando.id, fNombre, fEmoji, fOrden);
        await actividadService.registrar(
          'editar_categoria',
          `Editó la categoría ${fEmoji} ${fNombre}`,
          session.user?.uid ?? '',
          session.displayName
        );
      } else {
        await categoriasService.crear(fNombre, fEmoji, fOrden);
        await actividadService.registrar(
          'crear_categoria',
          `Creó la categoría ${fEmoji} ${fNombre}`,
          session.user?.uid ?? '',
          session.displayName
        );
      }
      modalAbierto = false;
    } finally {
      guardando = false;
    }
  }

  async function eliminar(c: Categoria) {
    if (!confirm(`¿Eliminar la categoría ${c.emoji} ${c.nombre}?`)) return;
    try {
      await categoriasService.eliminar(c.id);
      await actividadService.registrar(
        'eliminar_categoria',
        `Eliminó la categoría ${c.emoji} ${c.nombre}`,
        session.user?.uid ?? '',
        session.displayName
      );
    } catch {}
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Admin</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Categorías</p>
      </div>
      <button
        type="button"
        onclick={abrirNueva}
        class="w-10 h-10 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40 active:scale-90 transition-transform"
      >
        <Icon name="plus" size={20} class="text-granate-dark" />
      </button>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    <p class="text-[10px] text-white/40 tracking-[0.2em] font-bold uppercase px-1">
      {categorias.length} {categorias.length === 1 ? 'categoría' : 'categorías'}
    </p>

    {#if loading}
      <div class="space-y-2">
        {#each Array(3) as _}
          <div class="glass rounded-2xl h-16 animate-pulse"></div>
        {/each}
      </div>
    {:else if categorias.length === 0}
      <GlassCard padding="xl">
        <div class="flex flex-col items-center text-center py-4">
          <div class="w-14 h-14 rounded-full bg-dorado/10 flex items-center justify-center mb-3">
            <Icon name="grid" size={22} class="text-dorado/60" />
          </div>
          <p class="text-sm font-bold text-white">Sin categorías</p>
          <p class="text-xs text-white/50 mt-1">Toca + para crear la primera</p>
        </div>
      </GlassCard>
    {:else}
      <div class="space-y-2">
        {#each categorias as c (c.id)}
          <GlassCard padding="md">
            <div class="flex items-center gap-3">
              <div class="w-11 h-11 rounded-xl bg-granate flex items-center justify-center shrink-0 text-xl">
                {c.emoji}
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-white truncate">{c.nombre}</p>
                <p class="text-[11px] text-white/40">Orden: {c.orden}</p>
              </div>
              <button
                type="button"
                onclick={() => abrirEditar(c)}
                class="w-9 h-9 rounded-full bg-white/5 flex items-center justify-center text-dorado active:scale-90"
              >
                <Icon name="edit" size={14} />
              </button>
              <button
                type="button"
                onclick={() => eliminar(c)}
                class="w-9 h-9 rounded-full bg-red-500/10 flex items-center justify-center text-red-400 active:scale-90"
              >
                <Icon name="trash" size={14} />
              </button>
            </div>
          </GlassCard>
        {/each}
      </div>
    {/if}
  </div>
</div>

{#if modalAbierto}
  <div
    class="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-end"
    onclick={(e) => { if (e.target === e.currentTarget) modalAbierto = false; }}
    role="presentation"
  >
    <div class="w-full glass glass-strong rounded-t-3xl p-5 border-t border-dorado/30 space-y-4 pb-8">
      <div class="w-10 h-1 rounded-full bg-white/20 mx-auto"></div>
      <h2 class="text-lg font-black text-dorado text-center">
        {editando ? 'Editar categoría' : 'Nueva categoría'}
      </h2>

      <div class="grid grid-cols-3 gap-2">
        <div class="col-span-1">
          <GlassInput bind:value={fEmoji} label="Emoji" placeholder="📁" maxlength={4} />
        </div>
        <div class="col-span-2">
          <GlassInput bind:value={fNombre} label="Nombre" placeholder="Carnaval" />
        </div>
      </div>

      <GlassInput
        value={String(fOrden)}
        label="Orden"
        type="number"
        onInput={(v) => (fOrden = parseInt(v) || 0)}
      />

      <div class="flex gap-2">
        <div class="flex-1">
          <GlassButton variant="secondary" fullWidth onTap={() => (modalAbierto = false)}>Cancelar</GlassButton>
        </div>
        <div class="flex-1">
          <GlassButton variant="primary" fullWidth icon="check" loading={guardando} onTap={guardar}>
            {editando ? 'Guardar' : 'Crear'}
          </GlassButton>
        </div>
      </div>
    </div>
  </div>
{/if}