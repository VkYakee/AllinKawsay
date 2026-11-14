// lib/features/admin/screens/estadisticas_admin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/components/allin_loading_siku.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../widgets/stat_card.dart';

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
      final data = doc.data();
      final repros = (data['reproducciones'] as num?)?.toInt() ?? 0;
      totalReproducciones += repros;
      final titulo = data['titulo'] as String? ?? 'Sin título';
      cancionesPorTitulo[titulo] = repros;

      final ritmo = data['ritmo'] as String? ?? 'Otros';
      ritmos[ritmo] = (ritmos[ritmo] ?? 0) + 1;
    }

    for (final doc in usuariosSnap.docs) {
      final data = doc.data();
      final rol = data['rol'] as String? ?? 'publico';
      usuariosPorRol[rol] = (usuariosPorRol[rol] ?? 0) + 1;
    }

    final topList = cancionesPorTitulo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final ritmosList = ritmos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _Stats(
      totalCanciones: cancionesSnap.size,
      totalUsuarios: usuariosSnap.size,
      totalReproducciones: totalReproducciones,
      totalEventos: eventosSnap.size,
      totalRecuerdos: recuerdosSnap.size,
      topCanciones: topList.take(5).toList(),
      ritmos: ritmosList,
      usuariosPorRol: usuariosPorRol,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          'Panel Estadístico',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dorado,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<_Stats>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: AllinLoadingSiku(mensaje: 'Analizando métricas...'),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error al cargar estadísticas: ${snap.error}',
                style: AppText.body.copyWith(color: Colors.redAccent),
              ),
            );
          }
          final s = snap.data!;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
            children: [
              _seccionHeader('RESUMEN GENERAL', Icons.insights_rounded),
              const SizedBox(height: Sp.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.library_music_rounded,
                      value: '${s.totalCanciones}',
                      label: 'Canciones',
                    ),
                  ),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: StatCard(
                      icon: Icons.group_rounded,
                      value: '${s.totalUsuarios}',
                      label: 'Integrantes',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.play_circle_filled_rounded,
                      value: '${s.totalReproducciones}',
                      label: 'Reproducciones',
                    ),
                  ),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: StatCard(
                      icon: Icons.event_available_rounded,
                      value: '${s.totalEventos}',
                      label: 'Eventos',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.md),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.photo_library_rounded,
                      value: '${s.totalRecuerdos}',
                      label: 'Recuerdos',
                    ),
                  ),
                  const SizedBox(width: Sp.md),
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: Sp.xl),
              _seccionHeader('INTEGRANTES POR ROL', Icons.badge_rounded),
              const SizedBox(height: Sp.md),
              AppCard(
                glass: true,
                padding: const EdgeInsets.all(Sp.lg),
                child: Column(
                  children: s.usuariosPorRol.entries
                      .map((e) => _filaTexto(context, _labelRol(e.key), '${e.value}'))
                      .toList(),
                ),
              ),

              const SizedBox(height: Sp.xl),
              _seccionHeader('TOP 5 CANCIONES MÁS ENSAYADAS', Icons.local_fire_department_rounded),
              const SizedBox(height: Sp.md),
              AppCard(
                glass: true,
                padding: const EdgeInsets.all(Sp.lg),
                child: s.topCanciones.isEmpty ||
                        s.topCanciones.every((e) => e.value == 0)
                    ? Center(
                        child: Text(
                          'Aún no hay reproducciones registradas',
                          style: AppText.caption.copyWith(
                            color: AppColors.onSurfaceVariant(context),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        children: List.generate(
                          s.topCanciones.length,
                          (i) => _filaTop(
                            context,
                            i,
                            s.topCanciones[i].key,
                            s.topCanciones[i].value,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: Sp.xl),
              _seccionHeader('DISTRIBUCIÓN POR RITMO', Icons.graphic_eq_rounded),
              const SizedBox(height: Sp.md),
              AppCard(
                glass: true,
                padding: const EdgeInsets.all(Sp.lg),
                child: s.ritmos.isEmpty
                    ? Center(
                        child: Text(
                          'Sin canciones clasificadas',
                          style: AppText.caption.copyWith(
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        ),
                      )
                    : Column(
                        children: s.ritmos
                            .map((e) => _filaTexto(context, e.key, '${e.value}'))
                            .toList(),
                      ),
              ),

              const SizedBox(height: 60),
            ],
          );
        },
      ),
    );
  }

  Widget _seccionHeader(String titulo, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.dorado, size: 18),
        const SizedBox(width: Sp.sm),
        Text(
          titulo,
          style: AppText.label.copyWith(
            color: AppColors.dorado,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _filaTexto(BuildContext context, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.subtitle.copyWith(
                color: AppColors.onSurface(context),
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.granateProfundo,
              borderRadius: Rad.rPill,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.3),
              ),
            ),
            child: Text(
              valor,
              style: const TextStyle(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaTop(BuildContext context, int index, String titulo, int valor) {
    final medallas = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(medallas[index], style: const TextStyle(fontSize: 18)),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Text(
              titulo,
              style: AppText.subtitle.copyWith(
                color: AppColors.onSurface(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.dorado.withOpacity(0.15),
              borderRadius: Rad.rPill,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  size: 13,
                  color: AppColors.dorado,
                ),
                const SizedBox(width: 3),
                Text(
                  '$valor',
                  style: const TextStyle(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
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
        return 'Músicos Oficiales (Sikuris)';
      default:
        return 'Visitantes / Público';
    }
  }
}
