// lib/screens/numerofonia_fullscreen_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/design.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

class NumerofoniaFullscreenScreen extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;
  const NumerofoniaFullscreenScreen({super.key, required this.estrofas});

  @override
  State<NumerofoniaFullscreenScreen> createState() => _NumerofoniaFullscreenScreenState();
}

class _NumerofoniaFullscreenScreenState extends State<NumerofoniaFullscreenScreen> {
  final TransformationController _controller = TransformationController();
  bool _horizontal = true;

  @override
  void initState() {
    super.initState();
    _aplicarOrientacion();
  }

  void _aplicarOrientacion() {
    SystemChrome.setPreferredOrientations(_horizontal
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.dispose();
    super.dispose();
  }

  void _dobleTap() {
    _controller.value = _controller.value.getMaxScaleOnAxis() > 1.1 ? Matrix4.identity() : (Matrix4.identity()..scale(2.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Theme(
        data: Theme.of(context).copyWith(brightness: Brightness.dark),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: _dobleTap,
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 0.5, maxScale: 5.0,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(Sp.xxl, 60, Sp.xxl, Sp.xxl),
                      child: VisorNumerofonia(estrofas: widget.estrofas, escala: 1.6),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: Sp.xs),
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.close, color: AppColors.dorado), onPressed: () => Navigator.pop(context)),
                      const Expanded(child: Text('NUMEROFONÍA', style: TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 16))),
                      IconButton(
                        icon: Icon(_horizontal ? Icons.screen_lock_landscape : Icons.screen_lock_portrait, color: AppColors.dorado),
                        onPressed: () => setState(() { _horizontal = !_horizontal; _aplicarOrientacion(); }),
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