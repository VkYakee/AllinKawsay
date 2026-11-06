// src/lib/services/cloudinary.ts
import { cloudinaryUrl } from '../config/cloudinary';

export type ProgressCb = (pct: number) => void;
const UPLOAD_TIMEOUT_MS = 120_000;

export function subirArchivo(
  file: File,
  folder: string,
  onProgress?: ProgressCb
): Promise<string> {
  return new Promise((resolve, reject) => {
    const { url, formData } = cloudinaryUrl(folder, file);
    const xhr = new XMLHttpRequest();
    let settled = false;
    const fail = (message: string) => {
      if (settled) return;
      settled = true;
      reject(new Error(message));
    };

    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable && onProgress) {
        onProgress(Math.min(1, e.loaded / e.total));
      }
    });

    xhr.addEventListener('load', () => {
      if (settled) return;
      if (xhr.status >= 200 && xhr.status < 300) {
        try {
          const data = JSON.parse(xhr.responseText);
          const secureUrl = data.secure_url;
          if (typeof secureUrl === 'string' && secureUrl.length > 0) {
            settled = true;
            resolve(secureUrl);
          } else {
            fail('Respuesta de Cloudinary sin secure_url');
          }
        } catch {
          fail('Respuesta inválida de Cloudinary');
        }
      } else {
        fail(`Error ${xhr.status}: ${xhr.statusText || 'al subir el archivo'}`);
      }
    });

    xhr.addEventListener('error', () => fail('Error de red al subir el archivo'));
    xhr.addEventListener('abort', () => fail('Subida cancelada'));
    xhr.addEventListener('timeout', () => fail('La subida tardó demasiado. Comprueba tu conexión e inténtalo nuevamente.'));

    xhr.open('POST', url);
    xhr.timeout = UPLOAD_TIMEOUT_MS;
    xhr.send(formData);
  });
}

function validarTipo(file: File, familia: 'image' | 'audio' | 'video'): void {
  if (file.size <= 0) throw new Error('El archivo está vacío.');
  // Algunos selectores Android no informan MIME; en ese caso Cloudinary
  // conserva la validación final y no bloqueamos una selección legítima.
  const mime = file.type.toLowerCase();
  if (mime && mime !== 'application/octet-stream' && !mime.startsWith(`${familia}/`)) {
    throw new Error(`Selecciona un archivo de tipo ${familia === 'image' ? 'imagen' : familia === 'audio' ? 'audio' : 'video'}.`);
  }
}

export function subirFotoRecuerdo(file: File, onProgress?: ProgressCb): Promise<string> {
  validarTipo(file, 'image');
  return subirArchivo(file, 'recuerdos/fotos', onProgress);
}

export function subirVideoRecuerdo(file: File, onProgress?: ProgressCb): Promise<string> {
  validarTipo(file, 'video');
  return subirArchivo(file, 'recuerdos/videos', onProgress);
}

export function subirAudioCancion(file: File, onProgress?: ProgressCb): Promise<string> {
  validarTipo(file, 'audio');
  return subirArchivo(file, 'canciones/audio', onProgress);
}

export function subirImagenCancion(file: File, onProgress?: ProgressCb): Promise<string> {
  validarTipo(file, 'image');
  return subirArchivo(file, 'canciones/imagenes', onProgress);
}
