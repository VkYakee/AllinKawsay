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
- Se eliminó el workflow antiguo de release y la configuración Android Flutter (`android_config/`), conservando únicamente `android_config/icono.png`, que el workflow Tauri utiliza para generar iconos.

Por tanto, Dart ya no forma parte del camino normal de compilación de la rama reconstruida, pero sus fuentes todavía contienen referencias útiles al esquema Firestore, comportamientos anteriores y funcionalidades que deben contrastarse antes de retirar archivos.


## Revisión de integraciones — 6 de noviembre de 2026

### Firebase

- La aplicación activa inicializa Firebase de forma diferida y reutiliza la instancia existente.
- Auth y Firestore se consumen desde los servicios TypeScript.
- La API key web de Firebase incluida en el cliente identifica el proyecto; no debe tratarse como secreto. La protección real depende de Firebase Security Rules, App Check cuando corresponda y restricciones de API.
- Pendiente: revisar reglas publicadas y permisos efectivos. No se modifican reglas ni credenciales desde esta auditoría.

### Cloudinary

- El servicio activo usa unsigned upload preset y valida que la respuesta incluya `secure_url`.
- Las rutas nuevas están separadas por tipo (`canciones/audio`, `canciones/imagenes`, `recuerdos/fotos`, `recuerdos/videos`), mientras el servicio Dart antiguo agrupaba parte del contenido por ID de canción.
- No cambiar ni borrar los archivos remotos existentes: las URLs guardadas en Firestore siguen siendo referencias válidas aunque cambie la carpeta de futuras subidas.
- Pendiente: verificar el preset, límites y políticas de formatos/tamaño en el panel de Cloudinary; no se deben inventar ni codificar límites sin esa evidencia.

### OneSignal

- La aplicación activa usa el SDK web v16 y asocia/desasocia el UID de Firebase.
- El inicio del SDK es opcional. Se corrigió `src/App.svelte` para capturar el rechazo de inicialización: un fallo de OneSignal ya no deja una promesa rechazada sin gestionar durante el arranque.
- No se solicita permiso de notificaciones automáticamente al abrir la app; debe pedirse desde una acción explícita del usuario.
- **Riesgo del legado:** `lib/services/onesignal_service.dart` enviaba notificaciones REST desde el cliente leyendo `restApiKey` de Firestore. Una clave REST no debe exponerse a una app cliente ni leerse desde una colección accesible desde el dispositivo. No se migrará ese envío a TypeScript/Rust cliente. Cuando se reconstruya el panel de notificaciones, el envío debe pasar por un backend confiable (por ejemplo Cloud Functions) con autorización administrativa y secretos en entorno servidor.
- Pendiente: verificar la configuración de dominios/orígenes y el flujo de permiso en Android; el SDK web y el SDK Flutter no son equivalentes automáticamente.

### Almacenamiento local y motor nativo

- La sincronización de Ensayo se guarda como JSON versionado por canción en almacenamiento local, con validación al leer y antes de guardar.
- El audio original permanece externo y sin modificar.
- El motor de audio usa Rust/rodio; las dependencias Flutter de audio no deben seguir ampliándose.
- Pendiente: probar persistencia tras cerrar/reabrir la app Android y comprobar salida/latencia auditivamente en dispositivo real. La compilación por sí sola no demuestra ausencia de pop/plop.

### Caché multimedia

Los servicios Dart tenían caché persistente LRU para audio y recuerdos. La pantalla 3.0 solo cuenta y limpia archivos temporales `allin_` en el directorio temporal de Tauri; no es una caché offline equivalente. La UI ahora declara esa limitación y no promete conservar canciones, imágenes o videos sin conexión. La caché LRU queda pendiente de migración solo si se decide recuperar esa función.

### Clasificación inicial de legado Dart

| Bloque | Estado | Decisión |
|---|---|---|
| `lib/services/onesignal_service.dart` | Pendiente de sustituir con backend seguro | No migrar envío REST cliente; rescatar solo la asociación de identidad ya cubierta por SDK activo |
| `lib/services/storage_service.dart` | Parcialmente sustituido | Mantener como referencia hasta comprobar todas las subidas y referencias URL |
| `lib/features/grabar/**` | No migrar en bloque | Excluir las herramientas de dividir/editar audio descartadas; rescatar solo reglas de sincronización útiles |
| `lib/**` pantallas/modelos | Referencia/pendiente según módulo | Comparar campo por campo y flujo por flujo antes de borrar |
| `pubspec.yaml` y lockfile Flutter | Residual candidato | Retirar cuando termine la comparación de modelos y no queden scripts/workflows Flutter activos |

## Correcciones incorporadas durante la continuación

- La lectura Svelte conserva el orden histórico de las listas `fila6` y `fila7`, interpreta separadores de texto y conserva títulos de letras por partes. Al editar, los títulos se mantienen cuando el texto no cambia y se reasignan por párrafo cuando se reorganiza.
- El borrado de categorías comprueba referencias desde canciones dentro de una transacción Firestore.
- La carga a Cloudinary rechaza archivos vacíos y tipos MIME incompatibles, pero tolera `application/octet-stream` de selectores Android; los límites reales siguen dependiendo del preset del proveedor.
- La descarga nativa de audio acepta únicamente HTTPS desde el recurso Cloudinary del proyecto, valida el ID de canción y escribe por fragmentos en vez de cargar todo el archivo en memoria.
- El cliente valida los roles recibidos de Firestore y bloquea la interfaz a cuentas marcadas como suspendidas. Esto mejora la UX, pero no sustituye las reglas de seguridad del servidor.
- La configuración efectiva de Firebase Security Rules no está versionada en este repositorio; debe revisarse en Firebase Console antes de considerar cerrada la auditoría de permisos.

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

## Compatibilidad de datos recuperada

En la revisión del 6 de noviembre de 2026 se amplió el mapper Svelte de canciones para aceptar formatos históricos que el modelo Dart ya reconocía:

- `estrofas`, `compases` y `numerofoniaEstructurada` como fuentes alternativas de partitura.
- Columnas directas, eventos, arreglos `fila7`/`fila6` y texto con separadores `/` y `\\`.
- Tiempos por columna `timings7` y `timings6`.
- `tipo` y `numerofonia` al leer documentos antiguos.
- Partes de letra con título: si se editan otros campos o se deja intacto el texto combinado, se conservan sus títulos y divisiones. Si se modifica el texto en el editor actual, se guarda como una sola parte porque la interfaz todavía no edita títulos por separado.

Esto no completa todavía la paridad del antiguo modelo: `setlist` y el flujo de edición de audio siguen fuera del alcance acordado para Ensayo y no deben reintroducirse. Los campos originales no se borran al editar una canción desde el formulario nuevo.

## Integraciones y residuos Android

- **Firebase:** la app 3.0 usa Firebase JS SDK en `src/lib/config/firebase.ts` y `src/lib/services/*`; `firebase/google-services.json` y los servicios Dart no forman parte de ese cliente. La clave `apiKey` del SDK web identifica el proyecto, no sustituye las reglas de seguridad de Firestore.
- **Sesión Firebase:** `authService.currentUser()` ahora conserva la sesión autenticada si Firestore falla temporalmente al leer el perfil, aplicando privilegios públicos por defecto hasta poder leer el rol. Así no se confunde un fallo de red/permisos con un cierre de sesión; el acceso administrativo no se concede durante esa degradación.
- **Cloudinary:** la app 3.0 ya usa subida directa con preset unsigned desde `src/lib/services/cloudinary.ts`. El servicio Dart no debe seguir ampliándose. Mantener límites y permisos en la configuración de Cloudinary; no introducir secretos de API en el cliente.
- **OneSignal:** el cliente activo carga el SDK web en `src/App.svelte`. El servicio Dart antiguo también enviaba REST desde el dispositivo leyendo `restApiKey` de Firestore; no migrar ese envío al cliente nuevo ni exponer esa clave. Para notificaciones administrativas se necesita una función de servidor segura. La compatibilidad de push nativo en Android/Tauri queda pendiente de validación en dispositivo.
- **Android:** `validate-android.yml` compila mediante `tauri android init/build`. Se retiraron los Gradle, manifiestos, `MainActivity.kt` y recursos heredados de Flutter. Se conserva `android_config/icono.png` porque el workflow Tauri lo usa como fuente para generar los iconos.
- **Dart:** `pubspec.yaml` y `lib/` no participan en el workflow Android activo, pero continúan como referencia de modelos y formatos. No se eliminan hasta cerrar la comparación funcional y de datos.

## Secuencia de limpieza

1. Completar paridad funcional de módulos y servicios.
2. Migrar formatos/datos que todavía solo estén representados en Dart.
3. Retirar workflows, scripts y configuración Flutter que no tengan consumidores.
4. Retirar fuentes Dart ya sustituidas, por grupos pequeños y verificables.
5. Retirar `pubspec.yaml`, lockfiles y configuración Flutter cuando no quede ninguna tarea de referencia que los necesite.
6. Validar compilación Android Tauri e integraciones después de cada bloque significativo.

**Estado:** auditoría inicial; no se elimina todavía `lib/` ni el manifiesto Flutter porque siguen siendo material de comparación para completar la migración sin perder compatibilidad.


## Correcciones de fiabilidad — continuación

- El contador de temporales ahora propaga fallos de lectura; la pantalla de caché muestra error y permite reintentar en vez de presentar falsamente cero archivos.
- La subida Cloudinary tiene timeout de 120 segundos y mensajes diferenciados para red, cancelación, respuesta inválida y demora. No cambia el preset ni expone secretos.
- La eliminación de categorías está protegida por transacción y bloquea el borrado si existe una canción con ese `categoriaId`; el administrador debe reasignarla primero.
