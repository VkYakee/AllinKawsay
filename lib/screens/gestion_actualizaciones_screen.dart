// lib/screens/gestion_actualizaciones_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/info_version.dart';
import '../services/github_service.dart';
import '../services/update_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/dialogo_descarga_apk.dart';

class GestionActualizacionesScreen extends StatefulWidget {
  const GestionActualizacionesScreen({super.key});

  @override
  State<GestionActualizacionesScreen> createState() => _GestionActualizacionesScreenState();
}

class _GestionActualizacionesScreenState extends State<GestionActualizacionesScreen> {
  InfoVersion? _actual;
  List<ReleaseInfo> _releases = [];
  bool _cargando = true;
  bool _esDev = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final usuario = await UsuarioService().miUsuarioActual();
      final esDev = usuario?.esDev ?? false;
      final actual = await UpdateService.actual();
      final releases = esDev ? await GithubService.listarTodas(limite: 30) : await GithubService.listarEstables(limite: 30);
      if (mounted) setState(() { _actual = actual; _releases = releases; _esDev = esDev; _cargando = false; });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _promoverRelease(ReleaseInfo r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Promover a Release'),
        content: Text('¿Convertir ${r.tag} en un release estable? Los administradores podrán aprobarlo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Promover')),
        ],
      ),
    );
    if (ok == true) {
      final success = await GithubService.promoverAEstable(r.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Promovido con éxito' : 'Error al promover')));
        if (success) _cargar();
      }
    }
  }

  Future<void> _aprobarRelease(ReleaseInfo r) async {
    try {
      await UpdateService.aprobar(InfoVersion(
        build: r.build, version: r.versionLegible, url: r.urlApk, critica: false, notas: r.notas, aprobadaPor: 'admin',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actualización aprobada')));
        _cargar();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Actualizaciones',
      actions: [
        if (_esDev) const Padding(padding: EdgeInsets.only(right: 8), child: Center(child: Text('DEV', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)))),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _cargando ? null : _cargar),
      ],
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.granate))
          : ListView(
              padding: const EdgeInsets.all(Sp.lg),
              children: [
                if (_actual != null)
                  AppCard(
                    color: AppColors.granate,
                    child: Column(
                      children: [
                        Text('VERSIÓN APROBADA', style: AppType.eyebrow.copyWith(color: AppColors.dorado)),
                        const SizedBox(height: Sp.xs),
                        Text('v${_actual!.displayVersion}', style: AppType.h2.copyWith(color: AppColors.dorado)),
                      ],
                    ),
                  ),
                const SizedBox(height: Sp.lg),
                const SeccionHeader(title: 'Lanzamientos', icon: Icons.cloud_download, padding: EdgeInsets.zero),
                const SizedBox(height: Sp.md),
                ..._releases.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: Sp.sm),
                      child: AppCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(r.prerelease ? Icons.science : Icons.android, color: r.prerelease ? Colors.orange : AppColors.granate),
                                const SizedBox(width: Sp.sm),
                                Expanded(child: Text(r.tag, style: AppType.subtitle)),
                                if (r.prerelease) AppBadge(label: 'BETA', variant: AppBadgeVariant.warning),
                              ],
                            ),
                            const SizedBox(height: Sp.md),
                            Row(
                              children: [
                                Expanded(child: AppButton(label: 'DESCARGAR', variant: AppButtonVariant.secondary, onPressed: () => DialogoDescargaApk.mostrar(context, url: r.urlApk, nombre: 'app.apk', versionLegible: r.versionLegible))),
                                const SizedBox(width: Sp.sm),
                                if (r.prerelease && _esDev)
                                  Expanded(child: AppButton(label: 'PROMOVER', icon: Icons.upgrade, variant: AppButtonVariant.secondary, onPressed: () => _promoverRelease(r)))
                                else if (!r.prerelease)
                                  Expanded(child: AppButton(label: 'APROBAR', icon: Icons.check, onPressed: () => _aprobarRelease(r))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}