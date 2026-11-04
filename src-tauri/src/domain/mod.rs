// src-tauri/src/domain/mod.rs
pub mod cancion;
pub mod nota_zampona;
pub mod user;

pub use cancion::{Cancion, Columna, Estrofa};
pub use nota_zampona::NotaZampona;
pub use user::{User, UserRole};