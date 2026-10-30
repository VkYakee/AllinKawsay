// lib/features/ensayo/screens/modo_ensayo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/zampona_canvas.dart';

import '../../../models/cancion.dart';
import '../../../widgets/visor_numerofonia.dart';
import '../../../widgets/zampona/tool_scaffold.dart';

import '../controllers/ensayo_controller.dart';
import '../widgets/controles_ensayo.dart';

class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

class _ModoEnsayoScreenState extends State<ModoEnsayoScreen> {
  late final EnsayoController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = EnsayoController(cancion: widget.cancion);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.cargando) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            ),
          );
        }

        return ToolScaffold(
          titulo: widget.cancion.titulo,
          subtitulo: 'Modo Ensayo',
          onCerrar: () async {
            await _controller.pause();
            if (mounted) Navigator.pop(context);
          },
          body: Column(
            children: [
              Expanded(flex: 3, child: _buildTabla()),
              _buildKaraoke(),
              Expanded(flex: 5, child: _buildZamponaYControles()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabla() {
    final estrofas = _controller.estrofasAMostrar;
    return Container(
      margin: const EdgeInsets.all(Sp.sm),
      padding: const EdgeInsets.all(Sp.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF14080A),
        borderRadius: Rad.rMd,
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.granate.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: AppMotion.normal,
          switchInCurve: AppMotion.easeOutQuart,
          child: estrofas.isEmpty
              ? Text(
                  '♪ Esperando estrofa...',
                  key: const ValueKey('empty'),
                  style: AppText.caption.copyWith(
                    color: AppColors.dorado.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                )
              : FittedBox(
                  key: ValueKey(_controller.bloqueActual),
                  fit: BoxFit.scaleDown,
                  child: VisorNumerofonia(
                    estrofas: estrofas,
                    escala: 1.2,
                    fondoOscuro: true,
                    celdaActiva: _controller.celdaActiva,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildKaraoke() {
    final texto = _controller.textoKaraoke;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.dorado.withOpacity(0.08),
          ),
          bottom: BorderSide(
            color: AppColors.dorado.withOpacity(0.08),
          ),
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            texto.isEmpty ? '♪ (Esperando letra...) ♪' : texto,
            key: ValueKey(texto),
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              color: texto.isEmpty
                  ? AppColors.dorado.withOpacity(0.3)
                  : AppColors.dorado,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildZamponaYControles() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: ZamponaCanvas(
            brillando: _controller.notaSonando != null
                ? {_controller.notaSonando!}
                : {},
            mostrarNumeros: true,
            compacto: true,
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(Sp.sm),
            child: ControlesEnsayo(
              reproduciendo: _controller.reproduciendo,
              velocidad: _controller.velocidad,
              bucle: _controller.bucle,
              posMs: _controller.pos.inMilliseconds.toDouble(),
              totalMs:
                  (_controller.duracion?.inMilliseconds ?? 1).toDouble(),
              onPlay: _controller.play,
              onPause: _controller.pause,
              onStop: _controller.stop,
              onToggleBucle: _controller.toggleBucle,
              onVelocidad: _controller.setVelocidad,
              onSeek: _controller.seek,
            ),
          ),
        ),
      ],
    );
  }
}