<!-- src/lib/features/admin/EditorLetra.svelte -->
<script lang="ts">
  interface Props {
    letra: string;
    onCambio: (letra: string) => void;
  }

  let { letra = $bindable(''), onCambio }: Props = $props();
</script>

<div class="glass rounded-2xl border border-white/10">
  <textarea
    bind:value={letra}
    oninput={() => onCambio(letra)}
    rows="8"
    placeholder="Escribe la letra de la canción...&#10;&#10;Usa líneas en blanco para separar estrofas."
    class="w-full bg-transparent outline-none text-sm text-white placeholder:text-white/30 p-4 resize-none"
  ></textarea>
</div>