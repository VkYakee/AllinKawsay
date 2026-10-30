// lib/features/grabar/screens/grabar_timing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/zampona_canvas.dart';
import '../../../data/zampona_catalogo.dart';
import '../../../design/design.dart';
import '../../../models/numerofonia.dart';
import '../../../models/zampona_nota.dart';
import '../../../services/zampona_service.dart';
import '../../../theme/colors.dart';
import '../../../widgets/visor_numerofonia.dart';
import '../../../widgets/zampona/tool_scaffold.dart';

class GrabarTimingScreen extends StatefulWidget {
  final EstrofaNumerofonia estrofa;
  const GrabarTimingScreen({super.key, required this.estrofa});

  @override
  State<GrabarTimingScreen> createState() => _GrabarTimingScreenState();
}

class _NotaEnEstrofa {
  final int columna;
  final bool esFila7;
  final int notaIndex;
  final String caracter;

  _NotaEnEstrofa({
    required this.columna,
    required this.esFila7,
    required this.notaIndex,
    required this.caracter,
  });
}

class _GrabarTimingScreenState extends State<GrabarTimingScreen> {
  final _service = ZamponaService();
  final _scrollCtrl = ScrollController();
  late EstrofaNumerofonia _trabajo;
  late List<_NotaEnEstrofa> _notas;
  int _indexActual = 0;
  final List<int> _deltas = [];
  DateTime? _ultimoToque;
  bool _cargando = true;
  bool _terminado = false;
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _trabajo = widget.estrofa.copy();
    _notas = _extraerNotas(_trabajo);
    _service.init().then((_) {
      if (mounted) setState(() => _cargando = false);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<_NotaEnEstrofa> _extraerNotas(EstrofaNumerofonia e) {
    final lista = <_NotaEnEstrofa>[];
    for (int c = 0; c < e.columnas.length; c++) {
      final col = e.columnas[c];
      for (int i = 0; i < col.nota7.trim().length; i++) {
        lista.add(_NotaEnEstrofa(
          columna: c,
          esFila7: true,
          notaIndex: i,
          caracter: col.nota7[i],
        ));
      }
      for (int i = 0; i < col.nota6.trim().length; i++) {
        lista.add(_NotaEnEstrofa(
          columna: c,
          esFila7: false,
          notaIndex: i,
          caracter: col.nota6[i],
        ));
      }
    }
    return lista;
  }

  void _tocarCania(ZamponaNota nota) async {
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _sonando.remove(nota.id));
    });

    if (_terminado) return;

    final ahora = DateTime.now();
    final delta = _ultimoToque == null
        ? 0
        : ahora.difference(_ultimoToque!).inMilliseconds;
    _ultimoToque = ahora;

    setState(() {
      _deltas.add(delta);
      if (_indexActual < _notas.length) _indexActual++;
      if (_indexActual >= _notas.length) _terminado = true;
    });

    if (_scrollCtrl.hasClients) {
      final fraccion =
          _indexActual / (_notas.isEmpty ? 1 : _notas.length);
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent * fraccion,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _terminar() async {
    if (_deltas.isEmpty) return;
    final resultado = _trabajo.copy();
    for (final col in resultado.columnas) {
      col.timings7.clear();
      col.timings6.clear();
    }

    final maxLen = _deltas.length < _notas.length
        ? _deltas.length
        : _notas.length;
    for (int i = 0; i < maxLen; i++) {
      final nota = _notas[i];
      final col = resultado.columnas[nota.columna];
      if (nota.esFila7) {
        col.timings7.add(_deltas[i]);
      } else {
        col.timings6.add(_deltas[i]);
      }
    }
    if (mounted) Navigator.pop(context, resultado);
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
      titulo: 'Grabar Timing',
      subtitulo: 'Toca al ritmo de la canción',
      onCerrar: () => Navigator.pop(context),
      bottomBar: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'DESHACER',
              icon: Icons.undo,
              variant: AppButtonVariant.secondary,
              onPressed: _deltas.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _deltas.removeLast();
                        if (_indexActual > 0) _indexActual--;
                        _terminado = false;
                        _ultimoToque = null;
                      });
                    },
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            flex: 2,
            child: AppButton(
              label: _terminado ? 'GUARDAR TIMING' : 'TERMINAR',
              icon: Icons.check,
              onPressed: _deltas.isEmpty ? null : _terminar,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: Sp.sm),
            padding: const EdgeInsets.all(Sp.sm),
            decoration: BoxDecoration(
              color: const Color(0xFF14080A),
              borderRadius: Rad.rMd,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.4),
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: VisorNumerofonia(
                estrofas: [_trabajo],
                escala: 1.1,
                celdaActiva: (!_terminado && _indexActual < _notas.length)
                    ? CeldaActiva(
                        estrofa: 0,
                        columna: _notas[_indexActual].columna,
                        esFila7: _notas[_indexActual].esFila7,
                        notaIndex: _notas[_indexActual].notaIndex,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: Sp.sm),
          Expanded(
            child: ZamponaCanvas(
              brillando: _sonando,
              onTapNota: _tocarCania,
            ),
          ),
        ],
      ),
    );
  }
}