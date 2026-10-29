// lib/screens/evento_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- AGREGADO
import '../design/design.dart';
import '../models/evento.dart';
import '../services/weather_service.dart';
import '../theme/colors.dart';

class EventoDetalleScreen extends StatelessWidget {
  final Evento evento;
  const EventoDetalleScreen({super.key, required this.evento});

  Future<void> _abrirRuta() async {
    if (evento.lat == null || evento.lng == null) return;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${evento.lat},${evento.lng}';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error al abrir mapa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tieneUbicacion = evento.lat != null && evento.lng != null;

    return AppScaffold(
      title: 'Detalle del Evento',
      body: ListView(
        padding: const EdgeInsets.all(Sp.lg),
        children: [
          AppCard(
            color: AppColors.granate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento.titulo, style: AppType.h2.copyWith(color: AppColors.dorado)),
                const SizedBox(height: Sp.sm),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.dorado, size: 16),
                    const SizedBox(width: 4),
                    Text('${evento.fecha.day}/${evento.fecha.month}/${evento.fecha.year}', style: AppType.subtitle.copyWith(color: AppColors.dorado.withOpacity(0.8))),
                    const SizedBox(width: Sp.md),
                    const Icon(Icons.access_time, color: AppColors.dorado, size: 16),
                    const SizedBox(width: 4),
                    Text('${evento.fecha.hour.toString().padLeft(2, '0')}:${evento.fecha.minute.toString().padLeft(2, '0')}', style: AppType.subtitle.copyWith(color: AppColors.dorado.withOpacity(0.8))),
                  ],
                ),
                if (evento.descripcion.isNotEmpty) ...[
                  const SizedBox(height: Sp.md),
                  Text(evento.descripcion, style: AppType.bodySm.copyWith(color: Colors.white)),
                ],
              ],
            ),
          ),
          const SizedBox(height: Sp.lg),

          if (tieneUbicacion) ...[
            const SeccionHeader(title: 'Ubicación y Clima', icon: Icons.map),
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: Rad.rLg,
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(evento.lat!, evento.lng!),
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.allinkawsay.app'),
                          MarkerLayer(markers: [
                            Marker(point: LatLng(evento.lat!, evento.lng!), child: const Icon(Icons.location_on, color: AppColors.granate, size: 40)),
                          ]),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Sp.md),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Lugar', style: AppType.labelXs.copyWith(color: onSurface.withOpacity(0.5))),
                                    Text(evento.lugar, style: AppType.subtitle.copyWith(color: onSurface)),
                                  ],
                                ),
                              ),
                              FutureBuilder<WeatherInfo?>(
                                future: WeatherService.obtenerClima(evento.lat!, evento.lng!, evento.fecha),
                                builder: (context, snap) {
                                  if (!snap.hasData) return const SizedBox.shrink();
                                  final w = snap.data!;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
                                    decoration: BoxDecoration(color: AppColors.dorado.withOpacity(0.1), borderRadius: Rad.rMd, border: Border.all(color: AppColors.dorado.withOpacity(0.3))),
                                    child: Row(
                                      children: [
                                        Text(w.icono, style: const TextStyle(fontSize: 24)),
                                        const SizedBox(width: Sp.sm),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${w.temp}°C', style: AppType.subtitle.copyWith(color: onSurface)),
                                            Text(w.descripcion, style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.6))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: Sp.md),
                          // BOTÓN "CÓMO LLEGAR"
                          AppButton(
                            label: 'CÓMO LLEGAR (GOOGLE MAPS)',
                            icon: Icons.directions,
                            variant: AppButtonVariant.secondary,
                            fullWidth: true,
                            onPressed: _abrirRuta,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}