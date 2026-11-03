<!-- src/lib/components/ui/GlassIconButton.svelte -->
<script lang="ts">
  import Icon from './Icon.svelte';

  interface Props {
    icon: string;
    variant?: 'default' | 'gold' | 'granate';
    size?: 'sm' | 'md' | 'lg';
    onTap?: () => void;
    class?: string;
  }

  let {
    icon,
    variant = 'default',
    size = 'md',
    onTap,
    class: className = ''
  }: Props = $props();

  const sizeClass = {
    sm: 'w-9 h-9',
    md: 'w-11 h-11',
    lg: 'w-[52px] h-[52px]'
  };

  const iconSize = {
    sm: 16,
    md: 20,
    lg: 24
  };

  const variantClass = {
    default: 'glass text-dorado',
    gold: 'glass glass-gold text-dorado',
    granate: 'glass glass-granate text-dorado'
  };
</script>

<button
  type="button"
  onclick={onTap}
  class="
    {sizeClass[size]} {variantClass[variant]}
    rounded-full flex items-center justify-center
    transition-all duration-150 active:scale-90
    {className}
  "
>
  <Icon name={icon} size={iconSize[size]} />
</button>