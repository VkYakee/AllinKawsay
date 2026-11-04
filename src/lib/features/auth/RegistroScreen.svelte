<!-- src/lib/features/auth/RegistroScreen.svelte -->
<script lang="ts">
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassInput from '../../components/ui/GlassInput.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let nombre = $state('');
  let email = $state('');
  let password = $state('');
  let password2 = $state('');

  const nombreValid = $derived(nombre.trim().length >= 3);
  const emailValid = $derived(/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email));
  const passValid = $derived(password.length >= 6);
  const pass2Valid = $derived(password2.length > 0 && password === password2);
  const canSubmit = $derived(
    nombreValid && emailValid && passValid && pass2Valid && !session.loading
  );

  async function handleRegistro() {
    if (!canSubmit) return;
    try {
      await session.registrar(email, password, nombre);
      router.replace('verificacion');
    } catch {
      // Error mostrado desde session.error
    }
  }
</script>

<div class="app-background min-h-dvh flex flex-col px-5 py-6">
  <div class="flex items-center gap-3 mb-6">
    <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
    <div class="flex-1">
      <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Cuenta nueva</p>
      <h1 class="text-xl font-black text-white tracking-tight mt-0.5">Registrarse</h1>
    </div>
  </div>

  <div class="flex-1 flex flex-col justify-center gap-4 pb-8">
    <div class="text-center mb-2">
      <div class="relative inline-block mb-4">
        <div class="absolute inset-0 rounded-full bg-dorado blur-2xl opacity-30"></div>
        <div class="glass glass-gold relative w-20 h-20 rounded-full flex items-center justify-center">
          <span class="text-2xl font-black text-dorado">AK</span>
        </div>
      </div>
      <h2 class="text-xl font-black text-dorado tracking-[0.25em]">ALLIN KAWSAY</h2>
      <p class="text-white/50 text-[10px] tracking-[0.3em] mt-2 uppercase">Únete al grupo</p>
    </div>

    <GlassInput bind:value={nombre} label="Nombre completo" placeholder="Juan Pérez" icon="user" success={nombreValid} />
    <GlassInput bind:value={email} label="Email" placeholder="tu@email.com" icon="mail" type="email" success={emailValid} />
    <GlassInput bind:value={password} label="Contraseña" placeholder="Mínimo 6 caracteres" icon="lock" type="password" success={passValid} />
    <GlassInput bind:value={password2} label="Repetir contraseña" placeholder="Confirma tu contraseña" icon="lock" type="password" success={pass2Valid} error={password2 && !pass2Valid ? 'Las contraseñas no coinciden' : undefined} />

    {#if session.error}
      <div class="glass rounded-2xl p-3 border border-red-500/40 flex items-center gap-2">
        <Icon name="alert-circle" size={16} class="text-red-400 shrink-0" />
        <p class="text-xs text-red-300">{session.error}</p>
      </div>
    {/if}

    <GlassButton variant="primary" fullWidth icon="user-plus" loading={session.loading} disabled={!canSubmit} onTap={handleRegistro}>
      Crear cuenta
    </GlassButton>

    <p class="text-center text-[10px] text-white/40 leading-relaxed">
      Al registrarte aceptas que eres miembro o simpatizante del grupo
    </p>
  </div>
</div>