import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recuerdo.dart';
import '../services/recuerdo_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';

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
  bool get _esEdicion => widget.recuerdo != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _tituloCtrl.text = widget.recuerdo!.titulo;
      _descripcionCtrl.text = widget.recuerdo!.descripcion;
      _fotosUrls = List.from(widget.recuerdo!.fotos);
      _videosUrls = List.from(widget.recuerdo!.videos);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (imagen != null) {
      setState(() {
        _fotosNuevas.add(File(imagen.path));
      });
    }
  }

  Future<void> _agregarVideo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (resultado != null && resultado.files.isNotEmpty) {
      setState(() {
        _videosNuevos.add(File(resultado.files.first.path!));
      });
    }
  }

  void _eliminarFoto(int index, bool esNueva) {
    setState(() {
      if (esNueva) {
        _fotosNuevas.removeAt(index);
      } else {
        _fotosUrls.removeAt(index - _fotosNuevas.length);
      }
    });
  }

  void _eliminarVideo(int index, bool esNuevo) {
    setState(() {
      if (esNuevo) {
        _videosNuevos.removeAt(index);
      } else {
        _videosUrls.removeAt(index - _videosNuevos.length);
      }
    });
  }
Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _progreso = 'Subiendo archivos...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final fotosSubidas = <String>[];
      for (int i = 0; i < _fotosNuevas.length; i++) {
        setState(() => _progreso = 'Subiendo foto ${i + 1}/${_fotosNuevas.length}...');
        final url = await _storage.subirFoto(_fotosNuevas[i], 'recuerdos');
        fotosSubidas.add(url);
      }

      final videosSubidos = <String>[];
      for (int i = 0; i < _videosNuevos.length; i++) {
        setState(() => _progreso = 'Subiendo video ${i + 1}/${_videosNuevos.length}...');
        final url = await _storage.subirVideo(_videosNuevos[i], 'recuerdos');
        videosSubidos.add(url);
      }

      final todasFotos = [..._fotosUrls, ...fotosSubidas];
      final todosVideos = [..._videosUrls, ...videosSubidos];

      setState(() => _progreso = 'Guardando en base de datos...');

      final nuevoRecuerdo = Recuerdo(
        id: _esEdicion ? widget.recuerdo!.id : '',
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        fotos: todasFotos,
        videos: todosVideos,
        fecha: _esEdicion ? widget.recuerdo!.fecha : null,
        fechaCreacion: _esEdicion ? widget.recuerdo!.fechaCreacion : null,
        creadoPor: user.uid,
        creadorNombre: user.displayName ?? 'Usuario',
      );

      if (_esEdicion) {
        await _service.actualizar(widget.recuerdo!.id, nuevoRecuerdo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recuerdo actualizado correctamente'),
              backgroundColor: AppColors.dorado,
            ),
          );
        }
      } else {
        await _service.agregar(nuevoRecuerdo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recuerdo creado correctamente'),
              backgroundColor: AppColors.dorado,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
          _progreso = '';
        });
      }
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'EDITAR RECUERDO' : 'NUEVO RECUERDO'),
      ),
      body: _guardando
          ? _pantallaProgreso()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Ej: Fiesta patronal 2024',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'El título es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Cuenta la historia detrás de este recuerdo...',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _seccionMultimedia(
                    titulo: 'FOTOS',
                    icono: Icons.photo_library,
                    urlsExistentes: _fotosUrls,
                    archivosNuevos: _fotosNuevas,
                    onAgregar: _agregarFoto,
                    onEliminar: _eliminarFoto,
                    esImagen: true,
                  ),
                  const SizedBox(height: 24),
                  _seccionMultimedia(
                    titulo: 'VIDEOS',
                    icono: Icons.video_library,
                    urlsExistentes: _videosUrls,
                    archivosNuevos: _videosNuevos,
                    onAgregar: _agregarVideo,
                    onEliminar: _eliminarVideo,
                    esImagen: false,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text(_guardando ? 'GUARDANDO...' : (_esEdicion ? 'ACTUALIZAR' : 'GUARDAR')),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.granate,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
Widget _pantallaProgreso() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.dorado),
          const SizedBox(height: 24),
          Text(
            _progreso,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por favor espera...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _seccionMultimedia({
    required String titulo,
    required IconData icono,
    required List<String> urlsExistentes,
    required List<File> archivosNuevos,
    required VoidCallback onAgregar,
    required Function(int, bool) onEliminar,
    required bool esImagen,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: AppColors.granate, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '$titulo (${urlsExistentes.length + archivosNuevos.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onAgregar,
                icon: const Icon(Icons.add_circle, color: AppColors.dorado),
                tooltip: 'Agregar ${esImagen ? "foto" : "video"}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (urlsExistentes.isEmpty && archivosNuevos.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      esImagen ? Icons.photo_camera_outlined : Icons.videocam_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sin ${esImagen ? "fotos" : "videos"} aún',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < archivosNuevos.length; i++)
                  _previewItem(
                    esNuevo: true,
                    esImagen: esImagen,
                    file: archivosNuevos[i],
                    onEliminar: () => onEliminar(i, true),
                  ),
                for (int i = 0; i < urlsExistentes.length; i++)
                  _previewItem(
                    esNuevo: false,
                    esImagen: esImagen,
                    url: urlsExistentes[i],
                    onEliminar: () => onEliminar(i, false),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _previewItem({
    required bool esNuevo,
    required bool esImagen,
    File? file,
    String? url,
    required VoidCallback onEliminar,
  }) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.withOpacity(0.2),
            border: Border.all(
              color: esNuevo ? AppColors.dorado : AppColors.dorado.withOpacity(0.3),
              width: esNuevo ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: esImagen
                ? (file != null
                    ? Image.file(file, fit: BoxFit.cover)
                    : Image.network(url!, fit: BoxFit.cover))
                : Center(
                    child: Icon(
                      Icons.videocam,
                      color: AppColors.dorado,
                      size: 32,
                    ),
                  ),
          ),
        ),
        if (esNuevo)
          Positioned(
            top: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.dorado,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload, color: Colors.white, size: 14),
            ),
          ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onEliminar,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}