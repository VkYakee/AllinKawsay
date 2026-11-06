import { createSyncProject, validateSyncProject, type SyncProject } from '../domain/ensayo/sync-project';
const PREFIX = 'allinkawsay:ensayo-sync:v1:';
const key = (songId: string) => PREFIX + encodeURIComponent(songId);
export function loadSyncProject(songId: string): SyncProject | null {
  if (typeof localStorage === 'undefined') return null;
  try { const raw = localStorage.getItem(key(songId)); if (!raw) return null; const project = JSON.parse(raw) as SyncProject; if (project.songId !== songId || validateSyncProject(project).length) return null; return project; } catch { return null; }
}
export function saveSyncProject(project: SyncProject): void {
  const issues = validateSyncProject(project); if (issues.length) throw new Error('No se guardó: ' + issues[0].message);
  if (typeof localStorage === 'undefined') throw new Error('Almacenamiento local no disponible.');
  localStorage.setItem(key(project.songId), JSON.stringify({ ...project, updatedAt: Date.now() }));
}
export function getOrCreateSyncProject(songId: string): SyncProject { return loadSyncProject(songId) ?? createSyncProject('sync-' + encodeURIComponent(songId), songId); }
