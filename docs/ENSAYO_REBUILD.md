# Reconstrucción del modo Ensayo — AllinKawsay 3.0

> **Alcance vigente:** esta nota conserva el historial técnico del primer rebuild. La dirección funcional y técnica actual está definida en [SINCRONIZADOR_ENSAYO_SPEC.md](./SINCRONIZADOR_ENSAYO_SPEC.md), que prevalece sobre cualquier flujo antiguo de bloques/setlists o edición de audio.

## Objetivo vigente

Sincronizar el audio original (solo lectura) con tres capas: tabla de numerofonía, letra/karaoke y mini zampoña. No construir un DAW ni herramientas para cortar, dividir, recortar, mezclar o exportar audio.

## Principios vigentes

- El reloj del reproductor nativo es la autoridad temporal.
- Tabla, letra y mini zampoña comparten una base temporal y eventos estables.
- La UI solo representa snapshots; nunca dispara muestras desde su reloj visual.
- Los tiempos manuales prevalecen sobre BPM o estimaciones.
- El proyecto de sincronización es independiente de la canción y no modifica el cancionero.
- El motor de mini zampoña será persistente, con control de voces, envolventes y límites de mezcla; no un Sink nuevo por nota.
- Seek, pausa, reanudación, velocidad y cambio de canción invalidan eventos pendientes y reconstruyen el estado.

## Historial técnico ya implementado

- Compilador TypeScript inicial de línea de tiempo y repetición BIS.
- Búsqueda del evento visual activo.
- Backend de audio con actualización periódica de posición.
- Editor y visor de numerofonía por celdas, con filas 7 arriba y 6 abajo.

Estos componentes son una base histórica, no la arquitectura final del sincronizador.

## Próximas fases

1. Modelo versionado de sincronización (tabla/letra/zampoña) — iniciado en `sync-project.ts`.
2. Mixer persistente de mini zampoña.
3. Reloj nativo, snapshots y scheduler de eventos.
4. Conectar tabla y karaoke al mismo cursor.
5. Herramientas para marcar y corregir tiempos.
6. Reproductor simplificado y pruebas Android de latencia/artefactos.

## Compatibilidad

Los datos existentes `estrofas[].columnas[].nota7/nota6`, `bis` y letra siguen siendo fuente de lectura. Los proyectos nuevos se guardan aparte, versionados y no destructivos. No migrar automáticamente `timingsMs` ni `letraTimingsMs` sin validar su semántica.
