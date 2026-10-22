// lib/widgets/cancion/comentarios_section.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/comentario.dart';
import '../../services/comentario_service.dart';
import '../../theme/colors.dart';

class ComentariosSection extends StatefulWidget {
  final String cancionId;
  final bool puedeComentar;

  const ComentariosSection({
    super.key,
    required this.cancionId,
    required this.puedeComentar,
  });

  @override
  State<ComentariosSection> createState() => _ComentariosSectionState();
}

class _ComentariosSectionState extends State<ComentariosSection> {
  final _comentarioCtrl = TextEditingController();

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  void _enviar() async {
    final texto = _comentarioCtrl.text.trim();
    if (texto.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    
    await ComentarioService().agregar(
      widget.cancionId,
      Comentario(
        id: '',
        texto: texto,
        autorUid: user.uid,
        autorNombre: user.displayName ?? user.email ?? 'Anónimo',
      ),
    );
    _comentarioCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    return Column(
      children: [
        // Lista de comentarios
        Expanded(
          child: StreamBuilder<List<Comentario>>(
            stream: ComentarioService().listar(widget.cancionId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.granate));
              }
              final lista = snap.data ?? [];
              if (lista.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Sin comentarios',
                  subtitle: 'Sé el primero en comentar esta canción.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(Sp.md),
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final c = lista[i];
                  final esMio = c.autorUid == FirebaseAuth.instance.currentUser?.uid;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Sp.sm),
                    child: Container(
                      padding: const EdgeInsets.all(Sp.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor(context),
                        borderRadius: Rad.rMd,
                        border: Border.all(color: AppColors.granate.withOpacity(0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.granate.withOpacity(0.1),
                            child: Text(
                              c.autorNombre.isNotEmpty ? c.autorNombre[0].toUpperCase() : '?',
                              style: AppType.caption.copyWith(color: AppColors.granate, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: Sp.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(c.autorNombre, style: AppType.caption.copyWith(fontWeight: FontWeight.bold, color: onSurface)),
                                    const SizedBox(width: Sp.sm),
                                    Text(_fecha(c.fecha), style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.4))),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(c.texto, style: AppType.bodySm.copyWith(color: onSurface.withOpacity(0.8))),
                              ],
                            ),
                          ),
                          if (esMio)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => ComentarioService().eliminar(widget.cancionId, c.id),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // Input para nuevo comentario
        if (widget.puedeComentar)
          Container(
            padding: const EdgeInsets.all(Sp.md),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              border: Border(top: BorderSide(color: AppColors.granate.withOpacity(0.1))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: AppInput(
                      controller: _comentarioCtrl,
                      hint: 'Escribe un comentario...',
                    ),
                  ),
                  const SizedBox(width: Sp.sm),
                  Container(
                    decoration: const BoxDecoration(color: AppColors.granate, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.dorado, size: 20),
                      onPressed: _enviar,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(Sp.lg),
            child: Text(
              'Solo los miembros del grupo pueden comentar.',
              style: AppType.captionXs.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  String _fecha(DateTime? d) {
    if (d == null) return '...';
    return '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}