<!-- src/lib/features/auth/RecuperarScreen.svelte -->
<script lang="ts">
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let email = $state('');
  let enviado = $state(false);

  const emailValid = $derived(/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email));
  const canSubmit = $derived(emailValid && !session.loading);

  async function handleReset() {
    if (!canSubmit) return;
    try {
      await session.resetPassword(email);
      enviado = true;
    } catch {
      // Error mostrado desde session.error
    }
  }
</script>

<div class="app-background min-h-dvh flex flex-col px-5 py-6">
  <div class="flex items-center gap-3 mb-6">
    <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
    <div class="flex-1">
      <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Recuperar</p>
      <h1 class="text-xl font-black text-white tracking-tight mt-0.5">Contraseña</h1>
    </div>
  </div>

  <div class="flex-1 flex flex-col justify-center gap-4 pb-8">
    {#if enviado}
      <div class="glass glass-gold rounded-3xl p-6 border border-dorado/40 text-center">
        <div class="w-16 h-16 rounded-full bg-dorado/20 flex items-center justify-center mx-auto mb-4">
          <Icon name="mail" size={28} class="text-dorado" />
        </div>
        <h2 class="text-lg font-black text-white mb-2">Email enviado</h2>
        <p class="text-sm text-white/70 leading-relaxed mb-6">
          Revisa tu bandeja de entrada en <strong class="text-dorado">{email}</strong>.
          Si no lo ves, revisa spam.
        </p>
        <GlassButton variant="primary" fullWidth onTap={() => router.back()}>
          Volver al login
        </GlassButton>
      </div>
    {:else}
      <div class="text-center mb-4">
        <div class="w-20 h-20 rounded-full bg-dorado/15 flex items-center justify-center mx-auto mb-4">
          <Icon name="lock" size={32} class="text-dorado" />
        </div>
        <h2 class="text-lg font-black text-white mb-2">¿Olvidaste tu contraseña?</h2>
        <p class="text-sm text-white/50 leading-relaxed">
          Escribe tu email y te enviaremos un enlace para recuperarla.
        </p>
      </div>

      <GlassInput bind:value={email} label="Email" placeholder="tu@email.com" icon="mail" type="email" success={emailValid} onEnter={handleReset} />

      {#if session.error}
        <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
          <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
          <p class="text-xs text-red-300">{session.error}</p>
        </div>
      {/if}

      <GlassButton variant="primary" fullWidth icon="send" loading={session.loading} disabled={!canSubmit} onTap={handleReset}>
        Enviar enlace
      </GlassButton>
    {/if}
  </div>
</div>