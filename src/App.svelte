<!-- src/App.svelte -->
<script lang="ts">
  import {
    GlassCard,
    GlassButton,
    GlassInput,
    GlassChip,
    GlassIconButton,
    GlassAppBar,
    Icon
  } from './lib/components/ui';

  let email = $state('');
  let password = $state('');
  let taps = $state(0);

  const chips = ['Huayño', 'Carnaval', 'Qhapaq Qolla'];
  let selectedChip = $state('Huayño');
</script>

<div class="app-background min-h-dvh pb-10">
  <GlassAppBar
    title="Allin Kawsay"
    subtitle="LIQUID GLASS · v3.0"
  >
    {#snippet actions()}
      <GlassIconButton icon="bell" size="sm" />
      <GlassIconButton icon="settings" size="sm" />
    {/snippet}
  </GlassAppBar>

  <div class="px-5 py-6 space-y-5">
    <GlassCard variant="granate" padding="xl">
      <div class="flex items-center gap-4">
        <div class="w-16 h-16 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shadow-lg shadow-dorado/40">
          <Icon name="piano" size={28} class="text-granate-dark" />
        </div>
        <div class="flex-1">
          <p class="text-[10px] text-dorado/70 tracking-[0.2em] font-bold">INSTRUMENTO</p>
          <p class="text-2xl font-black text-white tracking-tight">Zampoña</p>
          <p class="text-xs text-white/50 mt-0.5">13 cañas · 2 filas</p>
        </div>
      </div>
    </GlassCard>

    <GlassCard variant="gold" padding="lg">
      <p class="text-[10px] text-dorado tracking-[0.2em] font-bold mb-1">NUEVO</p>
      <p class="text-lg font-bold text-white">Aprende tu primera canción</p>
      <p class="text-xs text-white/50 mt-1">Modo ensayo guiado paso a paso</p>
    </GlassCard>

    <div class="flex flex-wrap gap-2">
      {#each chips as chip}
        <GlassChip
          selected={selectedChip === chip}
          variant="granate"
          icon={selectedChip === chip ? 'check' : 'music'}
          onTap={() => selectedChip = chip}
        >
          {chip}
        </GlassChip>
      {/each}
    </div>

    <GlassInput
      bind:value={email}
      label="Email"
      placeholder="tu@email.com"
      icon="mail"
      type="email"
    />

    <GlassInput
      bind:value={password}
      label="Contraseña"
      placeholder="••••••••"
      icon="lock"
      type="password"
    />

    <GlassButton
      variant="primary"
      fullWidth
      icon="log-in"
      onTap={() => taps++}
    >
      Ingresar
    </GlassButton>

    <GlassButton variant="secondary" fullWidth icon="google">
      Continuar con Google
    </GlassButton>

    <div class="grid grid-cols-3 gap-2 pt-2">
      <div class="flex justify-center"><GlassIconButton icon="home" variant="gold" size="lg" /></div>
      <div class="flex justify-center"><GlassIconButton icon="heart" variant="granate" size="lg" /></div>
      <div class="flex justify-center"><GlassIconButton icon="share" size="lg" /></div>
    </div>

    <p class="text-center text-xs text-white/30 pt-4">Taps en Ingresar: {taps}</p>
  </div>
</div>