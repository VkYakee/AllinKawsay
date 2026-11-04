<!-- src/App.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { listen } from '@tauri-apps/api/event';
  import { router } from './lib/stores/router.svelte';
  import { session } from './lib/stores/session.svelte';
  import { initOneSignal, oneSignalLogin, oneSignalLogout } from './lib/services/onesignal';

  import SplashScreen from './lib/features/splash/SplashScreen.svelte';
  import LoginScreen from './lib/features/auth/LoginScreen.svelte';
  import HomeScreen from './lib/features/home/HomeScreen.svelte';
  import CancionDetalle from './lib/features/cancionero/CancionDetalle.svelte';
  import ZamponaScreen from './lib/features/zampona/ZamponaScreen.svelte';
  import EnsayoScreen from './lib/features/ensayo/EnsayoScreen.svelte';
  import EventoDetalle from './lib/features/eventos/EventoDetalle.svelte';
  import RecuerdoDetalle from './lib/features/recuerdos/RecuerdoDetalle.svelte';
  import AdminScreen from './lib/features/admin/AdminScreen.svelte';

  let unlistenBack: (() => void) | null = null;

  onMount(async () => {
    initOneSignal();

    // Interceptar el botón atrás de Android.
    // En Tauri 2 el evento se llama "tauri://back-button".
    try {
      unlistenBack = await listen('tauri://back-button', () => {
        if (router.history.length > 0) {
          router.back();
        }
        // Si no hay historial: se permite el comportamiento nativo (cerrar app).
      });
    } catch {
      // Web sin Tauri: sin listener.
    }
  });

  onDestroy(() => {
    unlistenBack?.();
  });

  $effect(() => {
    if (session.user) {
      oneSignalLogin(session.user.uid);
    } else {
      oneSignalLogout();
    }
  });

  async function onSplashComplete() {
    await session.restore();
    router.replace(session.isLogged ? 'home' : 'login');
  }
</script>

{#if router.current === 'splash'}
  <SplashScreen onComplete={onSplashComplete} />
{:else if router.current === 'login'}
  <LoginScreen />
{:else if router.current === 'home'}
  <HomeScreen />
{:else if router.current === 'cancion'}
  <CancionDetalle id={router.params.id as string} />
{:else if router.current === 'zampona'}
  <ZamponaScreen />
{:else if router.current === 'ensayo'}
  <EnsayoScreen id={router.params.id as string} />
{:else if router.current === 'evento'}
  <EventoDetalle id={router.params.id as string} />
{:else if router.current === 'recuerdo'}
  <RecuerdoDetalle id={router.params.id as string} />
{:else if router.current === 'admin'}
  <AdminScreen />
{:else}
  <div class="app-background min-h-dvh flex items-center justify-center">
    <p class="text-white/40 text-sm tracking-wider">404</p>
  </div>
{/if}