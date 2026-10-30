// lib/features/grabar/screens/grabar_setlist_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../design/design.dart';
import '../../../models/bloque_audio.dart';
import '../../../models/cancion.dart';
import '../../../services/player_service.dart';
import '../../../theme/colors.dart';
import '../../../widgets/zampona/tool_scaffold.dart';
import '../../../widgets/setlist/setlist_reproductor.dart';
import '../../../widgets/setlist/setlist_lista_bloques.dart';
import '../../../widgets/setlist/configurar_bloque_modal.dart';
import 'grabar_timing_bloque_screen.dart';
import 'grabar_letra_karaoke_screen.dart';

class GrabarSetlistScreen extends StatefulWidget {
  final Cancion cancion;
  final List<BloqueAudio> setlistInicial;

  const GrabarSetlistScreen({
    super.key,
    required this.cancion,
    required this.setlistInicial,
  });

  @override
  State<GrabarSetlistScreen> createState() => _GrabarSetlistScreenState();
}

class _GrabarSetlistScreenState extends State<GrabarSetlistScreen> {
  final _player = PlayerService().player;
  final _scrollCtrl = ScrollController();
  Duration _posicion = Duration.zero;
  Duration? _duracion;
  bool _cargando = true;
  late List<BloqueAudio> _bloques;
  StreamSubscription<Duration>? _subPos;
  StreamSubscription<Duration?>? _subDur;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _bloques = widget.setlistInicial.map((b) => b.copy()).toList();
    _cargar();
  }

  @override
  void dispose() {
    _subPos?.cancel();
    _subDur?.cancel();
    _player.pause();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      await _player.stop();
      final tag = MediaItem(
        id: 'setlist_${widget.cancion.id}',
        title: 'Setlist: ${widget.cancion.titulo}',
        artist: 'Allin Kawsay',
      );
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(widget.cancion.audioUrl), tag: tag),
      );
      _subPos = _player.positionStream.listen((p) {
        if (mounted) setState(() => _posicion = p);
      });
      _subDur = _player.durationStream.listen((d) {
        if (mounted) setState(() => _duracion = d);
      });
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _marcarBloque() async {
    final estaba = _player.playing;
    if (estaba) await _player.pause();
    final ms = _posicion.inMilliseconds;
    final estrofasCount =
        widget.cancion.estrofas.where((e) => !e.vacia).length;

    final res = await ConfigurarBloqueModal.mostrar(
      context,
      inicioMs: ms,
      estrofasDisponibles: estrofasCount,
    );

    if (res != null && mounted) {
      setState(() => _bloques.add(res));
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ));
    }
    if (estaba) await _player.play();
  }

  Future<void> _editarBloque(int index) async {
    final estrofasCount =
        widget.cancion.estrofas.where((e) => !e.vacia).length;
    final res = await ConfigurarBloqueModal.mostrar(
      context,
      inicioMs: _bloques[index].inicioMs,
      bloqueExistente: _bloques[index],
      estrofasDisponibles: estrofasCount,
    );
    if (res != null && mounted) setState(() => _bloques[index] = res);
  }

  Future<void> _regrabarTiming(int index) async {
    final res = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarTimingBloqueScreen(
          cancion: widget.cancion,
          bloque: _bloques[index],
        ),
      ),
    );
    if (res != null && mounted) {
      setState(() => _bloques[index] = _bloques[index].copyConTimings(res));
    }
  }

  Future<void> _grabarKaraoke(int index) async {
    final res = await Navigator.push<List<FragmentoKaraoke>>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarLetraKaraokeScreen(
          cancion: widget.cancion,
          bloque: _bloques[index],
        ),
      ),
    );
    if (res != null && mounted) {
      setState(() => _bloques[index] = _bloques[index].copyConKaraoke(res));
    }
  }

  void _guardar() {
    if (_bloques.isEmpty) return;
    _bloques.sort((a, b) => a.inicioMs.compareTo(b.inicioMs));
    Navigator.pop(context, _bloques);
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
      titulo: 'Setlist del Audio',
      subtitulo: '${_bloques.length} bloques marcados',
      onCerrar: () => Navigator.pop(context),
      bottomBar: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'MARCAR BLOQUE',
              icon: Icons.add,
              onPressed: _marcarBloque,
            ),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: AppButton(
              label: 'GUARDAR',
              icon: Icons.check,
              variant: AppButtonVariant.secondary,
              onPressed: _guardar,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SetlistReproductor(
            posicion: _posicion,
            duracion: _duracion,
            reproduciendo: _player.playing,
            onTogglePlay: () =>
                _player.playing ? _player.pause() : _player.play(),
            onSeek: (v) => _player.seek(Duration(milliseconds: v.toInt())),
          ),
          const SizedBox(height: Sp.sm),
          Expanded(
            child: SetlistListaBloques(
              bloques: _bloques,
              scrollCtrl: _scrollCtrl,
              onEditar: _editarBloque,
              onRegrabarTiming: _regrabarTiming,
              onGrabarKaraoke: _grabarKaraoke,
              onEliminar: (i) => setState(() => _bloques.removeAt(i)),
            ),
          ),
        ],
      ),
    );
  }
}