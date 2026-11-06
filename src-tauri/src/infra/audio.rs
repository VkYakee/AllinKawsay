// src-tauri/src/infra/audio.rs
use std::collections::{HashMap, VecDeque};
use std::io::BufReader;
use std::path::{Path, PathBuf};
use std::sync::mpsc::{self, RecvTimeoutError};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

use rodio::{Decoder, OutputStream, Sink, Source};
use serde::Serialize;
use tracing::{error, info, warn};

const MIXER_CHANNELS: u16 = 2;
const MIXER_SAMPLE_RATE: u32 = 44_100;
const MAX_ZAMPONA_VOICES: usize = 8;
const ZAMPONA_GAIN: f32 = 0.55;
const ATTACK_MS: u64 = 4;
const RELEASE_MS: u64 = 12;

#[derive(Debug, Clone, Serialize)]
pub struct ReproductorState {
    pub cancion_id: Option<String>,
    pub reproduciendo: bool,
    pub cargando: bool,
    pub posicion_ms: u64,
    pub duracion_ms: u64,
    pub velocidad: f32,
    pub generation: u64,
}


impl Default for ReproductorState {
    fn default() -> Self {
        Self { cancion_id: None, reproduciendo: false, cargando: false, posicion_ms: 0, duracion_ms: 0, velocidad: 1.0, generation: 0 }
    }
}

pub type ReproductorStateShare = Arc<Mutex<ReproductorState>>;

#[derive(Debug, Clone)]
pub struct ScheduledAudioNote { pub at_ms: u64, pub sample_id: String, pub event_id: String }

struct SampleData {
    channels: u16,
    sample_rate: u32,
    samples: Vec<f32>,
}

pub enum ComandoAudio {
    Nota(String),
    Programar { generation: u64, events: Vec<ScheduledAudioNote> },
    PlayCancion { cancion_id: String, path: PathBuf },
    Buscar(u64),
    Velocidad(f32),
    Pausar,
    Reanudar,
    Detener,
}

pub struct AudioHandle {
    tx: mpsc::Sender<ComandoAudio>,
    estado: ReproductorStateShare,
}

impl AudioHandle {
    pub fn tocar_nota(&self, id: &str) {
        let _ = self.tx.send(ComandoAudio::Nota(id.to_string()));
    }

    pub fn programar(&self, generation: u64, events: Vec<ScheduledAudioNote>) -> Result<(), String> {
        if events.len() > 4096 { return Err("Máximo 4096 notas por lote".into()); }
        self.tx.send(ComandoAudio::Programar { generation, events }).map_err(|e| e.to_string())
    }

    pub fn play_cancion(&self, cancion_id: String, path: PathBuf) {
        let _ = self.tx.send(ComandoAudio::PlayCancion { cancion_id, path });
    }

    pub fn buscar(&self, position_ms: u64) { let _ = self.tx.send(ComandoAudio::Buscar(position_ms)); }

    pub fn set_velocidad(&self, speed: f32) -> Result<(), String> {
        if !speed.is_finite() || !(0.25..=2.0).contains(&speed) { return Err("La velocidad debe estar entre 0.25x y 2.0x".into()); }
        self.tx.send(ComandoAudio::Velocidad(speed)).map_err(|e| e.to_string())
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

pub fn spawn(resource_dir: PathBuf) -> AudioHandle {
    let (tx, rx) = mpsc::channel::<ComandoAudio>();
    let estado: ReproductorStateShare = Arc::new(Mutex::new(ReproductorState::default()));
    let estado_thread = estado.clone();

    thread::spawn(move || {
        let (_stream, stream_handle) = match OutputStream::try_default() {
            Ok(v) => {
                info!("Audio device abierto");
                v
            }
            Err(e) => {
                error!("No se pudo abrir el audio device: {e}");
                return;
            }
        };

        let samples = cargar_samples(&resource_dir);
        info!("Muestras de zampoña precargadas: {}", samples.len());

        // Un solo Sink persistente alimenta el mixer dinámico. Las notas se agregan
        // como voces al mixer; nunca se crea un Sink independiente por nota.
        let (mut zampona_mixer, mixer_source) =
            rodio::dynamic_mixer::mixer::<f32>(MIXER_CHANNELS, MIXER_SAMPLE_RATE);
        let mut sink_zampona = match Sink::try_new(&stream_handle) {
            Ok(sink) => {
                // El Zero infinito mantiene vivo el Sink incluso cuando no hay voces.
                sink.append(mixer_source.mix(rodio::source::Zero::<f32>::new(
                    MIXER_CHANNELS,
                    MIXER_SAMPLE_RATE,
                )));
                sink.play();
                sink
            }
            Err(e) => {
                error!("No se pudo crear el mixer de zampoña: {e}");
                return;
            }
        };

        let mut sink_cancion: Option<Sink> = None;
        let mut voces_activas: VecDeque<(Instant, Duration)> = VecDeque::new();
        let mut scheduled: VecDeque<ScheduledAudioNote> = VecDeque::new();

        loop {
            let cmd = match rx.recv_timeout(Duration::from_millis(16)) {
                Ok(cmd) => Some(cmd),
                Err(RecvTimeoutError::Timeout) => None,
                Err(RecvTimeoutError::Disconnected) => break,
            };

            if let Some(cmd) = cmd {
                match cmd {
                    ComandoAudio::Programar { generation, mut events } => {
                        let current_generation = estado_thread.lock().unwrap().generation;
                        if generation != current_generation { warn!("Lote de zampoña ignorado: generación obsoleta"); continue; }
                        events.sort_by_key(|event| event.at_ms);
                        scheduled = events.into();
                    }
                    ComandoAudio::Nota(id) => {
                        let Some(sample) = samples.get(&id) else {
                            warn!("Nota no encontrada: {id}");
                            continue;
                        };

                        let now = Instant::now();
                        prune_voices(&mut voces_activas, now);

                        // Límite explícito para que una ráfaga no acumule voces ilimitadas.
                        if voces_activas.len() >= MAX_ZAMPONA_VOICES {
                            warn!("Se descartó {id}: límite de voces simultáneas alcanzado");
                            continue;
                        }

                        let canales = sample.channels.max(1);
                        let frames = sample.samples.len() / canales as usize;
                        if frames == 0 || sample.sample_rate == 0 {
                            continue;
                        }

                        // Aplicamos una envolvente corta a la muestra PCM antes de
                        // incorporarla al mixer: evita iniciar/cortar la onda en seco.
                        // La preparación ocurre en el hilo de comandos, no en el callback.
                        let attack_frames =
                            ((sample.sample_rate as u64 * ATTACK_MS) / 1_000).max(1) as usize;
                        let release_frames =
                            ((sample.sample_rate as u64 * RELEASE_MS) / 1_000).max(1) as usize;
                        let mut pcm = sample.samples.clone();

                        for (index, value) in pcm.iter_mut().enumerate() {
                            let frame = index / canales as usize;
                            let from_start = (frame as f32 / attack_frames as f32).min(1.0);
                            let from_end = ((frames.saturating_sub(frame + 1)) as f32
                                / release_frames as f32)
                                .min(1.0);
                            let envelope = from_start.min(from_end);
                            *value *= envelope * ZAMPONA_GAIN;
                        }

                        let duration = Duration::from_secs_f64(
                            frames as f64 / sample.sample_rate as f64,
                        );
                        let source = rodio::buffer::SamplesBuffer::new(
                            sample.channels,
                            sample.sample_rate,
                            pcm,
                        );
                        zampona_mixer.add(source);
                        voces_activas.push_back((now, duration));
                    }

                    ComandoAudio::PlayCancion { cancion_id, path } => {
                        scheduled.clear();
                        if let Some(sink) = sink_cancion.take() {
                            sink.stop();
                        }

                        // Invalidar las voces de la reproducción anterior. Reiniciamos
                        // el mixer completo al cambiar de canción para vaciar sus colas.
                        sink_zampona.stop();
                        let (nuevo_mixer, nueva_fuente) =
                            rodio::dynamic_mixer::mixer::<f32>(MIXER_CHANNELS, MIXER_SAMPLE_RATE);
                        let nuevo_sink = match Sink::try_new(&stream_handle) {
                            Ok(sink) => sink,
                            Err(e) => {
                                warn!("No se pudo reiniciar el mixer de zampoña: {e}");
                                continue;
                            }
                        };
                        nuevo_sink.append(nueva_fuente.mix(rodio::source::Zero::<f32>::new(
                            MIXER_CHANNELS,
                            MIXER_SAMPLE_RATE,
                        )));
                        nuevo_sink.play();
                        zampona_mixer = nuevo_mixer;
                        sink_zampona = nuevo_sink;
                        voces_activas.clear();

                        {
                            let mut state = estado_thread.lock().unwrap();
                            state.cancion_id = Some(cancion_id.clone());
                            state.cargando = true;
                            state.reproduciendo = false;
                            state.posicion_ms = 0;
                            state.duracion_ms = 0;
                            state.velocidad = 1.0;
                            state.generation = state.generation.wrapping_add(1);
                        }

                        let file = match std::fs::File::open(&path) {
                            Ok(file) => file,
                            Err(e) => {
                                warn!("No se pudo abrir archivo {:?}: {e}", path);
                                estado_thread.lock().unwrap().cargando = false;
                                continue;
                            }
                        };

                        let decoder = match Decoder::new(BufReader::new(file)) {
                            Ok(decoder) => decoder,
                            Err(e) => {
                                warn!("No se pudo decodificar {:?}: {e}", path);
                                estado_thread.lock().unwrap().cargando = false;
                                continue;
                            }
                        };

                        let duration = decoder.total_duration().unwrap_or_default();
                        let sink = match Sink::try_new(&stream_handle) {
                            Ok(sink) => sink,
                            Err(e) => {
                                warn!("No se pudo crear sink de canción: {e}");
                                estado_thread.lock().unwrap().cargando = false;
                                continue;
                            }
                        };

                        sink.append(decoder);
                        sink.play();
                        {
                            let mut state = estado_thread.lock().unwrap();
                            state.reproduciendo = true;
                            state.cargando = false;
                            state.duracion_ms = duration.as_millis() as u64;
                        }
                        sink_cancion = Some(sink);
                    }

                    ComandoAudio::Buscar(position_ms) => {
                        scheduled.clear();
                        {
                            let mut state = estado_thread.lock().unwrap();
                            state.generation = state.generation.wrapping_add(1);
                        }

                        // Un seek invalida las notas de la posición anterior: no deben
                        // continuar sonando después de saltar a otro punto de la canción.
                        sink_zampona.stop();
                        let (nuevo_mixer, nueva_fuente) =
                            rodio::dynamic_mixer::mixer::<f32>(MIXER_CHANNELS, MIXER_SAMPLE_RATE);
                        match Sink::try_new(&stream_handle) {
                            Ok(nuevo_sink) => {
                                nuevo_sink.append(nueva_fuente.mix(rodio::source::Zero::<f32>::new(
                                    MIXER_CHANNELS,
                                    MIXER_SAMPLE_RATE,
                                )));
                                nuevo_sink.play();
                                zampona_mixer = nuevo_mixer;
                                sink_zampona = nuevo_sink;
                            }
                            Err(e) => warn!("No se pudo reiniciar el mixer tras buscar: {e}"),
                        }
                        voces_activas.clear();

                        if let Some(sink) = &sink_cancion {
                            match sink.try_seek(Duration::from_millis(position_ms)) {
                                Ok(()) => estado_thread.lock().unwrap().posicion_ms = position_ms,
                                Err(e) => warn!("No se pudo buscar a {}ms: {}", position_ms, e),
                            }
                        }
                    }

                    ComandoAudio::Velocidad(speed) => {
                        scheduled.clear();
                        if let Some(sink) = &sink_cancion {
                            sink.set_speed(speed);
                            let mut state = estado_thread.lock().unwrap();
                            state.velocidad = speed;
                            state.generation = state.generation.wrapping_add(1);
                        }
                    }

                    ComandoAudio::Pausar => {
                        scheduled.clear();
                        { let mut state = estado_thread.lock().unwrap(); state.generation = state.generation.wrapping_add(1); }
                        if let Some(sink) = &sink_cancion {
                            sink.pause();
                            estado_thread.lock().unwrap().reproduciendo = false;
                        }
                        sink_zampona.pause();
                    }

                    ComandoAudio::Reanudar => {
                        scheduled.clear();
                        { let mut state = estado_thread.lock().unwrap(); state.generation = state.generation.wrapping_add(1); }
                        if let Some(sink) = &sink_cancion {
                            sink.play();
                            estado_thread.lock().unwrap().reproduciendo = true;
                        }
                        sink_zampona.play();
                    }

                    ComandoAudio::Detener => {
                        scheduled.clear();
                        if let Some(sink) = sink_cancion.take() {
                            sink.stop();
                        }
                        sink_zampona.stop();
                        let (nuevo_mixer, nueva_fuente) =
                            rodio::dynamic_mixer::mixer::<f32>(MIXER_CHANNELS, MIXER_SAMPLE_RATE);
                        if let Ok(nuevo_sink) = Sink::try_new(&stream_handle) {
                            nuevo_sink.append(nueva_fuente.mix(rodio::source::Zero::<f32>::new(
                                MIXER_CHANNELS,
                                MIXER_SAMPLE_RATE,
                            )));
                            nuevo_sink.play();
                            zampona_mixer = nuevo_mixer;
                            sink_zampona = nuevo_sink;
                        }
                        voces_activas.clear();
                        let mut state = estado_thread.lock().unwrap();
                        let generation = state.generation.wrapping_add(1);
                        *state = ReproductorState { generation, ..Default::default() };
                    }
                }
            }

            if let Some(sink) = &sink_cancion {
                let position = sink.get_pos();
                let mut state = estado_thread.lock().unwrap();
                state.posicion_ms = position.as_millis() as u64;
                if sink.empty() && state.reproduciendo { state.reproduciendo = false; scheduled.clear(); }
            }
            let now = Instant::now();
            prune_voices(&mut voces_activas, now);
            let (clock_ms, playing) = if let Some(sink) = &sink_cancion {
                let position = sink.get_pos().as_millis() as u64;
                let mut st = estado_thread.lock().unwrap(); st.posicion_ms = position;
                (position, st.reproduciendo)
            } else { (0, false) };
            if playing {
                while scheduled.front().map(|event| event.at_ms <= clock_ms).unwrap_or(false) {
                    let event = scheduled.pop_front().unwrap();
                    if let Some(sample) = samples.get(&event.sample_id) {
                        let channels = sample.channels.max(1) as usize;
                        let frames = sample.samples.len() / channels;
                        if frames > 0 && sample.sample_rate > 0 && voces_activas.len() < MAX_ZAMPONA_VOICES {
                            let attack = ((sample.sample_rate as u64 * ATTACK_MS) / 1000).max(1) as usize;
                            let release = ((sample.sample_rate as u64 * RELEASE_MS) / 1000).max(1) as usize;
                            let mut pcm = sample.samples.clone();
                            for (i, value) in pcm.iter_mut().enumerate() {
                                let frame = i / channels;
                                let env = (frame as f32 / attack as f32).min(1.0).min((frames.saturating_sub(frame + 1)) as f32 / release as f32);
                                *value *= env * ZAMPONA_GAIN;
                            }
                            zampona_mixer.add(rodio::buffer::SamplesBuffer::new(sample.channels, sample.sample_rate, pcm));
                            voces_activas.push_back((now, Duration::from_secs_f64(frames as f64 / sample.sample_rate as f64)));
                        }
                    } else { warn!("Muestra programada inexistente: {}", event.sample_id); }
                }
            } else { scheduled.clear(); }
        }
    });

    AudioHandle { tx, estado }
}

fn prune_voices(voices: &mut VecDeque<(Instant, Duration)>, now: Instant) {
    while let Some((started, duration)) = voices.front() {
        if now.saturating_duration_since(*started) >= *duration { voices.pop_front(); } else { break; }
    }
}

fn cargar_samples(resource_dir: &Path) -> HashMap<String, SampleData> {
    let mut map = HashMap::new();
    let candidatos = [
        resource_dir.join("assets").join("zampona"),
        resource_dir.join("zampona"),
        resource_dir.to_path_buf(),
    ];
    let base = candidatos
        .iter()
        .find(|path| path.exists())
        .cloned()
        .unwrap_or_else(|| resource_dir.to_path_buf());

    let ids = [
        "fila7_1", "fila7_2", "fila7_3", "fila7_4", "fila7_5", "fila7_6", "fila7_7",
        "fila6_1", "fila6_2", "fila6_3", "fila6_4", "fila6_5", "fila6_6",
    ];

    for id in ids {
        let path = base.join(format!("{id}.ogg"));
        match std::fs::File::open(&path) {
            Ok(file) => {
                let reader = BufReader::new(file);
                match Decoder::new(reader) {
                    Ok(decoder) => {
                        let channels = decoder.channels();
                        let sample_rate = decoder.sample_rate();
                        let samples: Vec<f32> = decoder.convert_samples().collect();
                        if !samples.is_empty() {
                            map.insert(
                                id.to_string(),
                                SampleData {
                                    channels,
                                    sample_rate,
                                    samples,
                                },
                            );
                        }
                    }
                    Err(e) => warn!("No se pudo decodificar {id}: {e}"),
                }
            }
            Err(e) => warn!("No se pudo leer {:?}: {e}", path),
        }
    }
    map
}
