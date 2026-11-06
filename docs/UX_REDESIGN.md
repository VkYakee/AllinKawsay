# Rediseño integral de experiencia — AllinKawsay 3.0

## Principio

La aplicación debe sentirse como una herramienta musical amable, no como un panel técnico de base de datos. El usuario piensa en canciones, partituras, ensayos, eventos y recuerdos; nunca en documentos, colecciones, URLs o estructuras internas.

## Áreas a rediseñar

### Navegación principal
- Inicio: resumen personal y accesos a tareas frecuentes.
- Cancionero: búsqueda clara, filtros comprensibles, estados vacíos útiles y tarjetas consistentes.
- Ensayo: acceso directo a continuar práctica, setlists y canciones recientes.
- Zampoña: instrumento interactivo y aprendizaje.
- Comunidad/actividad: eventos y recuerdos presentados como contenido, no como administración.

### Pantallas secundarias
- Detalle de canción: jerarquía clara entre portada, reproducción, letra, numerofonía y comentarios.
- Partitura: modo lectura completa sin scroll horizontal, simetría, tipografía legible y foco visual estable.
- Evento/recuerdo: formularios por pasos, vista previa y gestión multimedia sencilla.
- Perfil/configuración: lenguaje cotidiano y acciones agrupadas por intención.

### Creación y edición
- Formularios progresivos por pasos, con progreso visible y navegación atrás/adelante.
- Guardado explícito y validación junto al campo que requiere atención.
- Estados de carga/progreso y recuperación de errores sin perder lo escrito.
- Permitir guardar borradores incompletos cuando sea seguro.
- Vista previa antes de publicar.
- No exponer campos internos, IDs, nombres de colecciones ni JSON.
- Crear y editar deben compartir componentes y reglas; edición debe cargar datos existentes sin sobrescribirlos accidentalmente.

## Flujo de alta de canción

1. Datos: título obligatorio; autor, ritmo, región, etiquetas y descripción opcionales; portada/audio/vídeo opcionales.
2. Partitura: editor visual por columnas, fila 7 arriba y fila 6 abajo; ingreso rápido pegando texto; BIS por estrofa; previsualización fiel al visor.
3. Letra: edición por partes/estrofas, saltos de línea conservados y vista previa.
4. Confirmación: resumen de lo que se guardará, avisos de campos incompletos y acción clara de guardar.

La validación debe permitir contenido parcial si el modelo lo admite. No bloquear al usuario por metadatos opcionales.

## Editor de numerofonía

- Dos vías equivalentes: pegar/importar secuencia rápidamente y editar visualmente columna por columna.
- Cada columna mantiene ambas filas; borrar una nota no debe desplazar silenciosamente las notas de otras columnas.
- Acciones de agregar/eliminar columna, duplicar estrofa, reordenar y marcar BIS.
- Vista previa inmediata usando el mismo modelo que el visor y el motor de ensayo.
- Validación de caracteres no permitidos con corrección sugerida; nunca descartar texto silenciosamente.
- Soportar vacío y celdas intencionalmente vacías.

## Sistema visual y movimiento

- Paleta representativa granate/oro con superficies de contraste y uso medido de acentos.
- Escala tipográfica, espaciado, radios y elevaciones compartidos.
- Transiciones cortas entre pantallas y estados; microinteracciones consistentes.
- Animaciones decorativas opcionales, nunca necesarias para comprender información.
- Respetar `prefers-reduced-motion`, mantener buen rendimiento en Android y evitar animar propiedades costosas.
- La partitura no cambia de tamaño al resaltar una nota; el foco visual se dibuja dentro de la celda.

## Estado inicial observado

- El alta de canción actual reúne muchos campos en una sola pantalla larga.
- La numerofonía se edita con dos cajas de texto separadas por espacios, sin vista de columnas.
- El panel de administración está organizado por métricas y enlaces técnicos; necesita separar tareas de contenido y configuración.
- El cancionero tiene búsqueda y filtros básicos, pero requiere mejorar jerarquía, vacíos, filtros y consistencia.
- Los componentes Glass son una base visual reutilizable, pero necesitan un sistema de diseño más coherente y accesible.

## Trabajo ya iniciado en esta rama

- Alta/edición de canción dividida en tres pasos: Datos, Partitura y Letra.
- Editor visual de numerofonía por columnas, con campos independientes para fila 7/6, eliminación de columnas, BIS y entrada rápida por pegado de secuencias.
- Se conserva la llamada existente a servicios de subida y persistencia.
- La validación del título se ejecuta antes de avanzar; los campos opcionales siguen siendo opcionales.

## Criterios de aceptación UX

- Una persona que no conoce Firebase ni numerofonía puede completar una canción siguiendo instrucciones.
- Nunca se pierde contenido al cambiar de paso.
- En edición, se cargan todos los valores previos y no se duplican registros.
- Las acciones principales son visibles y táctiles en pantallas pequeñas.
- Los errores explican cómo resolver el problema.
- No se introduce scroll horizontal en el visor de partituras.
- Los estados de carga, vacío, éxito y error tienen diseño consistente.
