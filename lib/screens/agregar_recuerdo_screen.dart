// lib/screens/agregar_recuerdo_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../design/design.dart';
import '../models/recuerdo.dart';
import '../services/permisos_service.dart';
import '../services/recuerdo_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import '../widgets/recuerdos/recuerdo_form_media.dart';

class AgregarRecuerdoScreen extends StatefulWidget {
  final Recuerdo? recuerdo;
  const AgregarRecuerdoScreen({super.key, this.recuerdo});

  @override
  State<AgregarRecuerdoScreen> createState() => _AgregarRecuerdoScreenState();
}

class _AgregarRecuerdoScreenState extends State<AgregarRecuerdoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _service = RecuerdoService();
  final _storage = StorageService();

  List<String> _fotosUrls = [];
  List<String> _videosUrls = [];
  List<File> _fotosNuevas = [];
  List<File> _videosNuevos = [];
  bool _guardando = false;
  String _progreso = '';

  @override
  void initState() {
    super.initState();
    if (widget.recuerdo != null) {
      _tituloCtrl.text = widget.recuerdo!.titulo;
      _descripcionCtrl.text = widget.recuerdo!.descripcion;
      _fotosUrls = List.from(widget.recuerdo!.fotos);
      _videosUrls = List.from(widget.recuerdo!.videos);
    }
  }

  Future<void> _agregarFoto() async {
    if (!await PermisosService.pedirGaleria(context)) return;
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _fotosNuevas.add(File(x.path)));
  }

  Future<void> _agregarVideo() async {
    if (!await PermisosService.pedirVideos(context)) return;
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res != null && res.files.single.path != null) {
      setState(() => _videosNuevos.add(File(res.files.single.path!)));
    }
  }

  // LÓGICA PARA IMPORTAR DESDE DRIVE/PHOTOS
  Future<void> _importarDesdeNube() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media, // Permite tanto imágenes como videos
      );

      if (res != null && res.files.isNotEmpty) {
        setState(() {
          for (var file in res.files) {
            if (file.path == null) continue;
            final ext = file.extension?.toLowerCase() ?? '';
            if (['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)) {
              _fotosNuevas.add(File(file.path!));
            } else if (['mp4', 'mov', 'webm'].contains(ext)) {
              _videosNuevos.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al importar: $e')));
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final fotosSubidas = <String>[];
      for (var f in _fotosNuevas) {
        setState(() => _progreso = 'Subiendo foto...');
        fotosSubidas.add(await _storage.subirFoto(f, 'recuerdos'));
      }
      final videosSubidos = <String>[];
      for (var v in _videosNuevos) {
        setState(() => _progreso = 'Subiendo video...');
        videosSubidos.add(await _storage.subirVideo(v, 'recuerdos'));
      }
      final r = Recuerdo(
        id: widget.recuerdo?.id ?? '', titulo: _tituloCtrl.text.trim(), descripcion: _descripcionCtrl.text.trim(),
        fotos: [..._fotosUrls, ...fotosSubidas], videos: [..._videosUrls, ...videosSubidos],
        fecha: widget.recuerdo?.fecha, creadoPor: user.uid, creadorNombre: user.displayName ?? 'Admin',
      );
      if (widget.recuerdo == null) { await _service.agregar(r); } else { await _service.actualizar(widget.recuerdo!.id, r); }
      if (mounted) Navigator.pop(context);
    } finally { if (mounted) setState(() => _guardando = false); }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.recuerdo == null ? 'Nuevo Recuerdo' : 'Editar Recuerdo',
      actions: [
        IconButton(icon: const Icon(Icons.check), onPressed: _guardando ? null : _guardar),
      ],
      body: _guardando
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(color: AppColors.granate),
              const SizedBox(height: Sp.lg),
              Text(_progreso, style: AppType.subtitle),
            ]))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(Sp.lg),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(Sp.lg),
                    child: Column(
                      children: [
                        const SeccionHeader(title: 'Información', icon: Icons.info_outline, padding: EdgeInsets.zero),
                        const SizedBox(height: Sp.md),
                        AppInput(controller: _tituloCtrl, label: 'Título *', prefixIcon: Icons.title, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        const SizedBox(height: Sp.md),
                        AppInput(controller: _descripcionCtrl, label: 'Descripción', prefixIcon: Icons.description, maxLines: 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  RecuerdoFormMedia(
                    urlsFotos: _fotosUrls, urlsVideos: _videosUrls, fotosNuevas: _fotosNuevas, videosNuevos: _videosNuevos,
                    onAgregarFoto: _agregarFoto, onAgregarVideo: _agregarVideo,
                    onImportarNube: _importarDesdeNube, // <-- AÑADIDO
                    onEliminarFoto: (i, esNueva) => setState(() => esNueva ? _fotosNuevas.removeAt(i) : _fotosUrls.removeAt(i)),
                    onEliminarVideo: (i, esNuevo) => setState(() => esNuevo ? _videosNuevos.removeAt(i) : _videosUrls.removeAt(i)),
                  ),
                  const SizedBox(height: Sp.xl),
                  AppButton(label: 'GUARDAR RECUERDO', fullWidth: true, onPressed: _guardar),
                  const SizedBox(height: Sp.xxxl),
                ],
              ),
            ),
    );
  }
}