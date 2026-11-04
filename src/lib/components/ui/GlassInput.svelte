<!-- src/lib/components/ui/GlassInput.svelte -->
<script lang="ts">
  import Icon from './Icon.svelte';

  interface Props {
    value?: string;
    label?: string;
    placeholder?: string;
    icon?: string;
    type?: 'text' | 'email' | 'password' | 'number' | 'url' | 'tel' | 'date' | 'time';
    error?: string;
    success?: boolean;
    disabled?: boolean;
    maxlength?: number;
    autofocus?: boolean;
    onInput?: (value: string) => void;
    onEnter?: () => void;
    class?: string;
  }

  let {
    value = $bindable(''),
    label,
    placeholder = '',
    icon,
    type = 'text',
    error,
    success = false,
    disabled = false,
    maxlength,
    autofocus = false,
    onInput,
    onEnter,
    class: className = ''
  }: Props = $props();

  const uid = `gi-${Math.random().toString(36).slice(2, 9)}`;
  let focused = $state(false);
  let showPassword = $state(false);
  let inputEl: HTMLInputElement | undefined = $state(undefined);

  const inputType = $derived(type === 'password' && showPassword ? 'text' : type);

  const borderClass = $derived(
    error
      ? 'border-red-500/60 shadow-[0_0_20px_rgba(239,68,68,0.15)]'
      : success
        ? 'border-dorado/70 shadow-[0_0_20px_rgba(245,208,97,0.18)]'
        : focused
          ? 'border-dorado/60 shadow-[0_0_20px_rgba(245,208,97,0.12)]'
          : 'border-white/10'
  );

  function handleInput(e: Event) {
    const target = e.target as HTMLInputElement;
    value = target.value;
    onInput?.(value);
  }

  function handleKey(e: KeyboardEvent) {
    if (e.key === 'Enter') onEnter?.();
  }

  $effect(() => {
    if (autofocus && inputEl) inputEl.focus();
  });
</script>

<div class="flex flex-col gap-1.5 {className}">
  {#if label}
    <label
      for={uid}
      class="text-[11px] font-semibold tracking-[0.15em] uppercase text-dorado/80 px-1"
    >
      {label}
    </label>
  {/if}

  <div class="glass rounded-2xl {borderClass} transition-all duration-200">
    <div class="flex items-center gap-2 px-4 h-14">
      {#if icon}
        <Icon name={icon} size={18} class="text-dorado/80 shrink-0" />
      {/if}

      <input
        bind:this={inputEl}
        id={uid}
        type={inputType}
        {value}
        {placeholder}
        {disabled}
        {maxlength}
        oninput={handleInput}
        onkeydown={handleKey}
        onfocus={() => focused = true}
        onblur={() => focused = false}
        class="flex-1 bg-transparent outline-none text-[15px] text-white placeholder:text-white/30 font-medium"
      />

      {#if type === 'password'}
        <button
          type="button"
          onclick={() => showPassword = !showPassword}
          class="text-dorado/80 active:scale-90 transition-transform"
        >
          <Icon name={showPassword ? 'eye-off' : 'eye'} size={18} />
        </button>
      {:else if success}
        <Icon name="check-circle" size={18} class="text-dorado" />
      {:else if error}
        <Icon name="alert-circle" size={18} class="text-red-400" />
      {/if}
    </div>
  </div>

  {#if error}
    <p class="text-[11px] text-red-400 px-1 font-medium">{error}</p>
  {/if}
</div>