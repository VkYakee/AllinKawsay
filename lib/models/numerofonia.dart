// lib/models/numerofonia.dart
/// Modelo de numerofonía de Allin Kawsay.

class ColumnaNumerofonia {
  String nota7;
  String nota6;
  List<int> timings7;
  List<int> timings6;

  ColumnaNumerofonia({
    this.nota7 = '',
    this.nota6 = '',
    List<int>? timings7,
    List<int>? timings6,
  })  : timings7 = timings7 ?? <int>[],
        timings6 = timings6 ?? <int>[];

  bool get vacia => nota7.trim().isEmpty && nota6.trim().isEmpty;

  int get maxLen {
    final a = nota7.trim().length;
    final b = nota6.trim().length;
    return a > b ? a : b;
  }

  ColumnaNumerofonia copy() => ColumnaNumerofonia(
        nota7: nota7,
        nota6: nota6,
        timings7: List<int>.from(timings7),
        timings6: List<int>.from(timings6),
      );

  Map<String, dynamic> toMap() => {
        'nota7': nota7,
        'nota6': nota6,
        if (timings7.isNotEmpty) 'timings7': timings7,
        if (timings6.isNotEmpty) 'timings6': timings6,
      };

  factory ColumnaNumerofonia.fromMap(Map<String, dynamic> m) {
    return ColumnaNumerofonia(
      nota7: (m['nota7'] ?? '') as String,
      nota6: (m['nota6'] ?? '') as String,
      timings7: (m['timings7'] as List?)?.map((x) => (x as num).toInt()).toList() ?? <int>[],
      timings6: (m['timings6'] as List?)?.map((x) => (x as num).toInt()).toList() ?? <int>[],
    );
  }
}

class EstrofaNumerofonia {
  final List<ColumnaNumerofonia> columnas;
  bool bis;

  EstrofaNumerofonia({List<ColumnaNumerofonia>? columnas, this.bis = false})
      : columnas = columnas ?? <ColumnaNumerofonia>[];

  factory EstrofaNumerofonia.nueva({int n = 2}) => EstrofaNumerofonia(
        columnas: List.generate(n, (_) => ColumnaNumerofonia()),
      );

  bool get vacia => columnas.every((c) => c.vacia);

  EstrofaNumerofonia copy() => EstrofaNumerofonia(
        columnas: columnas.map((c) => c.copy()).toList(),
        bis: bis,
      );

  String get texto {
    final sb = StringBuffer();
    int? hilera;
    for (final c in columnas) {
      final notas = <MapEntry<int, String>>[
        if (c.nota6.trim().isNotEmpty) MapEntry(6, c.nota6.trim()),
        if (c.nota7.trim().isNotEmpty) MapEntry(7, c.nota7.trim()),
      ];
      for (final n in notas) {
        if (hilera == null) {
          hilera = n.key;
        } else if (hilera != n.key) {
          sb.write(n.key == 7 ? '/ ' : '\\ ');
          hilera = n.key;
        }
        sb.write('${n.value} ');
      }
    }
    return sb.toString().trim();
  }

  Map<String, dynamic> toMap() => {
        'columnas': columnas.map((c) => c.toMap()).toList(),
        'bis': bis,
      };

  factory EstrofaNumerofonia.fromMap(Map<String, dynamic> m) {
    if (m['columnas'] != null) {
      return EstrofaNumerofonia(
        columnas: (m['columnas'] as List)
            .map((x) => ColumnaNumerofonia.fromMap(Map<String, dynamic>.from(x)))
            .toList(),
        bis: m['bis'] ?? false,
      );
    }
    if (m['eventos'] != null) {
      return EstrofaNumerofonia(
        columnas: _eventosAColumnas((m['eventos'] as List)
            .map((x) => Map<String, dynamic>.from(x))
            .toList()),
        bis: m['bis'] ?? false,
      );
    }
    if (m['fila7'] != null || m['fila6'] != null) {
      final f6 = List<String>.from(m['fila6'] ?? []);
      final f7 = List<String>.from(m['fila7'] ?? []);
      return EstrofaNumerofonia(
        columnas: [
          ...f6.map((n) => ColumnaNumerofonia(nota6: n)),
          ...f7.map((n) => ColumnaNumerofonia(nota7: n)),
        ],
        bis: m['bis'] ?? false,
      );
    }
    return EstrofaNumerofonia(
      columnas: parsearTexto((m['texto'] as String?) ?? ''),
      bis: m['bis'] ?? false,
    );
  }

  static List<ColumnaNumerofonia> parsearTexto(String texto) {
    final cols = <ColumnaNumerofonia>[];
    int hilera = 6;
    for (final m in RegExp(r'([0-9.]+|/|\\)').allMatches(texto)) {
      final t = m.group(0)!;
      if (t == '/') {
        hilera = 7;
        continue;
      }
      if (t == '\\') {
        hilera = 6;
        continue;
      }
      cols.add(hilera == 7
          ? ColumnaNumerofonia(nota7: t)
          : ColumnaNumerofonia(nota6: t));
    }
    return cols;
  }

  /// ⚡ INGRESO RÁPIDO
  /// 43653/2332 -> 43653 va abajo (6), 2332 va arriba (7).
  /// 43653\2332 -> 43653 va arriba (7), 2332 va abajo (6).
  static List<ColumnaNumerofonia> parsearTextoRapido(String input) {
    final cleanInput = input.replaceAll(RegExp(r'\s+'), '');
    if (cleanInput.isEmpty) return [];

    final cols = <ColumnaNumerofonia>[];
    final parts = <String>[];
    final separators = <String>[];
    
    String currentPart = '';
    for (int i = 0; i < cleanInput.length; i++) {
      final char = cleanInput[i];
      if (char == '/' || char == '\\') {
        parts.add(currentPart);
        separators.add(char);
        currentPart = '';
      } else {
        currentPart += char;
      }
    }
    parts.add(currentPart);

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i < separators.length) {
        // Si hay un separador después, la fila de este bloque depende de ese separador
        if (separators[i] == '/') {
          // / significa "subir", así que este bloque es fila 6
          cols.add(ColumnaNumerofonia(nota6: part));
        } else {
          // \ significa "bajar", así que este bloque es fila 7
          cols.add(ColumnaNumerofonia(nota7: part));
        }
      } else {
        // Es el último bloque. Depende del último separador que se encontró
        if (separators.isNotEmpty) {
          final lastSep = separators.last;
          if (lastSep == '/') {
            cols.add(ColumnaNumerofonia(nota7: part)); // Venía subiendo
          } else {
            cols.add(ColumnaNumerofonia(nota6: part)); // Venía bajando
          }
        } else {
          cols.add(ColumnaNumerofonia(nota6: part)); // Sin barras, va a fila 6
        }
      }
    }

    return cols;
  }

  static List<ColumnaNumerofonia> _eventosAColumnas(List<Map<String, dynamic>> eventos) {
    final cols = <ColumnaNumerofonia>[];
    int hilera = 6;
    for (final e in eventos) {
      final tipo = (e['tipo'] as int?) ?? 1;
      final valor = (e['valor'] as String?) ?? '';
      if (tipo == 2) {
        hilera = valor == '/' ? 7 : 6;
      } else if (tipo == 0) {
        cols.add(ColumnaNumerofonia(nota7: valor));
        hilera = 7;
      } else {
        cols.add(ColumnaNumerofonia(nota6: valor));
        hilera = 6;
      }
    }
    return cols;
  }
}

String romanoNumerofonia(int n) {
  const vals = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const sim = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  final sb = StringBuffer();
  var x = n;
  for (int i = 0; i < vals.length; i++) {
    while (x >= vals[i]) {
      sb.write(sim[i]);
      x -= vals[i];
    }
  }
  return sb.toString();
}