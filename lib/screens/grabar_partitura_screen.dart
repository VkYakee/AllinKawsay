import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/zampona_catalogo.dart';
import '../models/numerofonia.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';

/// Pantalla de grabación de partitura con la zampoña.
///
/// Regla:
///   - Misma fila consecutiva → misma celda (concatena dígitos).
///   - Cambio de fila → nueva columna, empieza a escribir en esa fila.
///   - Guarda timing real (ms entre toques) para modo ensayo.
class GrabarPartituraScreen extends StatefulWidget {
  final EstrofaNumerofonia estrofaInicial;

  const GrabarPartituraScreen({
    super.key,
    required this.estrofaInicial,
  });

  @override
  State<GrabarPartituraScreen> createState() =>
      _GrabarPartituraScreenState();
}

class _GrabarPartituraScreenState extends State<GrabarPartituraScreen> {
  final _service = ZamponaService();
  final _scrollCtrl = ScrollController();

  late EstrofaNumerofonia _trabajo;

  /// Fila activa actual (7 o 6). Null = nada escrito aún.
  int? _filaActiva;

  /// Momento del último toque, para calcular delta.
  DateTime? _ultimoToque;

  /// Historial de deshacer.
  final List<_Snapshot> _historial = [];

  bool _cargando = true;
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _trabajo = widget.estrofaInicial.copy();
    _inicializar();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _service.init();
    if (mounted) setState(() => _cargando = false);
  }

  // ═══════════════════════════════════════════════════════════
  // LÓGICA DE GRABACIÓN
  // ═══════════════════════════════════════════════════════════
  void _tocarCania(ZamponaNota nota) async {
    // Sonar la nota (feedback auditivo)
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _sonando.remove(nota.id));
    });

    // Guardar snapshot para deshacer
    _historial.add(_Snapshot(_trabajo.copy(), _filaActiva));

    // Calcular delta de tiempo desde el último toque
    final ahora = DateTime.now();
    final delta = _ultimoToque == null
        ? 0
        : ahora.difference(_ultimoToque!).inMilliseconds;
    _ultimoToque = ahora;

    final numero = '${nota.posicion}';
    final fila = nota.fila;

    setState(() {
      if (_filaActiva == null || _filaActiva != fila) {
        // Cambio de fila (o primer toque) → nueva columna
        final nueva = ColumnaNumerofonia();
        if (fila == 7) {
          nueva.nota7 = numero;
          nueva.timings7 = [0];
        } else {
          nueva.nota6 = numero;
          nueva.timings6 = [0];
        }
        _trabajo.columnas.add(nueva);
        _filaActiva = fila;
      } else {
        // Misma fila → concatenar en la última columna
        if (_trabajo.columnas.isEmpty) {
          return;
        }
        final ultima = _trabajo.columnas.last;
        if (fila == 7) {
          ultima.nota7 = '${ultima.nota7}$numero';
          ultima.timings7 = [...ultima.timings7, delta];
        } else {
          ultima.nota6 = '${ultima.nota6}$numero';
          ultima.timings6 = [...ultima.timings6, delta];
        }
      }
    });

    // Auto-scroll al final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    setState(() {
      final snap = _historial.removeLast();
      _trabajo = snap.estrofa;
      _filaActiva = snap.filaActiva;
    });
  }

  void _limpiar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Limpiar todo',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: const Text(
            '¿Borrar todo lo grabado en esta estrofa? No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _trabajo = EstrofaNumerofonia(
        columnas: <ColumnaNumerofonia>[],
        bis: _trabajo.bis,
      );
      _filaActiva = null;
      _ultimoToque = null;
      _historial.clear();
    });
  }

  void _terminar() {
    Navigator.pop(context, _trabajo);
  }

  void _cancelar() async {
    if (_historial.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar grabación',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: const Text(
            '¿Salir sin guardar los cambios? Se perderá lo grabado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Seguir grabando'),
          ),
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
          _previewEstrofa(),
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
  final total = _trabajo.columnas.fold<int>(
    0,
    (s, c) => s + c.nota7.length + c.nota6.length,
  );
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
        const Icon(Icons.fiber_manual_record,
            color: Colors.redAccent, size: 14),
        const SizedBox(width: 6),
        const Text(
          'GRABANDO',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
          ),
          child: Text(
            '$total nota${total == 1 ? '' : 's'}',
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const Spacer(),
        if (_filaActiva != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Fila $_filaActiva',
              style: const TextStyle(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// PREVIEW EN VIVO DE LA ESTROFA
// ═══════════════════════════════════════════════════════════
Widget _previewEstrofa() {
  final cols = _trabajo.columnas.isEmpty
      ? [ColumnaNumerofonia(), ColumnaNumerofonia()]
      : _trabajo.columnas;

  return Container(
    height: 62,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF14080A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _EtiquetaFila('7'),
            SizedBox(height: 2),
            _EtiquetaFila('6'),
          ],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < cols.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _celdaPreview(cols[i]),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _celdaPreview(ColumnaNumerofonia c) {
  final ancho = (c.maxLen.clamp(1, 8) * 14.0).clamp(28.0, 120.0);
  return Container(
    width: ancho,
    height: 44,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      border: Border.all(color: AppColors.dorado.withOpacity(0.35)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              c.nota7,
              style: const TextStyle(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ),
        Container(
          height: 1,
          color: AppColors.dorado.withOpacity(0.25),
        ),
        Expanded(
          child: Center(
            child: Text(
              c.nota6,
              style: const TextStyle(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// BOTONES DE ACCIÓN
// ═══════════════════════════════════════════════════════════
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
            onTap: _historial.isEmpty ? null : _deshacer,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _botonAccion(
            icono: Icons.delete_sweep,
            label: 'LIMPIAR',
            color: Colors.redAccent,
            onTap: _trabajo.columnas.isEmpty ? null : _limpiar,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: _botonAccion(
            icono: Icons.check,
            label: 'TERMINAR',
            color: Colors.green,
            filled: true,
            onTap: _terminar,
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
  // ZAMPOÑA (círculos con hueco)
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

// ═══════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════
class _EtiquetaFila extends StatelessWidget {
  final String texto;
  const _EtiquetaFila(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.granate,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColors.dorado,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _Snapshot {
  final EstrofaNumerofonia estrofa;
  final int? filaActiva;
  _Snapshot(this.estrofa, this.filaActiva);
}