<!-- src/lib/features/splash/SplashScreen.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';

  interface Props {
    onComplete: () => void;
  }

  let { onComplete }: Props = $props();

  let progress = $state(0);
  let visible = $state(false);

  onMount(() => {
    const t = setTimeout(() => (visible = true), 80);
    const start = Date.now();
    const duration = 2000;
    const interval = setInterval(() => {
      progress = Math.min(1, (Date.now() - start) / duration);
      if (progress >= 1) {
        clearInterval(interval);
        setTimeout(() => onComplete(), 200);
      }
    }, 30);
    return () => {
      clearTimeout(t);
      clearInterval(interval);
    };
  });
</script>

<div class="app-background min-h-dvh flex flex-col items-center justify-center px-6 relative overflow-hidden">
  <!-- Logo con glow -->
  <div
    class="relative mb-10 transition-all duration-700"
    class:opacity-100={visible}
    class:scale-100={visible}
    class:opacity-0={!visible}
    class:scale-75={!visible}
  >
    <div class="absolute inset-0 rounded-full bg-dorado blur-3xl opacity-40 animate-pulse"></div>
    <div class="glass glass-gold relative w-32 h-32 rounded-full flex items-center justify-center">
      <span class="text-4xl font-black text-dorado tracking-tighter">AK</span>
    </div>
  </div>

  <h1
    class="text-3xl font-black text-dorado tracking-[0.4em] transition-all duration-700 delay-200"
    class:opacity-100={visible}
    class:translate-y-0={visible}
    class:opacity-0={!visible}
    class:translate-y-4={!visible}
  >
    ALLIN KAWSAY
  </h1>
  <p
    class="text-white/40 mt-3 text-[10px] tracking-[0.4em] font-semibold uppercase transition-all duration-700 delay-300"
    class:opacity-100={visible}
    class:opacity-0={!visible}
  >
    C.I.A.C. · Juliaca · Perú
  </p>

  <!-- Barra de carga -->
  <div class="absolute left-0 right-0 bottom-16 px-12">
    <div class="h-1 rounded-full bg-white/10 overflow-hidden">
      <div
        class="h-full bg-gradient-to-r from-dorado to-dorado-dark"
        style="width: {progress * 100}%; transition: width 80ms linear;"
      ></div>
    </div>
    <p class="text-center text-[9px] text-white/30 tracking-[0.3em] mt-3 uppercase">
      v3.0 · RUST EDITION
    </p>
  </div>
</div>