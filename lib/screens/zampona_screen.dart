import 'package:flutter/material.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';

/// Pantalla de la mini zampoña. Muestra las 13 cañas distribuidas
/// en 2 filas (arriba = 7, abajo = 6). Tocás una → suena.
class ZamponaScreen extends StatefulWidget {
  const ZamponaScreen({super.key});

  @override
  State<ZamponaScreen> createState() => _ZamponaScreenState();
}

class _ZamponaScreenState extends State<ZamponaScreen> {
  final _service = ZamponaService();
  bool _cargando = true;

  /// IDs que están sonando (para la animación de brillo).
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _service.init();
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _tocar(ZamponaNota nota) async {
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
    // Apagar el brillo después de 250ms
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _sonando.remove(nota.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZAMPOÑA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_off),
            tooltip: 'Detener sonidos',
            onPressed: () => _service.detener(),
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.granate.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _header(context),
                    const SizedBox(height: 24),

                    // Fila 7 (arriba)
                    _tituloFila(context, 'HILERA SUPERIOR · 7 cañas',
                        Icons.arrow_upward),
                    const SizedBox(height: 10),
                    _filaCanas(context, notasFila7, esArriba: true),

                    const SizedBox(height: 32),

                    // Separador visual
                    _separador(context),

                    const SizedBox(height: 32),

                    // Fila 6 (abajo)
                    _tituloFila(context, 'HILERA INFERIOR · 6 cañas',
                        Icons.arrow_downward),
                    const SizedBox(height: 10),
                    _filaCanas(context, notasFila6, esArriba: false),

                    const SizedBox(height: 40),

                    // Tip
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.dorado.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.dorado.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined,
                              size: 16, color: AppColors.granate),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tocá cada caña para escuchar su nota. '
                              'Las cañas más chicas (izquierda) son las más '
                              'agudas; las más grandes (derecha), las más '
                              'graves.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.75),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granate.withOpacity(0.08),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.gradienteGranate,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.granate.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.music_note,
                color: AppColors.dorado, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZAMPOÑA INTERACTIVA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.seccionTitulo(context),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Practicá la posición de las cañas y escuchá cada nota',
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withOpacity(0.65),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloFila(BuildContext context, String texto, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 14, color: AppColors.granate),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.granate,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _separador(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(color: AppColors.granate.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ZAMPOÑA',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.granate.withOpacity(0.4),
              letterSpacing: 3,
            ),
          ),
        ),
        Expanded(
            child: Divider(color: AppColors.granate.withOpacity(0.2))),
      ],
    );
  }

  Widget _filaCanas(BuildContext context,
      List<ZamponaNota> notas, {required bool esArriba}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.dorado.withOpacity(0.05),
            AppColors.granate.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final nota in notas)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _cania(context, nota, esArriba: esArriba),
            ),
        ],
      ),
    );
  }

  Widget _cania(BuildContext context, ZamponaNota nota,
      {required bool esArriba}) {
    final sonando = _sonando.contains(nota.id);

    // Altura de la caña proporcional a su posición:
    // posicion 1 = más chica (aguda) → altura menor
    // posicion N = más grande (grave) → altura mayor
    final total = esArriba ? 7.0 : 6.0;
    final alturaMin = esArriba ? 70.0 : 60.0;
    final alturaMax = esArriba ? 140.0 : 120.0;
    final factor = nota.posicion / total;
    final altura = alturaMin + (alturaMax - alturaMin) * factor;

    return GestureDetector(
      onTapDown: (_) => _tocar(nota),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nota
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: sonando
                  ? AppColors.dorado
                  : AppColors.granate.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
            child: Text(nota.nota),
          ),
          const SizedBox(height: 4),
          // Caña
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: 32,
            height: altura,
            decoration: BoxDecoration(
              gradient: sonando
                  ? AppColors.gradienteDorado
                  : AppColors.gradienteGranate,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: (sonando ? AppColors.dorado : AppColors.granate)
                      .withOpacity(sonando ? 0.6 : 0.25),
                  blurRadius: sonando ? 16 : 6,
                  spreadRadius: sonando ? 2 : 0,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: sonando
                    ? AppColors.dorado
                    : AppColors.granate.withOpacity(0.3),
                width: sonando ? 2 : 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.circle,
                size: 6,
                color: sonando
                    ? AppColors.granate
                    : AppColors.dorado.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}