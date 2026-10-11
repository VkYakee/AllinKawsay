import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/numerofonia.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

class NumerofoniaFullscreenScreen extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;

  const NumerofoniaFullscreenScreen({super.key, required this.estrofas});

  @override
  State<NumerofoniaFullscreenScreen> createState() =>
      _NumerofoniaFullscreenScreenState();
}

class _NumerofoniaFullscreenScreenState
    extends State<NumerofoniaFullscreenScreen> {
  final TransformationController _controller = TransformationController();
  bool _horizontal = true;

  @override
  void initState() {
    super.initState();
    _aplicarOrientacion();
  }

  void _aplicarOrientacion() {
    if (_horizontal) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.dispose();
    super.dispose();
  }

  void _dobleTap() {
    final escalaActual = _controller.value.getMaxScaleOnAxis();
    _controller.value = escalaActual > 1.1
        ? Matrix4.identity()
        : (Matrix4.identity()..scale(2.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Theme(
        // CLAVE: fuerza brillo oscuro para que el visor pinte claro
        data: Theme.of(context).copyWith(brightness: Brightness.dark),
        child: Stack(
          children: [
            // Partitura con zoom
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: _dobleTap,
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),
                      child: VisorNumerofonia(
                        estrofas: widget.estrofas,
                        escala: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Barra superior flotante
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.dorado),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'NUMEROFONÍA',
                        style: TextStyle(
                          color: AppColors.dorado,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _horizontal
                            ? Icons.screen_lock_landscape
                            : Icons.screen_lock_portrait,
                        color: AppColors.dorado,
                      ),
                      onPressed: () => setState(() {
                        _horizontal = !_horizontal;
                        _aplicarOrientacion();
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Hint inferior
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pellizcá para zoom • Doble tap para acercar',
                    style: TextStyle(color: AppColors.dorado, fontSize: 12),
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