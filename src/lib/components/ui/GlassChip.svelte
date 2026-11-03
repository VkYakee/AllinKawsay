<!-- src/lib/components/ui/GlassChip.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import Icon from './Icon.svelte';

  interface Props {
    selected?: boolean;
    icon?: string;
    variant?: 'default' | 'gold' | 'granate';
    onTap?: () => void;
    children: Snippet;
  }

  let {
    selected = false,
    icon,
    variant = 'default',
    onTap,
    children
  }: Props = $props();

  const selectedClass = $derived(
    selected
      ? variant === 'gold'
        ? 'bg-gradient-to-r from-dorado to-dorado-dark text-granate-dark border border-dorado shadow-lg shadow-dorado/30'
        : variant === 'granate'
          ? 'bg-gradient-to-r from-granate to-granate-dark text-dorado border border-dorado/40 shadow-lg shadow-granate/40'
          : 'glass glass-gold text-dorado'
      : 'glass text-white/70'
  );
</script>

<button
  type="button"
  onclick={onTap}
  class="
    inline-flex items-center gap-1.5 px-3.5 h-9 rounded-full
    text-[12px] font-semibold tracking-wide
    transition-all duration-150 active:scale-95
    {selectedClass}
  "
>
  {#if icon}
    <Icon name={icon} size={14} />
  {/if}
  {@render children()}
</button>