import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/zampona_catalogo.dart';
import '../models/cancion.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

/// Modos de audio del ensayo.
enum ModoAudio { silencio, ambas, solo7, solo6 }

/// Pantalla de ensayo guiado.
class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

/// Representa una nota concreta dentro del recorrido de reproducción.
class _NotaEnsayable {
  final int estrofa;
  final int columna;
  final bool esFila7;
  final int notaIndex;
  final int delayMs;

  _NotaEnsayable({
    required this.estrofa,
    required this.columna,
    required this.esFila7,
    required this.notaIndex,
    required this.delayMs,
  });
}

class _ModoEnsayoScreenState extends State<ModoEnsayoScreen> {
  final _service = ZamponaService();

  bool _cargando = true;
  bool _reproduciendo = false;
  bool _pausa = false;
  bool _bucle = true;
  double _velocidad = 1.0;
  ModoAudio _modoAudio = ModoAudio.silencio;

  int _estrofaActual = 0;
  _NotaEnsayable? _notaActiva;
  String? _notaSonando;
  String? _ultimaNotaSonada;

  int _runId = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _inicializar();
  }

  @override
  void dispose() {
    _runId++;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _service.init();
    if (mounted) setState(() => _cargando = false);
  }

  List<_NotaEnsayable> _extraerNotas() {
    final estrofas =
        widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (estrofas.isEmpty) return [];

    final lista = <_NotaEnsayable>[];

    for (int e = 0; e < estrofas.length; e++) {
      final cols = estrofas[e].columnas;

      for (int c = 0; c < cols.length; c++) {
        final col = cols[c];

        final n7 = col.nota7.trim();
        for (int i = 0; i < n7.length; i++) {
          final delay = i < col.timings7.length
              ? col.timings7[i]
              : (i == 0 ? 0 : 400);
          lista.add(_NotaEnsayable(
            estrofa: e,
            columna: c,
            esFila7: true,
            notaIndex: i,
            delayMs: delay,
          ));
        }

        final n6 = col.nota6.trim();
        for (int i = 0; i < n6.length; i++) {
          final delay = i < col.timings6.length
              ? col.timings6[i]
              : 400;
          lista.add(_NotaEnsayable(
            estrofa: e,
            columna: c,
            esFila7: false,
            notaIndex: i,
            delayMs: delay,
          ));
        }
      }
    }

    return lista;
  }

  String _caracterDe(_NotaEnsayable n) {
    final estrofas =
        widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (n.estrofa >= estrofas.length) return '';
    final cols = estrofas[n.estrofa].columnas;
    if (n.columna >= cols.length) return '';
    final texto =
        n.esFila7 ? cols[n.columna].nota7 : cols[n.columna].nota6;
    final limpio = texto.trim();
    if (n.notaIndex >= limpio.length) return '';
    return limpio[n.notaIndex];
  }

  ZamponaNota? _zamponaDe(String caracter, bool esFila7) {
    if (caracter == '.' || caracter.isEmpty) return null;
    final pos = int.tryParse(caracter);
    if (pos == null || pos < 1) return null;
    final id = esFila7 ? 'fila7_$pos' : 'fila6_$pos';
    for (final n in zamponaNotas) {
      if (n.id == id) return n;
    }
    return null;
  }

  bool _debeSonar(bool esFila7) {
    switch (_modoAudio) {
      case ModoAudio.silencio:
        return false;
      case ModoAudio.ambas:
        return true;
      case ModoAudio.solo7:
        return esFila7;
      case ModoAudio.solo6:
        return !esFila7;
    }
  }

  bool get _esModoSolo =>
      _modoAudio == ModoAudio.solo7 || _modoAudio == ModoAudio.solo6;
// ═══════════════════════════════════════════════════════════
// LOOP DE REPRODUCCIÓN (FIX: delay ANTES de tocar)
// ═══════════════════════════════════════════════════════════
Future<void> _reproducir() async {
  final id = ++_runId;
  setState(() {
    _reproduciendo = true;
    _pausa = false;
    _ultimaNotaSonada = null;
  });

  final notas = _extraerNotas();
  if (notas.isEmpty) {
    if (mounted) setState(() => _reproduciendo = false);
    return;
  }

  while (true) {
    if (id != _runId) return;

    for (final n in notas) {
      if (id != _runId) return;

      while (_pausa && id == _runId) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (id != _runId) return;

      // ⚠️ FIX: esperar el delay ANTES de tocar la nota.
      final delay = (n.delayMs / _velocidad).round();
      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay));
        if (id != _runId) return;
      }

      if (mounted) {
        setState(() {
          _estrofaActual = n.estrofa;
          _notaActiva = n;
        });
      }

      final caracter = _caracterDe(n);
      final nota = _zamponaDe(caracter, n.esFila7);

      if (nota == null) {
        // Nota no tocable (punto, etc). En modo solo, cortar la que suena.
        if (_esModoSolo && _ultimaNotaSonada != null) {
          final anterior = _ultimaNotaSonada!;
          _ultimaNotaSonada = null;
          _service.fadeOutNota(anterior);
        }
        continue;
      }

      if (mounted) setState(() => _notaSonando = nota.id);

      final debeSonar = _debeSonar(n.esFila7);

      if (_esModoSolo) {
        // En modo solo: aplicar fade a la nota anterior si es diferente
        // (o si esta nueva nota no va a sonar, cortar también la anterior).
        if (_ultimaNotaSonada != null &&
            _ultimaNotaSonada != nota.id) {
          final anterior = _ultimaNotaSonada!;
          _ultimaNotaSonada = null;
          _service.fadeOutNota(anterior);
        }
        if (debeSonar) {
          try {
            await _service.tocar(nota.id);
            _ultimaNotaSonada = nota.id;
          } catch (_) {}
        }
      } else {
        // Modo silencio o ambas: comportamiento simple
        if (debeSonar) {
          try {
            await _service.tocar(nota.id);
          } catch (_) {}
        }
      }

      final brilloMs = (260 / _velocidad).round().clamp(80, 800);
      Future.delayed(Duration(milliseconds: brilloMs), () {
        if (mounted && id == _runId) {
          setState(() => _notaSonando = null);
        }
      });
    }

    if (!_bucle) break;

    await Future.delayed(
        Duration(milliseconds: (700 / _velocidad).round()));
  }

  if (mounted && id == _runId) {
    setState(() {
      _reproduciendo = false;
      _notaActiva = null;
      _notaSonando = null;
    });
    final ultima = _ultimaNotaSonada;
    _ultimaNotaSonada = null;
    if (ultima != null) {
      _service.fadeOutNota(ultima);
    }
  }
}

void _pausar() => setState(() => _pausa = true);
void _reanudar() => setState(() => _pausa = false);

void _detener() {
  _runId++;
  final ultima = _ultimaNotaSonada;
  _ultimaNotaSonada = null;
  setState(() {
    _reproduciendo = false;
    _pausa = false;
    _notaActiva = null;
    _notaSonando = null;
  });
  if (ultima != null) {
    _service.fadeOutNota(ultima);
  }
  // Después del fade, cortar todo por si quedó algo colgado
  Future.delayed(const Duration(milliseconds: 200), () {
    _service.detener();
  });
}

void _reiniciar() {
  _detener();
  Future.delayed(const Duration(milliseconds: 300), () {
    if (mounted) _reproducir();
  });
}

// ═══════════════════════════════════════════════════════════
// BUILD
// ═══════════════════════════════════════════════════════════
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dorado))
          : Column(
              children: [
                _barraSuperior(),
                const SizedBox(height: 6),
                _filaModos(),
                const SizedBox(height: 6),
                _filaVelocidad(),
                const SizedBox(height: 6),
                _tablaActual(),
                const SizedBox(height: 6),
                _controles(),
                const SizedBox(height: 6),
                Expanded(child: _zamponaMini()),
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
          onPressed: () => Navigator.pop(context),
          tooltip: 'Salir',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.cancion.titulo,
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_reproduciendo)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: const Text(
              '● ENSAYANDO',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// CHIPS DE MODO (embellecidos)
// ═══════════════════════════════════════════════════════════
Widget _filaModos() {
  final modos = <(ModoAudio, String, IconData, Color)>[
    (ModoAudio.silencio, 'Silencio', Icons.volume_off, Colors.grey),
    (ModoAudio.ambas, 'Ambas', Icons.music_note, AppColors.dorado),
    (ModoAudio.solo7, 'Solo 7', Icons.arrow_upward, Colors.green),
    (ModoAudio.solo6, 'Solo 6', Icons.arrow_downward, Colors.blueAccent),
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        for (final m in modos)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _chipModo(
                label: m.$2,
                icono: m.$3,
                color: m.$4,
                activo: _modoAudio == m.$1,
                onTap: () => setState(() => _modoAudio = m.$1),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _chipModo({
  required String label,
  required IconData icono,
  required Color color,
  required bool activo,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        gradient: activo
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.95),
                  color.withOpacity(0.55),
                ],
              )
            : null,
        color: activo ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo ? color : color.withOpacity(0.3),
          width: activo ? 1.8 : 1.2,
        ),
        boxShadow: activo
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            size: 15,
            color: activo ? Colors.white : color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: activo ? Colors.white : color.withOpacity(0.9),
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              shadows: activo
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _filaVelocidad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.speed, color: AppColors.dorado, size: 14),
          const SizedBox(width: 6),
          Text(
            '${_velocidad.toStringAsFixed(2)}x',
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.dorado,
                thumbColor: AppColors.dorado,
                inactiveTrackColor: AppColors.dorado.withOpacity(0.2),
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                min: 0.25,
                max: 2.0,
                divisions: 35,
                value: _velocidad,
                onChanged: (v) => setState(() => _velocidad = v),
              ),
            ),
          ),
          Text(
            '${(_velocidad * 100).round()}%',
            style: TextStyle(
              color: AppColors.dorado.withOpacity(0.7),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablaActual() {
    final estrofas =
        widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (estrofas.isEmpty) {
      return const SizedBox.shrink();
    }

    final idx = _estrofaActual.clamp(0, estrofas.length - 1);
    final estrofa = estrofas[idx];

    CeldaActiva? activa;
    if (_notaActiva != null && _notaActiva!.estrofa == idx) {
      activa = CeldaActiva(
        estrofa: 0,
        columna: _notaActiva!.columna,
        esFila7: _notaActiva!.esFila7,
        notaIndex: _notaActiva!.notaIndex,
      );
    }

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14080A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: VisorNumerofonia(
          estrofas: [estrofa],
          escala: 0.9,
          celdaActiva: activa,
        ),
      ),
    );
  }

  Widget _controles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_reproduciendo)
            _botonControl(
              icono: Icons.play_arrow,
              label: 'REPRODUCIR',
              color: Colors.green,
              filled: true,
              onTap: _reproducir,
            )
          else if (_pausa)
            _botonControl(
              icono: Icons.play_arrow,
              label: 'REANUDAR',
              color: Colors.green,
              filled: true,
              onTap: _reanudar,
            )
          else
            _botonControl(
              icono: Icons.pause,
              label: 'PAUSA',
              color: Colors.orange,
              filled: true,
              onTap: _pausar,
            ),
          const SizedBox(width: 6),
          _botonControl(
            icono: Icons.restart_alt,
            label: 'REINICIAR',
            color: AppColors.dorado,
            onTap: _reiniciar,
          ),
          const SizedBox(width: 6),
          _botonControl(
            icono: _bucle ? Icons.repeat_one : Icons.repeat,
            label: 'BUCLE',
            color: AppColors.dorado,
            activo: _bucle,
            onTap: () => setState(() => _bucle = !_bucle),
          ),
          const SizedBox(width: 6),
          _botonControl(
            icono: Icons.stop,
            label: 'DETENER',
            color: Colors.redAccent,
            onTap: _detener,
          ),
        ],
      ),
    );
  }

  Widget _botonControl({
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
    bool activo = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: filled
                ? color.withOpacity(0.22)
                : (activo
                    ? color.withOpacity(0.28)
                    : Colors.white.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color
                  .withOpacity(filled || activo ? 0.8 : 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zamponaMini() {
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
    final sonando = _notaSonando == nota.id;

    return AnimatedScale(
      scale: sonando ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        width: diametro,
        height: diametro,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: sonando
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
            color: sonando
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.35),
            width: sonando ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.85),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
            if (sonando)
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
              color: sonando
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
    );
  }
}