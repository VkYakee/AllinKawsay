// src-tauri/src/lib.rs
mod commands;
mod domain;
mod infra;

use commands::auth::SessionState;
use commands::canciones::CancionesState;
use std::sync::Mutex;
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
        .manage(SessionState(Mutex::new(None)))
        .manage(CancionesState::new())
        .invoke_handler(tauri::generate_handler![
            commands::system::ping,
            commands::system::app_version,
            commands::auth::login,
            commands::auth::logout,
            commands::auth::current_user,
            commands::canciones::listar_canciones,
            commands::canciones::obtener_cancion,
            commands::canciones::incrementar_reproduccion,
        ])
        .run(tauri::generate_context!())
        .expect("error al iniciar Allin Kawsay");
}