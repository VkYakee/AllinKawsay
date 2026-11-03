<!-- src/lib/components/ui/GlassAppBar.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import Icon from './Icon.svelte';

  interface Props {
    title: string;
    subtitle?: string;
    showBack?: boolean;
    onBack?: () => void;
    actions?: Snippet;
    sticky?: boolean;
  }

  let {
    title,
    subtitle,
    showBack = false,
    onBack,
    actions,
    sticky = true
  }: Props = $props();
</script>

<header
  class="
    {sticky ? 'sticky top-0 z-40' : ''}
    w-full px-5 pt-3 pb-4
    bg-[#0A0A0A]/70 backdrop-blur-xl
    border-b border-white/5
  "
>
  <div class="flex items-center gap-3 min-h-[56px]">
    {#if showBack}
      <button
        type="button"
        onclick={onBack}
        class="glass w-10 h-10 rounded-full flex items-center justify-center text-dorado active:scale-90 transition-transform shrink-0"
      >
        <Icon name="chevron-left" size={20} />
      </button>
    {/if}

    <div class="flex-1 min-w-0">
      <h1 class="text-[22px] font-extrabold text-dorado tracking-tight truncate leading-tight">
        {title}
      </h1>
      {#if subtitle}
        <p class="text-[11px] text-white/50 font-medium tracking-wider truncate mt-0.5">
          {subtitle}
        </p>
      {/if}
    </div>

    {#if actions}
      <div class="flex items-center gap-2 shrink-0">
        {@render actions()}
      </div>
    {/if}
  </div>
</header>