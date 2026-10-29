// lib/screens/exportar_respaldo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/design.dart';
import '../services/respaldo_service.dart';
import '../theme/colors.dart';

class ExportarRespaldoScreen extends StatefulWidget {
  const ExportarRespaldoScreen({super.key});

  @override
  State<ExportarRespaldoScreen> createState() => _ExportarRespaldoScreenState();
}

class _ExportarRespaldoScreenState extends State<ExportarRespaldoScreen> {
  Map<String, int>? _conteo;
  String? _json;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    RespaldoService().contarElementos().then((c) { if (mounted) setState(() => _conteo = c); });
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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AppScaffold(
      title: 'Exportar Respaldo',
      body: ListView(
        padding: const EdgeInsets.all(Sp.lg),
        children: [
          AppCard(
            child: Column(
              children: [
                const SeccionHeader(title: 'Contenido Actual', icon: Icons.inventory_2, padding: EdgeInsets.zero),
                const SizedBox(height: Sp.md),
                if (_conteo != null) ...[
                  _fila('Canciones', _conteo!['canciones'] ?? 0, Icons.music_note),
                  _fila('Eventos', _conteo!['eventos'] ?? 0, Icons.event),
                  _fila('Recuerdos', _conteo!['recuerdos'] ?? 0, Icons.photo_library),
                  _fila('Usuarios', _conteo!['usuarios'] ?? 0, Icons.people),
                ],
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          
          if (_json == null)
            AppButton(
              label: 'GENERAR RESPALDO (JSON)', 
              icon: Icons.download, 
              fullWidth: true, 
              loading: _generando, 
              onPressed: _generar,
            )
          else ...[
            AppCard(
              color: const Color(0xFF0A0A0A), // Negro profundo
              border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Respaldo generado', style: AppType.subtitle.copyWith(color: AppColors.dorado)),
                      AppBadge(label: '${(_json!.length / 1024).toStringAsFixed(1)} KB', variant: AppBadgeVariant.gold),
                    ],
                  ),
                  const SizedBox(height: Sp.md),
                  Container(
                    padding: const EdgeInsets.all(Sp.md),
                    decoration: BoxDecoration(
                      color: Colors.black, 
                      borderRadius: Rad.rMd,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      _json!.length > 200 ? '${_json!.substring(0, 200)}...' : _json!, 
                      style: AppType.mono.copyWith(color: AppColors.dorado, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.lg),
            AppButton(
              label: 'COPIAR AL PORTAPAPELES', 
              icon: Icons.copy, 
              fullWidth: true, 
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _json!));
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respaldo copiado')));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _fila(String label, int valor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
      child: Row(
        children: [
          Icon(icon, color: AppColors.granate, size: 18),
          const SizedBox(width: Sp.sm),
          Expanded(child: Text(label, style: AppType.body.copyWith(color: Theme.of(context).colorScheme.onSurface))),
          AppBadge(label: '$valor', variant: AppBadgeVariant.granate),
        ],
      ),
    );
  }
}