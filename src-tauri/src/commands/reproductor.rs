// src-tauri/src/commands/reproductor.rs
use std::io::Write;
use tauri::State;

use crate::infra::audio::{AudioHandle, ReproductorState, ScheduledAudioNote};
use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct ScheduledNoteInput { pub at_ms: u64, pub sample_id: String, pub event_id: String, pub gain: f32 }

#[tauri::command]
pub async fn play_cancion(
    cancion_id: String,
    url: String,
    audio: State<'_, AudioHandle>,
) -> Result<(), String> {
    if cancion_id.trim().is_empty()
        || !cancion_id.chars().all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_')
    {
        return Err("Id de canción inválido".into());
    }

    let parsed_url = reqwest::Url::parse(url.trim())
        .map_err(|_| "URL de audio inválida".to_string())?;
    if parsed_url.scheme() != "https"
        || parsed_url.host_str() != Some("res.cloudinary.com")
        || !parsed_url.path().starts_with("/eveyybgz/")
        || !parsed_url.username().is_empty()
        || parsed_url.password().is_some()
    {
        return Err("El audio debe provenir del almacenamiento seguro de Cloudinary".into());
    }

    // No permitir que una redirección de Cloudinary convierta la descarga en
    // una petición a otro host (protección SSRF para el comando nativo).
    let client = reqwest::Client::builder()
        .redirect(reqwest::redirect::Policy::custom(|attempt| {
            if attempt.url().scheme() == "https"
                && attempt.url().host_str() == Some("res.cloudinary.com")
            {
                attempt.follow()
            } else {
                attempt.stop()
            }
        }))
        .build()
        .map_err(|e| format!("No se pudo preparar la descarga: {e}"))?;

    let mut response = client.get(parsed_url).send().await
        .map_err(|e| format!("Error de red: {e}"))?;
    if !response.status().is_success() {
        return Err(format!("HTTP {}", response.status()));
    }

    // Escribir por fragmentos evita cargar el audio completo en RAM.
    let tmp_dir = std::env::temp_dir();
    let path = tmp_dir.join(format!("allin_cancion_{cancion_id}.audio"));
    let mut file = std::fs::File::create(&path)
        .map_err(|e| format!("No se pudo crear archivo temporal: {e}"))?;
    let mut total_bytes = 0_u64;
    loop {
        match response.chunk().await {
            Ok(Some(chunk)) => {
                total_bytes = total_bytes.saturating_add(chunk.len() as u64);
                if let Err(e) = file.write_all(&chunk) {
                    let _ = std::fs::remove_file(&path);
                    return Err(format!("No se pudo guardar el audio: {e}"));
                }
            }
            Ok(None) => break,
            Err(e) => {
                let _ = std::fs::remove_file(&path);
                return Err(format!("Error descargando audio: {e}"));
            }
        }
    }
    if total_bytes == 0 {
        let _ = std::fs::remove_file(&path);
        return Err("Descarga vacía".into());
    }
    if let Err(e) = file.flush() {
        let _ = std::fs::remove_file(&path);
        return Err(format!("No se pudo completar el audio: {e}"));
    }

    audio.play_cancion(cancion_id, path);
    Ok(())
}

#[tauri::command]
pub async fn pausar_cancion(audio: State<'_, AudioHandle>) -> Result<(), String> {
    audio.pausar();
    Ok(())
}

#[tauri::command]
pub async fn reanudar_cancion(audio: State<'_, AudioHandle>) -> Result<(), String> {
    audio.reanudar();
    Ok(())
}

#[tauri::command]
pub async fn detener_cancion(audio: State<'_, AudioHandle>) -> Result<(), String> {
    audio.detener();
    Ok(())
}

#[tauri::command]
pub async fn estado_reproductor(
    audio: State<'_, AudioHandle>,
) -> Result<ReproductorState, String> {
    let share = audio.estado();
    let guard = share.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.clone())
}

#[tauri::command]
pub async fn buscar_cancion(position_ms: u64, audio: State<'_, AudioHandle>) -> Result<(), String> {
    audio.buscar(position_ms);
    Ok(())
}

#[tauri::command]
pub async fn velocidad_cancion(speed: f32, audio: State<'_, AudioHandle>) -> Result<(), String> {
    audio.set_velocidad(speed)
}


#[tauri::command]
pub async fn programar_notas(generation: u64, events: Vec<ScheduledNoteInput>, audio: State<'_, AudioHandle>) -> Result<(), String> {
    if events.len() > 4096 { return Err("Máximo 4096 notas por lote".into()); }
    if events.iter().any(|event| !event.gain.is_finite() || !(0.0..=1.0).contains(&event.gain)) { return Err("La ganancia de cada nota debe estar entre 0 y 1".into()); }
    let batch = events.into_iter().map(|e| ScheduledAudioNote { at_ms: e.at_ms, sample_id: e.sample_id, event_id: e.event_id, gain: e.gain }).collect();
    audio.programar(generation, batch)
}
