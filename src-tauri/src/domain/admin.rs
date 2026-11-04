// src-tauri/src/domain/admin.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AdminStats {
    pub total_canciones: u32,
    pub total_eventos: u32,
    pub total_recuerdos: u32,
    pub total_reproducciones: u32,
    pub total_fotos: u32,
    pub total_audios: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UsuarioResumen {
    pub uid: String,
    pub nombre: String,
    pub email: String,
    pub rol: String,
    pub foto_url: String,
    pub baneado: bool,
}