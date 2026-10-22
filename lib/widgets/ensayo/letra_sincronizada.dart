// lib/widgets/ensayo/letra_sincronizada.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class LetraSincronizada extends StatefulWidget {
  final String letra;
  final double progreso; // 0.0 a 1.0

  const LetraSincronizada({super.key, required this.letra, required this.progreso});

  @override
  State<LetraSincronizada> createState() => _LetraSincronizadaState();
}

class _LetraSincronizadaState extends State<LetraSincronizada> {
  late List<String> _lineas;
  int _lineaActual = 0;

  @override
  void initState() {
    super.initState();
    _lineas = widget.letra.split('\n').where((l) => l.trim().isNotEmpty).toList();
  }

  @override
  void didUpdateWidget(covariant LetraSincronizada oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_lineas.isEmpty) return;
    
    // Calcula qué línea mostrar basado en el porcentaje del bloque
    final index = (widget.progreso * _lineas.length).floor().clamp(0, _lineas.length - 1);
    if (index != _lineaActual) {
      setState(() => _lineaActual = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lineas.isEmpty) {
      return Center(
        child: Text('♪ Sin letra ♪', style: AppType.caption.copyWith(color: Colors.white54)),
      );
    }
    
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: Text(
          _lineas[_lineaActual],
          key: ValueKey(_lineaActual),
          textAlign: TextAlign.center,
          style: AppType.body.copyWith(color: AppColors.dorado, fontSize: 20, height: 1.5, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}