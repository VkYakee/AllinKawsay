# Migración progresiva de Dart a Rust — AllinKawsay 3.0

## Decisión de arquitectura

La aplicación activa es la reconstrucción Svelte + TypeScript + Tauri 2, con Rust para las capacidades nativas. La convivencia con Flutter/Dart es transitoria y no constituye la arquitectura objetivo.

- **Interfaz y lógica de producto:** Svelte 5 + TypeScript.
- **Capacidades nativas y motor de audio:** Rust mediante Tauri 2.
- **Servicios remotos:** Firebase/Firestore, Cloudinary y OneSignal desde la capa activa que corresponda.
- **Dart/Flutter:** legado de referencia durante la migración; no añadir nuevas funciones ni dependencias salvo necesidad demostrable de transición.

## Auditoría del repositorio

Revisión de la rama `rebuild/ensayo-engine`, 6 de noviembre de 2026:

- `package.json` define Vite/Svelte/Tauri y no contiene dependencias Flutter.
- `src-tauri/Cargo.toml` contiene el crate Rust y el motor de audio `rodio`.
- `.github/workflows/validate-android.yml` instala Node, Java, Rust y Android SDK; construye Android mediante Tauri y no ejecuta Flutter.
- `src/App.svelte` es el punto de entrada de la aplicación reconstruida.
- `pubspec.yaml` y el árbol `lib/**/*.dart` siguen presentes. El árbol Dart contiene más de un centenar de archivos entre pantallas, widgets, modelos y servicios.
- El workflow antiguo de release Flutter no forma parte del flujo activo; el workflow de build anterior está deshabilitado.

Por tanto, Dart ya no forma parte del camino normal de compilación de la rama reconstruida, pero sus fuentes todavía contienen referencias útiles al esquema Firestore, comportamientos anteriores y funcionalidades que deben contrastarse antes de retirar archivos.

## Reglas para retirar legado

No eliminar carpetas completas por lenguaje. Cada bloque se clasifica por función y evidencia:

1. **Sustituido:** existe una implementación activa en Svelte/Rust y se verificó que cubre el comportamiento y los datos.
2. **Referencia de migración:** no se ejecuta, pero conserva reglas de negocio, formatos históricos o compatibilidad que todavía no se han trasladado.
3. **Dependencia residual:** manifiestos, workflows, scripts o configuración exclusivamente Flutter que no intervienen en la compilación activa.
4. **Pendiente:** función Dart sin equivalente completo o con integración todavía necesaria.

La eliminación de una pieza debe acompañarse de:
- búsqueda de referencias desde los entrypoints y workflows activos;
- comparación de modelo y formato de datos;
- comprobación de que no se pierde compatibilidad con documentos Firestore existentes;
- validación Android Tauri después del cambio.

## Áreas que requieren comparación antes de borrar

- **Audio:** `lib/services/player_service.dart`, `reproduccion_service.dart`, `zampona_service.dart` y `lib/features/grabar/**` frente a `src-tauri/src/infra/audio.rs`, comandos Rust y el sincronizador Svelte. La reconstrucción de Ensayo no debe recuperar herramientas de edición/división de audio que ya fueron descartadas.
- **Modelos y Firestore:** `lib/models/**` frente a `src/lib/services/**`. Revisar especialmente campos históricos como `categoriaId`, `letras`, `setlist`, `tipo`, `numerofonia` y estructuras alternativas de estrofas.
- **Autenticación y servicios:** auth, notificaciones, caché, permisos, actualizaciones y respaldos frente a servicios Svelte/Tauri actuales.
- **Pantallas:** cada módulo Dart debe tener una pantalla o flujo activo equivalente antes de considerar su eliminación definitiva.

## Hallazgo corregido durante esta auditoría

El modelo Dart de canción ya persistía `categoriaId`, pero el modelo/servicio Svelte 3.0 no lo conservaba al leer ni al guardar. Se restauró el campo en el servicio y en el formulario de alta/edición. Además, la eliminación de categorías ahora consulta si alguna canción sigue asignada y la bloquea cuando corresponde, evitando dejar referencias huérfanas.

## Secuencia de limpieza

1. Completar paridad funcional de módulos y servicios.
2. Migrar formatos/datos que todavía solo estén representados en Dart.
3. Retirar workflows, scripts y configuración Flutter que no tengan consumidores.
4. Retirar fuentes Dart ya sustituidas, por grupos pequeños y verificables.
5. Retirar `pubspec.yaml`, lockfiles y configuración Flutter cuando no quede ninguna tarea de referencia que los necesite.
6. Validar compilación Android Tauri e integraciones después de cada bloque significativo.

**Estado:** auditoría inicial; no se elimina todavía `lib/` ni el manifiesto Flutter porque siguen siendo material de comparación para completar la migración sin perder compatibilidad.
