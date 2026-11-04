// src-tauri/src/commands/eventos.rs
use std::sync::Mutex;
use tauri::State;

use crate::domain::Evento;
use crate::infra::seed::eventos_demo;

pub struct EventosState(pub Mutex<Vec<Evento>>);

impl EventosState {
    pub fn new() -> Self {
        Self(Mutex::new(eventos_demo()))
    }
}

#[tauri::command]
pub async fn listar_eventos(state: State<'_, EventosState>) -> Result<Vec<Evento>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    let mut lista = guard.clone();
    lista.sort_by(|a, b| a.fecha.cmp(&b.fecha));
    Ok(lista)
}

#[tauri::command]
pub async fn obtener_evento(
    id: String,
    state: State<'_, EventosState>,
) -> Result<Option<Evento>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.iter().find(|e| e.id == id).cloned())
}