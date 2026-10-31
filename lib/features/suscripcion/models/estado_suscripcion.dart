// lib/features/suscripcion/models/estado_suscripcion.dart

/// Estado de monetización de un usuario. Es el resultado de evaluar
/// su documento en Firestore contra la hora actual.
enum EstadoTrial {
  /// Aún dentro de los días de prueba.
  trialActivo,

  /// Trial terminado y sin plan pagado. Ve el modo gratuito limitado.
  trialExpirado,

  /// Tiene Plan Sikurito mensual activo.
  suscriptor,

  /// Tiene Plan VIP (pago único) activo.
  vip,

  /// Es miembro oficial, admin o dev. No le aplica trial ni paywall.
  privilegiado,

  /// Todavía no se inicializó el trial (primer login).
  sinTrial,

  /// Cargando o error de red.
  cargando,
}

class EstadoSuscripcion {
  final EstadoTrial estado;
  final int diasRestantes;
  final DateTime? trialInicio;
  final DateTime? trialFin;
  final DateTime? suscripcionHasta;
  final String plan;
  final bool activa;
  final String rol;

  const EstadoSuscripcion({
    required this.estado,
    this.diasRestantes = 0,
    this.trialInicio,
    this.trialFin,
    this.suscripcionHasta,
    this.plan = 'ninguno',
    this.activa = false,
    this.rol = 'publico',
  });

  // ─── Atajos semánticos ─────────────────────────────────────

  bool get esSuscriptor => estado == EstadoTrial.suscriptor;
  bool get esVip => estado == EstadoTrial.vip;
  bool get enTrial => estado == EstadoTrial.trialActivo;
  bool get trialExpirado => estado == EstadoTrial.trialExpirado;
  bool get sinTrial => estado == EstadoTrial.sinTrial;
  bool get esPrivilegiado => estado == EstadoTrial.privilegiado;
  bool get cargando => estado == EstadoTrial.cargando;

  /// Tiene acceso completo a la app (todas las canciones, ensayo, etc).
  bool get tieneAccesoCompleto =>
      enTrial || esSuscriptor || esVip || esPrivilegiado;

  /// Está en modo gratuito limitado (solo 15 canciones, sin ensayo).
  bool get modoLimitado => trialExpirado;

  /// Le quedan pocos días de trial (banner de urgencia).
  bool get porVencer => enTrial && diasRestantes <= 1;

  /// ¿Puede usar la función de ensayo?
  bool get puedeUsarEnsayo => esSuscriptor || esVip || esPrivilegiado;

  /// ¿Cuántas canciones puede reproducir/ver completas?
  int get limiteCanciones {
    if (esSuscriptor || esVip || esPrivilegiado) return -1; // ilimitado
    if (enTrial) return 8; // PlanSuscripcion.cancionesTrial
    return 15; // PlanSuscripcion.cancionesPostTrial
  }

  /// ¿Puede descargar canciones para offline?
  bool get puedeDescargar => esSuscriptor || esVip || esPrivilegiado;

  /// ¿Puede escribir comentarios?
  bool get puedeComentar => esSuscriptor || esVip || esPrivilegiado;

  /// ¿Debe mostrarse el watermark con el email del usuario?
  bool get mostrarWatermark =>
      enTrial || trialExpirado || (rol == 'publico' && !esVip);

  /// ¿Debe bloquear capturas de pantalla (FLAG_SECURE)?
  bool get bloquearCapturas => !esPrivilegiado;

  /// ¿Debe ver la pantalla de paywall bloqueante?
  bool get debeBloquearApp => trialExpirado;

  // ─── Constructores estáticos ───────────────────────────────

  static const EstadoSuscripcion inicial = EstadoSuscripcion(
    estado: EstadoTrial.sinTrial,
  );

  static const EstadoSuscripcion cargando0 = EstadoSuscripcion(
    estado: EstadoTrial.cargando,
  );

  static const EstadoSuscripcion bloqueado = EstadoSuscripcion(
    estado: EstadoTrial.trialExpirado,
  );

  // ─── Copy con ──────────────────────────────────────────────

  EstadoSuscripcion copyWith({
    EstadoTrial? estado,
    int? diasRestantes,
    DateTime? trialInicio,
    DateTime? trialFin,
    DateTime? suscripcionHasta,
    String? plan,
    bool? activa,
    String? rol,
  }) {
    return EstadoSuscripcion(
      estado: estado ?? this.estado,
      diasRestantes: diasRestantes ?? this.diasRestantes,
      trialInicio: trialInicio ?? this.trialInicio,
      trialFin: trialFin ?? this.trialFin,
      suscripcionHasta: suscripcionHasta ?? this.suscripcionHasta,
      plan: plan ?? this.plan,
      activa: activa ?? this.activa,
      rol: rol ?? this.rol,
    );
  }

  @override
  String toString() =>
      'EstadoSuscripcion(estado: $estado, plan: $plan, rol: $rol, diasRestantes: $diasRestantes)';
}