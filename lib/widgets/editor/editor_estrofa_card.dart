// lib/widgets/editor/editor_estrofa_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/design.dart';
import '../../models/numerofonia.dart';
import '../../theme/colors.dart';

class EditorEstrofaCard extends StatefulWidget {
  final EstrofaNumerofonia estrofa;
  final int indice;
  final VoidCallback onCelda;
  final VoidCallback onToggleBis;
  final VoidCallback onAgregarColumna;
  final VoidCallback onQuitarColumna;
  final VoidCallback onEliminar;
  final VoidCallback onVerGlobal;

  const EditorEstrofaCard({
    super.key,
    required this.estrofa,
    required this.indice,
    required this.onCelda,
    required this.onToggleBis,
    required this.onAgregarColumna,
    required this.onQuitarColumna,
    required this.onEliminar,
    required this.onVerGlobal,
  });

  @override
  State<EditorEstrofaCard> createState() => _EditorEstrofaCardState();
}

class _EditorEstrofaCardState extends State<EditorEstrofaCard> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _quickCtrl = TextEditingController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _quickCtrl.dispose();
    super.dispose();
  }

  void _agregarColumna() {
    widget.onAgregarColumna();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _procesarTextoRapido() {
    final texto = _quickCtrl.text.trim();
    if (texto.isEmpty) return;

    final nuevasColumnas = EstrofaNumerofonia.parsearTextoRapido(texto);
    if (nuevasColumnas.isEmpty) return;

    setState(() {
      widget.estrofa.columnas.clear();
      widget.estrofa.columnas.addAll(nuevasColumnas);
    });
    
    _quickCtrl.clear();
    widget.onCelda(); // Notificar al padre
    
    // Hacer scroll hasta el final para ver el resultado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorNota = oscuro ? const Color(0xFFE8E8E8) : AppColors.negro;
    final n = widget.estrofa.columnas.length;

    final tabla = Table(
      columnWidths: {
        0: const FixedColumnWidth(32),
        for (int j = 0; j < n; j++)
          j + 1: FixedColumnWidth((widget.estrofa.columnas[j].maxLen.clamp(2, 10) * 18.0).clamp(48.0, 160.0)),
      },
      border: TableBorder.all(color: AppColors.granate.withOpacity(0.3), width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _etiqueta('7'),
          for (int j = 0; j < n; j++) _celda(j, true, widget.estrofa.columnas[j].nota7, colorNota),
        ]),
        TableRow(children: [
          _etiqueta('6'),
          for (int j = 0; j < n; j++) _celda(j, false, widget.estrofa.columnas[j].nota6, colorNota),
        ]),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(Sp.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ESTROFA ${romanoNumerofonia(widget.indice + 1)}', style: AppType.subtitle.copyWith(color: AppColors.granate)),
              if (widget.estrofa.columnas.any((c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty)) ...[
                const SizedBox(width: Sp.sm),
                const AppBadge(label: 'TIMING', icon: Icons.timer, variant: AppBadgeVariant.success),
              ],
              const Spacer(),
              IconButton(icon: const Icon(Icons.zoom_out_map, size: 20, color: AppColors.granate), onPressed: widget.onVerGlobal, tooltip: 'Ver todo'),
              IconButton(icon: Icon(Icons.repeat, size: 20, color: widget.estrofa.bis ? AppColors.dorado : onSurface.withOpacity(0.3)), onPressed: widget.onToggleBis, tooltip: 'BIS'),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: widget.onEliminar),
            ],
          ),
          const SizedBox(height: Sp.sm),
          
          // TABLA
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.granate.withOpacity(0.2)),
              borderRadius: Rad.rSm,
            ),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: tabla,
            ),
          ),
          
          const SizedBox(height: Sp.sm),
          
          // BOTONES DE COLUMNAS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: widget.estrofa.columnas.isEmpty ? null : widget.onQuitarColumna,
                icon: const Icon(Icons.remove, size: 16),
                label: const Text('COLUMNA'),
                style: TextButton.styleFrom(foregroundColor: AppColors.granate),
              ),
              TextButton.icon(
                onPressed: _agregarColumna,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('COLUMNA'),
                style: TextButton.styleFrom(foregroundColor: AppColors.granate),
              ),
            ],
          ),

          const SizedBox(height: Sp.md),
          const Divider(height: 1),
          const SizedBox(height: Sp.sm),

          // 🪄 INGRESO RÁPIDO CON MAGIA
          Row(
            children: [
              Expanded(
                child: AppInput(
                  controller: _quickCtrl,
                  hint: 'Ej: 43335/66472862\\86272',
                  prefixIcon: Icons.auto_fix_high,
                ),
              ),
              const SizedBox(width: Sp.sm),
              IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.granate, size: 32),
                onPressed: _procesarTextoRapido,
                tooltip: 'Auto-acomodar',
              ),
            ],
          ),
          const SizedBox(height: Sp.xs),
          Text(
            'Usa / para subir a fila 7 y \\ para bajar a fila 6.',
            style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.5), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String t) => Container(
        height: 48,
        color: AppColors.granate,
        alignment: Alignment.center,
        child: Text(t, style: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold, fontSize: 14)),
      );

  Widget _celda(int j, bool es7, String valor, Color color) => SizedBox(
        height: 48,
        child: TextFormField(
          key: ValueKey('cif-${identityHashCode(widget.estrofa)}-$j-${es7 ? 7 : 6}'),
          initialValue: valor,
          onChanged: (v) {
            if (es7) { widget.estrofa.columnas[j].nota7 = v; } else { widget.estrofa.columnas[j].nota6 = v; }
          },
          onFieldSubmitted: (_) => widget.onCelda(),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 16),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: '0',
            hintStyle: TextStyle(color: Colors.black12, fontSize: 14),
          ),
        ),
      );
}