// src-tauri/src/domain/mod.rs
pub mod cancion;
pub mod evento;
pub mod nota_zampona;
pub mod recuerdo;
pub mod user;

pub use cancion::{Cancion, Columna, Estrofa};
pub use evento::Evento;
pub use nota_zampona::NotaZampona;
pub use recuerdo::Recuerdo;
pub use user::{User, UserRole};