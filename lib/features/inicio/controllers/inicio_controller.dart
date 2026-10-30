// lib/features/inicio/controllers/inicio_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../models/cancion.dart';
import '../../../models/evento.dart';
import '../../../models/historia.dart';
import '../../../models/recuerdo.dart';
import '../../../services/cancion_service.dart';
import '../../../services/evento_service.dart';
import '../../../services/historia_service.dart';
import '../../../services/recuerdo_service.dart';

/// Controlador único del Inicio.
///
/// Antes: cada sección (próximo evento, últimas canciones, último
/// recuerdo, historia) tenía su propio StreamBuilder independiente.
/// Eso son 4 suscripciones + 4 rebuilds por cambio, más los builders
/// internos de cada widget.
///
/// Ahora: 4 suscripciones únicas, un ChangeNotifier, un rebuild.
class InicioController extends ChangeNotifier {
  final _eventos = EventoService();
  final _canciones = CancionService();
  final _recuerdos = RecuerdoService();
  final _historia = HistoriaService();

  StreamSubscription<List<Evento>>? _eventosSub;
  StreamSubscription<List<Cancion>>? _cancionesSub;
  StreamSubscription<List<Recuerdo>>? _recuerdosSub;
  StreamSubscription<Historia>? _historiaSub;

  Evento? _proximoEvento;
  List<Cancion> _ultimasCanciones = [];
  Recuerdo? _ultimoRecuerdo;
  Historia? _historiaActual;
  bool _loading = true;
  bool _historiaCargada = false;

  Evento? get proximoEvento => _proximoEvento;
  List<Cancion> get ultimasCanciones => _ultimasCanciones;
  Recuerdo? get ultimoRecuerdo => _ultimoRecuerdo;
  Historia? get historiaActual => _historiaActual;
  bool get loading => _loading;

  InicioController() {
    _subscribe();
  }

  void _subscribe() {
    final ahora = DateTime.now();

    _eventosSub = _eventos.listar().listen(
      (list) {
        final futuros = list.where((e) => e.fecha.isAfter(ahora)).toList();
        _proximoEvento = futuros.isEmpty ? null : futuros.first;
        _maybeEndLoading();
        notifyListeners();
      },
      onError: (_) => _maybeEndLoading(),
    );

    _cancionesSub = _canciones.listar().listen(
      (list) {
        _ultimasCanciones = list.take(3).toList();
        _maybeEndLoading();
        notifyListeners();
      },
      onError: (_) => _maybeEndLoading(),
    );

    _recuerdosSub = _recuerdos.listar().listen(
      (list) {
        _ultimoRecuerdo = list.isEmpty ? null : list.first;
        _maybeEndLoading();
        notifyListeners();
      },
      onError: (_) => _maybeEndLoading(),
    );

    _historiaSub = _historia.stream().listen(
      (h) {
        _historiaActual = h.contenido.isEmpty ? null : h;
        _historiaCargada = true;
        _maybeEndLoading();
        notifyListeners();
      },
      onError: (_) {
        _historiaCargada = true;
        _maybeEndLoading();
      },
    );
  }

  void _maybeEndLoading() {
    if (!_loading) return;
    // Consideramos cargado cuando las 4 secciones respondieron al menos una vez.
    // El _historiaCargada es el último en llegar porque suele ser más lento.
    if (_historiaCargada &&
        _ultimasCanciones.isNotEmpty &&
        _ultimoRecuerdo != null) {
      _loading = false;
    } else if (_historiaCargada) {
      // Si historia ya cargó y los demás aún no, igual salimos del loading
      // (para no bloquear la UI cuando no hay canciones/recuerdos todavía).
      _loading = false;
    }
  }

  @override
  void dispose() {
    _eventosSub?.cancel();
    _cancionesSub?.cancel();
    _recuerdosSub?.cancel();
    _historiaSub?.cancel();
    super.dispose();
  }
}