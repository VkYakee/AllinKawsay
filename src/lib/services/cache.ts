// src/lib/services/cache.ts
const isTauri =
  typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window;

const PREFIJO_CACHE = 'allin_';

/** Cuenta únicamente temporales propios; los errores se propagan para no confundirlos con una caché vacía. */
export async function contarArchivosCache(): Promise<number> {
  if (!isTauri) return 0;
  const { tempDir } = await import('@tauri-apps/api/path');
  const { readDir } = await import('@tauri-apps/plugin-fs');
  const dir = await tempDir();
  const entries = await readDir(dir);
  return entries.filter(
    (e) => e.isFile && e.name?.startsWith(PREFIJO_CACHE)
  ).length;
}

export async function limpiarCache(): Promise<number> {
  if (!isTauri) return 0;

  const { tempDir } = await import('@tauri-apps/api/path');
  const { readDir, remove } = await import('@tauri-apps/plugin-fs');
  const dir = await tempDir();
  const entries = await readDir(dir);
  let eliminados = 0;

  for (const entry of entries) {
    if (entry.isFile && entry.name?.startsWith(PREFIJO_CACHE)) {
      await remove(`${dir}/${entry.name}`);
      eliminados++;
    }
  }

  return eliminados;
}
