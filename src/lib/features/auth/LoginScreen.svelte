<!-- src/lib/features/auth/LoginScreen.svelte -->
<script lang="ts">
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let email = $state('');
  let password = $state('');
  let error = $state('');

  const emailValid = $derived(/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email));
  const passValid = $derived(password.length >= 4);
  const canSubmit = $derived(emailValid && passValid && !session.loading);

  async function handleLogin() {
    if (!canSubmit) return;
    error = '';
    try {
      await session.login(email, password);
      router.replace('home');
    } catch (e) {
      error = e instanceof Error ? e.message : 'Error al ingresar';
    }
  }
</script>

<div class="app-background min-h-dvh flex flex-col px-6 pt-12 pb-8">
  <!-- Logo + título -->
  <div class="flex-1 flex flex-col items-center justify-center">
    <div class="relative mb-8">
      <div class="absolute inset-0 rounded-full bg-dorado blur-3xl opacity-30"></div>
      <div class="glass glass-gold relative w-28 h-28 rounded-full flex items-center justify-center">
        <span class="text-3xl font-black text-dorado tracking-tighter">AK</span>
      </div>
    </div>

    <h1 class="text-2xl font-black text-dorado tracking-[0.35em]">ALLIN KAWSAY</h1>
    <p class="text-white/40 mt-3 text-[10px] tracking-[0.4em] font-semibold uppercase">
      Inicia sesión
    </p>
  </div>

  <!-- Formulario -->
  <div class="space-y-4 pb-4">
    <GlassInput
      bind:value={email}
      label="Email"
      placeholder="tu@email.com"
      icon="mail"
      type="email"
      success={emailValid}
      onEnter={handleLogin}
    />

    <GlassInput
      bind:value={password}
      label="Contraseña"
      placeholder="••••••••"
      icon="lock"
      type="password"
      success={passValid}
      onEnter={handleLogin}
    />

    {#if error}
      <div class="glass rounded-xl p-3 border border-red-500/30 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{error}</p>
      </div>
    {/if}

    <div class="pt-2">
      <GlassButton
        variant="primary"
        fullWidth
        icon="log-in"
        loading={session.loading}
        disabled={!canSubmit}
        onTap={handleLogin}
      >
        Ingresar
      </GlassButton>
    </div>

    <div class="flex items-center gap-3 py-2">
      <div class="flex-1 h-px bg-white/10"></div>
      <span class="text-[10px] text-white/40 tracking-[0.2em] font-semibold">O</span>
      <div class="flex-1 h-px bg-white/10"></div>
    </div>

    <GlassButton variant="secondary" fullWidth icon="google" onTap={() => {}}>
      Continuar con Google
    </GlassButton>

    <p class="text-center text-[10px] text-white/30 tracking-[0.2em] pt-4 uppercase">
      Hecho para el grupo · v3.0
    </p>
  </div>
</div>