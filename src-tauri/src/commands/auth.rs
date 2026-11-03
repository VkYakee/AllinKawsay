// src-tauri/src/commands/auth.rs
use std::sync::Mutex;
use tauri::State;

use crate::domain::{User, UserRole};

pub struct SessionState(pub Mutex<Option<User>>);

#[derive(serde::Deserialize)]
pub struct LoginPayload {
    pub email: String,
    pub password: String,
}

#[tauri::command]
pub async fn login(
    payload: LoginPayload,
    state: State<'_, SessionState>,
) -> Result<User, String> {
    if payload.email.trim().is_empty() || payload.password.len() < 4 {
        return Err("Credenciales inválidas".into());
    }
    if !payload.email.contains('@') {
        return Err("Email inválido".into());
    }

    // TODO: Firebase Auth real (fase posterior)
    tokio::time::sleep(std::time::Duration::from_millis(600)).await;

    let nombre = payload
        .email
        .split('@')
        .next()
        .unwrap_or("Usuario")
        .to_string();
    let short_uid: String = payload.email.chars().take(6).collect();

    let user = User {
        uid: format!("demo_{short_uid}"),
        nombre,
        email: payload.email.clone(),
        rol: UserRole::Admin,
        foto_url: String::new(),
    };

    let mut guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    *guard = Some(user.clone());

    Ok(user)
}

#[tauri::command]
pub async fn logout(state: State<'_, SessionState>) -> Result<(), String> {
    let mut guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    *guard = None;
    Ok(())
}

#[tauri::command]
pub async fn current_user(state: State<'_, SessionState>) -> Result<Option<User>, String> {
    let guard = state.0.lock().map_err(|_| "Estado bloqueado".to_string())?;
    Ok(guard.clone())
}