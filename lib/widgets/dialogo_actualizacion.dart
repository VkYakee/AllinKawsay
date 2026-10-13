import 'package:flutter/material.dart';
import '../models/info_version.dart';
import '../theme/colors.dart';
import '../screens/actualizacion_screen.dart';

class DialogoActualizacion extends StatelessWidget {
  final InfoVersion info;

  const DialogoActualizacion({super.key, required this.info});

  /// Muestra el diálogo. Devuelve `true` si el usuario tocó ACTUALIZAR
  /// (o era crítica), `false`/null si tocó MÁS TARDE o cerró.
  static Future<bool?> mostrar(BuildContext context, InfoVersion info) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !info.critica,
      builder: (_) => DialogoActualizacion(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return PopScope(
      canPop: !info.critica,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícono circular
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.granate.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_alt,
                    color: AppColors.dorado,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                info.critica
                    ? 'ACTUALIZACIÓN OBLIGATORIA'
                    : 'ACTUALIZACIÓN DISPONIBLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.seccionTitulo(context),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // Versión
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.granate.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.granate.withOpacity(0.2)),
                  ),
                  child: Text(
                    'v${info.version}.${info.build}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.seccionTitulo(context),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mensaje
              Text(
                info.critica
                    ? 'Necesitás actualizar para seguir usando la app. '
                        'Esta versión corrige problemas importantes.'
                    : 'Hay una nueva versión de Allin Kawsay disponible. '
                        'Se recomienda actualizar para aprovechar las '
                        'mejoras y correcciones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: onSurface.withOpacity(0.75),
                ),
              ),

              // Notas del admin
              if (info.notas.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.granate),
                          const SizedBox(width: 6),
                          Text(
                            'NOVEDADES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.seccionTitulo(context),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        info.notas,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.85),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botón ACTUALIZAR
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActualizacionScreen(info: info),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text(
                    'ACTUALIZAR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // Botón MÁS TARDE (solo si NO es crítica)
              if (!info.critica) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'MÁS TARDE',
                    style: TextStyle(
                      color: onSurface.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}