// src-tauri/src/domain/evento.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Evento {
    pub id: String,
    pub titulo: String,
    pub descripcion: String,
    pub lugar: String,
    /// ISO 8601 (ej: "2026-10-15T19:00:00")
    pub fecha: String,
    pub lat: Option<f64>,
    pub lng: Option<f64>,
    pub creado_por: String,
    pub creador_nombre: String,
}