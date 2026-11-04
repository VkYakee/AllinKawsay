// src-tauri/src/commands/admin.rs
use std::sync::Mutex;
use tauri::State;

use crate::commands::auth::SessionState;
use crate::commands::canciones::CancionesState;
use crate::commands::eventos::EventosState;
use crate::commands::recuerdos::RecuerdosState;
use crate::domain::{AdminStats, UsuarioResumen};

pub struct UsuariosState(pub Mutex<Vec<UsuarioResumen>>);

impl UsuariosState {
    pub fn new() -> Self {
        Self(Mutex::new(vec![
            UsuarioResumen {
                uid: "u1".into(),
                nombre: "Directiva Allin Kawsay".into(),
                email: "directiva@allinkawsay.pe".into(),
                rol: "admin".into(),
                foto_url: String::new(),
                baneado: false,
            },
            UsuarioResumen {
                uid: "u2".into(),
                nombre: "María Quispe".into(),
                email: "maria@allinkawsay.pe".into(),
                rol: "miembro".into(),
                foto_url: String::new(),
                baneado: false,
            },
            UsuarioResumen {
                uid: "u3".into(),
                nombre: "José Mamani".into(),
                email: "jose@allinkawsay.pe".into(),
                rol: "miembro".into(),
                foto_url: String::new(),
                baneado: false,
            },
            UsuarioResumen {
                uid: "u4".into(),
                nombre: "Rosa Ticona".into(),
                email: "rosa@allinkawsay.pe".into(),
                rol: "publico".into(),
                foto_url: String::new(),
                baneado: false,
            },
            UsuarioResumen {
                uid: "u5".into(),
                nombre: "Carlos Apaza".into(),
                email: "carlos@example.com".into(),
                rol: "publico".into(),
                foto_url: String::new(),
                baneado: true,
            },
        ]))
    }
}

fn check_admin(state: &State<'_, SessionState>) -> Result<(), String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    match &*guard {
        Some(u) if u.rol.is_admin() => Ok(()),
        _ => Err("Acceso denegado: no eres administrador".into()),
    }
}

#[tauri::command]
pub async fn admin_stats(
    session: State<'_, SessionState>,
    canciones: State<'_, CancionesState>,
    eventos: State<'_, EventosState>,
    recuerdos: State<'_, RecuerdosState>,
) -> Result<AdminStats, String> {
    check_admin(&session)?;

    let canciones_guard = canciones.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    let eventos_guard = eventos.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    let recuerdos_guard = recuerdos.0.lock().map_err(|_| "Estado bloqueado".to_string())?;

    let total_reproducciones: u32 = canciones_guard.iter().map(|c| c.reproducciones).sum();
    let total_fotos: u32 = recuerdos_guard
        .iter()
        .map(|r| r.fotos.len() as u32)
        .sum();
    let total_audios: u32 = canciones_guard
        .iter()
        .filter(|c| !c.audio_url.is_empty())
        .count() as u32;

    Ok(AdminStats {
        total_canciones: canciones_guard.len() as u32,
        total_eventos: eventos_guard.len() as u32,
        total_recuerdos: recuerdos_guard.len() as u32,
        total_reproducciones,
        total_fotos,
        total_audios,
    })
}

#[tauri::command]
pub async fn admin_usuarios(
    session: State<'_, SessionState>,
    usuarios: State<'_, UsuariosState>,
) -> Result<Vec<UsuarioResumen>, String> {
    check_admin(&session)?;
    let guard = usuarios.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.clone())
}