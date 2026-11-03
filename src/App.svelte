<!-- src/App.svelte -->
<script lang="ts">
  let count = $state(0);
</script>

<main class="min-h-dvh bg-bg text-white flex flex-col items-center justify-center p-6">
  <div class="w-32 h-32 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center mb-8 shadow-[0_0_60px_rgba(245,208,97,0.35)]">
    <span class="text-5xl font-black text-granate-dark tracking-tight">AK</span>
  </div>

  <h1 class="text-3xl font-black text-dorado tracking-[0.4em]">ALLIN KAWSAY</h1>
  <p class="text-white/40 mt-3 text-xs tracking-[0.3em]">RUST REWRITE · v3.0</p>

  <button
    onclick={() => count++}
    class="mt-12 px-8 py-4 rounded-full bg-granate text-dorado font-bold tracking-[0.2em] active:scale-95 transition-transform shadow-lg shadow-granate/50"
  >
    TOCAR · {count}
  </button>

  <p class="mt-8 text-xs text-white/30 tracking-wider">Svelte 5 · Tailwind 4 · Tauri 2</p>
</main>