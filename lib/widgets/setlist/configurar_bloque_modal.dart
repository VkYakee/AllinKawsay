// lib/widgets/setlist/configurar_bloque_modal.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/bloque_audio.dart';
import '../../theme/colors.dart';

class ConfigurarBloqueModal {
  static Future<BloqueAudio?> mostrar(BuildContext context, {
    required int inicioMs,
    BloqueAudio? bloqueExistente,
    required int estrofasDisponibles,
  }) {
    return showModalBottomSheet<BloqueAudio>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalContent(inicioMs: inicioMs, bloqueExistente: bloqueExistente, estrofasDisponibles: estrofasDisponibles),
    );
  }
}

class _ModalContent extends StatefulWidget {
  final int inicioMs;
  final BloqueAudio? bloqueExistente;
  final int estrofasDisponibles;

  const _ModalContent({required this.inicioMs, this.bloqueExistente, required this.estrofasDisponibles});

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  late TipoBloque _tipo;
  late int _estrofaRef;
  late bool _conLetra;

  @override
  void initState() {
    super.initState();
    final b = widget.bloqueExistente;
    _tipo = b?.tipo ?? TipoBloque.enganche;
    _estrofaRef = b?.estrofaRef ?? 0;
    _conLetra = b?.conLetra ?? false;
  }

  bool get _requiereEstrofa => _tipo == TipoBloque.estrofa || _tipo == TipoBloque.bis || _tipo == TipoBloque.ligero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.xl),
      decoration: BoxDecoration(color: AppColors.cardColor(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.granate.withOpacity(0.3), borderRadius: Rad.rPill))),
          const SizedBox(height: Sp.lg),
          Text('Configurar Bloque', style: AppType.h3, textAlign: TextAlign.center),
          const SizedBox(height: Sp.lg),
          Wrap(
            spacing: Sp.sm, runSpacing: Sp.sm,
            children: TipoBloque.values.map((t) => AppChoiceChip(
              label: t.name,
              selected: _tipo == t,
              onSelected: (_) => setState(() { _tipo = t; if (_requiereEstrofa && _estrofaRef < 0) _estrofaRef = 0; }),
            )).toList(),
          ),
          if (_requiereEstrofa && widget.estrofasDisponibles > 0) ...[
            const SizedBox(height: Sp.lg),
            Text('Estrofa de la tabla', style: AppType.eyebrow.copyWith(color: AppColors.granate)),
            const SizedBox(height: Sp.sm),
            Wrap(
              spacing: Sp.sm,
              children: [
                for (int i = 0; i < widget.estrofasDisponibles; i++)
                  AppChoiceChip(label: 'E${i + 1}', selected: _estrofaRef == i, onSelected: (_) => setState(() => _estrofaRef = i)),
              ],
            ),
          ],
          const SizedBox(height: Sp.xl),
          AppButton(
            label: widget.bloqueExistente == null ? 'AGREGAR BLOQUE' : 'GUARDAR CAMBIOS',
            onPressed: () {
              Navigator.pop(context, BloqueAudio(
                inicioMs: widget.inicioMs,
                estrofaRef: _requiereEstrofa ? _estrofaRef : -1,
                conLetra: _tipo == TipoBloque.estrofa && _conLetra,
                tipo: _tipo,
                velocidad: 1.0,
              ));
            },
          ),
        ],
      ),
    );
  }
}