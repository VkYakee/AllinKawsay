// src/lib/services/ensayo.ts
export interface EventoEnsayo {
  nota_id: string;
  estrofa_idx: number;
  columna_idx: number;
  es_fila7: boolean;
  offset_ms: number;
}

export interface EnsayoPreparado {
  eventos: EventoEnsayo[];
  duracion_nota_ms: number;
  duracion_total_ms: number;
}

export function prepararEventos(
  estrofas: Array<{
    columnas: Array<{ nota7: string; nota6: string }>;
    bis: boolean;
  }>,
  duracionNotaMs = 500
): EnsayoPreparado {
  const eventos: EventoEnsayo[] = [];
  let offset = 0;

  for (let ei = 0; ei < estrofas.length; ei++) {
    const est = estrofas[ei];
    for (let ci = 0; ci < est.columnas.length; ci++) {
      const col = est.columnas[ci];
      const n7 = col.nota7.trim();
      const n6 = col.nota6.trim();

      if (n7 && n7 !== '.') {
        eventos.push({
          nota_id: `fila7_${n7}`,
          estrofa_idx: ei,
          columna_idx: ci,
          es_fila7: true,
          offset_ms: offset
        });
        offset += duracionNotaMs;
      }

      if (n6 && n6 !== '.') {
        eventos.push({
          nota_id: `fila6_${n6}`,
          estrofa_idx: ei,
          columna_idx: ci,
          es_fila7: false,
          offset_ms: offset
        });
        offset += duracionNotaMs;
      }
    }
  }

  return {
    eventos,
    duracion_nota_ms: duracionNotaMs,
    duracion_total_ms: offset
  };
}