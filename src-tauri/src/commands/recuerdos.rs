// src-tauri/src/commands/recuerdos.rs
use std::sync::Mutex;
use tauri::State;

use crate::domain::Recuerdo;
use crate::infra::seed::recuerdos_demo;

pub struct RecuerdosState(pub Mutex<Vec<Recuerdo>>);

impl RecuerdosState {
    pub fn new() -> Self {
        Self(Mutex::new(recuerdos_demo()))
    }
}

#[tauri::command]
pub async fn listar_recuerdos(
    state: State<'_, RecuerdosState>,
) -> Result<Vec<Recuerdo>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    let mut lista = guard.clone();
    lista.sort_by(|a, b| b.fecha.cmp(&a.fecha));
    Ok(lista)
}

#[tauri::command]
pub async fn obtener_recuerdo(
    id: String,
    state: State<'_, RecuerdosState>,
) -> Result<Option<Recuerdo>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.iter().find(|r| r.id == id).cloned())
}