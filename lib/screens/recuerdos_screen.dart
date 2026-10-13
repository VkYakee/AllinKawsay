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
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _cargarUsuario();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _refreshing = false);
  }

  void _eliminar(Recuerdo r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar recuerdo', style: TextStyle(color: AppColors.granate, fontWeight: FontWeight.bold)),
        content: Text('¿Eliminar "${r.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.eliminar(r.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recuerdo "${r.titulo}" eliminado')),
        );
      }
    }
  }

  void _editar(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgregarRecuerdoScreen(recuerdo: r)),
    );
  }

  void _verDetalle(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecuerdoDetalleScreen(recuerdo: r)),
    );
  }
@override
  Widget build(BuildContext context) {
    final esAdmin = _usuario?.esAdmin ?? false;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('RECUERDOS', style: TextStyle(letterSpacing: 2)),
            const SizedBox(width: 8),
            StreamBuilder<List<Recuerdo>>(
              stream: _service.listar(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${snap.data!.length}',
                    style: const TextStyle(
                      color: AppColors.dorado,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AgregarRecuerdoScreen()),
              ),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('NUEVO'),
            )
          : null,
      body: WatermarkOverlay(
        opacity: 0.04,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.dorado,
          child: StreamBuilder<List<Recuerdo>>(
            stream: _service.listar(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                return const _LoadingSkeleton();
              }
              
              if (snap.hasError) {
                return _ErrorWidget(
                  error: snap.error.toString(),
                  onRetry: () => setState(() {}),
                );
              }
              
              final lista = snap.data ?? [];
              
              if (lista.isEmpty) {
                return _EmptyWidget(esAdmin: esAdmin, onSurface: onSurface);
              }
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (i * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _tarjetaRecuerdo(context, lista[i], esAdmin, onSurface),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
class _TarjetaRecuerdo extends StatelessWidget {
  final BuildContext parentContext;
  final Recuerdo r;
  final bool esAdmin;
  final Color onSurface;
  final Function(Recuerdo) onVerDetalle;
  final Function(Recuerdo) onEditar;
  final Function(Recuerdo) onEliminar;

  const _TarjetaRecuerdo({
    required this.parentContext,
    required this.r,
    required this.esAdmin,
    required this.onSurface,
    required this.onVerDetalle,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => onVerDetalle(r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  if (r.tieneFotos)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Hero(
                        tag: 'recuerdo_${r.id}_foto',
                        child: CachedNetworkImage(
                          imageUrl: r.fotos.first,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          memCacheWidth: 600,
                          memCacheHeight: 400,
                          placeholder: (_, __) => Container(
                            height: 220,
                            color: AppColors.granate.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(color: AppColors.granate),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 220,
                            color: AppColors.granate.withOpacity(0.1),
                            child: const Icon(Icons.broken_image, color: AppColors.granate, size: 48),
                          ),
                        ),
                      ),
                    )
                  else if (r.tieneVideos)
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black87, Colors.black54],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam, size: 56, color: AppColors.dorado),
                            const SizedBox(height: 8),
                            const Text(
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
                    )
                  else
                    Container(
                      height: 220,
                      color: AppColors.granate.withOpacity(0.1),
                      child: const Center(
                        child: Icon(Icons.photo_library, size: 64, color: AppColors.granate),
                      ),
                    ),

                  if (r.tieneFotos || r.tieneVideos)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (r.tieneFotos) ...[
                              const Icon(Icons.photo, size: 14, color: Colors.white),
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
                            if (r.tieneFotos && r.tieneVideos) const SizedBox(width: 8),
                            if (r.tieneVideos) ...[
                              const Icon(Icons.videocam, size: 14, color: Colors.white),
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

                  if (esAdmin)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onSelected: (v) {
                          if (v == 'editar') onEditar(r);
                          else if (v == 'eliminar') onEliminar(r);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: AppColors.granate),
                                const SizedBox(width: 10),
                                const Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                const SizedBox(width: 10),
                                const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 12, color: onSurface.withOpacity(0.45)),
                        const SizedBox(width: 4),
                        Text(r.creadorNombre, style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.55))),
                        if (r.fecha != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, size: 11, color: onSurface.withOpacity(0.45)),
                          const SizedBox(width: 4),
                          Text(
                            '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                            style: TextStyle(fontSize: 12, color: onSurface.withOpacity(0.55)),
                          ),
                        ],
                      ],
                    ),
                    if (r.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        r.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: onSurface.withOpacity(0.7), height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('VER RECUERDO', style: TextStyle(color: AppColors.granate, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: AppColors.granate),
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
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  color: Colors.grey.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 200, height: 20, color: Colors.grey.withOpacity(0.1)),
                      const SizedBox(height: 8),
                      Container(width: 120, height: 16, color: Colors.grey.withOpacity(0.1)),
                      const SizedBox(height: 12),
                      Container(width: double.infinity, height: 14, color: Colors.grey.withOpacity(0.1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 20),
            const Text(
              'Error al cargar recuerdos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final bool esAdmin;
  final Color onSurface;

  const _EmptyWidget({required this.esAdmin, required this.onSurface});

  @override
  Widget build(BuildContext context) {
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
              child: Icon(Icons.photo_library, size: 64, color: AppColors.granate.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin recuerdos aún',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.granate, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              esAdmin ? 'Toca el botón NUEVO para subir el primer recuerdo' : 'El admin aún no ha subido fotos',
              textAlign: TextAlign.center,
              style: TextStyle(color: onSurface.withOpacity(0.55), fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}