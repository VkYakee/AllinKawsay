import 'package:cloud_firestore/cloud_firestore.dart';

import 'numerofonia.dart';

/// Una letra completa (con sus estrofas adentro) y un título opcional.
class Letra {
  String titulo;
  String texto;

  Letra({this.titulo = '', this.texto = ''});

  bool get vacia => texto.trim().isEmpty;

  Letra copy() => Letra(titulo: titulo, texto: texto);

  Map<String, dynamic> toMap() => {'titulo': titulo, 'texto': texto};

  factory Letra.fromMap(Map<String, dynamic> m) => Letra(
        titulo: (m['titulo'] ?? '') as String,
        texto: (m['texto'] ?? '') as String,
      );
}

class Cancion {
  final String id;
  final String titulo;
  final String autor;
  final String tipo;
  final String ritmo;
  final String region;
  final String numerofonia;
  final List<EstrofaNumerofonia> estrofas;
  final String letra; // legacy: texto plano combinado
  final List<Letra> letras; // NUEVO: letras con título
  final String imagenUrl;
  final String audioUrl;
  final String videoUrl;
  final String descripcion;
  final List<String> tags;
  final String categoriaId;
  final int reproducciones;
  final String creadoPor;
  final String creadorNombre;
  final DateTime? fechaCreacion;

  Cancion({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.tipo,
    required this.ritmo,
    required this.region,
    required this.numerofonia,
    required this.estrofas,
    required this.letra,
    this.letras = const [],
    required this.imagenUrl,
    required this.audioUrl,
    this.videoUrl = '',
    required this.descripcion,
    required this.tags,
    this.categoriaId = '',
    this.reproducciones = 0,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
  });

  bool get tieneNumerofonia => estrofas.any((e) => !e.vacia);
  bool get tieneNumerofoniaString => numerofonia.isNotEmpty;
  bool get tieneVideo => videoUrl.isNotEmpty;
  bool get tieneCategoria => categoriaId.isNotEmpty;
  bool get tieneLetra => letras.any((l) => !l.vacia);

  factory Cancion.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final raw = d['estrofas'] ?? d['compases'] ?? d['numerofoniaEstructurada'];
    final lista = (raw as List?)
            ?.map((x) =>
                EstrofaNumerofonia.fromMap(Map<String, dynamic>.from(x)))
            .toList() ??
        <EstrofaNumerofonia>[];

    // Migración automática de letras viejas
    List<Letra> letras;
    final letrasRaw = d['letras'] as List?;
    if (letrasRaw != null && letrasRaw.isNotEmpty) {
      letras = letrasRaw
          .map((x) => Letra.fromMap(Map<String, dynamic>.from(x)))
          .toList();
    } else {
      final leg = (d['letra'] ?? '') as String;
      letras = leg.trim().isEmpty ? [] : [Letra(texto: leg)];
    }

    return Cancion(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      autor: d['autor'] ?? '',
      tipo: d['tipo'] ?? 'original',
      ritmo: d['ritmo'] ?? '',
      region: d['region'] ?? '',
      numerofonia: d['numerofonia'] ?? '',
      estrofas: lista,
      letra: (d['letra'] ?? '') as String,
      letras: letras,
      imagenUrl: d['imagenUrl'] ?? '',
      audioUrl: d['audioUrl'] ?? '',
      videoUrl: d['videoUrl'] ?? '',
      descripcion: d['descripcion'] ?? '',
      tags: List<String>.from(d['tags'] ?? []),
      categoriaId: d['categoriaId'] ?? '',
      reproducciones: (d['reproducciones'] ?? 0) is int
          ? d['reproducciones'] ?? 0
          : 0,
      creadoPor: d['creadoPor'] ?? '',
      creadorNombre: d['creadorNombre'] ?? '',
      fechaCreacion: (d['fechaCreacion'] as Timestamp?)?.toDate(),
    );
  }

  /// Normaliza las letras: si no hay `letras` pero sí `letra` legacy,
  /// la convierte. Si no hay ninguna, devuelve lista vacía.
  List<Letra> _letrasFinal() {
    if (letras.isNotEmpty) return letras;
    if (letra.trim().isEmpty) return const [];
    return [Letra(texto: letra)];
  }

  /// SOLO usar al CREAR una canción nueva.
  /// Incluye `fechaCreacion` (server timestamp) y `creadoPor`/`creadorNombre`.
  Map<String, dynamic> toMapCrear() {
    final finales = _letrasFinal();
    return {
      'titulo': titulo,
      'autor': autor,
      'tipo': tipo,
      'ritmo': ritmo,
      'region': region,
      'numerofonia': numerofonia,
      'estrofas': estrofas.map((e) => e.toMap()).toList(),
      'letra': finales.map((l) => l.texto).join('\n\n'),
      'letras': finales.map((l) => l.toMap()).toList(),
      'imagenUrl': imagenUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'descripcion': descripcion,
      'tags': tags,
      'categoriaId': categoriaId,
      'reproducciones': reproducciones,
      'creadoPor': creadoPor,
      'creadorNombre': creadorNombre,
      'fechaCreacion': FieldValue.serverTimestamp(),
    };
  }

  /// SOLO usar al EDITAR una canción existente.
  /// NUNCA pisa `fechaCreacion`, `creadoPor` ni `creadorNombre`.
  Map<String, dynamic> toMapEditar() {
    final finales = _letrasFinal();
    return {
      'titulo': titulo,
      'autor': autor,
      'tipo': tipo,
      'ritmo': ritmo,
      'region': region,
      'numerofonia': numerofonia,
      'estrofas': estrofas.map((e) => e.toMap()).toList(),
      'letra': finales.map((l) => l.texto).join('\n\n'),
      'letras': finales.map((l) => l.toMap()).toList(),
      'imagenUrl': imagenUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'descripcion': descripcion,
      'tags': tags,
      'categoriaId': categoriaId,
      'reproducciones': reproducciones,
    };
  }
}