<!-- src/lib/features/cancionero/ComentariosSection.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import GlassCard from '../../components/ui/GlassCard.svelte';
  import Icon from '../../components/ui/Icon.svelte';
  import { comentariosService, type Comentario } from '../../services/comentarios';
  import { session } from '../../stores/session.svelte';

  interface Props {
    cancionId: string;
  }

  let { cancionId }: Props = $props();

  let comentarios = $state<Comentario[]>([]);
  let texto = $state('');
  let enviando = $state(false);
  let cargando = $state(true);

  onMount(() => {
    const unsub = comentariosService.stream(
      cancionId,
      (items) => {
        comentarios = items;
        cargando = false;
      },
      () => (cargando = false)
    );
    return unsub;
  });

  async function enviar() {
    const limpio = texto.trim();
    if (!limpio || enviando || !session.user) return;
    enviando = true;
    try {
      await comentariosService.crear(
        cancionId,
        limpio,
        session.user.uid,
        session.user.nombre
      );
      texto = '';
    } finally {
      enviando = false;
    }
  }

  async function eliminar(id: string) {
    try {
      await comentariosService.eliminar(cancionId, id);
    } catch {}
  }

  function fechaBonita(iso: string): string {
    const d = new Date(iso);
    const ahora = new Date();
    const diff = ahora.getTime() - d.getTime();
    const min = Math.floor(diff / 60000);
    if (min < 1) return 'Ahora';
    if (min < 60) return `Hace ${min} min`;
    const h = Math.floor(min / 60);
    if (h < 24) return `Hace ${h} h`;
    return `${d.getDate()}/${d.getMonth() + 1}`;
  }

  function inicial(nombre: string): string {
    return nombre.trim().charAt(0).toUpperCase() || '?';
  }
</script>

<div class="space-y-3">
  {#if cargando}
    <div class="glass rounded-2xl h-20 animate-pulse"></div>
  {:else if comentarios.length === 0}
    <GlassCard padding="lg">
      <div class="flex flex-col items-center text-center py-4">
        <div class="w-12 h-12 rounded-full bg-dorado/15 flex items-center justify-center mb-2">
          <Icon name="list" size={20} class="text-dorado/60" />
        </div>
        <p class="text-sm font-bold text-white">Sin comentarios</p>
        <p class="text-[11px] text-white/50 mt-1">Sé el primero en comentar</p>
      </div>
    </GlassCard>
  {:else}
    {#each comentarios as c (c.id)}
      <GlassCard padding="md">
        <div class="flex items-start gap-3">
          <div class="w-9 h-9 rounded-full bg-gradient-to-br from-granate to-granate-dark flex items-center justify-center shrink-0">
            <span class="text-xs font-black text-dorado">{inicial(c.autorNombre)}</span>
          </div>
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 flex-wrap">
              <p class="text-[13px] font-bold text-white truncate">{c.autorNombre}</p>
              <span class="text-[10px] text-white/30">·</span>
              <span class="text-[10px] text-white/40">{fechaBonita(c.fecha)}</span>
            </div>
            <p class="text-sm text-white/80 mt-1 leading-relaxed break-words">{c.texto}</p>
          </div>
          {#if session.user?.uid === c.autorUid || session.isAdmin}
            <button
              type="button"
              onclick={() => eliminar(c.id)}
              class="w-8 h-8 rounded-full flex items-center justify-center text-red-400/60 hover:text-red-400 active:scale-90 shrink-0"
            >
              <Icon name="trash" size={14} />
            </button>
          {/if}
        </div>
      </GlassCard>
    {/each}
  {/if}

  {#if session.user}
    <div class="glass rounded-2xl border border-white/10 flex items-end gap-2 p-2">
      <textarea
        bind:value={texto}
        onkeydown={(e) => {
          if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            enviar();
          }
        }}
        rows="1"
        placeholder="Escribe un comentario..."
        class="flex-1 bg-transparent outline-none text-sm text-white placeholder:text-white/30 font-medium px-2 py-2 resize-none min-h-[40px] max-h-[120px]"
      ></textarea>
      <button
        type="button"
        onclick={enviar}
        disabled={!texto.trim() || enviando}
        class="w-10 h-10 rounded-full bg-gradient-to-br from-dorado to-dorado-dark flex items-center justify-center shrink-0 active:scale-90 disabled:opacity-40 transition-transform"
      >
        {#if enviando}
          <div class="w-4 h-4 border-2 border-granate-dark border-t-transparent rounded-full animate-spin"></div>
        {:else}
          <Icon name="send" size={16} class="text-granate-dark" />
        {/if}
      </button>
    </div>
  {/if}
</div>