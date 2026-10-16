/// Tipos de bloque que puede tener un audio de sikuri.
enum TipoBloque {
  enganche,   // solo audio, sin visual (silencio visual)
  intro,      // apertura especial
  diana,      // apertura especial
  chacota,    // apertura especial
  estrofa,    // estrofa de la tabla (instrumental o lírico)
  bis,        // estrofa repetida completa
  ligero,     // estrofa acelerada
}

/// Un bloque dentro del audio de la canción.
///
/// Divide el audio en secciones: enganches, estrofas, BIS, etc.
/// Cada uno apunta a una estrofa de la tabla (o a ninguna).
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

  BloqueAudio({
    required this.inicioMs,
    this.estrofaRef = -1,
    this.conLetra = false,
    required this.tipo,
    this.velocidad = 1.0,
  });

  /// ¿Este bloque tiene columnas visuales para iluminar?
  bool get tieneVisual => estrofaRef >= 0;

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
      );

  Map<String, dynamic> toMap() => {
        'inicioMs': inicioMs,
        'estrofaRef': estrofaRef,
        'conLetra': conLetra,
        'tipo': tipo.name,
        'velocidad': velocidad,
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
    return BloqueAudio(
      inicioMs: (m['inicioMs'] is int) ? m['inicioMs'] as int : 0,
      estrofaRef: (m['estrofaRef'] is int) ? m['estrofaRef'] as int : -1,
      conLetra: m['conLetra'] == true,
      tipo: t,
      velocidad: (m['velocidad'] is num)
          ? (m['velocidad'] as num).toDouble()
          : 1.0,
    );
  }
}