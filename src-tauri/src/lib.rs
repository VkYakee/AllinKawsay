// src-tauri/src/lib.rs
mod commands;
mod domain;
mod infra;

use commands::admin::UsuariosState;
use commands::auth::SessionState;
use commands::canciones::CancionesState;
use commands::eventos::EventosState;
use commands::recuerdos::RecuerdosState;
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
        .manage(SessionState(Mutex::new(None)))
        .manage(CancionesState::new())
        .manage(EventosState::new())
        .manage(RecuerdosState::new())
        .manage(UsuariosState::new())
        .invoke_handler(tauri::generate_handler![
            commands::system::ping,
            commands::system::app_version,
            commands::auth::login,
            commands::auth::logout,
            commands::auth::current_user,
            commands::canciones::listar_canciones,
            commands::canciones::obtener_cancion,
            commands::canciones::incrementar_reproduccion,
            commands::zampona::listar_notas_zampona,
            commands::zampona::tocar_nota,
            commands::ensayo::preparar_ensayo,
            commands::eventos::listar_eventos,
            commands::eventos::obtener_evento,
            commands::recuerdos::listar_recuerdos,
            commands::recuerdos::obtener_recuerdo,
            commands::admin::admin_stats,
            commands::admin::admin_usuarios,
            commands::reproductor::play_cancion,
            commands::reproductor::pausar_cancion,
            commands::reproductor::reanudar_cancion,
            commands::reproductor::detener_cancion,
            commands::reproductor::estado_reproductor,
        ])
        .run(tauri::generate_context!())
        .expect("error al iniciar Allin Kawsay");
}