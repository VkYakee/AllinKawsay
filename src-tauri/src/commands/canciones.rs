// src-tauri/src/commands/canciones.rs
use std::sync::Mutex;
use tauri::State;

use crate::domain::Cancion;
use crate::infra::seed::canciones_demo;

pub struct CancionesState(pub Mutex<Vec<Cancion>>);

impl CancionesState {
    pub fn new() -> Self {
        Self(Mutex::new(canciones_demo()))
    }
}

#[tauri::command]
pub async fn listar_canciones(state: State<'_, CancionesState>) -> Result<Vec<Cancion>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.clone())
}

#[tauri::command]
pub async fn obtener_cancion(
    id: String,
    state: State<'_, CancionesState>,
) -> Result<Option<Cancion>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.iter().find(|c| c.id == id).cloned())
}

#[tauri::command]
pub async fn incrementar_reproduccion(
    id: String,
    state: State<'_, CancionesState>,
) -> Result<u32, String> {
    let mut guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    if let Some(c) = guard.iter_mut().find(|c| c.id == id) {
        c.reproducciones = c.reproducciones.saturating_add(1);
        Ok(c.reproducciones)
    } else {
        Err("Canción no encontrada".into())
    }
}