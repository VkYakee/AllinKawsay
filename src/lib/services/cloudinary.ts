// src/lib/services/cloudinary.ts
import { cloudinaryUrl } from '../config/cloudinary';

export type ProgressCb = (pct: number) => void;

export function subirArchivo(
  file: File,
  folder: string,
  onProgress?: ProgressCb
): Promise<string> {
  return new Promise((resolve, reject) => {
    const { url, formData } = cloudinaryUrl(folder, file);
    const xhr = new XMLHttpRequest();

    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable && onProgress) {
        onProgress(Math.min(1, e.loaded / e.total));
      }
    });

    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        try {
          const data = JSON.parse(xhr.responseText);
          const secureUrl = data.secure_url;
          if (typeof secureUrl === 'string' && secureUrl.length > 0) {
            resolve(secureUrl);
          } else {
            reject(new Error('Respuesta de Cloudinary sin secure_url'));
          }
        } catch {
          reject(new Error('Respuesta inválida de Cloudinary'));
        }
      } else {
        reject(new Error(`Error ${xhr.status}: ${xhr.statusText}`));
      }
    });

    xhr.addEventListener('error', () => reject(new Error('Error de red')));
    xhr.addEventListener('abort', () => reject(new Error('Subida cancelada')));

    xhr.open('POST', url);
    xhr.send(formData);
  });
}

export function subirFotoRecuerdo(file: File, onProgress?: ProgressCb): Promise<string> {
  return subirArchivo(file, 'recuerdos/fotos', onProgress);
}

export function subirVideoRecuerdo(file: File, onProgress?: ProgressCb): Promise<string> {
  return subirArchivo(file, 'recuerdos/videos', onProgress);
}

export function subirAudioCancion(file: File, onProgress?: ProgressCb): Promise<string> {
  return subirArchivo(file, 'canciones/audio', onProgress);
}

export function subirImagenCancion(file: File, onProgress?: ProgressCb): Promise<string> {
  return subirArchivo(file, 'canciones/imagenes', onProgress);
}