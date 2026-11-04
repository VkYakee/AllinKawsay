<!-- src/lib/features/zampona/ZamponaCanvas.svelte -->
<script lang="ts">
  import type { NotaZampona } from '../../services/zampona';

  interface Props {
    notas: NotaZampona[];
    brillando: Set<string>;
    onTap: (nota: NotaZampona) => void;
    onRelease?: (nota: NotaZampona) => void;
  }

  let { notas, brillando, onTap, onRelease }: Props = $props();

  const RADIO = 19;
  const SPACING = 44;
  const CENTER_X = 210;
  const ROW7_Y = 72;
  const ROW6_Y = 190;
  const LISTON_Y = 120;
  const LISTON_H = 16;

  const fila7 = $derived(notas.filter((n) => n.fila === 7).sort((a, b) => a.posicion - b.posicion));
  const fila6 = $derived(notas.filter((n) => n.fila === 6).sort((a, b) => a.posicion - b.posicion));

  function posiciones(count: number): number[] {
    const total = (count - 1) * SPACING;
    const start = CENTER_X - total / 2;
    return Array.from({ length: count }, (_, i) => start + i * SPACING);
  }

  const posFila7 = posiciones(7);
  const posFila6 = posiciones(6);

  const canas = $derived.by(() => {
    const arr: Array<{ nota: NotaZampona; x: number; y: number }> = [];
    fila7.forEach((nota, i) => arr.push({ nota, x: posFila7[i], y: ROW7_Y }));
    fila6.forEach((nota, i) => arr.push({ nota, x: posFila6[i], y: ROW6_Y }));
    return arr;
  });

  interface Particula {
    id: number;
    x: number;
    y: number;
    drift: number;
    dur: number;
  }

  let particulas = $state<Particula[]>([]);
  let pid = 0;

  function spawn(cx: number, cy: number) {
    const nuevas: Particula[] = Array.from({ length: 6 }, () => ({
      id: ++pid,
      x: cx + (Math.random() - 0.5) * 16,
      y: cy,
      drift: (Math.random() - 0.5) * 44,
      dur: 550 + Math.random() * 300
    }));
    const ids = nuevas.map((p) => p.id);
    particulas = [...particulas, ...nuevas];
    setTimeout(() => {
      particulas = particulas.filter((p) => !ids.includes(p.id));
    }, 950);
  }

  function handleDown(nota: NotaZampona, x: number, y: number) {
    spawn(x, y);
    onTap(nota);
  }
</script>

<svg viewBox="0 0 420 260" class="w-full h-auto select-none block" xmlns="http://www.w3.org/2000/svg">
  <defs>
    {#each notas as nota (nota.id)}
      <radialGradient id="g-{nota.id}" cx="42%" cy="38%" r="68%">
        {#if brillando.has(nota.id)}
          <stop offset="0%" stop-color="#FFF3B0" />
          <stop offset="35%" stop-color="#E8C86A" />
          <stop offset="70%" stop-color="#C89B29" />
          <stop offset="100%" stop-color="#3A0810" />
        {:else}
          <stop offset="0%" stop-color="#4A151E" />
          <stop offset="40%" stop-color="#2A0308" />
          <stop offset="80%" stop-color="#1A0205" />
          <stop offset="100%" stop-color="#0A0103" />
        {/if}
      </radialGradient>
    {/each}

    <linearGradient id="liston-g" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#2A0308" />
      <stop offset="50%" stop-color="#150205" />
      <stop offset="100%" stop-color="#0A0103" />
    </linearGradient>
  </defs>

  <rect
    x={CENTER_X - 3 * SPACING - RADIO - 4}
    y={LISTON_Y}
    width={6 * SPACING + 2 * RADIO + 8}
    height={LISTON_H}
    rx={6}
    fill="url(#liston-g)"
    stroke="rgba(245, 208, 97, 0.25)"
    stroke-width="1"
  />

  {#each canas as c (c.nota.id)}
    {@const activa = brillando.has(c.nota.id)}
    <g
      transform="translate({c.x}, {c.y})"
      role="button"
      tabindex="0"
      class="cursor-pointer"
      onpointerdown={() => handleDown(c.nota, c.x, c.y)}
      onpointerup={() => onRelease?.(c.nota)}
      onpointerleave={() => onRelease?.(c.nota)}
    >
      <circle
        r={activa ? RADIO * 1.15 : RADIO}
        fill="url(#g-{c.nota.id})"
        stroke={activa ? '#FFEAA0' : 'rgba(168, 34, 53, 0.55)'}
        stroke-width={activa ? 2.5 : 1.4}
        style="
          transition: r 150ms cubic-bezier(0.34, 1.56, 0.64, 1),
                      stroke 150ms;
          filter: {activa
            ? 'drop-shadow(0 0 14px rgba(245, 208, 97, 0.75))'
            : 'drop-shadow(0 4px 4px rgba(0,0,0,0.55))'};
        "
      />
      <ellipse
        cx={-RADIO * 0.28}
        cy={-RADIO * 0.32}
        rx={RADIO * 0.28}
        ry={RADIO * 0.2}
        fill={activa ? 'rgba(255,255,255,0.65)' : 'rgba(255,255,255,0.14)'}
        style="transition: fill 150ms; pointer-events: none;"
      />
      <text
        text-anchor="middle"
        dominant-baseline="central"
        y="1"
        font-size={RADIO * 0.95}
        font-weight="900"
        fill={activa ? '#4A0D18' : '#F5D061'}
        style="transition: fill 150ms; pointer-events: none; font-family: 'Outfit', sans-serif;"
      >
        {c.nota.posicion}
      </text>
    </g>
  {/each}

  {#each particulas as p (p.id)}
    <circle cx={p.x} cy={p.y} r="2.6" fill="rgba(245, 208, 97, 0.95)" style="pointer-events: none;">
      <animate attributeName="cy" from={p.y} to={p.y - 65} dur="{p.dur}ms" fill="freeze" />
      <animate attributeName="cx" from={p.x} to={p.x + p.drift} dur="{p.dur}ms" fill="freeze" />
      <animate attributeName="opacity" from="1" to="0" dur="{p.dur}ms" fill="freeze" />
      <animate attributeName="r" from="2.6" to="0.8" dur="{p.dur}ms" fill="freeze" />
    </circle>
  {/each}
</svg>