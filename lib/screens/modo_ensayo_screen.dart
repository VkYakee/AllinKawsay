// lib/screens/modo_ensayo_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../design/design.dart';
import '../models/bloque_audio.dart';
import '../models/cancion.dart';
import '../services/player_service.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/ensayo/letra_sincronizada.dart';
import '../widgets/ensayo/controles_ensayo.dart';
import '../widgets/zampona/tool_scaffold.dart';
import '../widgets/zampona/zampona_widget.dart';
import 'zampona_practica_screen.dart';

class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

class _NotaEnBloque {
  final int estrofa;
  final int columna;
  final bool esFila7;
  final int notaIndex;
  final int timingMs;
  _NotaEnBloque({required this.estrofa, required this.columna, required this.esFila7, required this.notaIndex, required this.timingMs});
}

class _ModoEnsayoScreenState extends State<ModoEnsayoScreen> {
  final _player = PlayerService().player;
  final _service = ZamponaService();
  bool _cargando = true;
  double _velocidad = 1.0;
  bool _bucle = true;
  int _bloqueActual = -1;
  _NotaEnBloque? _notaActiva;
  String? _notaSonando;
  
  late List<BloqueAudio> _bloques;
  late List<_NotaEnBloque> _notasDelBloqueActual;
  Duration _pos = Duration.zero;
  Duration? _duracion;
  StreamSubscription<Duration>? _subPos;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bloques = widget.cancion.setlist;
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    try {
      await _player.stop();
      if (widget.cancion.audioUrl.isNotEmpty) {
        final tag = MediaItem(id: 'ensayo_${widget.cancion.id}', title: 'Ensayo: ${widget.cancion.titulo}', artist: 'Allin Kawsay');
        await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.cancion.audioUrl), tag: tag));
        
        _subPos = _player.positionStream.listen((p) {
          if (mounted) {
            setState(() => _pos = p);
            _actualizarNotaActiva();
          }
        });
        _player.durationStream.listen((d) { if (mounted) setState(() => _duracion = d); });
      }
    } catch (e) {
      debugPrint('Error al cargar audio: $e');
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _subPos?.cancel();
    _player.pause();
    _service.detener(); // Detener zampoña al salir
    super.dispose();
  }

  int _getBloqueIndex(Duration pos) {
    final ms = pos.inMilliseconds;
    for (int i = 0; i < _bloques.length; i++) {
      if (_bloques[i].inicioMs <= ms) {
        if (i == _bloques.length - 1) return i;
        if (_bloques[i + 1].inicioMs > ms) return i;
      }
    }
    return -1;
  }

  void _actualizarNotaActiva() {
    if (_bloques.isEmpty) return;
    final idx = _getBloqueIndex(_pos);
    
    if (idx != _bloqueActual) {
      setState(() {
        _bloqueActual = idx;
        _notaActiva = null;
        _notaSonando = null;
        if (idx >= 0) {
          _notasDelBloqueActual = _extraerNotasDeBloque(_bloques[idx]);
        } else {
          _notasDelBloqueActual = [];
        }
      });
    }
    if (idx < 0) return;

    final bloque = _bloques[idx];
    final elapsed = _pos.inMilliseconds - bloque.inicioMs;
    int acumulado = 0;
    _NotaEnBloque? encontrada;
    for (final n in _notasDelBloqueActual) {
      acumulado += n.timingMs;
      if (acumulado >= elapsed) {
        encontrada = n;
        break;
      }
    }
    if (encontrada != null) {
      final igual = _notaActiva?.columna == encontrada.columna && _notaActiva?.esFila7 == encontrada.esFila7 && _notaActiva?.notaIndex == encontrada.notaIndex;
      if (!igual) {
        setState(() => _notaActiva = encontrada);
      }
    }
  }

  List<_NotaEnBloque> _extraerNotasDeBloque(BloqueAudio bloque) {
    if (!bloque.tieneVisual) return [];
    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= estrofas.length) return [];
    final estrofa = estrofas[bloque.estrofaRef];
    final lista = <_NotaEnBloque>[];
    for (int c = 0; c < estrofa.columnas.length; c++) {
      final col = estrofa.columnas[c];
      for (int i = 0; i < col.nota7.trim().length; i++) {
        final t = i < col.timings7.length ? col.timings7[i] : 400;
        lista.add(_NotaEnBloque(estrofa: bloque.estrofaRef, columna: c, esFila7: true, notaIndex: i, timingMs: t));
      }
      for (int i = 0; i < col.nota6.trim().length; i++) {
        final t = i < col.timings6.length ? col.timings6[i] : 400;
        lista.add(_NotaEnBloque(estrofa: bloque.estrofaRef, columna: c, esFila7: false, notaIndex: i, timingMs: t));
      }
    }
    return lista;
  }

  double get _progreso {
    if (_bloqueActual < 0 || _bloqueActual >= _bloques.length) return 0;
    final bloque = _bloques[_bloqueActual];
    final finMs = (_bloqueActual + 1 < _bloques.length) ? _bloques[_bloqueActual + 1].inicioMs : (_duracion?.inMilliseconds ?? bloque.inicioMs + 10000);
    final total = finMs - bloque.inicioMs;
    if (total <= 0) return 0;
    final actual = (_pos.inMilliseconds - bloque.inicioMs).clamp(0, total);
    return actual / total;
  }

  String get _letraActual {
    if (_bloqueActual >= 0 && _bloques[_bloqueActual].conLetra && widget.cancion.tieneLetra) {
      return widget.cancion.letras.first.texto;
    }
    // Si no hay setlist configurado para esta canción, mostramos la letra general
    if (widget.cancion.tieneLetra) return widget.cancion.letras.first.texto;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: AppColors.dorado)));

    return ToolScaffold(
      titulo: widget.cancion.titulo,
      subtitulo: 'Modo Ensayo con Audio',
      onCerrar: () { _player.pause(); Navigator.pop(context); },
      actions: [
        // 🎹 CAMBIADO POR UN ÍCONO DE METRÓNOMO / HERRAMIENTAS
        IconButton(
          icon: const Icon(Icons.av_timer, color: AppColors.dorado),
          tooltip: 'Práctica Libre (Solo 6/7)',
          onPressed: () {
            _player.pause();
            Navigator.push(context, MaterialPageRoute(builder: (_) => ZamponaPracticaScreen(estrofasGuia: widget.cancion.estrofas)));
          },
        ),
      ],
      body: Column(
        children: [
          // 1. TABLA (Compacta y sin scroll)
          Expanded(
            flex: 3,
            child: Container(
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
                    estrofas: widget.cancion.estrofas,
                    escala: 1.0,
                    fondoOscuro: true,
                    celdaActiva: _notaActiva != null
                        ? CeldaActiva(
                            estrofa: _notaActiva!.estrofa,
                            columna: _notaActiva!.columna,
                            esFila7: _notaActiva!.esFila7,
                            notaIndex: _notaActiva!.notaIndex,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          
          // 2. LETRA SINCRO
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: LetraSincronizada(
              letra: _letraActual,
              progreso: _progreso,
            ),
          ),

          // 3. ZAMPOÑA (Protagonista abajo) + Controles
          Expanded(
            flex: 5,
            child: Row(
              children: [
                // Zampoña Grande
                Expanded(
                  flex: 6,
                  child: ZamponaWidget(
                    brillando: _notaSonando != null ? {_notaSonando!} : {}, 
                    onTapNota: null, // En modo ensayo se toca sola
                  ),
                ),
                // Controles Rediseñados
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(Sp.sm),
                    child: ControlesEnsayo(
                      reproduciendo: _player.playing,
                      velocidad: _velocidad,
                      bucle: _bucle,
                      posMs: _pos.inMilliseconds.toDouble(),
                      totalMs: (_duracion?.inMilliseconds ?? 1).toDouble(),
                      onPlay: () async {
                        if (_player.processingState == ProcessingState.completed) await _player.seek(Duration.zero);
                        _player.play();
                      },
                      onPause: () => _player.pause(),
                      onStop: () { _player.pause(); _player.seek(Duration.zero); },
                      onToggleBucle: () => setState(() => _bucle = !_bucle),
                      onVelocidad: (v) { setState(() => _velocidad = v); _player.setSpeed(v); },
                      onSeek: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                    ),
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