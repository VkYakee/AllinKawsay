import 'package:flutter/material.dart';
import '../services/audio_cache_service.dart';
import '../services/recuerdo_cache_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/seccion_card.dart';

class GestionCacheScreen extends StatefulWidget {
  const GestionCacheScreen({super.key});

  @override
  State<GestionCacheScreen> createState() => _GestionCacheScreenState();
}

class _GestionCacheScreenState extends State<GestionCacheScreen> {
  int _audioBytes = 0;
  int _audioCantidad = 0;
  int _recuerdoBytes = 0;
  int _recuerdoCantidad = 0;
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
    if (!mounted) return;
    setState(() {
      _audioBytes = aB;
      _audioCantidad = aC;
      _recuerdoBytes = rB;
      _recuerdoCantidad = rC;
      _cargando = false;
    });
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  Future<void> _limpiarAudios() async {
    final ok = await _confirmar(
      'Limpiar cache de audios',
      'Se borrarán $_audioCantidad canción(es) cacheada(s) ($_audioBytesFormateado). '
          'Se descargarán de nuevo la próxima vez que las reproduzcas.',
    );
    if (ok != true) return;
    setState(() => _limpiando = true);
    await AudioCacheService().limpiarTodo();
    await _cargar();
    if (!mounted) return;
    setState(() => _limpiando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache de audios borrado')),
    );
  }

  Future<void> _limpiarRecuerdos() async {
    final ok = await _confirmar(
      'Limpiar cache de recuerdos',
      'Se borrarán $_recuerdoCantidad archivo(s) de recuerdos ($_recuerdoBytesFormateado). '
          'Se descargarán de nuevo la próxima vez que los veas.',
    );
    if (ok != true) return;
    setState(() => _limpiando = true);
    await RecuerdoCacheService().limpiarTodo();
    await _cargar();
    if (!mounted) return;
    setState(() => _limpiando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache de recuerdos borrado')),
    );
  }

  Future<void> _limpiarTodo() async {
    final ok = await _confirmar(
      'Limpiar TODA la caché',
      'Se borrarán todos los archivos cacheados '
          '(${_fmt(_audioBytes + _recuerdoBytes)} en total). '
          'La app los descargará de nuevo cuando los necesites.',
    );
    if (ok != true) return;
    setState(() => _limpiando = true);
    await AudioCacheService().limpiarTodo();
    await RecuerdoCacheService().limpiarTodo();
    await _cargar();
    if (!mounted) return;
    setState(() => _limpiando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toda la caché borrada')),
    );
  }

  Future<bool?> _confirmar(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo,
            style: const TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        content: Text(mensaje, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  String get _audioBytesFormateado => _fmt(_audioBytes);
  String get _recuerdoBytesFormateado => _fmt(_recuerdoBytes);

  double get _audioPorcentaje =>
      (_audioBytes / (1024 * 1024 * 1024)).clamp(0.0, 1.0);
  double get _recuerdoPorcentaje =>
      (_recuerdoBytes / (1024 * 1024 * 1024)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final totalBytes = _audioBytes + _recuerdoBytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALMACENAMIENTO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargando ? null : _cargar,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate))
          : _limpiando
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.dorado))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Info
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.dorado.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.dorado.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16,
                              color: AppColors.seccionTitulo(context)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'La app guarda automáticamente los audios y '
                              'recuerdos que ves para que funcionen sin '
                              'internet. Cuando el cache se llena, borra los '
                              'archivos más viejos automáticamente.',
                              style: TextStyle(
                                fontSize: 12,
                                color: onSurface.withOpacity(0.75),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Total
                    SeccionCard(
                      icono: Icons.storage,
                      titulo: 'USO TOTAL',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _fmt(totalBytes),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.seccionTitulo(context),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'de 2 GB',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_audioCantidad + _recuerdoCantidad} archivo(s) guardado(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Audios
                    SeccionCard(
                      icono: Icons.music_note,
                      titulo: 'CANCIONES CACHEADAS',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_audioBytesFormateado · $_audioCantidad canción(es)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _barraProgreso(_audioPorcentaje),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: _audioCantidad == 0
                                  ? null
                                  : _limpiarAudios,
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.red),
                              label: const Text(
                                'LIMPIAR AUDIOS',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.red.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Recuerdos
                    SeccionCard(
                      icono: Icons.photo_library,
                      titulo: 'RECUERDOS CACHEADOS',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_recuerdoBytesFormateado · $_recuerdoCantidad archivo(s)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _barraProgreso(_recuerdoPorcentaje),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: _recuerdoCantidad == 0
                                  ? null
                                  : _limpiarRecuerdos,
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.red),
                              label: const Text(
                                'LIMPIAR RECUERDOS',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.red.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botón limpiar todo
                    if (totalBytes > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _limpiarTodo,
                          icon: const Icon(Icons.delete_sweep, size: 20),
                          label: const Text(
                            'LIMPIAR TODA LA CACHÉ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _barraProgreso(double valor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: valor,
        minHeight: 8,
        backgroundColor: AppColors.granate.withOpacity(0.15),
        valueColor:
            const AlwaysStoppedAnimation(AppColors.granate),
      ),
    );
  }
}