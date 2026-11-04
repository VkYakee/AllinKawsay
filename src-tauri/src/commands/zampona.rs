// src-tauri/src/commands/zampona.rs
use crate::domain::nota_zampona::{catalogo, NotaZampona};

#[tauri::command]
pub async fn listar_notas_zampona() -> Result<Vec<NotaZampona>, String> {
    Ok(catalogo())
}

/// Reproduce una nota. Por ahora no hay audio real cargado.
/// En una fase posterior cargará el .ogg correspondiente.
#[tauri::command]
pub async fn tocar_nota(id: String) -> Result<(), String> {
    let existe = catalogo().iter().any(|n| n.id == id);
    if !existe {
        return Err(format!("Nota desconocida: {id}"));
    }
    Ok(())
}