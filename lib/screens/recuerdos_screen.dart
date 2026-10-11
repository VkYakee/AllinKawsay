import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/recuerdo_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_recuerdo_screen.dart';
import 'recuerdo_detalle_screen.dart';

class RecuerdosScreen extends StatefulWidget {
  const RecuerdosScreen({super.key});

  @override
  State<RecuerdosScreen> createState() => _RecuerdosScreenState();
}

class _RecuerdosScreenState extends State<RecuerdosScreen> {
  final _service = RecuerdoService();
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  void _eliminar(Recuerdo r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recuerdo'),
        content: Text('¿Eliminar "${r.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(r.id);
  }

  void _editar(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarRecuerdoScreen(recuerdo: r),
      ),
    );
  }

  void _verDetalle(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuerdoDetalleScreen(recuerdo: r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = _usuario?.esAdmin ?? false;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('RECUERDOS')),
      floatingActionButton: esAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AgregarRecuerdoScreen(),
                ),
              ),
              child: const Icon(Icons.add_photo_alternate, size: 24),
            )
          : null,
      body: WatermarkOverlay(
        opacity: 0.04,
        child: StreamBuilder<List<Recuerdo>>(
          stream: _service.listar(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.granate));
            }

            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: ${snap.error}',
                      textAlign: TextAlign.center),
                ),
              );
            }

            final lista = snap.data ?? [];
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.photo_library,
                            size: 48, color: AppColors.granate.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Sin recuerdos aún',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        esAdmin
                            ? 'Toca el botón + para subir el primer recuerdo'
                            : 'El admin aún no ha subido fotos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: onSurface.withOpacity(0.55), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final r = lista[i];
                return _tarjetaRecuerdo(context, r, esAdmin, onSurface);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaRecuerdo(
    BuildContext context,
    Recuerdo r,
    bool esAdmin,
    Color onSurface,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dorado.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _verDetalle(r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con imagen principal
              Stack(
                children: [
                  // Imagen de portada OPTIMIZADA
                  if (r.tieneFotos)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: r.fotos.first,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        memCacheWidth: 600, // OPTIMIZACIÓN
                        memCacheHeight: 400,
                        placeholder: (_, __) => Container(
                          height: 220,
                          color: AppColors.granate.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.granate),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 220,
                          color: AppColors.granate.withOpacity(0.1),
                          child: const Icon(Icons.broken_image,
                              color: AppColors.granate, size: 48),
                        ),
                      ),
                    )
                  else if (r.tieneVideos)
                    Container(
                      height: 220,
                      color: Colors.black87,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam,
                                size: 48, color: AppColors.dorado),
                            SizedBox(height: 8),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: AppColors.dorado,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Badge de cantidad
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (r.tieneFotos) ...[
                            Icon(Icons.photo,
                                size: 14, color: AppColors.dorado),
                            const SizedBox(width: 4),
                            Text(
                              '${r.fotos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (r.tieneFotos && r.tieneVideos)
                            const SizedBox(width: 8),
                          if (r.tieneVideos) ...[
                            Icon(Icons.videocam,
                                size: 14, color: AppColors.dorado),
                            const SizedBox(width: 4),
                            Text(
                              '${r.videos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Menú admin
                  if (esAdmin)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_vert,
                              color: Colors.white, size: 20),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        onSelected: (v) {
                          if (v == 'editar') {
                            _editar(r);
                          } else if (v == 'eliminar') {
                            _eliminar(r);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 10),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Eliminar',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      r.titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Meta info
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 12, color: onSurface.withOpacity(0.45)),
                        const SizedBox(width: 4),
                        Text(
                          r.creadorNombre,
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.55),
                          ),
                        ),
                        if (r.fecha != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today,
                              size: 11, color: onSurface.withOpacity(0.45)),
                          const SizedBox(width: 4),
                          Text(
                            '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: onSurface.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Descripción (preview)
                    if (r.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        r.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],

                    // Indicador de "ver más"
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'VER RECUERDO',
                          style: TextStyle(
                            color: AppColors.granate,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 14, color: AppColors.granate),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}