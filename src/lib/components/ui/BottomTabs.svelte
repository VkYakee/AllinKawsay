<!-- src/lib/components/ui/BottomTabs.svelte -->
<script lang="ts">
  import Icon from './Icon.svelte';

  export interface TabItem {
    id: string;
    icon: string;
    activeIcon: string;
    label: string;
    badge?: number;
  }

  interface Props {
    tabs: TabItem[];
    active: string;
    onTap: (id: string) => void;
  }

  let { tabs, active, onTap }: Props = $props();

  const activeIndex = $derived(Math.max(0, tabs.findIndex((t) => t.id === active)));
</script>

<nav
  class="fixed bottom-0 left-0 right-0 z-50 px-4 pt-2 pointer-events-none"
  style="padding-bottom: calc(1rem + env(safe-area-inset-bottom, 0px));"
>
  <div
    class="glass glass-strong rounded-full h-[68px] p-1.5 pointer-events-auto shadow-2xl shadow-black/70"
  >
    <div class="relative w-full h-full">
      <div
        class="absolute top-0 bottom-0 pointer-events-none"
        style="
          width: calc(100% / {tabs.length});
          transform: translateX(calc({activeIndex} * 100%));
          transition: transform 420ms cubic-bezier(0.34, 1.56, 0.64, 1);
        "
      >
        <div
          class="absolute inset-1 rounded-full bg-gradient-to-br from-granate to-granate-dark shadow-lg shadow-granate/50"
        ></div>
      </div>

      <div class="relative flex h-full">
        {#each tabs as tab}
          {@const isActive = tab.id === active}
          <button
            type="button"
            onclick={() => onTap(tab.id)}
            class="flex-1 h-full flex flex-col items-center justify-center gap-0.5 transition-transform active:scale-90"
          >
            <div class="relative">
              <Icon
                name={isActive ? tab.activeIcon : tab.icon}
                size={22}
                class={isActive ? 'text-dorado' : 'text-white/50'}
              />
              {#if tab.badge && tab.badge > 0}
                <span
                  class="absolute -top-1 -right-1.5 min-w-[16px] h-[16px] px-1 rounded-full bg-red-500 text-white text-[9px] font-bold flex items-center justify-center ring-2 ring-[#12100F]"
                >
                  {tab.badge > 9 ? '9+' : tab.badge}
                </span>
              {/if}
            </div>
            <span
              class="text-[9px] font-bold tracking-[0.12em] uppercase transition-colors {isActive
                ? 'text-dorado'
                : 'text-white/45'}"
            >
              {tab.label}
            </span>
          </button>
        {/each}
      </div>
    </div>
  </div>
</nav>