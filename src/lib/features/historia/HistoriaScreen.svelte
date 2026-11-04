<!-- src/lib/features/historia/HistoriaScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { historiaService, type Historia } from '../../services/historia';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let historia = $state<Historia>({
    contenido: '',
    actualizadoPor: '',
    fechaActualizacion: null
  });
  let loading = $state(true);

  onMount(() => {
    const unsub = historiaService.stream(
      (h) => {
        historia = h;
        loading = false;
      },
      () => (loading = false)
    );
    return unsub;
  });

  function fechaBonita(iso: string | null): string {
    if (!iso) return '';
    const d = new Date(iso);
    return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`;
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Historia</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">Nuestra Historia</p>
      </div>
      {#if session.isAdmin}
        <GlassIconButton icon="edit" size="sm" onTap={() => router.go('editar-historia')} />
      {/if}
    </div>
  </header>

  <div class="px-5 py-6 pb-32">
    {#if loading}
      <div class="glass rounded-3xl h-64 animate-pulse"></div>
    {:else if !historia.contenido}
      <div class="flex flex-col items-center text-center py-16">
        <div class="w-20 h-20 rounded-full bg-dorado/15 flex items-center justify-center mb-4">
          <Icon name="info" size={32} class="text-dorado/60" />
        </div>
        <p class="text-base font-bold text-white">Historia vacía</p>
        <p class="text-xs text-white/50 mt-1">
          {session.isAdmin ? 'Toca el ícono de editar para escribirla' : 'El administrador aún no la ha escrito'}
        </p>
      </div>
    {:else}
      <GlassCard variant="granate" padding="xl">
        <div class="w-14 h-14 rounded-full bg-dorado/25 flex items-center justify-center mx-auto mb-4">
          <Icon name="star" size={26} class="text-dorado" fill />
        </div>
        <h1 class="text-xl font-black text-center text-dorado tracking-[0.15em] mb-6">
          C.I.A.C. ALLIN KAWSAY
        </h1>
        <div class="whitespace-pre-line text-[15px] leading-[1.9] text-white/85">
          {historia.contenido}
        </div>
        {#if historia.actualizadoPor}
          <div class="mt-8 pt-4 border-t border-dorado/20">
            <p class="text-[10px] text-white/40 italic text-center">
              Última edición por {historia.actualizadoPor}
              {#if historia.fechaActualizacion}· {fechaBonita(historia.fechaActualizacion)}{/if}
            </p>
          </div>
        {/if}
      </GlassCard>
    {/if}
  </div>
</div>