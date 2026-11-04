// src/lib/services/onesignal.ts
import { ONESIGNAL_APP_ID } from '../config/firebase';

interface OneSignalWindow extends Window {
  OneSignalDeferred?: Array<(OneSignal: OneSignalInstance) => void>;
  OneSignal?: OneSignalInstance;
}

interface OneSignalInstance {
  init: (opts: Record<string, unknown>) => Promise<void>;
  login: (externalId: string) => Promise<void>;
  logout: () => Promise<void>;
  Notifications: {
    requestPermission: () => Promise<void>;
  };
}

let cargado = false;
let inicializado = false;

export async function initOneSignal(): Promise<void> {
  if (cargado || !ONESIGNAL_APP_ID) return;
  cargado = true;

  await new Promise<void>((resolve) => {
    const existing = document.querySelector('script[src*="onesignal"]');
    if (existing) {
      resolve();
      return;
    }
    const script = document.createElement('script');
    script.src = 'https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js';
    script.defer = true;
    script.onload = () => resolve();
    script.onerror = () => {
      console.warn('⚠️ No se pudo cargar OneSignal');
      resolve();
    };
    document.head.appendChild(script);
  });

  const win = window as OneSignalWindow;
  win.OneSignalDeferred = win.OneSignalDeferred || [];
  win.OneSignalDeferred.push(async (OneSignal) => {
    try {
      await OneSignal.init({
        appId: ONESIGNAL_APP_ID,
        allowLocalhostAsSecureOrigin: true,
        notifyButton: { enable: false }
      });
      inicializado = true;
      console.log('✅ OneSignal inicializado');
    } catch (e) {
      console.warn('⚠️ Error inicializando OneSignal:', e);
    }
  });
}

export function oneSignalLogin(uid: string): void {
  if (!inicializado) return;
  try {
    (window as OneSignalWindow).OneSignal?.login(uid);
  } catch {
    // silencioso
  }
}

export function oneSignalLogout(): void {
  if (!inicializado) return;
  try {
    (window as OneSignalWindow).OneSignal?.logout();
  } catch {
    // silencioso
  }
}