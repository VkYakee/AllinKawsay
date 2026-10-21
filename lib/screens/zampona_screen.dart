import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';

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

  Future<void> _tocarDown(ZamponaNota nota) async {
    setState(() => _sonando.add(nota.id));
    await _service.tocar(nota.id);
  }

  Future<void> _soltar(ZamponaNota nota) async {
    await _service.soltar(nota.id);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) setState(() => _sonando.remove(nota.id));
      });
    }
  }

  void _apagarBrillo(ZamponaNota nota) {
    Future.delayed(const Duration(milliseconds: 300), () {
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
                      padding: const EdgeInsets.fromLTRB(8, 52, 8, 8),
                      child: _zampona(),
                    ),
                  ),
                  Positioned(top: 4, left: 8, right: 8, child: _barraSuperior()),
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
        const SizedBox(width: 14),
        _toggleModo(),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.volume_off, color: AppColors.dorado),
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
      onTap: () => setState(() => _service.setModo(modo)),
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
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.6,
          colors: [Color(0xFF1A0509), Colors.black],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, cons) {
          const separacion = 3.0;
          final disponible = cons.maxWidth - (separacion * 6) - 16;
          final anchoCania = disponible / 7;
          final diametro = anchoCania * 0.92;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _filaTubos(
                notas: notasFila7,
                diametro: diametro,
                separacion: separacion,
                colorMaderaClaro: AppColors.granateClaro,
                colorMaderaOscuro: const Color(0xFF3A0810),
              ),
              Container(
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2A0308),
                      AppColors.granateOscuro,
                      Color(0xFF2A0308),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.4),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              _filaTubos(
                notas: notasFila6,
                diametro: diametro,
                separacion: separacion,
                colorMaderaClaro: AppColors.granate,
                colorMaderaOscuro: const Color(0xFF2A0308),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filaTubos({
    required List<ZamponaNota> notas,
    required double diametro,
    required double separacion,
    required Color colorMaderaClaro,
    required Color colorMaderaOscuro,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final nota in notas)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: separacion / 2),
            child: _tubo(
              nota: nota,
              diametro: diametro,
              colorClaro: colorMaderaClaro,
              colorOscuro: colorMaderaOscuro,
            ),
          ),
      ],
    );
  }

  Widget _tubo({
    required ZamponaNota nota,
    required double diametro,
    required Color colorClaro,
    required Color colorOscuro,
  }) {
    final sonando = _sonando.contains(nota.id);
    final modoPulsado = _service.modo == ZamponaModo.pulsado;

    Widget contenido = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
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
                  colorOscuro,
                  colorClaro,
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
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          if (sonando)
            BoxShadow(
              color: AppColors.dorado.withOpacity(0.7),
              blurRadius: 18,
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
                : AppColors.dorado.withOpacity(0.55),
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
    );

    final gesture = modoPulsado
        ? GestureDetector(
            onTapDown: (_) => _tocarDown(nota),
            onTapUp: (_) => _soltar(nota),
            onTapCancel: () => _soltar(nota),
            behavior: HitTestBehavior.opaque,
            child: contenido,
          )
        : GestureDetector(
            onTapDown: (_) {
              _tocarDown(nota);
              _apagarBrillo(nota);
            },
            behavior: HitTestBehavior.opaque,
            child: contenido,
          );

    return AnimatedScale(
      scale: sonando ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: gesture,
    );
  }
}