<!-- src/lib/features/eventos/EventoCard.svelte -->
<script lang="ts">
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { diaNum, mesCorto, hora, esFuturo, type Evento } from '../../services/eventos';

  interface Props {
    evento: Evento;
    onTap: () => void;
  }

  let { evento, onTap }: Props = $props();

  const futuro = $derived(esFuturo(evento.fecha));
</script>

<GlassCard padding="md" {onTap}>
  <div class="flex items-start gap-3">
    <div
      class="shrink-0 w-16 h-16 rounded-2xl flex flex-col items-center justify-center shadow-md {futuro
        ? 'bg-gradient-to-br from-granate to-granate-dark shadow-granate/40'
        : 'bg-white/5'}"
    >
      <span class="text-xl font-black leading-none {futuro ? 'text-dorado' : 'text-white/40'}">
        {diaNum(evento.fecha)}
      </span>
      <span class="text-[9px] font-bold tracking-wider mt-1 {futuro ? 'text-dorado/80' : 'text-white/30'}">
        {mesCorto(evento.fecha)}
      </span>
    </div>

    <div class="flex-1 min-w-0">
      <p class="text-[15px] font-bold truncate leading-tight {futuro ? 'text-white' : 'text-white/50'}">
        {evento.titulo}
      </p>
      <div class="flex items-center gap-1.5 mt-1">
        <Icon name="clock" size={11} class={futuro ? 'text-dorado/70' : 'text-white/30'} />
        <span class="text-[11px] font-semibold {futuro ? 'text-dorado/80' : 'text-white/40'}">
          {hora(evento.fecha)}
        </span>
      </div>
      <div class="flex items-center gap-1 mt-1">
        <Icon name="map-pin" size={11} class="text-white/40" />
        <span class="text-[11px] text-white/50 truncate">{evento.lugar}</span>
      </div>
    </div>

    <Icon name="chevron-right" size={16} class="text-dorado/40 shrink-0 mt-2" />
  </div>
</GlassCard>