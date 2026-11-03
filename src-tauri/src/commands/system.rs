// src-tauri/src/commands/system.rs
use serde::Serialize;

#[derive(Serialize)]
pub struct AppInfo {
    pub name: String,
    pub version: String,
    pub platform: String,
}

/// Comando de salud. Sirve para verificar que el puente Rust ↔ JS funciona.
#[tauri::command]
pub async fn ping() -> Result<String, String> {
    Ok("pong".to_string())
}

/// Devuelve el nombre, versión y plataforma de la app.
#[tauri::command]
pub async fn app_version(app: tauri::AppHandle) -> Result<AppInfo, String> {
    let pkg = app.package_info();
    Ok(AppInfo {
        name: pkg.name.clone(),
        version: pkg.version.to_string(),
        platform: std::env::consts::OS.to_string(),
    })
}