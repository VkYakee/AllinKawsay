// lib/features/zampona/screens/zampona_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/zampona_nota.dart';
import '../../../services/zampona_service.dart';
import '../../../widgets/zampona/tool_scaffold.dart';
import '../../../widgets/zampona/zampona_widget.dart';

class ZamponaScreen extends StatefulWidget {
  const ZamponaScreen({super.key});

  @override
  State<ZamponaScreen> createState() => _ZamponaScreenState();
}

class _ZamponaScreenState extends State<ZamponaScreen> {
  final _service = ZamponaService();
  bool _cargando = true;
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _service.init().then((_) {
      if (mounted) setState(() => _cargando = false);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _tocarDown(ZamponaNota nota) async {
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
    if (_service.modo == ZamponaModo.sostenido) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _sonando.remove(nota.id));
      });
    }
  }

  Future<void> _soltar(ZamponaNota nota) async {
    await _service.soltar(nota.id);
    if (mounted) setState(() => _sonando.remove(nota.id));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.dorado),
        ),
      );
    }

    return ToolScaffold(
      titulo: 'Zampoña',
      subtitulo: 'Instrumento virtual',
      onCerrar: () => Navigator.pop(context),
      bottomBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chipModo('SOSTENIDO', ZamponaModo.sostenido),
          const SizedBox(width: Sp.sm),
          _chipModo('PULSADO', ZamponaModo.pulsado),
        ],
      ),
      body: ZamponaWidget(
        brillando: _sonando,
        onTapNota: _tocarDown,
        onReleaseNota: _soltar,
      ),
    );
  }

  Widget _chipModo(String label, ZamponaModo modo) {
    final activo = _service.modo == modo;
    return InkWell(
      onTap: () => setState(() => _service.setModo(modo)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sp.lg,
          vertical: Sp.sm,
        ),
        decoration: BoxDecoration(
          gradient: activo ? AppColors.gradienteDorado : null,
          borderRadius: Rad.rPill,
          border: Border.all(
            color: activo
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppText.labelXs.copyWith(
            color: activo ? AppColors.granate : AppColors.dorado,
          ),
        ),
      ),
    );
  }
}