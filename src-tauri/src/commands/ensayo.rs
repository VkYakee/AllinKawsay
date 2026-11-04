// src-tauri/src/commands/ensayo.rs
use serde::Serialize;
use tauri::State;

use crate::commands::canciones::CancionesState;

#[derive(Serialize, Clone)]
pub struct EventoEnsayo {
    pub nota_id: String,
    pub estrofa_idx: usize,
    pub columna_idx: usize,
    pub es_fila7: bool,
    pub offset_ms: u64,
}

#[derive(Serialize, Clone)]
pub struct EnsayoPreparado {
    pub cancion_id: String,
    pub titulo: String,
    pub eventos: Vec<EventoEnsayo>,
    pub duracion_nota_ms: u64,
    pub duracion_total_ms: u64,
}

#[tauri::command]
pub async fn preparar_ensayo(
    id: String,
    duracion_nota_ms: Option<u64>,
    state: State<'_, CancionesState>,
) -> Result<EnsayoPreparado, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    let cancion = guard
        .iter()
        .find(|c| c.id == id)
        .ok_or_else(|| "Canción no encontrada".to_string())?;

    let dur = duracion_nota_ms.unwrap_or(500);
    let mut eventos: Vec<EventoEnsayo> = Vec::new();
    let mut offset: u64 = 0;

    for (ei, estrofa) in cancion.estrofas.iter().enumerate() {
        for (ci, columna) in estrofa.columnas.iter().enumerate() {
            let n7 = columna.nota7.trim();
            let n6 = columna.nota6.trim();

            if !n7.is_empty() && n7 != "." {
                eventos.push(EventoEnsayo {
                    nota_id: format!("fila7_{}", n7),
                    estrofa_idx: ei,
                    columna_idx: ci,
                    es_fila7: true,
                    offset_ms: offset,
                });
                offset += dur;
            }

            if !n6.is_empty() && n6 != "." {
                eventos.push(EventoEnsayo {
                    nota_id: format!("fila6_{}", n6),
                    estrofa_idx: ei,
                    columna_idx: ci,
                    es_fila7: false,
                    offset_ms: offset,
                });
                offset += dur;
            }
        }
    }

    Ok(EnsayoPreparado {
        cancion_id: cancion.id.clone(),
        titulo: cancion.titulo.clone(),
        eventos,
        duracion_nota_ms: dur,
        duracion_total_ms: offset,
    })
}