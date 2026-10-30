// lib/features/admin/screens/estadisticas_admin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../theme/colors.dart';
import '../../../widgets/admin/stat_card.dart';

class EstadisticasAdminScreen extends StatefulWidget {
  const EstadisticasAdminScreen({super.key});

  @override
  State<EstadisticasAdminScreen> createState() =>
      _EstadisticasAdminScreenState();
}

class _Stats {
  final int totalCanciones;
  final int totalUsuarios;
  final int totalReproducciones;
  final int totalEventos;
  final int totalRecuerdos;
  final List<MapEntry<String, int>> topCanciones;
  final List<MapEntry<String, int>> ritmos;
  final Map<String, int> usuariosPorRol;

  _Stats({
    required this.totalCanciones,
    required this.totalUsuarios,
    required this.totalReproducciones,
    required this.totalEventos,
    required this.totalRecuerdos,
    required this.topCanciones,
    required this.ritmos,
    required this.usuariosPorRol,
  });
}

class _EstadisticasAdminScreenState
    extends State<EstadisticasAdminScreen> {
  late Future<_Stats> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<_Stats> _cargar() async {
    final db = FirebaseFirestore.instance;
    final cancionesSnap = await db.collection('canciones').get();
    final usuariosSnap = await db.collection('usuarios').get();
    final eventosSnap = await db.collection('eventos').get();
    final recuerdosSnap = await db.collection('recuerdos').get();

    int totalReproducciones = 0;
    final Map<String, int> cancionesPorTitulo = {};
    final Map<String, int> ritmos = {};
    final Map<String, int> usuariosPorRol = {};

    for (final doc in cancionesSnap.docs) {
      final d = doc.data();
      final r = (d['reproducciones'] is int)
          ? d['reproducciones'] as int
          : 0;
      totalReproducciones += r;
      cancionesPorTitulo[(d['titulo'] ?? 'Sin título').toString()] = r;
      final ritmo = (d['ritmo'] ?? '').toString().trim();
      final key = ritmo.isEmpty ? 'Sin ritmo' : ritmo;
      ritmos[key] = (ritmos[key] ?? 0) + 1;
    }

    for (final doc in usuariosSnap.docs) {
      final rol = (doc.data()['rol'] ?? 'publico').toString();
      usuariosPorRol[rol] = (usuariosPorRol[rol] ?? 0) + 1;
    }

    final topCancionesList = cancionesPorTitulo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final ritmosList = ritmos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _Stats(
      totalCanciones: cancionesSnap.docs.length,
      totalUsuarios: usuariosSnap.docs.length,
      totalReproducciones: totalReproducciones,
      totalEventos: eventosSnap.docs.length,
      totalRecuerdos: recuerdosSnap.docs.length,
      topCanciones: topCancionesList.take(5).toList(),
      ritmos: ritmosList,
      usuariosPorRol: usuariosPorRol,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Estadísticas',
      body: FutureBuilder<_Stats>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.granate),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: AppType.body),
            );
          }
          final s = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(Sp.lg),
            children: [
              const SeccionHeader(
                title: 'Resumen General',
                icon: Icons.insights,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: Sp.md),
              Row(children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.library_music,
                    value: '${s.totalCanciones}',
                    label: 'Canciones',
                  ),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: StatCard(
                    icon: Icons.people,
                    value: '${s.totalUsuarios}',
                    label: 'Usuarios',
                  ),
                ),
              ]),
              const SizedBox(height: Sp.md),
              Row(children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.play_arrow,
                    value: '${s.totalReproducciones}',
                    label: 'Reproducciones',
                  ),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: StatCard(
                    icon: Icons.event,
                    value: '${s.totalEventos}',
                    label: 'Eventos',
                  ),
                ),
              ]),
              const SizedBox(height: Sp.md),
              Row(children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.photo_library,
                    value: '${s.totalRecuerdos}',
                    label: 'Recuerdos',
                  ),
                ),
                const Expanded(child: SizedBox()),
              ]),
              const SizedBox(height: Sp.xl),
              const SeccionHeader(
                title: 'Usuarios por Rol',
                icon: Icons.badge_outlined,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: Sp.md),
              AppCard(
                padding: const EdgeInsets.all(Sp.lg),
                child: Column(
                  children: s.usuariosPorRol.entries
                      .map((e) => _filaTexto(_labelRol(e.key), '${e.value}'))
                      .toList(),
                ),
              ),
              const SizedBox(height: Sp.xl),
              const SeccionHeader(
                title: 'Top 5 Canciones',
                icon: Icons.local_fire_department,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: Sp.md),
              AppCard(
                padding: const EdgeInsets.all(Sp.lg),
                child: s.topCanciones.isEmpty ||
                        s.topCanciones.every((e) => e.value == 0)
                    ? Text(
                        'Aún no hay reproducciones',
                        style: AppType.captionXs.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Column(
                        children: List.generate(
                          s.topCanciones.length,
                          (i) => _filaTop(
                            i,
                            s.topCanciones[i].key,
                            s.topCanciones[i].value,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: Sp.xl),
              const SeccionHeader(
                title: 'Canciones por Ritmo',
                icon: Icons.graphic_eq,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: Sp.md),
              AppCard(
                padding: const EdgeInsets.all(Sp.lg),
                child: s.ritmos.isEmpty
                    ? Text(
                        'Sin datos',
                        style: AppType.captionXs.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Column(
                        children: s.ritmos
                            .map((e) => _filaTexto(e.key, '${e.value}'))
                            .toList(),
                      ),
              ),
              const SizedBox(height: Sp.xxxl),
            ],
          );
        },
      ),
    );
  }

  Widget _filaTexto(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppType.body)),
          AppBadge(
            label: valor,
            variant: AppBadgeVariant.granate,
          ),
        ],
      ),
    );
  }

  Widget _filaTop(int index, String titulo, int valor) {
    final medallas = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
      child: Row(
        children: [
          Text(medallas[index], style: const TextStyle(fontSize: 18)),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Text(
              titulo,
              style: AppType.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppBadge(
            label: '$valor',
            variant: AppBadgeVariant.granate,
          ),
        ],
      ),
    );
  }

  String _labelRol(String rol) {
    switch (rol) {
      case 'dev':
        return 'Desarrolladores';
      case 'admin':
        return 'Administradores';
      case 'miembro':
        return 'Miembros oficiales';
      default:
        return 'Público';
    }
  }
}