// lib/features/eventos/screens/seleccionar_ubicacion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_button.dart';

class SeleccionarUbicacionScreen extends StatefulWidget {
  final double? latInicial;
  final double? lngInicial;

  const SeleccionarUbicacionScreen({
    super.key,
    this.latInicial,
    this.lngInicial,
  });

  @override
  State<SeleccionarUbicacionScreen> createState() =>
      _SeleccionarUbicacionScreenState();
}

class _SeleccionarUbicacionScreenState
    extends State<SeleccionarUbicacionScreen> {
  late LatLng _puntoSeleccionado;
  final MapController _mapController = MapController();
  bool _mostrarAyuda = true;

  @override
  void initState() {
    super.initState();
    _puntoSeleccionado = LatLng(
      widget.latInicial ?? -15.4994,
      widget.lngInicial ?? -70.1333,
    );
  }

  void _confirmar() {
    AppMotion.hapticHeavy();
    Navigator.pop(context, _puntoSeleccionado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: Stack(
        children: [
          // Mapa
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _puntoSeleccionado,
                initialZoom: 15.0,
                onTap: (_, point) {
                  AppMotion.hapticSelection();
                  setState(() {
                    _puntoSeleccionado = point;
                    _mostrarAyuda = false;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.allinkawsay.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _puntoSeleccionado,
                      width: 60,
                      height: 60,
                      child: const _MarcadorAnimado(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.md, Sp.sm, Sp.md, 0),
                child: Row(
                  children: [
                    _BotonCircular(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.md,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.fondoOscuro.withOpacity(0.9),
                        borderRadius: Rad.rPill,
                        border: Border.all(
                          color: AppColors.dorado.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.dorado,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Toca el mapa',
                            style: AppText.captionXs.copyWith(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Ayuda flotante
          if (_mostrarAyuda)
            Positioned(
              top: 90,
              left: Sp.lg,
              right: Sp.lg,
              child: AppCard(
                glass: true,
                padding: const EdgeInsets.all(Sp.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Sp.sm),
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.2),
                        borderRadius: Rad.rSm,
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: AppColors.dorado,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: Sp.md),
                    Expanded(
                      child: Text(
                        'Toca el mapa para mover el marcador al lugar exacto.',
                        style: AppText.captionXs.copyWith(
                          color: AppColors.onSurface(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Panel inferior de confirmación
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.fondoOscuro.withOpacity(0.0),
                    AppColors.fondoOscuro.withOpacity(0.85),
                    AppColors.fondoOscuro,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: AppCard(
                  glass: true,
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.dorado.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.dorado.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.dorado,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: Sp.sm),
                          Text(
                            'COORDENADAS',
                            style: AppText.label.copyWith(
                              color: AppColors.dorado,
                              letterSpacing: 1.5,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              AppMotion.hapticSelection();
                              _mapController.move(_puntoSeleccionado, 16);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.dorado.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.my_location_rounded,
                                color: AppColors.dorado,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.md),
                      Row(
                        children: [
                          Expanded(
                            child: _CoordChip(
                              label: 'LAT',
                              valor: _puntoSeleccionado.latitude
                                  .toStringAsFixed(5),
                            ),
                          ),
                          const SizedBox(width: Sp.sm),
                          Expanded(
                            child: _CoordChip(
                              label: 'LNG',
                              valor: _puntoSeleccionado.longitude
                                  .toStringAsFixed(5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.lg),
                      AppButton(
                        label: 'CONFIRMAR UBICACIÓN',
                        icon: Icons.check_circle_rounded,
                        fullWidth: true,
                        onPressed: _confirmar,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MARCADOR ANIMADO
// ═══════════════════════════════════════════════════════════

class _MarcadorAnimado extends StatefulWidget {
  const _MarcadorAnimado();

  @override
  State<_MarcadorAnimado> createState() => _MarcadorAnimadoState();
}

class _MarcadorAnimadoState extends State<_MarcadorAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Halo pulsante
            Container(
              width: 60 * (0.6 + 0.4 * t),
              height: 60 * (0.6 + 0.4 * t),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dorado.withOpacity(0.25 * (1 - t)),
              ),
            ),
            // Pin
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradienteGranate,
                border: Border.all(
                  color: AppColors.dorado.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.granate.withOpacity(0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.dorado,
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTÓN CIRCULAR
// ═══════════════════════════════════════════════════════════

class _BotonCircular extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BotonCircular({required this.icon, required this.onTap});

  @override
  State<_BotonCircular> createState() => _BotonCircularState();
}

class _BotonCircularState extends State<_BotonCircular> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticSelection();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.bouncy,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.fondoOscuro.withOpacity(0.9),
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.3),
            ),
          ),
          child: Icon(widget.icon, color: AppColors.dorado, size: 18),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CHIP DE COORDENADA
// ═══════════════════════════════════════════════════════════

class _CoordChip extends StatelessWidget {
  final String label;
  final String valor;

  const _CoordChip({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.md,
        vertical: Sp.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.dorado.withOpacity(0.08),
        borderRadius: Rad.rMd,
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.captionXs.copyWith(
              color: AppColors.dorado.withOpacity(0.6),
              letterSpacing: 1.5,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: AppText.mono.copyWith(
              color: AppColors.dorado,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}