<!-- src/lib/features/auth/VerificacionScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { session } from '../../stores/session.svelte';
  import { router } from '../../stores/router.svelte';

  let reenviando = $state(false);
  let verificando = $state(false);
  let cooldown = $state(0);
  let interval: ReturnType<typeof setInterval> | null = null;

  onMount(() => {
    iniciarCooldown(60);
    return () => { if (interval) clearInterval(interval); };
  });

  function iniciarCooldown(segundos: number) {
    cooldown = segundos;
    if (interval) clearInterval(interval);
    interval = setInterval(() => {
      if (cooldown > 0) cooldown--;
    }, 1000);
  }

  async function reenviar() {
    if (cooldown > 0) return;
    reenviando = true;
    try {
      await session.reenviarVerificacion();
      iniciarCooldown(60);
    } catch {
      // error mostrado desde session.error
    } finally {
      reenviando = false;
    }
  }

  async function verificar() {
    verificando = true;
    try {
      const ok = await session.verificarEmail();
      if (ok) {
        router.replace('home');
      }
    } finally {
      verificando = false;
    }
  }

  async function cerrarSesion() {
    await session.logout();
    router.reset('login');
  }
</script>

<div class="app-background min-h-dvh flex flex-col px-5 py-6">
  <div class="flex-1 flex flex-col justify-center gap-6 max-w-md mx-auto w-full pb-8">
    <div class="text-center">
      <div class="relative inline-block mb-6">
        <div class="absolute inset-0 rounded-full bg-dorado blur-2xl opacity-30"></div>
        <div class="glass glass-gold relative w-24 h-24 rounded-full flex items-center justify-center">
          <Icon name="mail" size={40} class="text-dorado" />
        </div>
      </div>
      <h1 class="text-2xl font-black text-dorado tracking-[0.15em] mb-2">VERIFICA TU EMAIL</h1>
      <p class="text-sm text-white/60 leading-relaxed">
        Te enviamos un enlace a:<br/>
        <strong class="text-dorado">{session.user?.email ?? ''}</strong>
      </p>
    </div>

    <div class="glass rounded-3xl p-6 space-y-4">
      <div class="flex items-start gap-3">
        <div class="w-8 h-8 rounded-full bg-granate flex items-center justify-center text-dorado font-black text-xs shrink-0">1</div>
        <div>
          <p class="text-sm font-bold text-white">Abre tu correo</p>
          <p class="text-xs text-white/50 mt-0.5">Busca el email de Allin Kawsay</p>
        </div>
      </div>
      <div class="flex items-start gap-3">
        <div class="w-8 h-8 rounded-full bg-granate flex items-center justify-center text-dorado font-black text-xs shrink-0">2</div>
        <div>
          <p class="text-sm font-bold text-white">Toca el enlace</p>
          <p class="text-xs text-white/50 mt-0.5">"Verificar correo electrónico"</p>
        </div>
      </div>
      <div class="flex items-start gap-3">
        <div class="w-8 h-8 rounded-full bg-granate flex items-center justify-center text-dorado font-black text-xs shrink-0">3</div>
        <div>
          <p class="text-sm font-bold text-white">Vuelve aquí</p>
          <p class="text-xs text-white/50 mt-0.5">Y presiona "Ya verifiqué"</p>
        </div>
      </div>
    </div>

    <GlassButton variant="primary" fullWidth icon="check-circle" loading={verificando} onTap={verificar}>
      Ya verifiqué
    </GlassButton>

    <GlassButton variant="secondary" fullWidth icon="refresh" loading={reenviando} disabled={cooldown > 0} onTap={reenviar}>
      {cooldown > 0 ? `Reenviar en ${cooldown}s` : 'Reenviar email'}
    </GlassButton>

    <button type="button" onclick={cerrarSesion} class="text-center text-xs text-white/40 underline">
      Cerrar sesión y usar otra cuenta
    </button>
  </div>
</div>