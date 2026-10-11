/// Modelo de numerofonía de Allin Kawsay.
///
/// Cada estrofa es una TABLA de 2 hileras x N columnas:
///   - Hilera 7 (arriba): cañas agudas
///   - Hilera 6 (abajo): cañas graves
/// Cada celda contiene una nota o un grupo ("4", "56665", "44.6").
/// Compatible con todos los formatos históricos guardados en Firestore.

class ColumnaNumerofonia {
  String nota7;
  String nota6;

  ColumnaNumerofonia({this.nota7 = '', this.nota6 = ''});

  bool get vacia => nota7.trim().isEmpty && nota6.trim().isEmpty;

  /// Largo de la celda más larga de la columna (para el ancho tipo Excel).
  int get maxLen {
    final a = nota7.trim().length;
    final b = nota6.trim().length;
    return a > b ? a : b;
  }

  ColumnaNumerofonia copy() => ColumnaNumerofonia(nota7: nota7, nota6: nota6);

  Map<String, dynamic> toMap() => {'nota7': nota7, 'nota6': nota6};

  factory ColumnaNumerofonia.fromMap(Map<String, dynamic> m) =>
      ColumnaNumerofonia(
        nota7: (m['nota7'] ?? '') as String,
        nota6: (m['nota6'] ?? '') as String,
      );
}

class EstrofaNumerofonia {
  final List<ColumnaNumerofonia> columnas;
  bool bis;

  EstrofaNumerofonia({List<ColumnaNumerofonia>? columnas, this.bis = false})
      : columnas = columnas ?? <ColumnaNumerofonia>[];

  /// Estrofa nueva con [n] columnas vacías (el editor usa 2 por defecto).
  factory EstrofaNumerofonia.nueva({int n = 2}) => EstrofaNumerofonia(
        columnas: List.generate(n, (_) => ColumnaNumerofonia()),
      );

  bool get vacia => columnas.every((c) => c.vacia);

  EstrofaNumerofonia copy() => EstrofaNumerofonia(
        columnas: columnas.map((c) => c.copy()).toList(),
        bis: bis,
      );

  /// Texto plano para compartir por WhatsApp / respaldo.
  /// Ej: "4 4 3 4 / 5 5 6 5 \ 3 3 2 3"
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
    // 1) Formato actual: columnas de tabla
    if (m['columnas'] != null) {
      return EstrofaNumerofonia(
        columnas: (m['columnas'] as List)
            .map((x) =>
                ColumnaNumerofonia.fromMap(Map<String, dynamic>.from(x)))
            .toList(),
        bis: m['bis'] ?? false,
      );
    }
    // 2) Formato intermedio: eventos secuenciales {tipo, valor}
    if (m['eventos'] != null) {
      return EstrofaNumerofonia(
        columnas: _eventosAColumnas((m['eventos'] as List)
            .map((x) => Map<String, dynamic>.from(x))
            .toList()),
        bis: m['bis'] ?? false,
      );
    }
    // 3) Formato viejo: fila7 / fila6
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
    // 4) Texto plano legacy
    return EstrofaNumerofonia(
      columnas: parsearTexto((m['texto'] as String?) ?? ''),
      bis: m['bis'] ?? false,
    );
  }

  /// Convierte "4 4 3 4 / 5 5 6 5 \ 3 3 2 3" (o "4434 / 5565") a columnas.
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

  /// TipoEvento antiguo: 0 = nota7, 1 = nota6, 2 = direccion
  static List<ColumnaNumerofonia> _eventosAColumnas(
      List<Map<String, dynamic>> eventos) {
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

/// Números romanos para rotular las partes (PARTE I, II, III...).
String romanoNumerofonia(int n) {
  const vals = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const sim = [
    'M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'
  ];
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