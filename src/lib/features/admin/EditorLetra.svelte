<!-- src/lib/features/admin/EditorLetra.svelte -->
<script lang="ts">
  interface Props {
    letra: string;
    onCambio: (letra: string) => void;
  }

  let { letra = $bindable(''), onCambio }: Props = $props();

  let cantidadLineas = $derived(letra.length ? letra.split('\\n').length : 0);
  let cantidadPalabras = $derived(
    letra.trim() ? letra.trim().split(/\\s+/).length : 0
  );
</script>

<div class="glass rounded-2xl border border-white/10 focus-within:border-dorado/40 transition-colors overflow-hidden">
  <div class="flex items-center justify-between gap-3 px-4 pt-3">
    <span class="text-[10px] font-bold tracking-[0.18em] text-dorado/70 uppercase">Letra de la canción</span>
    <span class="text-[10px] text-white/40 tabular-nums">
      {cantidadLineas} líneas · {cantidadPalabras} palabras
    </span>
  </div>
  <textarea
    bind:value={letra}
    oninput={() => onCambio(letra)}
    rows="10"
    aria-label="Letra de la canción"
    placeholder="Escribe la letra de la canción...&#10;&#10;Deja una línea en blanco para separar las estrofas."
    class="w-full min-h-[220px] bg-transparent outline-none text-sm leading-relaxed text-white placeholder:text-white/30 p-4 resize-y"
  ></textarea>
</div>