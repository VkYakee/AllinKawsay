// lib/widgets/zampona/tool_scaffold.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class ToolScaffold extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final VoidCallback onCerrar;
  final Widget body;
  final Widget? bottomBar;

  const ToolScaffold({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.onCerrar,
    required this.body,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.sm, Sp.sm, Sp.sm, Sp.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.dorado),
                    onPressed: onCerrar,
                  ),
                  const SizedBox(width: Sp.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: AppType.subtitle.copyWith(color: AppColors.dorado)),
                      Text(subtitulo, style: AppType.captionXs.copyWith(color: AppColors.dorado.withOpacity(0.5))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: body),
            if (bottomBar != null)
              Padding(
                padding: const EdgeInsets.all(Sp.sm),
                child: bottomBar!,
              ),
          ],
        ),
      ),
    );
  }
}