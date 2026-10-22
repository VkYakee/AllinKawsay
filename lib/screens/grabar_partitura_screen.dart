// lib/screens/grabar_partitura_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/zampona_catalogo.dart';
import '../design/design.dart';
import '../models/numerofonia.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/zampona/tool_scaffold.dart';
import '../widgets/zampona/zampona_widget.dart';

class GrabarPartituraScreen extends StatefulWidget {
  final EstrofaNumerofonia estrofaInicial;
  const GrabarPartituraScreen({super.key, required this.estrofaInicial});

  @override
  State<GrabarPartituraScreen> createState() => _GrabarPartituraScreenState();
}

class _GrabarPartituraScreenState extends State<GrabarPartituraScreen> {
  final _service = ZamponaService();
  final _scrollCtrl = ScrollController();
  late EstrofaNumerofonia _trabajo;
  int? _filaActiva;
  DateTime? _ultimoToque;
  final List<_Snapshot> _historial = [];
  bool _cargando = true;
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _trabajo = widget.estrofaInicial.copy();
    while (_trabajo.columnas.isNotEmpty && _trabajo.columnas.last.vacia) {
      _trabajo.columnas.removeLast();
    }
    _service.init().then((_) { if (mounted) setState(() => _cargando = false); });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _tocarCania(ZamponaNota nota) async {
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
    Future.delayed(const Duration(milliseconds: 250), () { if (mounted) setState(() => _sonando.remove(nota.id)); });

    _historial.add(_Snapshot(_trabajo.copy(), _filaActiva));
    final ahora = DateTime.now();
    final delta = _ultimoToque == null ? 0 : ahora.difference(_ultimoToque!).inMilliseconds;
    _ultimoToque = ahora;

    final numero = '${nota.posicion}';
    final fila = nota.fila;

    setState(() {
      if (_filaActiva == null || _filaActiva != fila) {
        final nueva = ColumnaNumerofonia();
        if (fila == 7) { nueva.nota7 = numero; nueva.timings7 = [0]; } 
        else { nueva.nota6 = numero; nueva.timings6 = [0]; }
        _trabajo.columnas.add(nueva);
        _filaActiva = fila;
      } else {
        if (_trabajo.columnas.isEmpty) return;
        final ultima = _trabajo.columnas.last;
        if (fila == 7) { ultima.nota7 = '${ultima.nota7}$numero'; ultima.timings7 = [...ultima.timings7, delta]; } 
        else { ultima.nota6 = '${ultima.nota6}$numero'; ultima.timings6 = [...ultima.timings6, delta]; }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
      }
    });
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    setState(() {
      final snap = _historial.removeLast();
      _trabajo = snap.estrofa;
      _filaActiva = snap.filaActiva;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: AppColors.dorado)));

    return ToolScaffold(
      titulo: 'Grabar Partitura',
      subtitulo: 'Toca para escribir',
      onCerrar: () => Navigator.pop(context, _trabajo),
      bottomBar: Row(
        children: [
          Expanded(child: _btnAccion('DESHACER', Icons.undo, Colors.orange, _historial.isEmpty ? null : _deshacer)),
          const SizedBox(width: Sp.sm),
          Expanded(child: _btnAccion('LIMPIAR', Icons.delete_sweep, Colors.redAccent, _trabajo.columnas.isEmpty ? null : () {
            setState(() { _trabajo.columnas.clear(); _filaActiva = null; _ultimoToque = null; _historial.clear(); });
          })),
          const SizedBox(width: Sp.sm),
          Expanded(flex: 2, child: _btnAccion('TERMINAR', Icons.check, Colors.green, () => Navigator.pop(context, _trabajo))),
        ],
      ),
      body: Column(
        children: [
          _preview(),
          const SizedBox(height: Sp.sm),
          Expanded(child: ZamponaWidget(brillando: _sonando, onTapNota: _tocarCania)),
        ],
      ),
    );
  }

  Widget _preview() {
    final cols = _trabajo.columnas.isEmpty ? [ColumnaNumerofonia(), ColumnaNumerofonia()] : _trabajo.columnas;
    return Container(
      height: 62,
      margin: const EdgeInsets.symmetric(horizontal: Sp.sm),
      padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: Sp.sm),
      decoration: BoxDecoration(color: const Color(0xFF14080A), borderRadius: Rad.rMd, border: Border.all(color: AppColors.dorado.withOpacity(0.4))),
      child: Row(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: const [_Etiqueta('7'), SizedBox(height: 2), _Etiqueta('6')]),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Row(children: [for (final c in cols) _celdaPreview(c)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _celdaPreview(ColumnaNumerofonia c) {
    final ancho = (c.maxLen.clamp(1, 8) * 14.0).clamp(28.0, 120.0);
    return Container(
      width: ancho, height: 44,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border.all(color: AppColors.dorado.withOpacity(0.35)), borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          Expanded(child: Center(child: Text(c.nota7, style: AppType.mono.copyWith(color: AppColors.dorado, fontWeight: FontWeight.bold)))),
          Container(height: 1, color: AppColors.dorado.withOpacity(0.25)),
          Expanded(child: Center(child: Text(c.nota6, style: AppType.mono.copyWith(color: AppColors.dorado, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _btnAccion(String label, IconData icon, Color color, VoidCallback? onTap) {
    return AppButton(label: label, icon: icon, variant: AppButtonVariant.secondary, onPressed: onTap);
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta(this.texto);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 18, alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.granate, borderRadius: BorderRadius.circular(4)),
      child: Text(texto, style: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}

class _Snapshot {
  final EstrofaNumerofonia estrofa;
  final int? filaActiva;
  _Snapshot(this.estrofa, this.filaActiva);
}