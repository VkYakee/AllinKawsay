// lib/screens/agregar_evento_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../design/design.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../theme/colors.dart';
import 'seleccionar_ubicacion_screen.dart';

class AgregarEventoScreen extends StatefulWidget {
  final Evento? evento;
  const AgregarEventoScreen({super.key, this.evento});

  @override
  State<AgregarEventoScreen> createState() => _AgregarEventoScreenState();
}

class _AgregarEventoScreenState extends State<AgregarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _lugar = TextEditingController();

  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 19, minute: 0);
  bool _guardando = false;
  
  LatLng? _ubicacion; // <-- NUEVO: Guarda lat y lng

  bool get _esEdicion => widget.evento != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final e = widget.evento!;
      _titulo.text = e.titulo;
      _descripcion.text = e.descripcion;
      _lugar.text = e.lugar;
      _fecha = e.fecha;
      _hora = TimeOfDay(hour: e.fecha.hour, minute: e.fecha.minute);
      if (e.lat != null && e.lng != null) {
        _ubicacion = LatLng(e.lat!, e.lng!);
      }
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _lugar.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.granate),
        ),
        child: child!,
      ),
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora() async {
    final h = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.granate),
        ),
        child: child!,
      ),
    );
    if (h != null) setState(() => _hora = h);
  }

  Future<void> _abrirMapa() async {
    final res = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarUbicacionScreen(
          latInicial: _ubicacion?.latitude,
          lngInicial: _ubicacion?.longitude,
        ),
      ),
    );
    if (res != null && mounted) {
      setState(() => _ubicacion = res);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final fechaFinal = DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);
      final service = EventoService();

      if (_esEdicion) {
        await service.actualizar(widget.evento!.id, {
          'titulo': _titulo.text.trim(),
          'descripcion': _descripcion.text.trim(),
          'lugar': _lugar.text.trim(),
          'fecha': fechaFinal,
          'lat': _ubicacion?.latitude,
          'lng': _ubicacion?.longitude,
        });
      } else {
        await service.agregar(Evento(
          id: '',
          titulo: _titulo.text.trim(),
          descripcion: _descripcion.text.trim(),
          lugar: _lugar.text.trim(),
          fecha: fechaFinal,
          lat: _ubicacion?.latitude,
          lng: _ubicacion?.longitude,
          creadoPor: user.uid,
          creadorNombre: user.displayName ?? user.email ?? 'Anónimo',
        ));
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AppScaffold(
      title: _esEdicion ? 'Editar Evento' : 'Nuevo Evento',
      actions: [
        IconButton(icon: const Icon(Icons.check, color: AppColors.dorado), onPressed: _guardando ? null : _guardar),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Sp.lg),
          children: [
            AppCard(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                children: [
                  const SeccionHeader(title: 'Información', icon: Icons.info_outline, padding: EdgeInsets.zero),
                  const SizedBox(height: Sp.md),
                  AppInput(
                    controller: _titulo,
                    label: 'Título *',
                    prefixIcon: Icons.event,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: Sp.md),
                  AppInput(controller: _lugar, label: 'Lugar (Nombre)', prefixIcon: Icons.place_outlined),
                  const SizedBox(height: Sp.md),
                  AppInput(controller: _descripcion, label: 'Descripción', prefixIcon: Icons.notes, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: Sp.md),
            
            // SECCIÓN DEL MAPA
            AppCard(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SeccionHeader(title: 'Ubicación Exacta', icon: Icons.map, padding: EdgeInsets.zero),
                  const SizedBox(height: Sp.sm),
                  Text(
                    _ubicacion != null 
                      ? 'Ubicación seleccionada: ${_ubicacion!.latitude.toStringAsFixed(4)}, ${_ubicacion!.longitude.toStringAsFixed(4)}'
                      : 'Aún no has seleccionado un punto en el mapa.',
                    style: AppType.caption.copyWith(color: onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(height: Sp.md),
                  AppButton(
                    label: _ubicacion != null ? 'CAMBIAR UBICACIÓN EN MAPA' : 'SELECCIONAR EN MAPA',
                    icon: Icons.pin_drop,
                    variant: AppButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: _abrirMapa,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.md),

            AppCard(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SeccionHeader(title: 'Fecha y Hora', icon: Icons.calendar_today, padding: EdgeInsets.zero),
                  const SizedBox(height: Sp.md),
                  Row(
                    children: [
                      Expanded(child: _botonFecha(Icons.calendar_today, '${_fecha.day}/${_fecha.month}/${_fecha.year}', _elegirFecha)),
                      const SizedBox(width: Sp.sm),
                      Expanded(child: _botonFecha(Icons.access_time, _hora.format(context), _elegirHora)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.xl),
            AppButton(label: _esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR EVENTO', fullWidth: true, loading: _guardando, onPressed: _guardar),
            const SizedBox(height: Sp.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _botonFecha(IconData icono, String texto, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: Rad.rMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.granate.withOpacity(0.04),
          borderRadius: Rad.rMd,
          border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icono, color: AppColors.granate, size: 18),
            const SizedBox(width: Sp.sm),
            Expanded(child: Text(texto, style: AppType.subtitle)),
          ],
        ),
      ),
    );
  }
}