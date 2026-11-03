// src-tauri/src/domain/mod.rs
pub mod cancion;
pub mod user;

pub use cancion::{Cancion, Columna, Estrofa};
pub use user::{User, UserRole};