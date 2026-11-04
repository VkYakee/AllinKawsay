// src-tauri/src/commands/zampona.rs
use tauri::State;

use crate::domain::nota_zampona::{catalogo, NotaZampona};
use crate::infra::audio::AudioHandle;

#[tauri::command]
pub async fn listar_notas_zampona() -> Result<Vec<NotaZampona>, String> {
    Ok(catalogo())
}

#[tauri::command]
pub async fn tocar_nota(
    id: String,
    audio: State<'_, AudioHandle>,
) -> Result<(), String> {
    let existe = catalogo().iter().any(|n| n.id == id);
    if !existe {
        return Err(format!("Nota desconocida: {id}"));
    }
    audio.tocar(&id);
    Ok(())
}