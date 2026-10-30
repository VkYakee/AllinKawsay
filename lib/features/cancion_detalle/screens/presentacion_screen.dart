// lib/features/cancion_detalle/screens/presentacion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../widgets/visor_numerofonia.dart';

class PresentacionScreen extends StatefulWidget {
  final Cancion cancion;
  const PresentacionScreen({super.key, required this.cancion});

  @override
  State<PresentacionScreen> createState() => _PresentacionScreenState();
}

class _PresentacionScreenState extends State<PresentacionScreen> {
  final _transformController = TransformationController();
  bool _zoomActivo = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _transformController.addListener(() {
      final z = _transformController.value.getMaxScaleOnAxis();
      if ((z > 1.05) != _zoomActivo) setState(() => _zoomActivo = z > 1.05);
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    return Scaffold(
      backgroundColor: AppColors.negroPuro,
      body: Theme(
        data: Theme.of(context).copyWith(brightness: Brightness.dark),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.8,
                maxScale: 4.0,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(Sp.xl, 80, Sp.xl, Sp.xxl),
                  child: Column(
                    children: [
                      Text(
                        c.titulo.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppText.h1.copyWith(
                          color: AppColors.dorado,
                          fontSize: 32,
                          letterSpacing: 4,
                        ),
                      ),
                      if (c.autor.isNotEmpty) ...[
                        const SizedBox(height: Sp.sm),
                        Text(
                          c.autor,
                          textAlign: TextAlign.center,
                          style: AppText.subtitle.copyWith(
                            color: AppColors.dorado.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: Sp.xxl),
                      if (c.tieneNumerofonia)
                        Container(
                          padding: const EdgeInsets.all(Sp.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: Rad.rMd,
                          ),
                          child: VisorNumerofonia(
                            estrofas: c.estrofas,
                            escala: 1.3,
                          ),
                        )
                      else if (c.tieneNumerofoniaString)
                        Container(
                          padding: const EdgeInsets.all(Sp.lg),
                          decoration: BoxDecoration(
                            color: AppColors.negroPuro,
                            borderRadius: Rad.rMd,
                            border: Border.all(color: AppColors.dorado),
                          ),
                          child: Text(
                            c.numerofonia,
                            style: AppText.mono.copyWith(
                              color: AppColors.dorado,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      if (c.tieneLetra) ...[
                        const SizedBox(height: Sp.xxl),
                        Text(
                          '— LETRA —',
                          style: AppText.captionXs.copyWith(
                            color: AppColors.dorado,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: Sp.md),
                        Container(
                          padding: const EdgeInsets.all(Sp.xl),
                          decoration: BoxDecoration(
                            color: AppColors.negroPuro,
                            borderRadius: Rad.rLg,
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            c.letra,
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(
                              color: AppColors.doradoClaro,
                              fontSize: 20,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: Sp.xxl),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sp.sm,
                    vertical: Sp.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.dorado,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: Sp.sm),
                      Text(
                        'MODO PRESENTACIÓN',
                        style: AppText.label.copyWith(
                          color: AppColors.dorado,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      if (_zoomActivo)
                        IconButton(
                          icon: const Icon(
                            Icons.center_focus_strong,
                            color: AppColors.dorado,
                          ),
                          onPressed: () =>
                              _transformController.value = Matrix4.identity(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}