// lib/screens/seleccionar_ubicacion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../design/design.dart';
import '../theme/colors.dart';

class SeleccionarUbicacionScreen extends StatefulWidget {
  final double? latInicial;
  final double? lngInicial;

  const SeleccionarUbicacionScreen({
    super.key,
    this.latInicial,
    this.lngInicial,
  });

  @override
  State<SeleccionarUbicacionScreen> createState() => _SeleccionarUbicacionScreenState();
}

class _SeleccionarUbicacionScreenState extends State<SeleccionarUbicacionScreen> {
  late LatLng _puntoSeleccionado;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Si viene con coordenadas previas (edición), las usamos. Si no, apuntamos a Juliaca, Perú.
    _puntoSeleccionado = LatLng(
      widget.latInicial ?? -15.4994, 
      widget.lngInicial ?? -70.1333
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.dorado),
            onPressed: () {
              // Devuelve las coordenadas seleccionadas al formulario
              Navigator.pop(context, _puntoSeleccionado);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _puntoSeleccionado,
              initialZoom: 14.0,
              onTap: (tapPosition, point) {
                // Al tocar el mapa, movemos el marcador
                setState(() => _puntoSeleccionado = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.allinkawsay.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _puntoSeleccionado,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: AppColors.granate, size: 40),
                  ),
                ],
              ),
            ],
          ),
          
          // Instrucción flotante
          Positioned(
            top: 16, left: 16, right: 16,
            child: AppCard(
              padding: const EdgeInsets.all(Sp.md),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: AppColors.granate),
                  const SizedBox(width: Sp.sm),
                  Expanded(
                    child: Text(
                      'Toca el mapa para mover el marcador al lugar exacto.',
                      style: AppType.caption.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel inferior con coordenadas
          Positioned(
            bottom: 24, left: 24, right: 24,
            child: AppCard(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Coordenadas seleccionadas:', style: AppType.labelXs.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: Sp.xs),
                  Text(
                    'Lat: ${_puntoSeleccionado.latitude.toStringAsFixed(5)}  |  Lng: ${_puntoSeleccionado.longitude.toStringAsFixed(5)}',
                    style: AppType.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.granate),
                  ),
                  const SizedBox(height: Sp.md),
                  AppButton(
                    label: 'CONFIRMAR UBICACIÓN',
                    fullWidth: true,
                    onPressed: () => Navigator.pop(context, _puntoSeleccionado),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}