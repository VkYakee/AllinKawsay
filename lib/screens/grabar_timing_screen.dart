import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/zampona_catalogo.dart';
import '../models/numerofonia.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

/// Pantalla para GRABAR EL TIMING de una estrofa ya escrita.
///
/// A diferencia del grabador de partituras (que AGREGA números),
/// esta pantalla NO toca los números existentes. Solo captura
/// los ms entre cada toque y los inyecta en `timings7` / `timings6`.
///
/// Uso típico: alguien escribió la tabla a mano. Después abrís
/// esta pantalla, tocás la mini app al ritmo que querés, y se
/// guarda el timing real.
class GrabarTimingScreen extends StatefulWidget {
  final EstrofaNumerofonia estrofa;

  const GrabarTimingScreen({super.key, required this.estrofa});

  @override
  State<GrabarTimingScreen> createState() => _GrabarTimingScreenState();
}

/// Una nota individual dentro de la estrofa (con su ubicación).
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
  final List<int> _deltas = []; // ms entre toques
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

    _inicializar();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _service.init();
    if (mounted) setState(() => _cargando = false);
  }

  /// Extrae todas las notas en el mismo orden que se van a tocar:
  /// por columna, primero fila 7, después fila 6.
  List<_NotaEnEstrofa> _extraerNotas(EstrofaNumerofonia e) {
    final lista = <_NotaEnEstrofa>[];
    for (int c = 0; c < e.columnas.length; c++) {
      final col = e.columnas[c];

      final n7 = col.nota7.trim();
      for (int i = 0; i < n7.length; i++) {
        lista.add(_NotaEnEstrofa(
          columna: c,
          esFila7: true,
          notaIndex: i,
          caracter: n7[i],
        ));
      }

      final n6 = col.nota6.trim();
      for (int i = 0; i < n6.length; i++) {
        lista.add(_NotaEnEstrofa(
          columna: c,
          esFila7: false,
          notaIndex: i,
          caracter: n6[i],
        ));
      }
    }
    return lista;
  }

  // ═══════════════════════════════════════════════════════════
  // TOQUE
  // ═══════════════════════════════════════════════════════════
  void _tocarCania(ZamponaNota nota) async {
    // Feedback auditivo y visual
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _sonando.remove(nota.id));
    });

    if (_terminado) return;

    // Guardar delta de tiempo
    final ahora = DateTime.now();
    final delta = _ultimoToque == null
        ? 0
        : ahora.difference(_ultimoToque!).inMilliseconds;
    _ultimoToque = ahora;

    setState(() {
      _deltas.add(delta);
      if (_indexActual < _notas.length) {
        _indexActual++;
      }
      if (_indexActual >= _notas.length) {
        _terminado = true;
      }
    });

    // Auto-scroll a la columna actual (aproximado)
    _autoscroll();
  }

  void _autoscroll() {
    if (!_scrollCtrl.hasClients || _notas.isEmpty) return;
    final idx = _indexActual.clamp(0, _notas.length - 1);
    final fraccion = idx / _notas.length;
    final max = _scrollCtrl.position.maxScrollExtent;
    _scrollCtrl.animateTo(
      max * fraccion,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _deshacer() {
    if (_deltas.isEmpty) return;
    setState(() {
      _deltas.removeLast();
      if (_indexActual > 0) _indexActual--;
      _terminado = false;
      _ultimoToque = null;
      // Recalcular último toque desde el delta anterior (aproximado)
      // No es exacto pero sirve para seguir grabando.
    });
  }

  void _reiniciar() async {
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
            '¿Borrar todo el timing grabado hasta ahora?'),
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
      _deltas.clear();
      _indexActual = 0;
      _terminado = false;
      _ultimoToque = null;
    });
  }
// ═══════════════════════════════════════════════════════════
// GUARDAR TIMINGS EN LA ESTROFA
// ═══════════════════════════════════════════════════════════
Future<void> _terminar() async {
  if (_deltas.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tocá al menos una caña antes de guardar')),
    );
    return;
  }

  if (_deltas.length != _notas.length) {
    final faltan = _notas.length - _deltas.length;
    final sobran = _deltas.length - _notas.length;
    final String detalle = faltan > 0
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
            'La tabla tiene ${_notas.length} notas y grabaste ${_deltas.length}.\n\n'
            '¿Guardar igual? Se recortará o rellenará con 0.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir grabando')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar igual'),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }

  // Aplicar deltas a la estrofa
  final resultado = _trabajo.copy();

  // Limpiar timings viejos
  for (final col in resultado.columnas) {
    col.timings7.clear();
    col.timings6.clear();
  }

  // Recorrer notas y deltas en paralelo
  final maxLen = _deltas.length < _notas.length
      ? _deltas.length
      : _notas.length;

  for (int i = 0; i < maxLen; i++) {
    final nota = _notas[i];
    final delta = _deltas[i];
    final col = resultado.columnas[nota.columna];
    if (nota.esFila7) {
      col.timings7.add(delta);
    } else {
      col.timings6.add(delta);
    }
  }

  // Rellenar con 0 si sobraron notas sin tocar
  for (int i = maxLen; i < _notas.length; i++) {
    final nota = _notas[i];
    final col = resultado.columnas[nota.columna];
    if (nota.esFila7) {
      col.timings7.add(0);
    } else {
      col.timings6.add(0);
    }
  }

  if (!mounted) return;
  Navigator.pop(context, resultado);
}

Future<void> _cancelar() async {
  if (_deltas.isEmpty) {
    Navigator.pop(context);
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
          'Se perderá el timing grabado. ¿Salir igual?'),
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
  if (ok == true && mounted) Navigator.pop(context);
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

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          _barraSuperior(),
          const SizedBox(height: 6),
          _previewTabla(),
          const SizedBox(height: 6),
          _barraAcciones(),
          const SizedBox(height: 6),
          Expanded(child: _zampona()),
        ],
      ),
    ),
  );
}

Widget _barraSuperior() {
  final idx = _indexActual.clamp(0, _notas.length);
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
        const Text(
          'GRABAR TIMING',
          style: TextStyle(
            color: AppColors.dorado,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _terminado
                ? Colors.green.withOpacity(0.25)
                : AppColors.granate.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _terminado
                  ? Colors.green
                  : AppColors.dorado.withOpacity(0.4),
            ),
          ),
          child: Text(
            '$idx / ${_notas.length} notas',
            style: TextStyle(
              color: _terminado ? Colors.green : AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const Spacer(),
        if (_terminado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green, size: 14),
                SizedBox(width: 5),
                Text(
                  'COMPLETADO',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
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

Widget _previewTabla() {
  CeldaActiva? activa;
  if (!_terminado && _indexActual < _notas.length) {
    final n = _notas[_indexActual];
    activa = CeldaActiva(
      estrofa: 0,
      columna: n.columna,
      esFila7: n.esFila7,
      notaIndex: n.notaIndex,
    );
  }

  return Container(
    height: 100,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF14080A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
    ),
    child: SingleChildScrollView(
      controller: _scrollCtrl,
      scrollDirection: Axis.horizontal,
      child: VisorNumerofonia(
        estrofas: [_trabajo],
        escala: 1.1,
        celdaActiva: activa,
      ),
    ),
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
              onTap: _deltas.isEmpty ? null : _deshacer,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _botonAccion(
              icono: Icons.restart_alt,
              label: 'REINICIAR',
              color: Colors.redAccent,
              onTap: _deltas.isEmpty ? null : _reiniciar,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _botonAccion(
              icono: Icons.check,
              label: _terminado ? 'GUARDAR TIMING' : 'TERMINAR',
              color: Colors.green,
              filled: true,
              onTap: _deltas.isEmpty ? null : _terminar,
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
  // ZAMPOÑA
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
    final sonando = _sonando.contains(nota.id);

    return GestureDetector(
      onTapDown: (_) => _tocarCania(nota),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
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
      ),
    );
  }
}