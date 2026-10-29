// lib/screens/zampona_practica_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/design.dart';
import '../models/numerofonia.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/zampona/tool_scaffold.dart';
import '../widgets/zampona/zampona_teclado.dart';

enum ModoPractica { ambos, solo7, solo6 }

class ZamponaPracticaScreen extends StatefulWidget {
  final List<EstrofaNumerofonia>? estrofasGuia;
  const ZamponaPracticaScreen({super.key, this.estrofasGuia});

  @override
  State<ZamponaPracticaScreen> createState() => _ZamponaPracticaScreenState();
}

class _ZamponaPracticaScreenState extends State<ZamponaPracticaScreen> {
  final _service = ZamponaService();
  bool _cargando = true;
  ModoPractica _modo = ModoPractica.ambos;
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();
    // Mantenemos horizontal porque venimos del modo ensayo
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _service.init().then((_) { if (mounted) setState(() => _cargando = false); });
  }

  @override
  void dispose() {
    // 🛑 DETENER EL AUDIO AL SALIR
    _service.detener();
    super.dispose();
  }

  void _tocar(nota) {
    if (_modo == ModoPractica.solo7 && nota.fila != 7) return;
    if (_modo == ModoPractica.solo6 && nota.fila != 6) return;
    
    setState(() => _sonando.add(nota.id));
    _service.tocar(nota.id);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) setState(() => _sonando.remove(nota.id)); });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: AppColors.dorado)));

    final tieneGuia = widget.estrofasGuia != null && widget.estrofasGuia!.isNotEmpty;

    return ToolScaffold(
      titulo: 'Práctica Libre',
      subtitulo: 'Toca la zampoña',
      onCerrar: () => Navigator.pop(context),
      bottomBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ModoPractica.values.map((m) {
          final label = m == ModoPractica.ambos ? 'AMBOS' : (m == ModoPractica.solo7 ? 'FILA 7' : 'FILA 6');
          final activo = _modo == m;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
            child: ChoiceChip(
              label: Text(label),
              selected: activo,
              onSelected: (_) => setState(() => _modo = m),
            ),
          );
        }).toList(),
      ),
      // Usamos Column para que no se superpongan
      body: Column(
        children: [
          if (tieneGuia)
            Container(
              height: 90, // Altura fija para la guía
              width: double.infinity,
              margin: const EdgeInsets.all(Sp.sm),
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF14080A),
                borderRadius: Rad.rMd,
                border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: VisorNumerofonia(
                    estrofas: widget.estrofasGuia!,
                    escala: 1.0,
                    fondoOscuro: true,
                  ),
                ),
              ),
            ),
          // La zampoña ocupa todo el espacio restante
          Expanded(
            child: ZamponaTeclado(brillando: _sonando, onTapNota: _tocar),
          ),
        ],
      ),
    );
  }
}