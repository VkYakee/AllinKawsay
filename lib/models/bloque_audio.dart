// lib/models/bloque_audio.dart
enum TipoBloque { enganche, intro, diana, chacota, estrofa, bis, ligero }

class BloqueAudio {
  final int inicioMs;
  final int estrofaRef;
  final bool conLetra;
  final TipoBloque tipo;
  final double velocidad;
  final List<int> timingsMs;
  
  // ⚡ NUEVO: Guarda los milisegundos exactos donde cambia cada línea de la letra
  final List<int> letraTimingsMs; 

  BloqueAudio({
    required this.inicioMs,
    this.estrofaRef = -1,
    this.conLetra = false,
    required this.tipo,
    this.velocidad = 1.0,
    List<int>? timingsMs,
    List<int>? letraTimingsMs,
  })  : timingsMs = timingsMs ?? <int>[],
        letraTimingsMs = letraTimingsMs ?? <int>[];

  bool get tieneVisual => estrofaRef >= 0;
  bool get tieneTimingA => timingsMs.isNotEmpty;

  String get label {
    switch (tipo) {
      case TipoBloque.enganche: return 'Enganche';
      case TipoBloque.intro: return 'Intro';
      case TipoBloque.diana: return 'Diana';
      case TipoBloque.chacota: return 'Chacota';
      case TipoBloque.estrofa: return 'Estrofa ${estrofaRef + 1}${conLetra ? ' · con letra' : ''}';
      case TipoBloque.bis: return 'BIS Estrofa ${estrofaRef + 1}';
      case TipoBloque.ligero: return 'Ligero';
    }
  }

  String get inicioFormateado {
    final totalSeg = inicioMs ~/ 1000;
    return '${(totalSeg ~/ 60).toString().padLeft(2, '0')}:${(totalSeg % 60).toString().padLeft(2, '0')}';
  }

  BloqueAudio copy() => BloqueAudio(
        inicioMs: inicioMs, estrofaRef: estrofaRef, conLetra: conLetra,
        tipo: tipo, velocidad: velocidad, timingsMs: List<int>.from(timingsMs),
        letraTimingsMs: List<int>.from(letraTimingsMs),
      );

  BloqueAudio copyConTimings(List<int> nuevosTimings, List<int> nuevasLetras) => BloqueAudio(
        inicioMs: inicioMs, estrofaRef: estrofaRef, conLetra: conLetra,
        tipo: tipo, velocidad: velocidad, timingsMs: nuevosTimings,
        letraTimingsMs: nuevasLetras,
      );

  Map<String, dynamic> toMap() => {
        'inicioMs': inicioMs, 'estrofaRef': estrofaRef, 'conLetra': conLetra,
        'tipo': tipo.name, 'velocidad': velocidad,
        if (timingsMs.isNotEmpty) 'timingsMs': timingsMs,
        if (letraTimingsMs.isNotEmpty) 'letraTimingsMs': letraTimingsMs,
      };

  factory BloqueAudio.fromMap(Map<String, dynamic> m) {
    TipoBloque t = TipoBloque.enganche;
    final rawTipo = (m['tipo'] ?? 'enganche').toString();
    for (final v in TipoBloque.values) {
      if (v.name == rawTipo) { t = v; break; }
    }

    final rawTimings = m['timingsMs'] as List?;
    final timings = rawTimings?.map((x) => (x as num).toInt()).toList() ?? <int>[];
    
    final rawLetras = m['letraTimingsMs'] as List?;
    final letras = rawLetras?.map((x) => (x as num).toInt()).toList() ?? <int>[];

    return BloqueAudio(
      inicioMs: (m['inicioMs'] is int) ? m['inicioMs'] as int : 0,
      estrofaRef: (m['estrofaRef'] is int) ? m['estrofaRef'] as int : -1,
      conLetra: m['conLetra'] == true, tipo: t,
      velocidad: (m['velocidad'] is num) ? (m['velocidad'] as num).toDouble() : 1.0,
      timingsMs: timings, letraTimingsMs: letras,
    );
  }
}