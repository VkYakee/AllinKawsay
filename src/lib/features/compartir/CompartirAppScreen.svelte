<!-- src/lib/features/compartir/CompartirAppScreen.svelte -->
<script lang="ts">
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import GlassIconButton from '../../components/ui/GlassIconButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { router } from '../../stores/router.svelte';

  const URL_DESCARGA = 'https://github.com/VkYakee/AllinKawsay/releases/latest';
  const QR_URL = `https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=${encodeURIComponent(URL_DESCARGA)}&bgcolor=FFFFFF&color=8B1A2B`;

  let copiado = $state(false);

  async function copiarEnlace() {
    try {
      await navigator.clipboard.writeText(URL_DESCARGA);
      copiado = true;
      setTimeout(() => (copiado = false), 2000);
    } catch {}
  }

  function compartirWhatsApp() {
    const texto = `📲 Descarga la app oficial de Allin Kawsay:\n\n${URL_DESCARGA}\n\nEl cancionero, la zampoña y la historia del grupo. 🎶`;
    window.open(`https://wa.me/?text=${encodeURIComponent(texto)}`, '_blank');
  }

  function compartirNativo() {
    if (navigator.share) {
      navigator.share({
        title: 'Allin Kawsay',
        text: 'La app oficial del grupo',
        url: URL_DESCARGA
      }).catch(() => {});
    } else {
      compartirWhatsApp();
    }
  }
</script>

<div class="app-background min-h-dvh">
  <header class="sticky top-0 z-30 px-5 pt-3 pb-3 bg-[#12100F]/85 backdrop-blur-xl border-b border-white/5">
    <div class="flex items-center gap-3">
      <GlassIconButton icon="chevron-left" onTap={() => router.back()} />
      <div class="flex-1 min-w-0">
        <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase">Compartir</p>
        <p class="text-sm font-bold text-white truncate mt-0.5">App Allin Kawsay</p>
      </div>
    </div>
  </header>

  <div class="px-5 py-6 pb-32 space-y-4">
    <GlassCard variant="granate" padding="xl">
      <div class="text-center">
        <div class="w-16 h-16 rounded-full bg-dorado/25 flex items-center justify-center mx-auto mb-3">
          <Icon name="share" size={28} class="text-dorado" />
        </div>
        <h2 class="text-lg font-black text-white mb-1">Invita al grupo</h2>
        <p class="text-xs text-white/60 leading-relaxed">
          Comparte la app con otros miembros, amigos o simpatizantes.
        </p>
      </div>
    </GlassCard>

    <GlassCard padding="xl">
      <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase text-center mb-4">
        Escanea el código QR
      </p>
      <div class="bg-white p-3 rounded-2xl mx-auto w-fit">
        <img
          src={QR_URL}
          alt="QR Allin Kawsay"
          class="w-56 h-56 block"
          loading="eager"
        />
      </div>
      <p class="text-[11px] text-white/40 text-center mt-3">
        Apunta la cámara del celular al código
      </p>
    </GlassCard>

    <div class="space-y-2">
      <GlassButton variant="primary" fullWidth icon="share" onTap={compartirNativo}>
        Compartir con amigos
      </GlassButton>

      <GlassButton variant="secondary" fullWidth icon="chat" onTap={compartirWhatsApp}>
        Compartir por WhatsApp
      </GlassButton>

      <GlassButton
        variant={copiado ? 'primary' : 'secondary'}
        fullWidth
        icon={copiado ? 'check' : 'copy'}
        onTap={copiarEnlace}
      >
        {copiado ? 'Enlace copiado' : 'Copiar enlace'}
      </GlassButton>
    </div>

    <GlassCard padding="md">
      <p class="text-[10px] text-dorado/70 tracking-[0.25em] font-bold uppercase mb-2">
        Enlace directo
      </p>
      <p class="text-[11px] text-white/60 font-mono break-all leading-relaxed">
        {URL_DESCARGA}
      </p>
    </GlassCard>
  </div>
</div>