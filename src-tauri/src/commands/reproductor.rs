// src-tauri/src/commands/reproductor.rs
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
    if url.trim().is_empty() {
        return Err("URL vacía".into());
    }

    let response = reqwest::get(&url)
        .await
        .map_err(|e| format!("Error de red: {e}"))?;

    if !response.status().is_success() {
        return Err(format!("HTTP {}", response.status()));
    }

    let bytes = response
        .bytes()
        .await
        .map_err(|e| format!("Error descargando: {e}"))?;

    if bytes.is_empty() {
        return Err("Descarga vacía".into());
    }

    let tmp_dir = std::env::temp_dir();
    let path = tmp_dir.join(format!("allin_cancion_{cancion_id}.audio"));
    std::fs::write(&path, &bytes).map_err(|e| format!("No se pudo guardar: {e}"))?;

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
