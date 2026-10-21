import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../data/zampona_catalogo.dart';
import '../models/bloque_audio.dart';
import '../models/cancion.dart';
import '../models/numerofonia.dart';
import '../models/zampona_nota.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

/// Pantalla para grabar el TIMING A de un bloque del setlist.
///
/// - Suena el audio real (solo audible en esta pantalla).
/// - La mini zampoña aparece como guía VISUAL (no suena).
/// - El usuario toca las cañas siguiendo lo que escucha.
/// - Cada toque registra `audio.position` (ms absoluto en el audio).
/// - Se guardan los ms en `timingsMs` del bloque.
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

/// Una nota individual dentro del bloque (en el orden en que aparece).
class _NotaEnBloque {
  final int columna;
  final bool esFila7;
  final int notaIndex;
  final String caracter;

  _NotaEnBloque({
    required this.columna,
    required this.esFila7,
    required this.notaIndex,
    required this.caracter,
  });
}

class _GrabarTimingBloqueScreenState extends State<GrabarTimingBloqueScreen> {
  final _player = AudioPlayer();

  late List<_NotaEnBloque> _notas;
  late EstrofaNumerofonia _estrofa;

  bool _cargando = true;
  bool _error = false;
  String _errorMsg = '';

  /// Cada toque registra su ms absoluto en el audio.
  final List<int> _toquesMs = [];

  /// Índice de la próxima nota esperada (para resaltar en la tabla).
  int _indexEsperada = 0;

  /// Ids de cañas que deben brillar momentáneamente.
  final Set<String> _brillo = {};

  Duration _pos = Duration.zero;
  Duration? _duracion;

  StreamSubscription<Duration>? _subPos;
  StreamSubscription<Duration?>? _subDur;
  StreamSubscription<PlayerState>? _subState;

  bool get _completo =>
      _indexEsperada >= _notas.length && _notas.isNotEmpty;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Preparar estrofa y notas del bloque
    final estrofas =
        widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (widget.bloque.estrofaRef < 0 ||
        widget.bloque.estrofaRef >= estrofas.length) {
      _error = true;
      _errorMsg = 'Bloque sin estrofa asignada';
      _estrofa = EstrofaNumerofonia();
      _notas = [];
      _cargando = false;
      return;
    }

    _estrofa = estrofas[widget.bloque.estrofaRef];
    _notas = _extraerNotas(_estrofa);

    _cargar();
  }

  @override
  void dispose() {
    _subPos?.cancel();
    _subDur?.cancel();
    _subState?.cancel();
    _player.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<_NotaEnBloque> _extraerNotas(EstrofaNumerofonia e) {
    final lista = <_NotaEnBloque>[];
    for (int c = 0; c < e.columnas.length; c++) {
      final col = e.columnas[c];

      final n7 = col.nota7.trim();
      for (int i = 0; i < n7.length; i++) {
        lista.add(_NotaEnBloque(
          columna: c,
          esFila7: true,
          notaIndex: i,
          caracter: n7[i],
        ));
      }

      final n6 = col.nota6.trim();
      for (int i = 0; i < n6.length; i++) {
        lista.add(_NotaEnBloque(
          columna: c,
          esFila7: false,
          notaIndex: i,
          caracter: n6[i],
        ));
      }
    }
    return lista;
  }

  Future<void> _cargar() async {
    try {
      if (widget.cancion.audioUrl.isEmpty) {
        setState(() {
          _error = true;
          _errorMsg = 'La canción no tiene un audio cargado.';
          _cargando = false;
        });
        return;
      }

      final tag = MediaItem(
        id: 'timingA_${widget.cancion.id}_${widget.bloque.inicioMs}',
        title: 'Timing: ${widget.bloque.label}',
        artist: 'Allin Kawsay',
      );

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.cancion.audioUrl),
          tag: tag,
        ),
      );

      // Si el bloque ya tiene timing, precargamos para editarlo.
      if (widget.bloque.tieneTimingA) {
        _toquesMs.addAll(widget.bloque.timingsMs);
        _indexEsperada = _toquesMs.length.clamp(0, _notas.length);
      }

      // Posicionar el audio al inicio del bloque.
      await _player.seek(
          Duration(milliseconds: widget.bloque.inicioMs));

      _subPos = _player.positionStream.listen((p) {
        if (mounted) setState(() => _pos = p);
      });
      _subDur = _player.durationStream.listen((d) {
        if (mounted) setState(() => _duracion = d);
      });
      _subState = _player.playerStateStream.listen((s) {
        if (mounted) setState(() {});
      });

      setState(() => _cargando = false);
    } catch (e) {
      debugPrint('⚠️ Error al cargar audio: $e');
      if (mounted) {
        setState(() {
          _error = true;
          _errorMsg = e.toString();
          _cargando = false;
        });
      }
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _reproduciendo =>
      _player.playerState.playing &&
      _player.processingState != ProcessingState.completed;

  Future<void> _togglePlay() async {
    if (_reproduciendo) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(
            Duration(milliseconds: widget.bloque.inicioMs));
      }
      await _player.play();
    }
  }

  Future<void> _seek(Duration d) async {
    await _player.seek(d);
  }
// ═══════════════════════════════════════════════════════════
// TOCAR CAÑA (SOLO VISUAL — NO SUENA)
// ═══════════════════════════════════════════════════════════
void _tocarCania(ZamponaNota nota) {
  if (_completo) return;

  // Registrar el toque con el tiempo ACTUAL del audio.
  final ms = _pos.inMilliseconds;
  setState(() {
    _toquesMs.add(ms);
    _indexEsperada = _toquesMs.length.clamp(0, _notas.length);
    _brillo.add(nota.id);
  });

  Future.delayed(const Duration(milliseconds: 220), () {
    if (mounted) setState(() => _brillo.remove(nota.id));
  });
}

void _deshacer() {
  if (_toquesMs.isEmpty) return;
  setState(() {
    _toquesMs.removeLast();
    _indexEsperada = _toquesMs.length.clamp(0, _notas.length);
  });
}

Future<void> _reiniciar() async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      title: const Text('Reiniciar grabación',
          style: TextStyle(
              color: AppColors.granate,
              fontWeight: FontWeight.bold)),
      content: const Text(
          '¿Borrar todos los toques y empezar de nuevo?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reiniciar'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  setState(() {
    _toquesMs.clear();
    _indexEsperada = 0;
  });
  await _player.seek(
      Duration(milliseconds: widget.bloque.inicioMs));
}

Future<void> _terminar() async {
  if (_toquesMs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Tocá al menos una caña antes de guardar')),
    );
    return;
  }

  if (_toquesMs.length != _notas.length) {
    final faltan = _notas.length - _toquesMs.length;
    final sobran = _toquesMs.length - _notas.length;
    final detalle = faltan > 0
        ? 'Faltan $faltan toques.'
        : 'Tocaste $sobran toques de más.';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Faltan notas',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: Text(
            '$detalle\n\n'
            'La estrofa tiene ${_notas.length} notas y grabaste '
            '${_toquesMs.length}.\n\n'
            '¿Guardar igual? Se recortará o se rellenará.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir grabando')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar igual')),
        ],
      ),
    );
    if (ok != true) return;
  }

  final recortado = _toquesMs.length > _notas.length
      ? _toquesMs.sublist(0, _notas.length)
      : _toquesMs;

  if (!mounted) return;
  await _player.pause();
  Navigator.pop(context, recortado);
}

Future<void> _cancelar() async {
  if (_toquesMs.isEmpty) {
    await _player.pause();
    if (mounted) Navigator.pop(context);
    return;
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      title: const Text('Salir sin guardar',
          style: TextStyle(
              color: AppColors.granate,
              fontWeight: FontWeight.bold)),
      content: const Text(
          'Se perderán los toques grabados. ¿Salir igual?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir grabando')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await _player.pause();
    if (mounted) Navigator.pop(context);
  }
}

// ═══════════════════════════════════════════════════════════
// BUILD
// ═══════════════════════════════════════════════════════════
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

  if (_error) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('TIMING DEL BLOQUE'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.dorado, fontSize: 13),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('VOLVER'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          _barraSuperior(),
          const SizedBox(height: 6),
          _barraReproductor(),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14080A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.4)),
                    ),
                    child: SingleChildScrollView(
                      child: _tabla(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4),
                    child: _zampona(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _barraAcciones(),
          const SizedBox(height: 6),
        ],
      ),
    ),
  );
}
  Widget _barraSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.dorado),
            onPressed: _cancelar,
            tooltip: 'Cancelar',
          ),
          const SizedBox(width: 4),
          const Icon(Icons.timer, color: AppColors.dorado, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIMING · ${widget.bloque.label}',
                  style: const TextStyle(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Toca al ritmo del audio (sin sonido de zampoña)',
                  style: TextStyle(
                    color: AppColors.dorado.withOpacity(0.6),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _completo
                  ? Colors.green.withOpacity(0.25)
                  : AppColors.granate.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _completo
                    ? Colors.green
                    : AppColors.dorado.withOpacity(0.4),
              ),
            ),
            child: Text(
              '${_indexEsperada.clamp(0, _notas.length)} / ${_notas.length}',
              style: TextStyle(
                color: _completo ? Colors.green : AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (_completo)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'COMPLETO',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _barraReproductor() {
    final total = _duracion ?? Duration.zero;
    final posSec = _pos.inMilliseconds.toDouble();
    final totalSec =
        total.inMilliseconds.toDouble().clamp(1.0, 999999999.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _reproduciendo
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppColors.dorado,
              size: 30,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.dorado,
                thumbColor: AppColors.dorado,
                inactiveTrackColor: AppColors.dorado.withOpacity(0.2),
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 15),
              ),
              child: Slider(
                value: posSec.clamp(0.0, totalSec),
                max: totalSec,
                onChanged: (v) =>
                    _seek(Duration(milliseconds: v.toInt())),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 4),
            child: Text(
              '${_fmt(_pos)} / '
              '${total == Duration.zero ? '--:--' : _fmt(total)}',
              style: TextStyle(
                color: AppColors.dorado.withOpacity(0.85),
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabla() {
    CeldaActiva? activa;
    if (_indexEsperada < _notas.length) {
      final n = _notas[_indexEsperada];
      activa = CeldaActiva(
        estrofa: 0,
        columna: n.columna,
        esFila7: n.esFila7,
        notaIndex: n.notaIndex,
      );
    }

    return VisorNumerofonia(
      estrofas: [_estrofa],
      escala: 1.0,
      celdaActiva: activa,
    );
  }

  Widget _barraAcciones() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: _botonAccion(
              icono: Icons.undo,
              label: 'DESHACER',
              color: Colors.orange,
              onTap: _toquesMs.isEmpty ? null : _deshacer,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _botonAccion(
              icono: Icons.restart_alt,
              label: 'REINICIAR',
              color: Colors.redAccent,
              onTap: _toquesMs.isEmpty ? null : _reiniciar,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _botonAccion(
              icono: Icons.check,
              label: _completo ? 'GUARDAR TIMING' : 'TERMINAR',
              color: Colors.green,
              filled: true,
              onTap: _toquesMs.isEmpty ? null : _terminar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonAccion({
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool filled = false,
  }) {
    final habilitado = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: filled
                ? color.withOpacity(habilitado ? 0.25 : 0.08)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(habilitado ? 0.7 : 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono,
                  color: color.withOpacity(habilitado ? 1.0 : 0.4),
                  size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(habilitado ? 1.0 : 0.4),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ZAMPOÑA (SOLO VISUAL)
  // ═══════════════════════════════════════════════════════════
  Widget _zampona() {
    return LayoutBuilder(
      builder: (context, cons) {
        const separacion = 3.0;
        final disponible = cons.maxWidth - (separacion * 6) - 24;
        final maxPorAltura = (cons.maxHeight - 20) / 2.2;
        final diametroBase = disponible / 7;
        final diametro = diametroBase < maxPorAltura
            ? diametroBase
            : maxPorAltura;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final nota in notasFila7)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: separacion / 2),
                      child: _tubo(nota, diametro),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 8,
                width: diametro * 7 + separacion * 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A0308),
                      AppColors.granateOscuro,
                      Color(0xFF2A0308),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.35),
                    width: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final nota in notasFila6)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: separacion / 2),
                      child: _tubo(nota, diametro),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tubo(ZamponaNota nota, double diametro) {
    final brillando = _brillo.contains(nota.id);

    return GestureDetector(
      onTapDown: (_) => _tocarCania(nota),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: brillando ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          width: diametro,
          height: diametro,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: brillando
                  ? [
                      const Color(0xFF0A0103),
                      const Color(0xFF1A0205),
                      AppColors.granate,
                      AppColors.dorado,
                    ]
                  : [
                      const Color(0xFF0A0103),
                      const Color(0xFF1A0205),
                      const Color(0xFF3A0810),
                      AppColors.granateClaro,
                    ],
              stops: const [0.0, 0.35, 0.78, 1.0],
            ),
            border: Border.all(
              color: brillando
                  ? AppColors.dorado
                  : AppColors.dorado.withOpacity(0.35),
              width: brillando ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
              if (brillando)
                BoxShadow(
                  color: AppColors.dorado.withOpacity(0.7),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Center(
            child: Text(
              '${nota.posicion}',
              style: TextStyle(
                color: brillando
                    ? AppColors.dorado
                    : AppColors.dorado.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: diametro * 0.32,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.9),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}