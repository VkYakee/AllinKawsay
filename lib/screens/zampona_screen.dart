import 'package:flutter/material.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';

/// Pantalla de la mini zampoña con diseño realista.
/// Las cañas tienen hueco visible (como la zampoña real) y
/// las dos filas están pegadas para no mover mucho los dedos.
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
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _sonando.remove(nota.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ZAMPOÑA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              child: CircularProgressIndicator(color: AppColors.dorado))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                child: Column(
                  children: [
                    _zampona(),
                    const SizedBox(height: 20),
                    _leyenda(),
                  ],
                ),
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ZAMPOÑA (contenedor principal)
  // ═══════════════════════════════════════════════════════════
  Widget _zampona() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.4,
          colors: [
            const Color(0xFF1A0A0D),
            Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.granate.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, cons) {
          // Ancho de cada caña calculado sobre 7 columnas fijas
          // (así fila 7 y fila 6 tienen el mismo ancho de caña).
          const separacion = 4.0;
          final disponible = cons.maxWidth - (separacion * 6);
          final anchoCania = disponible / 7;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── FILA 7 (arriba) ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final nota in notasFila7)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: separacion / 2),
                      child: SizedBox(
                        width: anchoCania,
                        child: _cania(nota, esArriba: true),
                      ),
                    ),
                ],
              ),

              // ─── LISTÓN CENTRAL ───
              const SizedBox(height: 6),
              _liston(),
              const SizedBox(height: 6),

              // ─── FILA 6 (abajo) ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final nota in notasFila6)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: separacion / 2),
                      child: SizedBox(
                        width: anchoCania,
                        child: _cania(nota, esArriba: false),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LISTÓN DORADO CENTRAL
  // ═══════════════════════════════════════════════════════════
  Widget _liston() {
    return Container(
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.doradoOscuro,
            AppColors.dorado,
            AppColors.doradoOscuro,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.dorado.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CAÑA INDIVIDUAL
  // ═══════════════════════════════════════════════════════════
  Widget _cania(ZamponaNota nota, {required bool esArriba}) {
    final sonando = _sonando.contains(nota.id);

    // Altura proporcional a su posición (aguda = corta, grave = larga)
    final total = esArriba ? 7.0 : 6.0;
    final alturaMin = esArriba ? 70.0 : 62.0;
    final alturaMax = esArriba ? 135.0 : 120.0;
    final factor = nota.posicion / total;
    final altura = alturaMin + (alturaMax - alturaMin) * factor;

    return GestureDetector(
      onTapDown: (_) => _tocar(nota),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: sonando ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── NOMBRE DE LA NOTA (arriba) ───
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: sonando
                    ? AppColors.dorado
                    : AppColors.dorado.withOpacity(0.7),
                letterSpacing: 0.3,
                height: 1.0,
              ),
              child: Text(nota.nota),
            ),
            const SizedBox(height: 5),

            // ─── HUECO (orificio del tubo) ───
            AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: sonando
                        ? [
                            const Color(0xFF3A0810),
                            AppColors.granate,
                            AppColors.dorado.withOpacity(0.95),
                          ]
                        : [
                            Colors.black,
                            const Color(0xFF0A0305),
                            AppColors.granateOscuro,
                          ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  border: Border.all(
                    color: sonando
                        ? AppColors.dorado
                        : AppColors.dorado.withOpacity(0.35),
                    width: sonando ? 2.5 : 1.3,
                  ),
                  boxShadow: sonando
                      ? [
                          BoxShadow(
                            color: AppColors.dorado.withOpacity(0.8),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
              ),
            ),
            const SizedBox(height: 3),

            // ─── CUERPO DE LA CAÑA (cilíndrico) ───
            AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              width: double.infinity,
              height: altura,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: sonando
                      ? [
                          AppColors.doradoOscuro,
                          AppColors.dorado,
                          AppColors.doradoClaro,
                          AppColors.dorado,
                          AppColors.doradoOscuro,
                        ]
                      : [
                          const Color(0xFF3A0810),
                          AppColors.granate,
                          AppColors.granateClaro,
                          AppColors.granate,
                          AppColors.granateOscuro,
                        ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                border: Border.all(
                  color: sonando
                      ? AppColors.dorado
                      : AppColors.dorado.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  // Sombra lateral derecha (efecto 3D cilíndrico)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  ),
                  if (sonando)
                    BoxShadow(
                      color: AppColors.dorado.withOpacity(0.55),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LEYENDA INFERIOR
  // ═══════════════════════════════════════════════════════════
  Widget _leyenda() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dorado.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined,
              size: 16, color: AppColors.dorado),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tocá cada caña para escuchar su nota. '
              'Las cañas más chicas (izquierda) son las más agudas; '
              'las más grandes (derecha), las más graves.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}