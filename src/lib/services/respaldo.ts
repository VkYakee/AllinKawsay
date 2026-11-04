// src/lib/services/respaldo.ts
import { collection, getDocs } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

function limpiar(valor: unknown): unknown {
  if (valor === null || valor === undefined) return null;
  if (valor instanceof Date) return valor.toISOString();
  if (Array.isArray(valor)) return valor.map(limpiar);
  if (typeof valor === 'object') {
    const obj = valor as Record<string, unknown>;
    if ('toDate' in obj && typeof obj.toDate === 'function') {
      return (obj.toDate() as Date).toISOString();
    }
    if ('latitude' in obj && 'longitude' in obj) {
      return { lat: obj.latitude, lng: obj.longitude };
    }
    const out: Record<string, unknown> = {};
    for (const k of Object.keys(obj)) out[k] = limpiar(obj[k]);
    return out;
  }
  return valor;
}

async function leerColeccion(nombre: string): Promise<unknown[]> {
  const db = getFirebaseDb();
  const snap = await getDocs(collection(db, nombre));
  return snap.docs.map((d) => ({ id: d.id, ...(limpiar(d.data()) as Record<string, unknown>) }));
}

export const respaldoService = {
  async generar(): Promise<string> {
    const [canciones, eventos, recuerdos, usuarios, categorias, historia] =
      await Promise.all([
        leerColeccion('canciones'),
        leerColeccion('eventos'),
        leerColeccion('recuerdos'),
        leerColeccion('usuarios'),
        leerColeccion('categorias'),
        leerColeccion('historia')
      ]);

    const data = {
      generadoEn: new Date().toISOString(),
      version: '3.0.0',
      plataforma: 'rust-tauri',
      canciones,
      eventos,
      recuerdos,
      usuarios,
      categorias,
      historia
    };

    return JSON.stringify(data, null, 2);
  },

  async contar(): Promise<{
    canciones: number;
    eventos: number;
    recuerdos: number;
    usuarios: number;
    categorias: number;
  }> {
    const [c, e, r, u, cat] = await Promise.all([
      leerColeccion('canciones'),
      leerColeccion('eventos'),
      leerColeccion('recuerdos'),
      leerColeccion('usuarios'),
      leerColeccion('categorias')
    ]);
    return {
      canciones: c.length,
      eventos: e.length,
      recuerdos: r.length,
      usuarios: u.length,
      categorias: cat.length
    };
  },

  descargar(json: string, nombre: string = `allin_kawsay_respaldo_${new Date().toISOString().slice(0, 10)}.json`): void {
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = nombre;
    a.click();
    URL.revokeObjectURL(url);
  }
};