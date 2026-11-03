// src-tauri/src/domain/cancion.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Columna {
    pub nota7: String,
    pub nota6: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Estrofa {
    pub columnas: Vec<Columna>,
    pub bis: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cancion {
    pub id: String,
    pub titulo: String,
    pub autor: String,
    pub ritmo: String,
    pub region: String,
    pub imagen_url: String,
    pub audio_url: String,
    pub video_url: String,
    pub descripcion: String,
    pub reproducciones: u32,
    pub estrofas: Vec<Estrofa>,
    pub letra: String,
    pub tags: Vec<String>,
}

impl Cancion {
    pub fn tiene_numerofonia(&self) -> bool {
        self.estrofas.iter().any(|e| {
            e.columnas
                .iter()
                .any(|c| !c.nota7.trim().is_empty() || !c.nota6.trim().is_empty())
        })
    }

    pub fn tiene_letra(&self) -> bool {
        !self.letra.trim().is_empty()
    }
}