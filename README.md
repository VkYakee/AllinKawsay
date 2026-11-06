# Allin Kawsay

Aplicación móvil de música y comunidad para el conjunto de sikuris **Allin Kawsay**, de Puno, Perú. La versión 3.0 está en reconstrucción: busca reunir el cancionero de numerofonía, herramientas de práctica, mini zampoña, eventos y memoria comunitaria en una experiencia clara y accesible.

## Áreas de la aplicación

- **Inicio:** accesos a la música, agenda y herramientas del conjunto.
- **Cancionero:** catálogo de canciones, búsqueda, filtros y detalle.
- **Partituras:** numerofonía organizada por estrofas y columnas; fila 7 arriba y fila 6 abajo.
- **Ensayo:** sincronizador independiente que utiliza el audio original como reloj maestro para tabla, letra y mini zampoña. No modifica ni divide el audio.
- **Mini zampoña:** instrumento interactivo y reproducción de muestras.
- **Comunidad:** eventos, recuerdos, historia y actividad.
- **Administración:** creación y edición de canciones, eventos y recuerdos; gestión de usuarios, categorías y respaldos.

## Tecnología

- Svelte 5 + TypeScript
- Vite 6 + Tailwind CSS 4
- Tauri 2 para escritorio y Android
- Firebase Authentication y Cloud Firestore
- Cloudinary para recursos multimedia
- Rust + rodio para reproducción nativa de audio
- OneSignal para notificaciones

## Estructura principal

```text
src/
  lib/
    components/ui/       Componentes visuales reutilizables
    design/              Colores, tipografía, movimiento y tokens
    domain/              Modelos y lógica de dominio
    features/             Pantallas agrupadas por área funcional
    services/             Firebase, multimedia, audio y servicios
    stores/               Estado compartido de la aplicación
  App.svelte              Enrutamiento y composición de pantallas

src-tauri/
  src/
    commands/             Comandos expuestos a la interfaz
    domain/               Modelos nativos
    infra/                Audio y recursos nativos

docs/
  UX_REDESIGN.md
  SINCRONIZADOR_ENSAYO_SPEC.md
  ENSAYO_REBUILD.md
```

## Desarrollo local

Requisitos generales:

- Node.js 20 o compatible con Vite 6
- Rust estable
- Dependencias nativas de Tauri 2 para la plataforma

Instalar dependencias (incluye paquetes opcionales de plataforma usados por Rollup):

```bash
npm install --include=optional
```

Iniciar el entorno web:

```bash
npm run dev
```

Comprobar la compilación frontend:

```bash
npm run build
```

## Validación Android

La validación de CI usa Java 17, Android SDK, NDK r26b y el target Rust `aarch64-linux-android`.

Para generar un APK local de depuración, con el entorno Android de Tauri preparado:

```bash
npm run tauri android build -- --apk --debug --target aarch64
```

El workflow `.github/workflows/validate-android.yml` compila y publica únicamente un artefacto APK de depuración con retención temporal. No firma una versión de producción ni crea un Release.

## Estado de la reconstrucción 3.0

La reconstrucción se trabaja por áreas, sin considerar una pantalla terminada solo porque compile:

1. Unificar el lenguaje visual y la navegación.
2. Completar Inicio, cancionero, búsqueda y detalle de canción.
3. Hacer confiables los flujos de alta y edición, preservando los datos existentes.
4. Consolidar eventos, recuerdos, perfil y administración.
5. Terminar el sincronizador Ensayo y validar su audio en Android real.
6. Revisar integración nativa, accesibilidad, estados de error y compilación Android.

Los cambios deben conservar la compatibilidad con los documentos existentes de Firestore. Los proyectos nuevos de sincronización se almacenan aparte y no alteran los archivos de audio originales.

## Documentación

- [Plan de rediseño UX](docs/UX_REDESIGN.md)
- [Especificación del sincronizador Ensayo](docs/SINCRONIZADOR_ENSAYO_SPEC.md)
- [Historial técnico de Ensayo](docs/ENSAYO_REBUILD.md)
