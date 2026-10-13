import 'package:flutter/material.dart';
import '../models/info_version.dart';
import '../services/github_service.dart';
import '../services/update_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/seccion_card.dart';

class GestionActualizacionesScreen extends StatefulWidget {
  const GestionActualizacionesScreen({super.key});

  @override
  State<GestionActualizacionesScreen> createState() =>
      _GestionActualizacionesScreenState();
}

class _GestionActualizacionesScreenState
    extends State<GestionActualizacionesScreen> {
  InfoVersion? _actual;
  List<ReleaseInfo> _releases = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final actual = await UpdateService.actual();
      final releases = await GithubService.listarConApk(limite: 20);
      if (!mounted) return;
      setState(() {
        _actual = actual;
        _releases = releases;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _desactivar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Desactivar actualización',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: const Text(
            'Se borrará el aviso de actualización. Ningún usuario '
            'recibirá el diálogo hasta que apruebes otra versión. '
            '¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await UpdateService.desactivar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aviso de actualización desactivado')),
      );
      await _cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
Future<void> _aprobarRelease(ReleaseInfo r) async {
  final notasCtrl = TextEditingController(text: r.notas);
  bool critica = false;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dorado,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'APROBAR ${r.tag}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.seccionTitulo(context),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Build ${r.build} · ${r.tamanoMb} MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(ctx)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: notasCtrl,
                  maxLines: 4,
                  minLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas / novedades (opcional)',
                    hintText:
                        'Ej: Correcciones en numerofonía, mejoras de rendimiento...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: critica,
                  activeColor: AppColors.granate,
                  title: const Text('Actualización CRÍTICA',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                      'Los usuarios NO podrán posponerla',
                      style: TextStyle(fontSize: 11)),
                  onChanged: (v) => setSheet(() => critica = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('APROBAR Y PUBLICAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        )),
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  if (ok != true) return;

  try {
    await UpdateService.aprobar(InfoVersion(
      build: r.build,
      version: r.versionLegible,
      url: r.urlApk,
      critica: critica,
      notas: notasCtrl.text.trim(),
      aprobadaPor: 'admin',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${r.tag} aprobada')),
    );
    await _cargar();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
Future<void> _simular() async {
  if (_releases.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('No hay releases con APK para simular')),
    );
    return;
  }

  final buildCtrl = TextEditingController(text: '99999');
  final notasCtrl = TextEditingController(
      text: 'PRUEBA de flujo de actualización. Ignorar.');
  String urlSeleccionada = _releases.first.urlApk;
  bool critica = false;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dorado,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'SIMULAR ACTUALIZACIÓN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.seccionTitulo(context),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escribe un build ficticio mayor al instalado. '
                  'Después reiniciá la app para ver el diálogo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: buildCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Build ficticio',
                    hintText: '99999',
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: urlSeleccionada,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'APK a usar',
                    prefixIcon: Icon(Icons.android),
                  ),
                  items: _releases
                      .map((r) => DropdownMenuItem(
                            value: r.urlApk,
                            child: Text(
                              '${r.tag} · ${r.tamanoMb} MB',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setSheet(() => urlSeleccionada = v);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notasCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: critica,
                  activeColor: AppColors.granate,
                  title: const Text('Marcar como CRÍTICA'),
                  onChanged: (v) => setSheet(() => critica = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('SIMULAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        )),
                    onPressed: () {
                      final b = int.tryParse(buildCtrl.text.trim());
                      if (b == null || b <= 0) return;
                      Navigator.pop(ctx, true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  if (ok != true) return;

  final buildNum = int.tryParse(buildCtrl.text.trim()) ?? 0;
  if (buildNum <= 0) return;

  try {
    await UpdateService.aprobar(InfoVersion(
      build: buildNum,
      version: 'PRUEBA',
      url: urlSeleccionada,
      critica: critica,
      notas: notasCtrl.text.trim(),
      aprobadaPor: 'admin (simulado)',
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Simulación activa: build $buildNum. Cerrá y reabrí la app.'),
        duration: const Duration(seconds: 5),
      ),
    );
    await _cargar();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTUALIZACIONES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargando ? null : _cargar,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate))
          : _error != null
              ? _buildError(onSurface)
              : RefreshIndicator(
                  onRefresh: _cargar,
                  color: AppColors.dorado,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSeccionActual(onSurface),
                      const SizedBox(height: 20),
                      _buildSeccionPrueba(onSurface),
                      const SizedBox(height: 20),
                      _buildSeccionReleases(onSurface),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError(Color onSurface) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error',
              textAlign: TextAlign.center,
              style: TextStyle(color: onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionActual(Color onSurface) {
    return SeccionCard(
      icono: Icons.verified,
      titulo: 'VERSIÓN APROBADA ACTUAL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_actual == null)
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: onSurface.withOpacity(0.5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ninguna versión aprobada. '
                    'Los usuarios no reciben aviso.',
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            Text(
              'v${_actual!.version}.${_actual!.build}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.seccionTitulo(context),
                letterSpacing: 1,
              ),
            ),
            if (_actual!.critica) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: const Text('CRÍTICA',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 2,
                    )),
              ),
            ],
            if (_actual!.notas.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _actual!.notas,
                style: TextStyle(
                  fontSize: 13,
                  color: onSurface.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Aprobada por: ${_actual!.aprobadaPor}',
              style: TextStyle(
                fontSize: 11,
                color: onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _desactivar,
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
                label: const Text('DESACTIVAR',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    )),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeccionPrueba(Color onSurface) {
    return SeccionCard(
      icono: Icons.science,
      titulo: 'MODO PRUEBA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escribí un build ficticio para probar el flujo sin '
            'romper el versionado real. Después de simular, cerrá y '
            'reabrí la app para ver el diálogo.',
            style: TextStyle(
              fontSize: 12,
              color: onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _simular,
              icon: const Icon(Icons.play_arrow,
                  size: 18, color: AppColors.granate),
              label: const Text('SIMULAR ACTUALIZACIÓN',
                  style: TextStyle(
                    color: AppColors.granate,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  )),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.granate.withOpacity(0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionReleases(Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.cloud_download,
                    size: 14, color: AppColors.seccionTitulo(context)),
              ),
              const SizedBox(width: 10),
              Text(
                'RELEASES DISPONIBLES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.seccionTitulo(context),
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        if (_releases.isEmpty)
          SeccionCard(
            icono: Icons.inbox,
            titulo: 'SIN RELEASES',
            child: Text(
              'No se encontraron releases con APK en el repo.',
              style: TextStyle(
                  color: onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                  fontSize: 13),
            ),
          )
        else
          ..._releases.map((r) => _buildTarjetaRelease(r, onSurface)),
      ],
    );
  }

  Widget _buildTarjetaRelease(ReleaseInfo r, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.android,
                      color: AppColors.dorado, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.tag,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Build ${r.build} · ${r.tamanoMb} MB',
                        style: TextStyle(
                          fontSize: 11,
                          color: onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                if (r.prerelease)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.dorado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.5)),
                    ),
                    child: const Text('PRE',
                        style: TextStyle(
                          color: AppColors.dorado,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 1,
                        )),
                  ),
              ],
            ),
            if (r.fecha != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 11, color: onSurface.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text(
                    '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () => _aprobarRelease(r),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('APROBAR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}