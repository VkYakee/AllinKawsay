import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';

/// Pantalla de la mini zampoña en modo horizontal (landscape),
/// pantalla completa (immersive), con las 2 filas pegadas para
/// mínima distancia entre dedos.
class ZamponaScreen extends StatefulWidget {
  const ZamponaScreen({super.key});

  @override
  State<ZamponaScreen> createState() => _ZamponaScreenState();
}

class _ZamponaScreenState extends State<ZamponaScreen> {
  final _service = ZamponaService();
  bool _cargando = true;
  final Set<String> _sonando = {};

  @override
  void initState() {
    super.initState();

    // Forzar landscape + pantalla completa
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _inicializar();
  }

  @override
  void dispose() {
    // Restaurar orientación y barras
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
      body: SafeArea(
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.dorado))
            : Stack(
                children: [
                  // Zampoña centrada
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 44, 12, 12),
                      child: _zampona(),
                    ),
                  ),

                  // Barra superior flotante
                  Positioned(
                    top: 4,
                    left: 8,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.dorado),
                          tooltip: 'Volver',
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'ZAMPOÑA',
                          style: TextStyle(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.volume_off,
                          color: AppColors.dorado),
                      tooltip: 'Detener sonidos',
                      onPressed: () => _service.detener(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ZAMPOÑA (fila 7 arriba + fila 6 pegada abajo)
  // ═══════════════════════════════════════════════════════════
  Widget _zampona() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.6),
          radius: 1.6,
          colors: [
            Color(0xFF1A0A0D),
            Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
          // Ancho por caña (basado en 7 columnas para alinear filas)
          const separacion = 4.0;
          final disponible = cons.maxWidth - (separacion * 6);
          final anchoCania = disponible / 7;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              // ─── FILA 6 pegada (sin listón central) ───
              const SizedBox(height: 2),

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
  // CAÑA INDIVIDUAL (hueco con número + cuerpo cilíndrico)
  // ═══════════════════════════════════════════════════════════
  Widget _cania(ZamponaNota nota, {required bool esArriba}) {
    final sonando = _sonando.contains(nota.id);

    // Altura proporcional a su posición (aguda = corta, grave = larga)
    final total = esArriba ? 7.0 : 6.0;
    final alturaMin = esArriba ? 48.0 : 42.0;
    final alturaMax = esArriba ? 92.0 : 80.0;
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
            // ─── HUECO con NÚMERO adentro ───
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
                        : AppColors.dorado.withOpacity(0.45),
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
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final lado = c.maxWidth;
                      return Text(
                        '${nota.posicion}',
                        style: TextStyle(
                          color: sonando
                              ? AppColors.dorado
                              : AppColors.dorado.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: (lado * 0.5).clamp(11.0, 26.0),
                          height: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),

            // ─── CUERPO cilíndrico ───
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
}
