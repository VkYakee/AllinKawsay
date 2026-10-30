// lib/features/cancionero/controllers/cancionero_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../models/cancion.dart';
import '../../../models/usuario.dart';
import '../../../services/cancion_service.dart';
import '../../../services/player_service.dart';
import '../../../services/reproduccion_service.dart';
import '../../../services/usuario_service.dart';

/// Controlador único del Cancionero.
///
/// Antes: 3 StreamBuilder anidados + 1 ValueListenableBuilder por fila.
/// Con 50 canciones eso eran 150 suscripciones activas y 50 rebuilds
/// por frame de scroll.
///
/// Ahora: una sola suscripción por servicio, un solo ChangeNotifier
/// para la pantalla. El widget escucha al controller. Cero builders
/// anidados en el árbol.
class CancioneroController extends ChangeNotifier {
  final _cancionService = CancionService();
  final _usuarioService = UsuarioService();
  final _player = PlayerService();

  StreamSubscription<List<Cancion>>? _cancionesSub;
  StreamSubscription<Usuario?>? _usuarioSub;

  List<Cancion> _cancionesRaw = [];
  List<String> _favoritos = [];
  bool _esAdmin = false;
  bool _loading = true;
  String _query = '';
  EstadoPlayer _estado = const EstadoPlayer();

  List<Cancion> get canciones => _filtradas;
  List<String> get favoritos => _favoritos;
  bool get esAdmin => _esAdmin;
  bool get loading => _loading;
  EstadoPlayer get estado => _estado;
  String get query => _query;

  List<Cancion> get _filtradas {
    if (_query.isEmpty) return _cancionesRaw;
    final q = _query.toLowerCase();
    return _cancionesRaw
        .where((c) =>
            c.titulo.toLowerCase().contains(q) ||
            c.autor.toLowerCase().contains(q) ||
            c.ritmo.toLowerCase().contains(q))
        .toList();
  }

  CancioneroController() {
    _subscribe();
  }

  void _subscribe() {
    _cancionesSub = _cancionService.listar().listen(
      (list) {
        _cancionesRaw = list;
        if (_loading) _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );

    _usuarioSub = _usuarioService.miUsuario().listen((u) {
      _favoritos = u?.favoritos ?? [];
      _esAdmin = u?.esAdmin ?? false;
      notifyListeners();
    });

    _player.estado.addListener(_onPlayerChanged);
    _estado = _player.estado.value;
  }

  void _onPlayerChanged() {
    _estado = _player.estado.value;
    notifyListeners();
  }

  void setQuery(String q) {
    if (_query == q) return;
    _query = q;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  Future<void> togglePlay(Cancion c) async {
    final yaSonaba = _player.sonando(c.id);
    await _player.toggle(c);
    if (_player.sonando(c.id) && !yaSonaba) {
      await ReproduccionService.contarUnaVez(c.id);
    }
  }

  Future<void> toggleFavorito(String cancionId) async {
    await _usuarioService.toggleFavorito(cancionId);
  }

  @override
  void dispose() {
    _cancionesSub?.cancel();
    _usuarioSub?.cancel();
    _player.estado.removeListener(_onPlayerChanged);
    super.dispose();
  }
}