// lib/core/widgets/animated_list_item.dart
import 'package:flutter/material.dart';
import '../design/motion.dart';

/// Entrada escalonada para los hijos de una lista.
///
/// Uso:
///   SliverList.builder(
///     itemBuilder: (context, i) => AnimatedListItem(
///       index: i,
///       child: TarjetaCancion(...),
///     ),
///   )
///
/// Cada item entra con fade + slide, con un delay proporcional a su índice
/// (capado a 600ms para que el scroll rápido no acumule delays).
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration interval;
  final Offset slideFrom;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = Duration.zero,
    this.interval = const Duration(milliseconds: 45),
    this.slideFrom = const Offset(0, 0.08),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: AppMotion.easeOutQuart,
    );

    _slide = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: AppMotion.easeOutQuart,
      ),
    );

    final delayMs = widget.baseDelay.inMilliseconds +
        widget.interval.inMilliseconds * widget.index;
    final delay = delayMs.clamp(0, 600);

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}