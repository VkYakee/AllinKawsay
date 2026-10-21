/// Tipos de bloque que puede tener un audio de sikuri.
enum TipoBloque {
  enganche,
  intro,
  diana,
  chacota,
  estrofa,
  bis,
  ligero,
}

/// Un bloque dentro del audio de la canción.
///
/// Divide el audio en secciones: enganches, estrofas, BIS, etc.
class BloqueAudio {
  /// Milisegundo donde arranca este bloque dentro del audio.
  final int inicioMs;

  /// Índice de la estrofa de la tabla a la que apunta.
  /// -1 = no apunta a ninguna (enganche, intro, diana, chacota).
  final int estrofaRef;

  /// Si durante este bloque se superpone la letra.
  final bool conLetra;

  /// Tipo de bloque (para UI y lógica de reproducción).
  final TipoBloque tipo;

  /// Multiplicador de velocidad del timing.
  /// 1.0 para todo menos "ligero", donde puede ser 1.15-1.30.
  final double velocidad;

  /// TIMING A: posiciones absolutas (en ms del audio) de cada toque
  /// grabado para este bloque. Cada elemento corresponde a una nota
  /// en el orden en que aparecen las notas de la estrofa.
  /// Si está vacío, el ensayo usa fallback (timings7/6 de la estrofa
  /// dividido por velocidad).
  final List<int> timingsMs;

  BloqueAudio({
    required this.inicioMs,
    this.estrofaRef = -1,
    this.conLetra = false,
    required this.tipo,
    this.velocidad = 1.0,
    List<int>? timingsMs,
  }) : timingsMs = timingsMs ?? <int>[];

  bool get tieneVisual => estrofaRef >= 0;

  /// ¿Tiene timing A grabado?
  bool get tieneTimingA => timingsMs.isNotEmpty;

  /// Texto legible para mostrar en UI.
  String get label {
    switch (tipo) {
      case TipoBloque.enganche:
        return 'Enganche';
      case TipoBloque.intro:
        return 'Intro';
      case TipoBloque.diana:
        return 'Diana';
      case TipoBloque.chacota:
        return 'Chacota';
      case TipoBloque.estrofa:
        return 'Estrofa ${estrofaRef + 1}'
            '${conLetra ? ' · con letra' : ''}';
      case TipoBloque.bis:
        return 'BIS Estrofa ${estrofaRef + 1}';
      case TipoBloque.ligero:
        return 'Ligero';
    }
  }

  /// Formato mm:ss para mostrar.
  String get inicioFormateado {
    final totalSeg = inicioMs ~/ 1000;
    final m = totalSeg ~/ 60;
    final s = totalSeg % 60;
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  BloqueAudio copy() => BloqueAudio(
        inicioMs: inicioMs,
        estrofaRef: estrofaRef,
        conLetra: conLetra,
        tipo: tipo,
        velocidad: velocidad,
        timingsMs: List<int>.from(timingsMs),
      );

  BloqueAudio copyConTimings(List<int> nuevosTimings) => BloqueAudio(
        inicioMs: inicioMs,
        estrofaRef: estrofaRef,
        conLetra: conLetra,
        tipo: tipo,
        velocidad: velocidad,
        timingsMs: nuevosTimings,
      );

  Map<String, dynamic> toMap() => {
        'inicioMs': inicioMs,
        'estrofaRef': estrofaRef,
        'conLetra': conLetra,
        'tipo': tipo.name,
        'velocidad': velocidad,
        if (timingsMs.isNotEmpty) 'timingsMs': timingsMs,
      };

  factory BloqueAudio.fromMap(Map<String, dynamic> m) {
    TipoBloque t = TipoBloque.enganche;
    final rawTipo = (m['tipo'] ?? 'enganche').toString();
    for (final v in TipoBloque.values) {
      if (v.name == rawTipo) {
        t = v;
        break;
      }
    }

    final rawTimings = m['timingsMs'] as List?;
    final timings = rawTimings
            ?.map((x) => (x as num).toInt())
            .toList() ??
        <int>[];

    return BloqueAudio(
      inicioMs: (m['inicioMs'] is int) ? m['inicioMs'] as int : 0,
      estrofaRef: (m['estrofaRef'] is int) ? m['estrofaRef'] as int : -1,
      conLetra: m['conLetra'] == true,
      tipo: t,
      velocidad: (m['velocidad'] is num)
          ? (m['velocidad'] as num).toDouble()
          : 1.0,
      timingsMs: timings,
    );
  }
}