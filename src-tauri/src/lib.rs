// src-tauri/src/lib.rs
mod commands;
mod domain;
mod infra;

use std::sync::Mutex;
use tauri::Manager;
use tracing_subscriber::EnvFilter;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    tauri::Builder::default()
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_http::init())
        .setup(|app| {
            let resource_dir = app
                .path()
                .resource_dir()
                .unwrap_or_else(|_| std::path::PathBuf::from("."));
            let audio = infra::audio::spawn(resource_dir);
            app.manage(audio);
            Ok(())
        })
        .manage::<()>(())
        .invoke_handler(tauri::generate_handler![
            commands::system::ping,
            commands::system::app_version,
            commands::zampona::listar_notas_zampona,
            commands::zampona::tocar_nota,
            commands::reproductor::play_cancion,
            commands::reproductor::pausar_cancion,
            commands::reproductor::reanudar_cancion,
            commands::reproductor::detener_cancion,
            commands::reproductor::estado_reproductor,
            commands::reproductor::buscar_cancion,
            commands::reproductor::velocidad_cancion,
        ])
        .run(tauri::generate_context!())
        .expect("error al iniciar Allin Kawsay");

    // Silenciar warning de import no usado de Mutex
    let _ = Mutex::new(());
}