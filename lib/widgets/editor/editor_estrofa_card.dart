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
    widget.onCelda();
    
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
    final colorLinea = AppColors.granate.withOpacity(0.3);
    final n = widget.estrofa.columnas.length;
    final anchos = [for (int j = 0; j < n; j++) (widget.estrofa.columnas[j].maxLen.clamp(2, 10) * 18.0).clamp(48.0, 160.0)];

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
          
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colorLinea, width: 1), left: BorderSide(color: colorLinea, width: 1)),
              borderRadius: Rad.rSm,
            ),
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fila 7
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _etiqueta('7', colorLinea),
                      for (int j = 0; j < n; j++) 
                        _celda(j, true, widget.estrofa.columnas[j].nota7, colorNota, colorLinea, anchos[j]),
                    ],
                  ),
                  // Fila 6
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _etiqueta('6', colorLinea),
                      for (int j = 0; j < n; j++) 
                        _celda(j, false, widget.estrofa.columnas[j].nota6, colorNota, colorLinea, anchos[j]),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: Sp.sm),
          
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

  Widget _etiqueta(String t, Color borderColor) => Container(
        width: 32,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.granate,
          border: Border(right: BorderSide(color: borderColor, width: 1), bottom: BorderSide(color: borderColor, width: 1)),
        ),
        alignment: Alignment.center,
        child: Text(t, style: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold, fontSize: 14)),
      );

  Widget _celda(int j, bool es7, String valor, Color color, Color borderColor, double ancho) => Container(
        width: ancho,
        height: 48,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: borderColor, width: 1), bottom: BorderSide(color: borderColor, width: 1)),
        ),
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