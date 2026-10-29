// lib/models/bloque_audio.dart
enum TipoBloque { enganche, intro, diana, chacota, estrofa, bis, ligero }

class FragmentoKaraoke {
  final int inicioMs;
  final int finMs;
  final String texto;

  FragmentoKaraoke({required this.inicioMs, required this.finMs, required this.texto});

  Map<String, dynamic> toMap() => {'inicioMs': inicioMs, 'finMs': finMs, 'texto': texto};

  factory FragmentoKaraoke.fromMap(Map<String, dynamic> m) => FragmentoKaraoke(
    inicioMs: (m['inicioMs'] ?? 0) as int,
    finMs: (m['finMs'] ?? 0) as int,
    texto: (m['texto'] ?? '') as String,
  );
}

class BloqueAudio {
  final int inicioMs;
  final int estrofaRef;
  final bool conLetra;
  final TipoBloque tipo;
  final double velocidad;
  final List<int> timingsMs;
  final List<FragmentoKaraoke> karaokeFragments;

  BloqueAudio({
    required this.inicioMs,
    this.estrofaRef = -1,
    this.conLetra = false,
    required this.tipo,
    this.velocidad = 1.0,
    List<int>? timingsMs,
    List<FragmentoKaraoke>? karaokeFragments,
  })  : timingsMs = timingsMs ?? <int>[],
        karaokeFragments = karaokeFragments ?? <FragmentoKaraoke>[];

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
        karaokeFragments: List<FragmentoKaraoke>.from(karaokeFragments),
      );

  BloqueAudio copyConTimings(List<int> nuevosTimings) => BloqueAudio(
        inicioMs: inicioMs, estrofaRef: estrofaRef, conLetra: conLetra,
        tipo: tipo, velocidad: velocidad, timingsMs: nuevosTimings,
        karaokeFragments: karaokeFragments,
      );

  BloqueAudio copyConKaraoke(List<FragmentoKaraoke> nuevosFragmentos) => BloqueAudio(
        inicioMs: inicioMs, estrofaRef: estrofaRef, conLetra: conLetra,
        tipo: tipo, velocidad: velocidad, timingsMs: timingsMs,
        karaokeFragments: nuevosFragmentos,
      );

  Map<String, dynamic> toMap() => {
        'inicioMs': inicioMs, 'estrofaRef': estrofaRef, 'conLetra': conLetra,
        'tipo': tipo.name, 'velocidad': velocidad,
        if (timingsMs.isNotEmpty) 'timingsMs': timingsMs,
        if (karaokeFragments.isNotEmpty) 'karaoke': karaokeFragments.map((f) => f.toMap()).toList(),
      };

  factory BloqueAudio.fromMap(Map<String, dynamic> m) {
    TipoBloque t = TipoBloque.enganche;
    final rawTipo = (m['tipo'] ?? 'enganche').toString();
    for (final v in TipoBloque.values) {
      if (v.name == rawTipo) { t = v; break; }
    }

    final rawTimings = m['timingsMs'] as List?;
    final timings = rawTimings?.map((x) => (x as num).toInt()).toList() ?? <int>[];
    
    final rawKaraoke = m['karaoke'] as List?;
    final karaoke = rawKaraoke?.map((x) => FragmentoKaraoke.fromMap(Map<String, dynamic>.from(x))).toList() ?? <FragmentoKaraoke>[];

    return BloqueAudio(
      inicioMs: (m['inicioMs'] is int) ? m['inicioMs'] as int : 0,
      estrofaRef: (m['estrofaRef'] is int) ? m['estrofaRef'] as int : -1,
      conLetra: m['conLetra'] == true, tipo: t,
      velocidad: (m['velocidad'] is num) ? (m['velocidad'] as num).toDouble() : 1.0,
      timingsMs: timings, karaokeFragments: karaoke,
    );
  }
}