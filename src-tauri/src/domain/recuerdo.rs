// src-tauri/src/domain/recuerdo.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Recuerdo {
    pub id: String,
    pub titulo: String,
    pub descripcion: String,
    pub fotos: Vec<String>,
    pub videos: Vec<String>,
    /// ISO 8601 (ej: "2025-03-12T18:00:00")
    pub fecha: String,
    pub creado_por: String,
    pub creador_nombre: String,
}

impl Recuerdo {
    pub fn tiene_fotos(&self) -> bool {
        !self.fotos.is_empty()
    }

    pub fn tiene_videos(&self) -> bool {
        !self.videos.is_empty()
    }

    pub fn portada(&self) -> Option<&String> {
        self.fotos.first()
    }
}