<!-- src/App.svelte -->
<script lang="ts">
  import { router } from './lib/stores/router.svelte';
  import { session } from './lib/stores/session.svelte';
  import SplashScreen from './lib/features/splash/SplashScreen.svelte';
  import LoginScreen from './lib/features/auth/LoginScreen.svelte';
  import HomeScreen from './lib/features/home/HomeScreen.svelte';

  function onSplashComplete() {
    router.replace(session.isLogged ? 'home' : 'login');
  }
</script>

{#if router.current === 'splash'}
  <SplashScreen onComplete={onSplashComplete} />
{:else if router.current === 'login'}
  <LoginScreen />
{:else if router.current === 'home'}
  <HomeScreen />
{:else}
  <div class="app-background min-h-dvh flex items-center justify-center">
    <p class="text-white/40 text-sm tracking-wider">404</p>
  </div>
{/if}