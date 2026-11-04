// src-tauri/src/infra/audio.rs
use std::collections::HashMap;
use std::io::BufReader;
use std::path::{Path, PathBuf};
use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

use rodio::{Decoder, OutputStream, Sink, Source};
use serde::Serialize;
use tracing::{error, info, warn};

// ─── Estado público del reproductor (compartido con comandos) ───
#[derive(Debug, Clone, Serialize, Default)]
pub struct ReproductorState {
    pub cancion_id: Option<String>,
    pub reproduciendo: bool,
    pub cargando: bool,
    pub posicion_ms: u64,
    pub duracion_ms: u64,
}

pub type ReproductorStateShare = Arc<Mutex<ReproductorState>>;

// ─── Comandos internos al thread de audio ───
pub enum ComandoAudio {
    Nota(String),
    PlayCancion { cancion_id: String, path: PathBuf },
    Pausar,
    Reanudar,
    Detener,
}

// ─── Handle público ───
pub struct AudioHandle {
    tx: mpsc::Sender<ComandoAudio>,
    estado: ReproductorStateShare,
}

impl AudioHandle {
    pub fn tocar_nota(&self, id: &str) {
        let _ = self.tx.send(ComandoAudio::Nota(id.to_string()));
    }

    pub fn play_cancion(&self, cancion_id: String, path: PathBuf) {
        let _ = self.tx.send(ComandoAudio::PlayCancion { cancion_id, path });
    }

    pub fn pausar(&self) {
        let _ = self.tx.send(ComandoAudio::Pausar);
    }

    pub fn reanudar(&self) {
        let _ = self.tx.send(ComandoAudio::Reanudar);
    }

    pub fn detener(&self) {
        let _ = self.tx.send(ComandoAudio::Detener);
    }

    pub fn estado(&self) -> ReproductorStateShare {
        self.estado.clone()
    }
}

// ─── Levanta el thread de audio ───
pub fn spawn(resource_dir: PathBuf) -> AudioHandle {
    let (tx, rx) = mpsc::channel::<ComandoAudio>();
    let estado: ReproductorStateShare = Arc::new(Mutex::new(ReproductorState::default()));
    let estado_thread = estado.clone();

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

        let mut sink_cancion: Option<Sink> = None;
        let mut duracion_actual = Duration::ZERO;

        while let Ok(cmd) = rx.recv() {
            match cmd {
                ComandoAudio::Nota(id) => {
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
                        Err(e) => warn!("No se pudo crear sink de nota: {e}"),
                    }
                }

                ComandoAudio::PlayCancion { cancion_id, path } => {
                    if let Some(s) = &sink_cancion {
                        s.stop();
                    }

                    {
                        let mut g = estado_thread.lock().unwrap();
                        g.cancion_id = Some(cancion_id.clone());
                        g.cargando = true;
                        g.reproduciendo = false;
                        g.posicion_ms = 0;
                        g.duracion_ms = 0;
                    }

                    let file = match std::fs::File::open(&path) {
                        Ok(f) => f,
                        Err(e) => {
                            warn!("No se pudo abrir archivo {:?}: {e}", path);
                            estado_thread.lock().unwrap().cargando = false;
                            continue;
                        }
                    };

                    let decoder = match Decoder::new(BufReader::new(file)) {
                        Ok(d) => d,
                        Err(e) => {
                            warn!("No se pudo decodificar {:?}: {e}", path);
                            estado_thread.lock().unwrap().cargando = false;
                            continue;
                        }
                    };

                    duracion_actual = decoder.total_duration().unwrap_or(Duration::ZERO);

                    let sink = match Sink::try_new(&stream_handle) {
                        Ok(s) => s,
                        Err(e) => {
                            warn!("No se pudo crear sink de canción: {e}");
                            estado_thread.lock().unwrap().cargando = false;
                            continue;
                        }
                    };

                    sink.append(decoder);
                    sink.play();

                    {
                        let mut g = estado_thread.lock().unwrap();
                        g.reproduciendo = true;
                        g.cargando = false;
                        g.duracion_ms = duracion_actual.as_millis() as u64;
                    }

                    sink_cancion = Some(sink);
                }

                ComandoAudio::Pausar => {
                    if let Some(s) = &sink_cancion {
                        s.pause();
                        estado_thread.lock().unwrap().reproduciendo = false;
                    }
                }

                ComandoAudio::Reanudar => {
                    if let Some(s) = &sink_cancion {
                        s.play();
                        estado_thread.lock().unwrap().reproduciendo = true;
                    }
                }

                ComandoAudio::Detener => {
                    if let Some(s) = sink_cancion.take() {
                        s.stop();
                    }
                    *estado_thread.lock().unwrap() = ReproductorState::default();
                }
            }

            // Actualizar posición si hay canción activa
            if let Some(s) = &sink_cancion {
                let pos = s.get_pos();
                let mut g = estado_thread.lock().unwrap();
                g.posicion_ms = pos.as_millis() as u64;

                if s.empty() && g.reproduciendo {
                    // terminó
                    g.reproduciendo = false;
                }
            }
        }
    });

    AudioHandle { tx, estado }
}

fn cargar_samples(resource_dir: &Path) -> HashMap<String, Vec<f32>> {
    let mut map = HashMap::new();

    let candidatos = [
        resource_dir.join("assets").join("zampona"),
        resource_dir.join("zampona"),
        resource_dir.to_path_buf(),
    ];

    let base = candidatos
        .iter()
        .find(|p| p.exists())
        .cloned()
        .unwrap_or_else(|| resource_dir.to_path_buf());

    let ids = [
        "fila7_1", "fila7_2", "fila7_3", "fila7_4", "fila7_5", "fila7_6", "fila7_7",
        "fila6_1", "fila6_2", "fila6_3", "fila6_4", "fila6_5", "fila6_6",
    ];

    for id in ids {
        let path = base.join(format!("{id}.ogg"));
        match std::fs::read(&path) {
            Ok(bytes) => {
                let cursor = std::io::Cursor::new(bytes);
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