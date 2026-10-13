import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  void _enviarComentario() async {
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
        SizedBox(height: 300, child: _comentariosBody(onSurface)),
        if (widget.puedeComentar)
          _comentarioInput()
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Solo los miembros del grupo pueden comentar.',
              style: TextStyle(color: onSurface.withOpacity(0.5), fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _comentariosBody(Color onSurface) {
    return StreamBuilder<List<Comentario>>(
      stream: ComentarioService().listar(widget.cancionId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.granate));
        }

        final lista = snap.data ?? [];

        if (lista.isEmpty) {
          return Center(
            child: Text('Sin comentarios aún', style: TextStyle(color: onSurface.withOpacity(0.5), fontStyle: FontStyle.italic)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final c = lista[i];
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            final esMio = c.autorUid == uid;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    c.autorNombre.isNotEmpty ? c.autorNombre[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(c.autorNombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: onSurface)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(c.texto, style: TextStyle(color: onSurface.withOpacity(0.8), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(_fmtFecha(c.fecha), style: TextStyle(fontSize: 10, color: onSurface.withOpacity(0.4))),
                  ],
                ),
                trailing: esMio
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.granate, size: 20),
                        onPressed: () => ComentarioService().eliminar(widget.cancionId, c.id),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _comentarioInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.dorado.withOpacity(0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _comentarioCtrl,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario...',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.dorado, size: 20),
                onPressed: _enviarComentario,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return '...';
    return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}