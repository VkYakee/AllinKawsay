// lib/features/perfil/screens/gestion_cache_screen.dart
import 'package:flutter/material.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_dialog.dart';
import '../../../core/components/allin_loading_siku.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/audio_cache_service.dart';
import '../../../services/recuerdo_cache_service.dart';

class GestionCacheScreen extends StatefulWidget {
  const GestionCacheScreen({super.key});

  @override
  State<GestionCacheScreen> createState() => _GestionCacheScreenState();
}

class _GestionCacheScreenState extends State<GestionCacheScreen> {
  int _audioBytes = 0, _audioCantidad = 0;
  int _recuerdoBytes = 0, _recuerdoCantidad = 0;
  bool _cargando = true;
  bool _limpiando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final aB = await AudioCacheService().espacioUsado();
    final aC = await AudioCacheService().cantidad();
    final rB = await RecuerdoCacheService().espacioUsado();
    final rC = await RecuerdoCacheService().cantidad();
    if (mounted) {
      setState(() {
        _audioBytes = aB;
        _audioCantidad = aC;
        _recuerdoBytes = rB;
        _recuerdoCantidad = rC;
        _cargando = false;
      });
    }
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  Future<void> _confirmarBorrado({
    required String titulo,
    required String mensaje,
    required Future<void> Function() accion,
  }) async {
    final ok = await AllinDialog.confirm(
      context,
      title: titulo,
      message: mensaje,
      confirmText: 'Borrar Datos',
      cancelText: 'Cancelar',
      isDestructive: true,
      icon: Icons.delete_forever_outlined,
    );

    if (ok == true) {
      setState(() => _limpiando = true);
      await accion();
      await _cargar();
      if (mounted) {
        setState(() => _limpiando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caché liberada correctamente'),
            backgroundColor: AppColors.granateSagrado,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBytes = _audioBytes + _recuerdoBytes;

    return Scaffold(
      backgroundColor: AppColors.fondoOLED,
      appBar: AppBar(
        backgroundColor: AppColors.fondoOLED,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.oroSolar, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Almacenamiento y Caché',
          style: AppText.title.copyWith(
            color: AppColors.oroSolar,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.oroSolar),
            onPressed: (_cargando || _limpiando) ? null : _cargar,
          ),
        ],
      ),
      body: (_cargando || _limpiando)
          ? Center(
              child: AllinLoadingSiku(
                message: _limpiando ? 'Liberando espacio...' : 'Calculando caché...',
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta Hero con resumen de uso
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Sp.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.granateSagrado,
                          AppColors.granateOscuro,
                          Color(0xFF1A0A0E),
                        ],
                      ),
                      borderRadius: Rad.rXl,
                      border: Border.all(
                        color: AppColors.oroSolar.withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: AppColors.glowGranate(intens: 0.35, blur: 20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.pie_chart_outline_rounded,
                          color: AppColors.oroSolar,
                          size: 38,
                        ),
                        const SizedBox(height: Sp.sm),
                        Text(
                          _fmt(totalBytes),
                          style: const TextStyle(
                            color: AppColors.oroReflejo,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total ocupado por Allin Kawsay',
                          style: AppText.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.xl),

                  Text(
                    'DESGLOSE DE ARCHIVOS DESCARGADOS',
                    style: AppText.captionXs.copyWith(
                      color: AppColors.oroSolar,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: Sp.md),

                  // Tarjeta Audios
                  _CacheItemCard(
                    icon: Icons.music_note,
                    titulo: 'Audios y Pistas de Ensayo',
                    cantidad: '$_audioCantidad archivos',
                    espacio: _fmt(_audioBytes),
                    onLimpiar: _audioBytes == 0
                        ? null
                        : () => _confirmarBorrado(
                              titulo: 'Borrar Audios en Caché',
                              mensaje: '¿Deseas eliminar los audios descargados? Podrás volver a escucharlos si tienes conexión a internet.',
                              accion: () => AudioCacheService().borrarTodo(),
                            ),
                  ),
                  const SizedBox(height: Sp.md),

                  // Tarjeta Recuerdos
                  _CacheItemCard(
                    icon: Icons.photo_library_outlined,
                    titulo: 'Fotos y Videos de Recuerdos',
                    cantidad: '$_recuerdoCantidad elementos',
                    espacio: _fmt(_recuerdoBytes),
                    onLimpiar: _recuerdoBytes == 0
                        ? null
                        : () => _confirmarBorrado(
                              titulo: 'Borrar Recuerdos en Caché',
                              mensaje: '¿Deseas eliminar las miniaturas y fotos guardadas localmente?',
                              accion: () => RecuerdoCacheService().borrarTodo(),
                            ),
                  ),
                  const SizedBox(height: Sp.xxl),

                  // Botón Borrar Todo
                  if (totalBytes > 0)
                    AllinButton(
                      text: 'LIBERAR TODO EL ALMACENAMIENTO',
                      icon: Icons.cleaning_services_rounded,
                      variant: AllinButtonVariant.danger,
                      height: 52,
                      onPressed: () => _confirmarBorrado(
                        titulo: 'Limpieza Completa',
                        mensaje: 'Se eliminarán todos los archivos temporales de música y recuerdos para liberar espacio en tu teléfono.',
                        accion: () async {
                          await AudioCacheService().borrarTodo();
                          await RecuerdoCacheService().borrarTodo();
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _CacheItemCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String cantidad;
  final String espacio;
  final VoidCallback? onLimpiar;

  const _CacheItemCard({
    required this.icon,
    required this.titulo,
    required this.cantidad,
    required this.espacio,
    this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(
        color: AppColors.grafitoCarbon,
        borderRadius: Rad.rLg,
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.granateSagrado.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.oroSolar.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppColors.oroSolar, size: 22),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: AppText.subtitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$cantidad · $espacio',
                  style: AppText.caption.copyWith(
                    color: AppColors.oroSolar,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AllinButton(
            text: 'BORRAR',
            variant: AllinButtonVariant.glass,
            fullWidth: false,
            height: 36,
            onPressed: onLimpiar,
          ),
        ],
      ),
    );
  }
}
