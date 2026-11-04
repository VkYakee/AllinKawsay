// src/lib/services/update.ts
import { doc, getDoc } from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

export const APP_VERSION = '3.0.0';
export const APP_BUILD = 1;

export interface InfoVersion {
  build: number;
  version: string;
  url: string;
  critica: boolean;
  notas: string;
  aprobadaPor: string;
}

export async function hayActualizacion(): Promise<InfoVersion | null> {
  try {
    const db = getFirebaseDb();
    const snap = await getDoc(doc(db, 'config', 'ultimaAprobada'));
    if (!snap.exists()) return null;
    const data = snap.data() ?? {};
    const build = typeof data.build === 'number' ? data.build : 0;
    if (build <= APP_BUILD) return null;
    return {
      build,
      version: typeof data.version === 'string' ? data.version : '',
      url: typeof data.url === 'string' ? data.url : '',
      critica: data.critica === true,
      notas: typeof data.notas === 'string' ? data.notas : '',
      aprobadaPor: typeof data.aprobadaPor === 'string' ? data.aprobadaPor : ''
    };
  } catch {
    return null;
  }
}