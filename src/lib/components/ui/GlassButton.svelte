<!-- src/lib/components/ui/GlassButton.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import Icon from './Icon.svelte';

  interface Props {
    variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
    icon?: string;
    iconRight?: string;
    loading?: boolean;
    disabled?: boolean;
    fullWidth?: boolean;
    onTap?: () => void;
    children?: Snippet;
    class?: string;
  }

  let {
    variant = 'primary',
    icon,
    iconRight,
    loading = false,
    disabled = false,
    fullWidth = false,
    onTap,
    children,
    class: className = ''
  }: Props = $props();

  const variantClass: Record<string, string> = {
    primary: 'bg-gradient-to-br from-granate to-granate-dark text-dorado border border-dorado/30 shadow-lg shadow-granate/40',
    secondary: 'glass text-dorado',
    ghost: 'bg-transparent text-dorado',
    danger: 'bg-gradient-to-br from-red-600 to-red-800 text-white border border-red-400/30 shadow-lg shadow-red-900/40'
  };

  const isDisabled = $derived(disabled || loading);
</script>

<button
  type="button"
  onclick={onTap}
  disabled={isDisabled}
  class="
    relative overflow-hidden rounded-full
    h-[52px] px-6 flex items-center justify-center gap-2
    font-bold tracking-[0.15em] text-sm uppercase
    transition-all duration-150 active:scale-[0.96]
    {variantClass[variant]}
    {fullWidth ? 'w-full' : ''}
    {isDisabled ? 'opacity-50 pointer-events-none' : ''}
    {className}
  "
>
  {#if loading}
    <span class="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin"></span>
  {:else if icon}
    <Icon name={icon} size={18} />
  {/if}

  {#if children}
    {@render children()}
  {/if}

  {#if iconRight && !loading}
    <Icon name={iconRight} size={18} />
  {/if}
</button>