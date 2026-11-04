// src/lib/services/clima.ts
export interface Clima {
  temp: number;
  code: number;
  descripcion: string;
  icono: string;
}

const cache = new Map<string, Clima>();

function clave(lat: number, lng: number): string {
  return `${lat.toFixed(3)},${lng.toFixed(3)}`;
}

function describe(code: number): { desc: string; icono: string } {
  if (code === 0) return { desc: 'Despejado', icono: '☀️' };
  if (code >= 1 && code <= 3) return { desc: 'Parcialmente nublado', icono: '⛅' };
  if (code >= 45 && code <= 48) return { desc: 'Niebla', icono: '🌫️' };
  if (code >= 51 && code <= 67) return { desc: 'Lluvia', icono: '🌧️' };
  if (code >= 71 && code <= 77) return { desc: 'Nieve', icono: '❄️' };
  if (code >= 80 && code <= 82) return { desc: 'Chubascos', icono: '🌦️' };
  if (code >= 95) return { desc: 'Tormenta', icono: '⛈️' };
  return { desc: 'Desconocido', icono: '🌡️' };
}

export async function obtenerClima(lat: number, lng: number): Promise<Clima | null> {
  const k = clave(lat, lng);
  if (cache.has(k)) return cache.get(k)!;

  try {
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}&current_weather=true`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 5000);
    const res = await fetch(url, { signal: controller.signal });
    clearTimeout(timer);

    if (!res.ok) return null;

    const data = await res.json();
    const cw = data.current_weather;
    if (!cw) return null;

    const info = describe(cw.weathercode);
    const clima: Clima = {
      temp: Math.round(cw.temperature),
      code: cw.weathercode,
      descripcion: info.desc,
      icono: info.icono
    };

    cache.set(k, clima);
    return clima;
  } catch {
    return null;
  }
}