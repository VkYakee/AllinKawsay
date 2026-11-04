// src-tauri/src/infra/audio.rs
use std::collections::HashMap;
use std::io::{BufReader, Cursor};
use std::path::PathBuf;
use std::sync::mpsc;
use std::thread;

use rodio::{Decoder, OutputStream, Sink, Source};
use tracing::{error, info, warn};

/// Handle para enviar peticiones al thread de audio.
pub struct AudioHandle {
    tx: mpsc::Sender<String>,
}

impl AudioHandle {
    /// Envía una nota al thread de audio. No bloquea, no falla.
    pub fn tocar(&self, id: &str) {
        let _ = self.tx.send(id.to_string());
    }
}

/// Levanta el thread de audio y precarga los samples.
pub fn spawn(resource_dir: PathBuf) -> AudioHandle {
    let (tx, rx) = mpsc::channel::<String>();

    thread::spawn(move || {
        let (_stream, stream_handle) = match OutputStream::try_default() {
            Ok(v) => {
                info!("🔊 Audio device abierto");
                v
            }
            Err(e) => {
                error!("❌ No se pudo abrir el audio device: {e}");
                return;
            }
        };

        let samples = cargar_samples(&resource_dir);
        info!("🎵 Samples precargados: {}", samples.len());

        while let Ok(id) = rx.recv() {
            let Some(data) = samples.get(&id) else {
                warn!("Nota no encontrada: {id}");
                continue;
            };
            match Sink::try_new(&stream_handle) {
                Ok(sink) => {
                    sink.append(rodio::buffer::SamplesBuffer::new(
                        2,
                        44100,
                        data.clone(),
                    ));
                    sink.detach();
                }
                Err(e) => warn!("No se pudo crear sink: {e}"),
            }
        }
    });

    AudioHandle { tx }
}

fn cargar_samples(resource_dir: &PathBuf) -> HashMap<String, Vec<f32>> {
    let mut map = HashMap::new();

    // Tauri copia los resources manteniendo la ruta relativa del config.
    // Buscamos en varias rutas posibles por si cambia entre plataformas.
    let candidatos = [
        resource_dir.join("assets").join("zampona"),
        resource_dir.join("zampona"),
        resource_dir.to_path_buf(),
    ];

    let base = candidatos
        .iter()
        .find(|p| p.exists())
        .cloned()
        .unwrap_or_else(|| resource_dir.clone());

    let ids = [
        "fila7_1", "fila7_2", "fila7_3", "fila7_4", "fila7_5", "fila7_6", "fila7_7",
        "fila6_1", "fila6_2", "fila6_3", "fila6_4", "fila6_5", "fila6_6",
    ];

    for id in ids {
        let path = base.join(format!("{id}.ogg"));
        match std::fs::read(&path) {
            Ok(bytes) => {
                let cursor = Cursor::new(bytes);
                let reader = BufReader::new(cursor);
                match Decoder::new(reader) {
                    Ok(decoder) => {
                        let pcm: Vec<f32> = decoder.convert_samples().collect();
                        map.insert(id.to_string(), pcm);
                    }
                    Err(e) => warn!("No se pudo decodificar {id}: {e}"),
                }
            }
            Err(e) => warn!("No se pudo leer {:?}: {e}", path),
        }
    }

    map
}