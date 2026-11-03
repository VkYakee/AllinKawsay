<!-- src/lib/features/home/HomeScreen.svelte -->
<script lang="ts">
  import BottomTabs from '../../components/ui/BottomTabs.svelte';
  import type { TabItem } from '../../components/ui/BottomTabs.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import InicioTab from './tabs/InicioTab.svelte';

  type TabId = 'inicio' | 'cancionero' | 'eventos' | 'recuerdos' | 'perfil';

  const tabs: TabItem[] = [
    { id: 'inicio', icon: 'home', activeIcon: 'home', label: 'Inicio' },
    { id: 'cancionero', icon: 'music', activeIcon: 'music', label: 'Música' },
    { id: 'eventos', icon: 'calendar', activeIcon: 'calendar', label: 'Eventos', badge: 2 },
    { id: 'recuerdos', icon: 'image', activeIcon: 'image', label: 'Recuerdos' },
    { id: 'perfil', icon: 'user', activeIcon: 'user', label: 'Perfil' }
  ];

  let activeTab = $state<TabId>('inicio');

  const placeholders: Record<Exclude<TabId, 'inicio'>, string> = {
    cancionero: 'Cancionero',
    eventos: 'Eventos',
    recuerdos: 'Recuerdos',
    perfil: 'Perfil'
  };
</script>

<div class="app-background min-h-dvh">
  {#if activeTab === 'inicio'}
    <InicioTab />
  {:else}
    <div class="min-h-[70dvh] flex flex-col items-center justify-center px-8 text-center">
      <div class="glass w-24 h-24 rounded-full flex items-center justify-center mb-6">
        <Icon name="sparkles" size={36} class="text-dorado" />
      </div>
      <h2 class="text-2xl font-black text-dorado tracking-tight">
        {placeholders[activeTab]}
      </h2>
      <p class="text-white/40 text-sm mt-2">Próximamente</p>
    </div>
  {/if}

  <BottomTabs
    {tabs}
    active={activeTab}
    onTap={(id) => activeTab = id as TabId}
  />
</div>