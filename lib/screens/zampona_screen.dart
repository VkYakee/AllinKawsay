import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';

/// Pantalla de la mini zampoña en modo horizontal (landscape),
/// pantalla completa (immersive), con las 2 filas pegadas.
/// Incluye toggle SOSTENIDO / PULSADO.
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _inicializar();
  }

  @override
  void dispose() {
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

  // ─── MODO SOSTENIDO ───
  Future<void> _tocarDown(ZamponaNota nota) async {
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
  }

  // ─── MODO PULSADO ───
  Future<void> _soltar(ZamponaNota nota) async {
    await _service.soltar(nota.id);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) setState(() => _sonando.remove(nota.id));
      });
    }
  }

  void _apagarBrillo(ZamponaNota nota) {
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
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 54, 12, 12),
                      child: _zampona(),
                    ),
                  ),

                  // Barra superior flotante
                  Positioned(
                    top: 4,
                    left: 8,
                    right: 8,
                    child: _barraSuperior(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _barraSuperior() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dorado),
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
        const SizedBox(width: 16),

        // Toggle SOSTENIDO / PULSADO
        _toggleModo(),

        const Spacer(),
        IconButton(
          icon: const Icon(Icons.volume_off, color: AppColors.dorado),
          tooltip: 'Detener sonidos',
          onPressed: () async {
            await _service.detener();
            if (mounted) setState(() => _sonando.clear());
          },
        ),
      ],
    );
  }

  Widget _toggleModo() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chipModo('SOSTENIDO', Icons.waves, ZamponaModo.sostenido),
          const SizedBox(width: 3),
          _chipModo('PULSADO', Icons.touch_app, ZamponaModo.pulsado),
        ],
      ),
    );
  }

  Widget _chipModo(String texto, IconData icono, ZamponaModo modo) {
    final activo = _service.modo == modo;
    return GestureDetector(
      onTap: () {
        setState(() => _service.setModo(modo));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: activo ? AppColors.gradienteDorado : null,
          color: activo ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 12,
              color: activo
                  ? AppColors.granate
                  : AppColors.dorado.withOpacity(0.6),
            ),
            const SizedBox(width: 5),
            Text(
              texto,
              style: TextStyle(
                color: activo
                    ? AppColors.granate
                    : AppColors.dorado.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          const separacion = 4.0;
          final disponible = cons.maxWidth - (separacion * 6);
          final anchoCania = disponible / 7;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // FILA 7
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

              const SizedBox(height: 2),

              // FILA 6 pegada
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

  Widget _cania(ZamponaNota nota, {required bool esArriba}) {
    final sonando = _sonando.contains(nota.id);
    final modoPulsado = _service.modo == ZamponaModo.pulsado;

    final total = esArriba ? 7.0 : 6.0;
    final alturaMin = esArriba ? 48.0 : 42.0;
    final alturaMax = esArriba ? 92.0 : 80.0;
    final factor = nota.posicion / total;
    final altura = alturaMin + (alturaMax - alturaMin) * factor;

    // En modo sostenido: onTapDown solo
    // En modo pulsado: onTapDown + onTapUp + onTapCancel
    final gesture = modoPulsado
        ? GestureDetector(
            onTapDown: (_) => _tocarDown(nota),
            onTapUp: (_) => _soltar(nota),
            onTapCancel: () => _soltar(nota),
            behavior: HitTestBehavior.opaque,
            child: _contenidoCania(nota, sonando, altura),
          )
        : GestureDetector(
            onTapDown: (_) {
              _tocarDown(nota);
              _apagarBrillo(nota);
            },
            behavior: HitTestBehavior.opaque,
            child: _contenidoCania(nota, sonando, altura),
          );

    return AnimatedScale(
      scale: sonando ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: gesture,
    );
  }

  Widget _contenidoCania(ZamponaNota nota, bool sonando, double altura) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // HUECO con NÚMERO adentro
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

        // CUERPO cilíndrico
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
    );
  }
}