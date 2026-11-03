// src-tauri/src/domain/user.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub uid: String,
    pub nombre: String,
    pub email: String,
    pub rol: UserRole,
    pub foto_url: String,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum UserRole {
    Publico,
    Miembro,
    Admin,
    Dev,
}

impl UserRole {
    #[allow(dead_code)]
    pub fn is_admin(&self) -> bool {
        matches!(self, UserRole::Admin | UserRole::Dev)
    }
}