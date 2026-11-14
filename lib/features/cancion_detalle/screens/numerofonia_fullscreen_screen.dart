// lib/features/cancion_detalle/screens/numerofonia_fullscreen_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/atril_numerofonia.dart';
import '../../../models/numerofonia.dart';

class NumerofoniaFullscreenScreen extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;
  const NumerofoniaFullscreenScreen({super.key, required this.estrofas});

  @override
  State<NumerofoniaFullscreenScreen> createState() =>
      _NumerofoniaFullscreenScreenState();
}

class _NumerofoniaFullscreenScreenState
    extends State<NumerofoniaFullscreenScreen> {
  bool _horizontal = true;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _aplicarOrientacion();
  }

  void _aplicarOrientacion() {
    SystemChrome.setPreferredOrientations(
      _horizontal
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _toggleOrientacion() {
    setState(() {
      _horizontal = !_horizontal;
      _aplicarOrientacion();
    });
  }

  void _aumentarFuente() {
    if (_fontSize < 28.0) {
      setState(() => _fontSize += 2.0);
    }
  }

  void _disminuirFuente() {
    if (_fontSize > 13.0) {
      setState(() => _fontSize -= 2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Área de lectura de partitura: Atril musical de lectura vertical fija
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.md, 60, Sp.md, Sp.md),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AtrilNumerofonia(
                    estrofas: widget.estrofas,
                    fontSize: _fontSize,
                    fondoOscuro: true,
                  ),
                ),
              ),
            ),
          ),

          // Barra superior de herramientas de atril
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.oroSolar,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Salir',
                    ),
                    const SizedBox(width: Sp.sm),
                    Text(
                      'ATRIL DE ESCENARIO',
                      style: AppText.caption.copyWith(
                        color: AppColors.oroSolar,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Controles de tamaño de nota
                    IconButton(
                      icon: const Icon(Icons.text_decrease, color: Colors.white70, size: 20),
                      onPressed: _disminuirFuente,
                      tooltip: 'Reducir tamaño',
                    ),
                    Text(
                      '${_fontSize.toInt()}',
                      style: const TextStyle(
                        color: AppColors.oroSolar,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.text_increase, color: Colors.white70, size: 20),
                      onPressed: _aumentarFuente,
                      tooltip: 'Aumentar tamaño',
                    ),
                    const SizedBox(width: Sp.xs),
                    // Rotación
                    IconButton(
                      icon: Icon(
                        _horizontal ? Icons.screen_lock_landscape : Icons.screen_lock_portrait,
                        color: AppColors.oroSolar,
                        size: 22,
                      ),
                      onPressed: _toggleOrientacion,
                      tooltip: 'Cambiar orientación',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
