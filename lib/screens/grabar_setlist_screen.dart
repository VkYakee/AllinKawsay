import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/bloque_audio.dart';
import '../models/cancion.dart';
import '../services/player_service.dart';
import '../theme/colors.dart';
import 'grabar_timing_bloque_screen.dart';

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
  // ⚠️ Usamos el player GLOBAL en vez de uno nuevo.
  // Eso evita conflictos con just_audio_background.
  final _player = PlayerService().player;
  final _scrollCtrl = ScrollController();

  Duration _posicion = Duration.zero;
  Duration? _duracion;
  bool _cargando = true;
  bool _error = false;
  String _errorMsg = '';

  late List<BloqueAudio> _bloques;

  StreamSubscription<Duration>? _subPos;
  StreamSubscription<Duration?>? _subDur;
  StreamSubscription<PlayerState>? _subState;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _bloques = widget.setlistInicial.map((b) => b.copy()).toList();
    _cargarAudio();
  }

  @override
  void dispose() {
    // NO dispose del player global.
    _subPos?.cancel();
    _subDur?.cancel();
    _subState?.cancel();
    _player.pause();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarAudio() async {
    try {
      if (widget.cancion.audioUrl.isEmpty) {
        setState(() {
          _error = true;
          _errorMsg = 'La canción no tiene un audio cargado.';
          _cargando = false;
        });
        return;
      }

      // Detener cualquier audio que estuviera sonando antes.
      await _player.stop();

      final tag = MediaItem(
        id: 'setlist_${widget.cancion.id}',
        title: 'Setlist: ${widget.cancion.titulo}',
        artist: 'Allin Kawsay',
      );

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.cancion.audioUrl),
          tag: tag,
        ),
      );

      _subPos = _player.positionStream.listen((p) {
        if (mounted) setState(() => _posicion = p);
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
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  Future<void> _seek(Duration d) async {
    await _player.seek(d);
  }

  Future<List<int>?> _preguntarGrabarTiming(BloqueAudio bloque) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Grabar timing?',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        content: const Text(
            'Para que el modo ensayo funcione en modo Audio URL, '
            'necesitás grabar cuándo suena cada nota del bloque.\n\n'
            '¿Grabar el timing de este bloque ahora?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Después')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Grabar ahora'),
          ),
        ],
      ),
    );
    if (ok != true) return null;
    if (!mounted) return null;

    final resultado = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarTimingBloqueScreen(
          cancion: widget.cancion,
          bloque: bloque,
        ),
      ),
    );
    return resultado;
  }

  Future<void> _marcarBloque() async {
    final estabaReproduciendo = _reproduciendo;
    if (estabaReproduciendo) {
      await _player.pause();
    }

    final ms = _posicion.inMilliseconds;
    if (!mounted) return;

    final resultado = await showModalBottomSheet<BloqueAudio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ConfigurarBloque(
        inicioMs: ms,
        estrofasDisponibles:
            widget.cancion.estrofas.where((e) => !e.vacia).length,
        letrasDisponibles:
            widget.cancion.letras.where((l) => !l.vacia).length,
      ),
    );

    if (!mounted) return;

    if (resultado != null) {
      List<int>? timings;
      if (resultado.tieneVisual) {
        timings = await _preguntarGrabarTiming(resultado);
      }
      if (!mounted) return;

      final bloqueFinal = timings != null
          ? resultado.copyConTimings(timings)
          : resultado;

      setState(() {
        _bloques.add(bloqueFinal);
      });
      _autoScroll();
    }

    if (estabaReproduciendo) {
      await _player.play();
    }
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _editarBloque(int index) async {
    final actual = _bloques[index];
    final resultado = await showModalBottomSheet<BloqueAudio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ConfigurarBloque(
        inicioMs: actual.inicioMs,
        bloqueExistente: actual,
        estrofasDisponibles:
            widget.cancion.estrofas.where((e) => !e.vacia).length,
        letrasDisponibles:
            widget.cancion.letras.where((l) => !l.vacia).length,
      ),
    );

    if (resultado == null || !mounted) return;

    List<int> timings = [];
    if (resultado.tieneVisual) {
      final mismoDestino =
          resultado.estrofaRef == actual.estrofaRef &&
          resultado.tipo == actual.tipo;
      if (mismoDestino) {
        timings = actual.timingsMs;
      } else {
        final grabados = await _preguntarGrabarTiming(resultado);
        timings = grabados ?? [];
      }
    }

    if (!mounted) return;

    final bloqueFinal = timings.isNotEmpty
        ? resultado.copyConTimings(timings)
        : resultado.copyConTimings([]);

    setState(() => _bloques[index] = bloqueFinal);
  }

  Future<void> _regrabarTiming(int index) async {
    final actual = _bloques[index];
    final resultado = await Navigator.push<List<int>>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarTimingBloqueScreen(
          cancion: widget.cancion,
          bloque: actual,
        ),
      ),
    );
    if (resultado != null && mounted) {
      setState(() {
        _bloques[index] = actual.copyConTimings(resultado);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timing A actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _eliminarBloque(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar bloque',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: Text('¿Eliminar "${_bloques[index].label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _bloques.removeAt(index));
    }
  }

  Future<void> _limpiarTodo() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Borrar todo',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: Text('¿Eliminar los ${_bloques.length} bloques?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _bloques.clear());
    }
  }

  void _guardar() {
    if (_bloques.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Marcá al menos un bloque antes de guardar')),
      );
      return;
    }
    final ordenados = List<BloqueAudio>.from(_bloques)
      ..sort((a, b) => a.inicioMs.compareTo(b.inicioMs));
    Navigator.pop(context, ordenados);
  }

  Future<void> _cancelar() async {
    if (_bloques.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Salir sin guardar',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: const Text(
            'Se perderán los cambios. ¿Salir igual?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir editando')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETLIST DEL AUDIO'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelar,
        ),
        actions: [
          if (_bloques.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Borrar todo',
              onPressed: _limpiarTodo,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Guardar',
            onPressed: _guardar,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate))
          : _error
              ? _buildError()
              : Column(
                  children: [
                    _buildReproductor(),
                    _buildBotonMarcar(),
                    const SizedBox(height: 12),
                    Expanded(child: _buildLista()),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el audio',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg, // ⬅️ muestra el error exacto
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('VOLVER'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReproductor() {
    final total = _duracion ?? Duration.zero;
    final posSec = _posicion.inMilliseconds.toDouble();
    final totalSec =
        total.inMilliseconds.toDouble().clamp(1.0, 999999999.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.negro, Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteDorado,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dorado.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _reproduciendo
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.granate,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.dorado,
                        thumbColor: AppColors.dorado,
                        inactiveTrackColor:
                            AppColors.dorado.withOpacity(0.2),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(
                                overlayRadius: 14),
                      ),
                      child: Slider(
                        value: posSec.clamp(0.0, totalSec),
                        max: totalSec,
                        onChanged: (v) => _seek(
                            Duration(milliseconds: v.toInt())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Text(
                            _fmt(_posicion),
                            style: TextStyle(
                              color: AppColors.dorado.withOpacity(0.9),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            total == Duration.zero
                                ? '--:--'
                                : _fmt(total),
                            style: TextStyle(
                              color: AppColors.dorado.withOpacity(0.6),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonMarcar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: FilledButton.icon(
          onPressed: _marcarBloque,
          icon: const Icon(Icons.fiber_manual_record,
              color: Colors.white, size: 20),
          label: const Text(
            'MARCAR BLOQUE AQUÍ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLista() {
    if (_bloques.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.queue_music,
                    size: 48,
                    color: AppColors.granate.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              Text(
                'Sin bloques aún',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reproducí el audio y tocá MARCAR BLOQUE\n'
                'cada vez que empiece una sección nueva.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _bloques.length,
      itemBuilder: (context, i) {
        final b = _bloques[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _editarBloque(i),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradienteGranate,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.dorado,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _iconoDe(b.tipo),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  b.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timer,
                                  size: 11,
                                  color: AppColors.granate),
                              const SizedBox(width: 4),
                              Text(
                                b.inicioFormateado,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.granate
                                      .withOpacity(0.8),
                                  fontFamily: 'monospace',
                                ),
                              ),
                              if (b.tieneTimingA) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 9,
                                          color: Colors.green),
                                      SizedBox(width: 3),
                                      Text(
                                        'TIMING A',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (b.tipo == TipoBloque.ligero) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.orange
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${b.velocidad.toStringAsFixed(2)}x',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (b.tieneVisual)
                      IconButton(
                        icon: Icon(Icons.timer,
                            size: 20,
                            color: b.tieneTimingA
                                ? Colors.green
                                : Colors.grey.withOpacity(0.6)),
                        tooltip: b.tieneTimingA
                            ? 'Regrabar timing A'
                            : 'Grabar timing A',
                        onPressed: () => _regrabarTiming(i),
                      ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 20,
                          color: Colors.red.withOpacity(0.7)),
                      onPressed: () => _eliminarBloque(i),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _iconoDe(TipoBloque t) {
    switch (t) {
      case TipoBloque.enganche:
        return const Icon(Icons.link,
            size: 14, color: Colors.grey);
      case TipoBloque.intro:
        return const Icon(Icons.play_circle_outline,
            size: 14, color: Colors.purpleAccent);
      case TipoBloque.diana:
        return const Icon(Icons.wb_sunny_outlined,
            size: 14, color: Colors.amber);
      case TipoBloque.chacota:
        return const Icon(Icons.celebration_outlined,
            size: 14, color: Colors.pinkAccent);
      case TipoBloque.estrofa:
        return const Icon(Icons.music_note,
            size: 14, color: AppColors.granate);
      case TipoBloque.bis:
        return const Icon(Icons.repeat,
            size: 14, color: Colors.green);
      case TipoBloque.ligero:
        return const Icon(Icons.bolt,
            size: 14, color: Colors.orange);
    }
  }
}
// ═══════════════════════════════════════════════════════════
// DIÁLOGO / SHEET PARA CONFIGURAR UN BLOQUE
// ═══════════════════════════════════════════════════════════
class _ConfigurarBloque extends StatefulWidget {
  final int inicioMs;
  final BloqueAudio? bloqueExistente;
  final int estrofasDisponibles;
  final int letrasDisponibles;

  const _ConfigurarBloque({
    required this.inicioMs,
    this.bloqueExistente,
    required this.estrofasDisponibles,
    required this.letrasDisponibles,
  });

  @override
  State<_ConfigurarBloque> createState() => _ConfigurarBloqueState();
}

class _ConfigurarBloqueState extends State<_ConfigurarBloque> {
  late TipoBloque _tipo;
  late int _estrofaRef;
  late bool _conLetra;
  late double _velocidad;

  @override
  void initState() {
    super.initState();
    final b = widget.bloqueExistente;
    _tipo = b?.tipo ?? TipoBloque.enganche;
    _estrofaRef = b?.estrofaRef ?? -1;
    _conLetra = b?.conLetra ?? false;
    _velocidad = b?.velocidad ?? 1.2;
  }

  String get _inicioFmt {
    final seg = widget.inicioMs ~/ 1000;
    final m = seg ~/ 60;
    final s = seg % 60;
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  bool get _requiereEstrofa =>
      _tipo == TipoBloque.estrofa ||
      _tipo == TipoBloque.bis ||
      _tipo == TipoBloque.ligero;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dorado,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.fiber_manual_record,
                      color: Colors.red, size: 14),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'CONFIGURAR BLOQUE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.granate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.granate.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _inicioFmt,
                      style: const TextStyle(
                        color: AppColors.granate,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'TIPO DE BLOQUE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: TipoBloque.values
                    .map((t) => _chipTipo(t))
                    .toList(),
              ),

              if (_requiereEstrofa) ...[
                const SizedBox(height: 20),
                Text(
                  'ESTROFA DE LA TABLA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (int i = 0; i < widget.estrofasDisponibles; i++)
                      _chipEstrofa(i),
                  ],
                ),
              ],

              if (_tipo == TipoBloque.estrofa) ...[
                const SizedBox(height: 20),
                SwitchListTile(
                  value: _conLetra,
                  activeColor: Colors.blueAccent,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Mostrar letra durante este bloque',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    _conLetra
                        ? 'El karaoke aparecerá'
                        : 'Solo instrumental visual',
                    style: TextStyle(
                      fontSize: 11,
                      color: onSurface.withOpacity(0.55),
                    ),
                  ),
                  onChanged: (v) => setState(() => _conLetra = v),
                ),
              ],

              if (_tipo == TipoBloque.ligero) ...[
                const SizedBox(height: 16),
                Text(
                  'VELOCIDAD · ${_velocidad.toStringAsFixed(2)}x',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.orange,
                    thumbColor: Colors.orange,
                    inactiveTrackColor:
                        Colors.orange.withOpacity(0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    min: 1.0,
                    max: 1.5,
                    divisions: 10,
                    value: _velocidad,
                    onChanged: (v) =>
                        setState(() => _velocidad = v),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () {
                    final bloque = BloqueAudio(
                      inicioMs: widget.inicioMs,
                      estrofaRef: _requiereEstrofa ? _estrofaRef : -1,
                      conLetra:
                          _tipo == TipoBloque.estrofa && _conLetra,
                      tipo: _tipo,
                      velocidad: _tipo == TipoBloque.ligero
                          ? _velocidad
                          : 1.0,
                    );
                    Navigator.pop(context, bloque);
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    widget.bloqueExistente == null
                        ? 'AGREGAR BLOQUE'
                        : 'GUARDAR CAMBIOS',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCELAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipTipo(TipoBloque t) {
    final activo = _tipo == t;
    final String label;
    final IconData icono;
    switch (t) {
      case TipoBloque.enganche:
        label = 'Enganche';
        icono = Icons.link;
        break;
      case TipoBloque.intro:
        label = 'Intro';
        icono = Icons.play_circle_outline;
        break;
      case TipoBloque.diana:
        label = 'Diana';
        icono = Icons.wb_sunny_outlined;
        break;
      case TipoBloque.chacota:
        label = 'Chacota';
        icono = Icons.celebration_outlined;
        break;
      case TipoBloque.estrofa:
        label = 'Estrofa';
        icono = Icons.music_note;
        break;
      case TipoBloque.bis:
        label = 'BIS';
        icono = Icons.repeat;
        break;
      case TipoBloque.ligero:
        label = 'Ligero';
        icono = Icons.bolt;
        break;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipo = t;
          if (_requiereEstrofa && _estrofaRef < 0) _estrofaRef = 0;
          if (!_requiereEstrofa) _conLetra = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: activo ? AppColors.gradienteGranate : null,
          color: activo ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo
                ? AppColors.granate
                : AppColors.granate.withOpacity(0.3),
            width: activo ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono,
                size: 14,
                color: activo ? AppColors.dorado : AppColors.granate),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color:
                    activo ? AppColors.dorado : AppColors.granate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipEstrofa(int i) {
    final activo = _estrofaRef == i;
    return GestureDetector(
      onTap: () => setState(() => _estrofaRef = i),
      child: Container(
        width: 50,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: activo ? AppColors.gradienteGranate : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo
                ? AppColors.granate
                : AppColors.granate.withOpacity(0.3),
            width: activo ? 1.8 : 1,
          ),
        ),
        child: Text(
          'E${i + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: activo ? AppColors.dorado : AppColors.granate,
          ),
        ),
      ),
    );
  }
}