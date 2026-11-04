<!-- src/lib/components/ui/GlassCard.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    variant?: 'default' | 'strong' | 'granate' | 'gold';
    padding?: 'none' | 'sm' | 'md' | 'lg' | 'xl';
    onTap?: () => void;
    class?: string;
    children: Snippet;
  }

  let {
    variant = 'default',
    padding = 'lg',
    onTap,
    class: className = '',
    children
  }: Props = $props();

  const variantClass: Record<string, string> = {
    default: '',
    strong: 'glass-strong',
    granate: 'glass-granate',
    gold: 'glass-gold'
  };

  const paddingClass: Record<string, string> = {
    none: '',
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-5',
    xl: 'p-6'
  };

  const baseClass = $derived(
    `glass ${variantClass[variant]} ${paddingClass[padding]} rounded-3xl ${onTap ? 'glass-button text-left w-full' : ''} ${className}`
  );
</script>

{#if onTap}
  <button type="button" onclick={onTap} class={baseClass}>
    {@render children()}
  </button>
{:else}
  <div class={baseClass}>
    {@render children()}
  </div>
{/if}