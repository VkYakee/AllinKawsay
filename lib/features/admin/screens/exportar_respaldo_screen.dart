// lib/features/admin/screens/exportar_respaldo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_loading_siku.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/respaldo_service.dart';

class ExportarRespaldoScreen extends StatefulWidget {
  const ExportarRespaldoScreen({super.key});

  @override
  State<ExportarRespaldoScreen> createState() =>
      _ExportarRespaldoScreenState();
}

class _ExportarRespaldoScreenState extends State<ExportarRespaldoScreen> {
  Map<String, int>? _conteo;
  String? _json;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    RespaldoService().contarElementos().then((c) {
      if (mounted) setState(() => _conteo = c);
    });
  }

  Future<void> _generar() async {
    setState(() => _generando = true);
    try {
      final json = await RespaldoService().generarRespaldo();
      if (mounted) setState(() => _json = json);
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          'Exportar Respaldo',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dorado,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
        children: [
          AppCard(
            glass: true,
            padding: const EdgeInsets.all(Sp.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.dorado,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Colecciones del Sistema',
                      style: AppText.h3.copyWith(
                        color: AppColors.dorado,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.md),
                if (_conteo == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: AllinLoadingSiku(mensaje: 'Contando documentos...'),
                    ),
                  )
                else ...[
                  _fila('Canciones registradas', _conteo!['canciones'] ?? 0, Icons.music_note_rounded),
                  _fila('Eventos programados', _conteo!['eventos'] ?? 0, Icons.event_rounded),
                  _fila('Recuerdos en galería', _conteo!['recuerdos'] ?? 0, Icons.photo_library_rounded),
                  _fila('Usuarios del grupo', _conteo!['usuarios'] ?? 0, Icons.group_rounded),
                ],
              ],
            ),
          ),

          const SizedBox(height: Sp.xl),

          if (_json == null)
            AllinButton(
              label: _generando ? 'GENERANDO ARCHIVO JSON...' : 'GENERAR RESPALDO JSON',
              icono: Icons.download_rounded,
              variant: AllinButtonVariant.gold,
              expand: true,
              loading: _generando,
              onPressed: _generar,
            )
          else ...[
            AppCard(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.dorado,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Respaldo Listo',
                            style: AppText.subtitle.copyWith(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.dorado.withOpacity(0.15),
                          borderRadius: Rad.rPill,
                          border: Border.all(
                            color: AppColors.dorado.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${(_json!.length / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.md),
                  Container(
                    padding: const EdgeInsets.all(Sp.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0D11),
                      borderRadius: Rad.rMd,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _json!.length > 250
                          ? '${_json!.substring(0, 250)}...'
                          : _json!,
                      style: const TextStyle(
                        color: AppColors.dorado,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.lg),
            AllinButton(
              label: 'COPIAR AL PORTAPAPELES',
              icono: Icons.copy_rounded,
              variant: AllinButtonVariant.gold,
              expand: true,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _json!));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Respaldo JSON copiado al portapapeles',
                        style: AppText.body.copyWith(color: AppColors.dorado),
                      ),
                      backgroundColor: AppColors.granateProfundo,
                    ),
                  );
                }
              },
            ),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _fila(String label, int valor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.dorado.withOpacity(0.8), size: 18),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Text(
              label,
              style: AppText.body.copyWith(
                color: AppColors.onSurface(context),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.granateProfundo,
              borderRadius: Rad.rPill,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.3),
              ),
            ),
            child: Text(
              '$valor',
              style: const TextStyle(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
