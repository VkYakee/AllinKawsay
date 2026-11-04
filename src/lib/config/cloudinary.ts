// src/lib/config/cloudinary.ts
// Unsigned upload preset (no requiere API secret, es seguro exponerlo).
export const cloudinaryConfig = {
  cloudName: 'eveyybgz',
  uploadPreset: 'sikuris_preset'
};

export function cloudinaryUrl(folder: string, file: File): {
  url: string;
  formData: FormData;
} {
  const url = `https://api.cloudinary.com/v1_1/${cloudinaryConfig.cloudName}/auto/upload`;
  const formData = new FormData();
  formData.append('upload_preset', cloudinaryConfig.uploadPreset);
  formData.append('folder', `sikuris/${folder}`);
  formData.append('file', file);
  return { url, formData };
}