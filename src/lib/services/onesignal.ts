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

let inicializacion: Promise<void> | null = null;
let inicializado = false;
let identidadPendiente: string | null = null;

function aplicarIdentidad(OneSignal: OneSignalInstance): void {
  const accion = identidadPendiente
    ? OneSignal.login(identidadPendiente)
    : OneSignal.logout();
  void accion.catch((e) => console.warn('⚠️ No se pudo actualizar la identidad de OneSignal:', e));
}

export function initOneSignal(): Promise<void> {
  if (inicializacion) return inicializacion;
  if (!ONESIGNAL_APP_ID || typeof window === 'undefined' || typeof document === 'undefined') {
    return Promise.resolve();
  }

  inicializacion = new Promise<void>((resolve, reject) => {
    const win = window as OneSignalWindow;

    const cargarSdk = (): Promise<void> => new Promise((resolveScript, rejectScript) => {
      const existing = document.querySelector<HTMLScriptElement>('script[src*="OneSignalSDK.page.js"]');
      if (existing) {
        // El evento load pudo ocurrir antes de esta llamada; la cola Deferred
        // también funciona cuando el SDK ya está presente.
        resolveScript();
        return;
      }

      const script = document.createElement('script');
      script.src = 'https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js';
      script.defer = true;
      script.onload = () => resolveScript();
      script.onerror = () => rejectScript(new Error('No se pudo cargar OneSignal'));
      document.head.appendChild(script);
    });

    void cargarSdk().then(() => {
      win.OneSignalDeferred = win.OneSignalDeferred || [];
      win.OneSignalDeferred.push(async (OneSignal) => {
        try {
          await OneSignal.init({
            appId: ONESIGNAL_APP_ID,
            allowLocalhostAsSecureOrigin: true,
            notifyButton: { enable: false }
          });
          inicializado = true;
          aplicarIdentidad(OneSignal);
          console.log('✅ OneSignal inicializado');
          resolve();
        } catch (e) {
          console.warn('⚠️ Error inicializando OneSignal:', e);
          inicializacion = null;
          reject(e);
        }
      });
    }).catch((e: unknown) => {
      inicializacion = null;
      console.warn('⚠️ Error cargando OneSignal:', e);
      reject(e);
    });
  });

  return inicializacion;
}

export function oneSignalLogin(uid: string): void {
  identidadPendiente = uid;
  if (!inicializado) return;
  const OneSignal = (window as OneSignalWindow).OneSignal;
  if (OneSignal) aplicarIdentidad(OneSignal);
}

export function oneSignalLogout(): void {
  identidadPendiente = null;
  if (!inicializado) return;
  const OneSignal = (window as OneSignalWindow).OneSignal;
  if (OneSignal) aplicarIdentidad(OneSignal);
}
