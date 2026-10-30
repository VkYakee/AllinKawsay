// lib/features/grabar/screens/grabar_letra_karaoke_screen.dart
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

class GrabarLetraKaraokeScreen extends StatefulWidget {
  final Cancion cancion;
  final BloqueAudio bloque;

  const GrabarLetraKaraokeScreen({
    super.key,
    required this.cancion,
    required this.bloque,
  });

  @override
  State<GrabarLetraKaraokeScreen> createState() =>
      _GrabarLetraKaraokeScreenState();
}

class _GrabarLetraKaraokeScreenState extends State<GrabarLetraKaraokeScreen> {
  final _player = PlayerService().player;
  bool _cargando = true;
  String _errorMsg = '';

  late List<String> _palabras;
  late List<bool> _seleccionadas;

  late List<FragmentoKaraoke> _fragmentos;

  Duration _pos = Duration.zero;
  Duration? _duracion;
  StreamSubscription<Duration>? _subPos;
  StreamSubscription<Duration?>? _subDur;

  bool _grabando = false;
  int _inicioActualMs = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final texto =
        widget.cancion.tieneLetra ? widget.cancion.letras.first.texto : '';
    _palabras =
        texto.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    _seleccionadas = List.generate(_palabras.length, (_) => false);

    _fragmentos = List.from(widget.bloque.karaokeFragments);

    _cargarAudio();
  }

  @override
  void dispose() {
    _subPos?.cancel();
    _subDur?.cancel();
    _player.pause();
    super.dispose();
  }

  Future<void> _cargarAudio() async {
    try {
      await _player.stop();
      final tag = MediaItem(
        id: 'karaoke_${widget.cancion.id}_${widget.bloque.inicioMs}',
        title: 'Karaoke: ${widget.bloque.label}',
        artist: 'Allin Kawsay',
      );

      await _player
          .setAudioSource(
            AudioSource.uri(Uri.parse(widget.cancion.audioUrl), tag: tag),
          )
          .timeout(const Duration(seconds: 15));
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

  void _togglePalabra(int index) {
    if (!_grabando) return;
    setState(() => _seleccionadas[index] = !_seleccionadas[index]);
  }

  void _iniciarGrabacion() {
    setState(() {
      _grabando = true;
      _inicioActualMs = _pos.inMilliseconds;
      for (int i = 0; i < _seleccionadas.length; i++) {
        _seleccionadas[i] = false;
      }
    });
  }

  void _terminarGrabacion() {
    final seleccionadasTexto = <String>[];
    for (int i = 0; i < _palabras.length; i++) {
      if (_seleccionadas[i]) seleccionadasTexto.add(_palabras[i]);
    }

    if (seleccionadasTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una palabra')),
      );
      return;
    }

    final nuevoFrag = FragmentoKaraoke(
      inicioMs: _inicioActualMs,
      finMs: _pos.inMilliseconds,
      texto: seleccionadasTexto.join(' '),
    );

    setState(() {
      _fragmentos.add(nuevoFrag);
      _grabando = false;
    });
  }

  void _eliminarFragmento(int index) {
    setState(() => _fragmentos.removeAt(index));
  }

  void _guardar() {
    Navigator.pop(context, _fragmentos);
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
          child: Text(_errorMsg, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return ToolScaffold(
      titulo: 'Karaoke: ${widget.bloque.label}',
      subtitulo: 'Selecciona las palabras para cada fragmento',
      onCerrar: () => Navigator.pop(context),
      actions: [
        IconButton(
          icon: const Icon(Icons.check, color: AppColors.dorado),
          onPressed: _guardar,
        ),
      ],
      bottomBar: Row(
        children: [
          if (!_grabando)
            Expanded(
              child: AppButton(
                label: 'INICIAR KARAOKE',
                icon: Icons.play_arrow,
                onPressed: _iniciarGrabacion,
              ),
            )
          else
            Expanded(
              child: AppButton(
                label: 'TERMINAR KARAOKE',
                icon: Icons.stop,
                variant: AppButtonVariant.danger,
                onPressed: _terminarGrabacion,
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
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: Sp.sm),
              padding: const EdgeInsets.all(Sp.md),
              decoration: BoxDecoration(
                color: const Color(0xFF14080A),
                borderRadius: Rad.rMd,
                border: Border.all(
                  color: AppColors.dorado.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  children: List.generate(_palabras.length, (i) {
                    final sel = _seleccionadas[i];
                    return GestureDetector(
                      onTap: () => _togglePalabra(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sp.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.red.withOpacity(0.8)
                              : Colors.transparent,
                          borderRadius: Rad.rSm,
                        ),
                        child: Text(
                          _palabras[i],
                          style: AppType.body.copyWith(
                            color: sel
                                ? Colors.white
                                : (_grabando
                                    ? AppColors.dorado
                                    : Colors.white54),
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: Sp.sm),
          if (_fragmentos.isNotEmpty)
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: Sp.sm),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _fragmentos.length,
                itemBuilder: (context, i) {
                  final f = _fragmentos[i];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: Sp.sm),
                    padding: const EdgeInsets.all(Sp.sm),
                    decoration: BoxDecoration(
                      color: AppColors.granate.withOpacity(0.3),
                      borderRadius: Rad.rMd,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(f.inicioMs / 1000).toStringAsFixed(1)}s - ${(f.finMs / 1000).toStringAsFixed(1)}s',
                              style: AppType.captionXs.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                              onPressed: () => _eliminarFragmento(i),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.texto,
                          style: AppType.captionXs.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}