<!-- src/lib/features/update/ActualizacionDialog.svelte -->
<script lang="ts">
  import GlassButton from '../../components/ui/GlassButton.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import type { InfoVersion } from '../../services/update';

  interface Props {
    info: InfoVersion;
    onCerrar: () => void;
  }

  let { info, onCerrar }: Props = $props();

  function descargar() {
    let destino: URL;
    try {
      destino = new URL(info.url);
    } catch {
      console.warn('URL de actualización inválida');
      return;
    }
    if (destino.protocol !== 'https:' || !destino.hostname || destino.username || destino.password) {
      console.warn('Se bloqueó una URL de actualización no segura');
      return;
    }
    window.open(destino.href, '_blank', 'noopener,noreferrer');
    onCerrar();
  }
</script>

<div
  class="fixed inset-0 z-[100] bg-black/80 backdrop-blur-sm flex items-center justify-center p-6"
  role="presentation"
>
  <div class="glass glass-strong rounded-3xl p-6 max-w-sm w-full border border-dorado/40">
    <div class="w-16 h-16 rounded-full bg-dorado/25 flex items-center justify-center mx-auto mb-4">
      <Icon name="download" size={28} class="text-dorado" />
    </div>
    <h2 class="text-xl font-black text-dorado text-center mb-2">
      {info.critica ? 'Actualización obligatoria' : 'Nueva versión disponible'}
    </h2>
    <p class="text-sm text-white/70 text-center mb-2">v{info.version}</p>
    {#if info.notas}
      <p class="text-xs text-white/60 text-center mb-4 leading-relaxed">{info.notas}</p>
    {/if}
    <div class="space-y-2 mt-4">
      <GlassButton variant="primary" fullWidth icon="download" onTap={descargar}>
        Descargar ahora
      </GlassButton>
      {#if !info.critica}
        <GlassButton variant="ghost" fullWidth onTap={onCerrar}>
          Más tarde
        </GlassButton>
      {/if}
    </div>
  </div>
</div>