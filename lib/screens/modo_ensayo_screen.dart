// lib/screens/modo_ensayo_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../data/zampona_catalogo.dart';
import '../design/design.dart';
import '../models/bloque_audio.dart';
import '../models/cancion.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/zampona/tool_scaffold.dart';
import '../widgets/zampona/zampona_widget.dart';
import '../widgets/ensayo/ensayo_controles.dart';
import '../widgets/ensayo/ensayo_modos.dart';

class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

class _NotaEnsayable {
  final int estrofa;
  final int columna;
  final bool esFila7;
  final int notaIndex;
  final int delayMs;
  _NotaEnsayable({required this.estrofa, required this.columna, required this.esFila7, required this.notaIndex, required this.delayMs});
}

class _ModoEnsayoScreenState extends State<ModoEnsayoScreen> {
  final _service = ZamponaService();
  final _player = AudioPlayer();
  bool _cargando = true;
  bool _reproduciendo = false;
  bool _pausa = false;
  bool _bucle = true;
  double _velocidad = 1.0;
  String _modo = 'audio';
  int _estrofaActual = 0;
  _NotaEnsayable? _notaActiva;
  String? _notaSonando;
  int _runId = 0;

  bool get _puedeAudio => widget.cancion.puedeAudioUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (!_puedeAudio) _modo = 'solo7';
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    if (mounted) setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _runId++;
    _player.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<_NotaEnsayable> _extraerNotas() {
    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    final lista = <_NotaEnsayable>[];
    for (int e = 0; e < estrofas.length; e++) {
      final cols = estrofas[e].columnas;
      for (int c = 0; c < cols.length; c++) {
        final col = cols[c];
        for (int i = 0; i < col.nota7.trim().length; i++) {
          lista.add(_NotaEnsayable(estrofa: e, columna: c, esFila7: true, notaIndex: i, delayMs: i < col.timings7.length ? col.timings7[i] : 400));
        }
        for (int i = 0; i < col.nota6.trim().length; i++) {
          lista.add(_NotaEnsayable(estrofa: e, columna: c, esFila7: false, notaIndex: i, delayMs: i < col.timings6.length ? col.timings6[i] : 400));
        }
      }
    }
    return lista;
  }

  String _caracterDe(_NotaEnsayable n) {
    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (n.estrofa >= estrofas.length) return '';
    final cols = estrofas[n.estrofa].columnas;
    if (n.columna >= cols.length) return '';
    final texto = n.esFila7 ? cols[n.columna].nota7 : cols[n.columna].nota6;
    final limpio = texto.trim();
    return n.notaIndex < limpio.length ? limpio[n.notaIndex] : '';
  }

  ZamponaNota? _zamponaDe(String caracter, bool esFila7) {
    final pos = int.tryParse(caracter);
    if (pos == null || pos < 1) return null;
    final id = esFila7 ? 'fila7_$pos' : 'fila6_$pos';
    return zamponaNotas.firstWhere((n) => n.id == id, orElse: () => zamponaNotas.first);
  }

  Future<void> _reproducir() async {
    final id = ++_runId;
    setState(() { _reproduciendo = true; _pausa = false; });
    final notas = _extraerNotas();

    for (final n in notas) {
      if (id != _runId) return;
      while (_pausa && id == _runId) { await Future.delayed(const Duration(milliseconds: 100)); }
      if (n.delayMs > 0) await Future.delayed(Duration(milliseconds: (n.delayMs / _velocidad).round()));
      
      final nota = _zamponaDe(_caracterDe(n), n.esFila7);
      if (nota != null && (_modo == 'solo7' && n.esFila7 || _modo == 'solo6' && !n.esFila7)) {
        _service.tocar(nota.id);
      }
      if (mounted) setState(() { _estrofaActual = n.estrofa; _notaActiva = n; _notaSonando = nota?.id; });
      await Future.delayed(Duration(milliseconds: (200 / _velocidad).round()));
    }
    if (mounted && id == _runId) setState(() { _reproduciendo = false; _notaActiva = null; _notaSonando = null; });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: AppColors.dorado)));

    return ToolScaffold(
      titulo: widget.cancion.titulo,
      subtitulo: 'Modo Ensayo',
      onCerrar: () { _runId++; Navigator.pop(context); },
      bottomBar: EnsayoControles(
        reproduciendo: _reproduciendo, pausa: _pausa, bucle: _bucle, velocidad: _velocidad,
        esModoAudio: _modo == 'audio', audioReproduciendo: false, audioPos: 0, audioTotal: 1,
        onPlay: _reproducir, onPausa: () => setState(() => _pausa = true), onReset: () { _runId++; _reproducir(); },
        onDetener: () { _runId++; setState(() => _reproduciendo = false); }, onToggleBucle: () => setState(() => _bucle = !_bucle),
        onVelocidad: (v) => setState(() => _velocidad = v), onAudioPlay: () {}, onAudioSeek: (_) {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
            child: EnsayoModos(modo: _modo, puedeAudio: _puedeAudio, onCambiar: (m) => setState(() => _modo = m)),
          ),
          const SizedBox(height: Sp.sm),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: const EdgeInsets.all(Sp.sm),
                    padding: const EdgeInsets.all(Sp.sm),
                    decoration: BoxDecoration(color: const Color(0xFF14080A), borderRadius: Rad.rMd, border: Border.all(color: AppColors.dorado.withOpacity(0.3))),
                    child: SingleChildScrollView(
                      child: VisorNumerofonia(
                        estrofas: widget.cancion.estrofas,
                        escala: 0.9,
                        celdaActiva: _notaActiva != null ? CeldaActiva(estrofa: _notaActiva!.estrofa, columna: _notaActiva!.columna, esFila7: _notaActiva!.esFila7, notaIndex: _notaActiva!.notaIndex) : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ZamponaWidget(
                    brillando: _notaSonando != null ? {_notaSonando!} : {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}