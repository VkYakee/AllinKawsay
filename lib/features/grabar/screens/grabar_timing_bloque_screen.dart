// lib/features/grabar/screens/grabar_timing_bloque_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../core/widgets/zampona_canvas.dart';
import '../../../design/design.dart';
import '../../../models/bloque_audio.dart';
import '../../../models/cancion.dart';
import '../../../models/numerofonia.dart';
import '../../../models/zampona_nota.dart';
import '../../../services/player_service.dart';
import '../../../theme/colors.dart';
import '../../../widgets/visor_numerofonia.dart';
import '../../../widgets/zampona/tool_scaffold.dart';
import '../../../widgets/setlist/setlist_reproductor.dart';

class GrabarTimingBloqueScreen extends StatefulWidget {
  final Cancion cancion;
  final BloqueAudio bloque;

  const GrabarTimingBloqueScreen({
    super.key,
    required this.cancion,
    required this.bloque,
  });

  @override
  State<GrabarTimingBloqueScreen> createState() =>
      _GrabarTimingBloqueScreenState();
}

class _GrabarTimingBloqueScreenState extends State<GrabarTimingBloqueScreen> {
  final _player = PlayerService().player;
  late EstrofaNumerofonia _estrofa;
  bool _cargando = true;
  String _errorMsg = '';

  final List<int> _toquesMs = [];
  int _indexEsperada = 0;
  final Set<String> _brillo = {};

  Duration _pos = Duration.zero;
  Duration? _duracion;
  StreamSubscription<Duration>? _subPos;
  StreamSubscription<Duration?>? _subDur;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (widget.bloque.estrofaRef < 0 ||
        widget.bloque.estrofaRef >= estrofas.length) {
      _errorMsg = 'Este bloque no tiene una estrofa asignada.';
      _estrofa = EstrofaNumerofonia();
      _cargando = false;
      return;
    }

    _estrofa = estrofas[widget.bloque.estrofaRef];
    _cargarAudio();
  }

  @override
  void dispose() {
    _subPos?.cancel();
    _subDur?.cancel();
    _player.pause();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _cargarAudio() async {
    try {
      await _player.stop();
      final tag = MediaItem(
        id: 'timing_${widget.cancion.id}_${widget.bloque.inicioMs}',
        title: 'Timing: ${widget.bloque.label}',
        artist: 'Allin Kawsay',
      );

      await _player
          .setAudioSource(
            AudioSource.uri(
              Uri.parse(widget.cancion.audioUrl),
              tag: tag,
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (widget.bloque.tieneTimingA) {
        _toquesMs.addAll(widget.bloque.timingsMs);
        _indexEsperada = _toquesMs.length;
      }

      await _player.seek(Duration(milliseconds: widget.bloque.inicioMs));

      _subPos = _player.positionStream.listen((p) {
        if (mounted) setState(() => _pos = p);
      });
      _subDur = _player.durationStream.listen((d) {
        if (mounted) setState(() => _duracion = d);
      });

      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error al cargar el audio:\n$e';
          _cargando = false;
        });
      }
    }
  }

  void _tocarCania(ZamponaNota nota) {
    setState(() => _brillo.add(nota.id));
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _brillo.remove(nota.id));
    });

    if (_indexEsperada >= _notasTotales) return;

    setState(() {
      _toquesMs.add(_pos.inMilliseconds);
      _indexEsperada = _toquesMs.length;
    });
  }

  int get _notasTotales {
    int count = 0;
    for (var c in _estrofa.columnas) {
      count += c.nota7.trim().length + c.nota6.trim().length;
    }
    return count;
  }

  void _terminar() {
    if (_toquesMs.isEmpty) return;
    final recortado = _toquesMs.length > _notasTotales
        ? _toquesMs.sublist(0, _notasTotales)
        : _toquesMs;
    Navigator.pop(context, recortado);
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
    if (_errorMsg.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            _errorMsg,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return ToolScaffold(
      titulo: 'Timing: ${widget.bloque.label}',
      subtitulo: 'Toca al ritmo del audio',
      onCerrar: () => Navigator.pop(context),
      bottomBar: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'DESHACER',
              icon: Icons.undo,
              variant: AppButtonVariant.secondary,
              onPressed: _toquesMs.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _toquesMs.removeLast();
                        _indexEsperada = _toquesMs.length;
                      });
                    },
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            flex: 2,
            child: AppButton(
              label:
                  _indexEsperada >= _notasTotales ? 'GUARDAR' : 'TERMINAR',
              icon: Icons.check,
              onPressed: _toquesMs.isEmpty ? null : _terminar,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SetlistReproductor(
            posicion: _pos,
            duracion: _duracion,
            reproduciendo: _player.playing,
            onTogglePlay: () =>
                _player.playing ? _player.pause() : _player.play(),
            onSeek: (v) => _player.seek(Duration(milliseconds: v.toInt())),
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF14080A),
                      borderRadius: Rad.rMd,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: VisorNumerofonia(
                          estrofas: [_estrofa],
                          escala: 1.2,
                          fondoOscuro: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ZamponaCanvas(
                    brillando: _brillo,
                    onTapNota: _tocarCania,
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