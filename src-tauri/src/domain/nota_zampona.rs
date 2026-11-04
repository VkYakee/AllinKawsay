// src-tauri/src/domain/nota_zampona.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotaZampona {
    pub id: String,
    pub nota: String,
    pub fila: u8,
    pub posicion: u8,
}

fn n(id: &str, nota: &str, fila: u8, pos: u8) -> NotaZampona {
    NotaZampona {
        id: id.into(),
        nota: nota.into(),
        fila,
        posicion: pos,
    }
}

pub fn catalogo() -> Vec<NotaZampona> {
    vec![
        n("fila7_1", "Do", 7, 1),
        n("fila7_2", "Lab", 7, 2),
        n("fila7_3", "Fa", 7, 3),
        n("fila7_4", "Reb", 7, 4),
        n("fila7_5", "Sib", 7, 5),
        n("fila7_6", "Sol", 7, 6),
        n("fila7_7", "Mib", 7, 7),
        n("fila6_1", "Sib", 6, 1),
        n("fila6_2", "Sol", 6, 2),
        n("fila6_3", "Mib", 6, 3),
        n("fila6_4", "Do", 6, 4),
        n("fila6_5", "Lab", 6, 5),
        n("fila6_6", "Fa", 6, 6),
    ]
}