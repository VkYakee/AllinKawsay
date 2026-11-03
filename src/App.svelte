<!-- src/App.svelte -->
<script lang="ts">
  let count = $state(0);
</script>

<div class="app-background flex flex-col items-center justify-center p-6">
  <!-- Logo flotante con glow -->
  <div class="relative mb-8">
    <div class="absolute inset-0 rounded-full bg-dorado blur-3xl opacity-40"></div>
    <div class="glass glass-gold relative w-32 h-32 rounded-full flex items-center justify-center">
      <span class="text-4xl font-black text-dorado tracking-tighter">AK</span>
    </div>
  </div>

  <h1 class="text-3xl font-black text-dorado tracking-[0.4em]">ALLIN KAWSAY</h1>
  <p class="text-white/40 mt-3 text-[10px] tracking-[0.4em] font-semibold">LIQUID GLASS · v3.0</p>

  <div class="glass glass-strong mt-12 px-8 py-6 rounded-3xl w-full max-w-sm">
    <p class="text-white/70 text-sm text-center leading-relaxed">
      Esta tarjeta usa <span class="text-dorado font-bold">Liquid Glass</span> real:
      blur, saturación, especularidad y bordes internos de luz.
    </p>
  </div>

  <button
    onclick={() => count++}
    class="glass glass-granate glass-button mt-8 px-10 py-4 rounded-full text-dorado font-bold tracking-[0.2em]"
  >
    TOCAR · {count}
  </button>

  <p class="mt-8 text-[10px] text-white/30 tracking-wider">Svelte 5 · Tailwind 4 · Tauri 2 · Rust</p>
</div>