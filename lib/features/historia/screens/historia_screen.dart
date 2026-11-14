// lib/features/historia/screens/historia_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_loading_siku.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/historia.dart';
import '../../../services/historia_service.dart';
import '../../../services/usuario_service.dart';
import 'editar_historia_screen.dart';

class HistoriaScreen extends StatefulWidget {
  const HistoriaScreen({super.key});

  @override
  State<HistoriaScreen> createState() => _HistoriaScreenState();
}

class _HistoriaScreenState extends State<HistoriaScreen> {
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    UsuarioService().soyAdmin().then((a) {
      if (mounted) setState(() => _esAdmin = a);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: StreamBuilder<Historia>(
        stream: HistoriaService().stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: AllinLoadingSiku(mensaje: 'Cargando memoria ancestral...'),
            );
          }

          final h = snap.data;
          final tieneContenido = h != null && h.contenido.trim().isNotEmpty;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── HERO HEADER APP BAR ───
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.fondoOscuro,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: Rad.rRound,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant(context).withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.dorado.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.dorado,
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (_esAdmin)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: Rad.rRound,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant(context).withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.dorado.withOpacity(0.3),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: AppColors.dorado,
                                size: 20,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditarHistoriaScreen(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Nuestra Historia',
                    style: AppText.h3.copyWith(
                      color: AppColors.dorado,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.granateProfundo,
                              AppColors.granateOscuro,
                              AppColors.fondoOscuro,
                            ],
                          ),
                        ),
                      ),
                      // Glow radial
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.dorado.withOpacity(0.18),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Emblema Central
                      Align(
                        alignment: const Alignment(0, -0.2),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.dorado.withOpacity(0.3),
                                AppColors.granateOscuro,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dorado.withOpacity(0.25),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: AppColors.dorado,
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── BODY ───
              if (!tieneContenido)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Sp.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_edu_rounded,
                            size: 64,
                            color: AppColors.dorado.withOpacity(0.5),
                          ),
                          const SizedBox(height: Sp.md),
                          Text(
                            'Historia vacía',
                            style: AppText.h3.copyWith(color: AppColors.dorado),
                          ),
                          const SizedBox(height: Sp.xs),
                          Text(
                            'El administrador aún no ha escrito la historia de la hermandad.',
                            textAlign: TextAlign.center,
                            style: AppText.caption.copyWith(
                              color: AppColors.onSurfaceVariant(context),
                            ),
                          ),
                          if (_esAdmin) ...[
                            const SizedBox(height: Sp.lg),
                            AllinButton(
                              label: 'Escribir historia',
                              variant: AllinButtonVariant.gold,
                              icono: Icons.edit_note_rounded,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditarHistoriaScreen(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Sp.md),

                        // Subtítulo con identidad
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dorado.withOpacity(0.12),
                              borderRadius: Rad.rRound,
                              border: Border.all(
                                color: AppColors.dorado.withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              'C.I.A.C. ALLIN KAWSAY • JULIACA, PUNO',
                              style: AppText.caption.copyWith(
                                color: AppColors.dorado,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: Sp.lg),

                        // Timeline / Capítulos generados a partir del contenido
                        ..._buildTimelineChapters(context, h.contenido),

                        // Footer de edición
                        if (h.actualizadoPor.isNotEmpty) ...[
                          const SizedBox(height: Sp.xl),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant(context).withOpacity(0.3),
                                borderRadius: Rad.rMd,
                                border: Border.all(
                                  color: AppColors.border(context).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Última actualización por: ${h.actualizadoPor}',
                                style: AppText.caption.copyWith(
                                  color: AppColors.onSurfaceVariant(context),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTimelineChapters(BuildContext context, String rawText) {
    // Dividir en párrafos no vacíos
    final parrafos = rawText
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parrafos.isEmpty) {
      parrafos.add(rawText.trim());
    }

    return List.generate(parrafos.length, (index) {
      final parrafo = parrafos[index];
      final numeroCapitulo = (index + 1).toString().padLeft(2, '0');

      return Padding(
        padding: const EdgeInsets.only(bottom: Sp.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de Timeline vertical
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.dorado, AppColors.granateProfundo],
                      ),
                      border: Border.all(
                        color: AppColors.dorado,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dorado.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        numeroCapitulo,
                        style: const TextStyle(
                          color: AppColors.fondoOscuro,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.dorado.withOpacity(0.6),
                            AppColors.dorado.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: Sp.md),

              // Tarjeta de contenido editorial
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.dorado.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'MEMORIA SIKURI',
                            style: AppText.caption.copyWith(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.sm),
                      Text(
                        parrafo,
                        style: AppText.body.copyWith(
                          fontSize: 15,
                          height: 1.75,
                          color: AppColors.onSurface(context).withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
