import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../models/cancion.dart';
import '../models/categoria.dart';
import '../models/numerofonia.dart';
import '../services/cancion_service.dart';
import '../services/categoria_service.dart';
import '../services/permisos_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import '../widgets/editor_letras.dart';
import '../widgets/editor_numerofonia.dart';

class AgregarCancionScreen extends StatefulWidget {
  final Cancion? cancion;
  const AgregarCancionScreen({super.key, this.cancion});

  @override
  State<AgregarCancionScreen> createState() => _AgregarCancionScreenState();
}

class _AgregarCancionScreenState extends State<AgregarCancionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _ritmoCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String _tipo = 'original';
  String _categoriaId = '';
  List<EstrofaNumerofonia> _numerofoniaEstrofas = [];
  List<Letra> _letras = [];
  String? _imagenUrl;
  String? _audioUrl;
  String? _audioNombre;

  bool _subiendoImagen = false;
  bool _subiendoAudio = false;
  bool _guardando = false;
  bool _cargandoCategorias = true;

  List<Categoria> _categorias = [];
  StreamSubscription<List<Categoria>>? _categoriasSub;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    if (widget.cancion != null) {
      final c = widget.cancion!;
      _tituloCtrl.text = c.titulo;
      _autorCtrl.text = c.autor;
      _ritmoCtrl.text = c.ritmo;
      _regionCtrl.text = c.region;
      _descripcionCtrl.text = c.descripcion;
      _videoCtrl.text = c.videoUrl;
      _tagsCtrl.text = c.tags.join(', ');
      _tipo = c.tipo;
      _categoriaId = c.categoriaId;
      _imagenUrl = c.imagenUrl.isNotEmpty ? c.imagenUrl : null;
      _audioUrl = c.audioUrl.isNotEmpty ? c.audioUrl : null;
      _numerofoniaEstrofas = c.estrofas.map((e) => e.copy()).toList();
      _letras = c.letras.map((l) => l.copy()).toList();
    }
    if (_letras.isEmpty) _letras.add(Letra());
  }

  void _cargarCategorias() {
    _categoriasSub?.cancel();
    _categoriasSub = CategoriaService().listar().listen(
      (lista) {
        if (mounted) {
          setState(() {
            _categorias = lista;
            _cargandoCategorias = false;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _cargandoCategorias = false);
      },
    );
  }

  @override
  void dispose() {
    _categoriasSub?.cancel();
    _tituloCtrl.dispose();
    _autorCtrl.dispose();
    _ritmoCtrl.dispose();
    _regionCtrl.dispose();
    _descripcionCtrl.dispose();
    _videoCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    // Pedir permiso de galería primero
    final ok = await PermisosService.pedirGaleria(context);
    if (!ok || !mounted) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    setState(() => _subiendoImagen = true);
    try {
      final url = await StorageService()
          .subirFoto(File(file.path), 'imagenes_canciones');
      if (mounted) setState(() => _imagenUrl = url);
    } catch (e) {
      if (mounted) _error('No se pudo subir la imagen: $e');
    } finally {
      if (mounted) setState(() => _subiendoImagen = false);
    }
  }

  Future<void> _seleccionarAudio() async {
    // Pedir permiso de audio primero
    final ok = await PermisosService.pedirAudio(context);
    if (!ok || !mounted) return;

    final res = await FilePicker.platform
        .pickFiles(type: FileType.audio, allowMultiple: false);
    if (res == null || res.files.isEmpty || res.files.single.path == null) {
      return;
    }

    final path = res.files.single.path!;
    setState(() => _subiendoAudio = true);

    try {
      final url = await StorageService()
          .subirAudio(File(path), widget.cancion?.id ?? 'nueva');
      if (mounted) {
        setState(() {
          _audioUrl = url;
          _audioNombre = res.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) _error('No se pudo subir el audio: $e');
    } finally {
      if (mounted) setState(() => _subiendoAudio = false);
    }
  }

  void _error(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error('Debes iniciar sesión para guardar');
      return;
    }

    setState(() => _guardando = true);
    try {
      final tags = _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      final letraPlana = _letras.map((l) => l.texto).join('\n\n');

      final esEdicion = widget.cancion != null;
      final creadoPor =
          esEdicion ? widget.cancion!.creadoPor : user.uid;
      final creadorNombre = esEdicion
          ? widget.cancion!.creadorNombre
          : (user.displayName ?? user.email ?? 'Usuario');

      final cancion = Cancion(
        id: widget.cancion?.id ?? '',
        titulo: _tituloCtrl.text.trim(),
        autor: _autorCtrl.text.trim(),
        tipo: _tipo,
        ritmo: _ritmoCtrl.text.trim(),
        region: _regionCtrl.text.trim(),
        numerofonia: '',
        estrofas: _numerofoniaEstrofas,
        letra: letraPlana,
        letras: _letras,
        imagenUrl: _imagenUrl ?? '',
        audioUrl: _audioUrl ?? '',
        videoUrl: _videoCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        tags: tags,
        categoriaId: _categoriaId,
        creadoPor: creadoPor,
        creadorNombre: creadorNombre,
        reproducciones: widget.cancion?.reproducciones ?? 0,
      );

      if (esEdicion) {
        await CancionService()
            .actualizar(widget.cancion!.id, cancion.toMapEditar());
      } else {
        await CancionService().agregar(cancion);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _error('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
@override
Widget build(BuildContext context) {
  final esEdicion = widget.cancion != null;
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return Scaffold(
    appBar: AppBar(
      title: Text(esEdicion ? 'Editar canción' : 'Nueva canción'),
      actions: [
        if (_guardando)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: AppColors.dorado, strokeWidth: 2),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.dorado),
            tooltip: 'Guardar',
            onPressed: _guardar,
          ),
      ],
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _seccion('INFO BÁSICA', Icons.info_outline, [
            _campo(_tituloCtrl, 'Título *', obligatorio: true),
            const SizedBox(height: 12),
            _campo(_autorCtrl, 'Autor'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _campo(_ritmoCtrl, 'Ritmo')),
                const SizedBox(width: 12),
                Expanded(child: _campo(_regionCtrl, 'Región')),
              ],
            ),
            const SizedBox(height: 16),
            _selectorTipo(),
            const SizedBox(height: 12),
            _cargandoCategorias
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          color: AppColors.granate, strokeWidth: 2),
                    ),
                  )
                : _selectorCategoria(),
            const SizedBox(height: 12),
            _campo(_tagsCtrl, 'Tags',
                hint: 'ej: huayño, festivo, tradicional'),
          ]),
          const SizedBox(height: 20),

          _seccion('NUMEROFONÍA', Icons.grid_on, [
            EditorNumerofonia(
              estrofas: _numerofoniaEstrofas,
              onChanged: (v) =>
                  setState(() => _numerofoniaEstrofas = v),
            ),
          ]),
          const SizedBox(height: 20),

          _seccion('LETRAS', Icons.lyrics_outlined, [
            EditorLetras(letras: _letras),
          ]),
          const SizedBox(height: 20),

          _seccion('DESCRIPCIÓN', Icons.notes, [
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 4,
              style: TextStyle(color: onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Descripción breve de la canción...',
                hintStyle:
                    TextStyle(color: onSurface.withOpacity(0.4)),
                filled: true,
                fillColor: AppColors.granate.withOpacity(0.04),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          _seccion('AUDIO', Icons.music_note, [_bloqueAudio(onSurface)]),
          const SizedBox(height: 20),

          _seccion('IMAGEN (opcional)', Icons.image,
              [_bloqueImagen(onSurface)]),
          const SizedBox(height: 20),

          _seccion('VIDEO YOUTUBE (opcional)',
              Icons.play_circle_outline, [
            _campo(_videoCtrl, 'Link de YouTube',
                hint: 'https://youtube.com/watch?v=...'),
          ]),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.dorado, strokeWidth: 2),
                    )
                  : const Icon(Icons.save, color: AppColors.dorado),
              label: Text(
                esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR CANCIÓN',
                style: const TextStyle(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.granate,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}

Widget _seccion(String titulo, IconData icono, List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardColor(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: AppColors.granate, size: 14),
            ),
            const SizedBox(width: 10),
            Text(titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    fontSize: 12,
                    letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}

Widget _campo(TextEditingController ctrl, String label,
    {String? hint, bool obligatorio = false}) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return TextFormField(
    controller: ctrl,
    style: TextStyle(color: onSurface, fontSize: 14),
    validator: obligatorio
        ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
        : null,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.granate, fontSize: 13),
      hintStyle:
          TextStyle(color: onSurface.withOpacity(0.4), fontSize: 13),
      filled: true,
      fillColor: AppColors.granate.withOpacity(0.04),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

Widget _selectorTipo() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.granate.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tipo = 'original'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _tipo == 'original'
                    ? AppColors.granate
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ORIGINAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _tipo == 'original'
                        ? AppColors.dorado
                        : AppColors.granate,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tipo = 'adaptacion'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _tipo == 'adaptacion'
                    ? AppColors.granate
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ADAPTACIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _tipo == 'adaptacion'
                        ? AppColors.dorado
                        : AppColors.granate,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _selectorCategoria() {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return DropdownButtonFormField<String>(
    value: _categorias.any((c) => c.id == _categoriaId)
        ? _categoriaId
        : null,
    isExpanded: true,
    dropdownColor: AppColors.cardColor(context),
    style: TextStyle(color: onSurface, fontSize: 14),
    decoration: InputDecoration(
      labelText: 'Categoría',
      labelStyle: const TextStyle(color: AppColors.granate, fontSize: 13),
      filled: true,
      fillColor: AppColors.granate.withOpacity(0.04),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    items: [
      const DropdownMenuItem<String>(
        value: '',
        child: Text('Sin categoría',
            style: TextStyle(fontStyle: FontStyle.italic)),
      ),
      ..._categorias.map((c) => DropdownMenuItem<String>(
            value: c.id,
            child: Text('${c.emoji} ${c.nombre}'),
          )),
    ],
    onChanged: (v) => setState(() => _categoriaId = v ?? ''),
  );
}
  Widget _bloqueAudio(Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_audioUrl != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.dorado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.dorado.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.granate,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.audiotrack,
                      color: AppColors.dorado, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Audio cargado',
                          style: TextStyle(
                              color: AppColors.granate,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1)),
                      if (_audioNombre != null)
                        Text(_audioNombre!,
                            style: TextStyle(
                                color: onSurface.withOpacity(0.7),
                                fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.granate, size: 20),
                  onPressed: () => setState(() {
                    _audioUrl = null;
                    _audioNombre = null;
                  }),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _subiendoAudio ? null : _seleccionarAudio,
              icon: _subiendoAudio
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.granate, strokeWidth: 2))
                  : const Icon(Icons.upload_file,
                      color: AppColors.granate),
              label: Text(
                _subiendoAudio ? 'SUBIENDO...' : 'SUBIR AUDIO (MP3)',
                style: const TextStyle(
                    color: AppColors.granate,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 11),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.granate.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _bloqueImagen(Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_imagenUrl != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _imagenUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.granate.withOpacity(0.1),
                    child: const Icon(Icons.broken_image,
                        color: AppColors.granate, size: 48),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColors.granate, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.dorado, size: 18),
                    onPressed: () => setState(() => _imagenUrl = null),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _subiendoImagen ? null : _seleccionarImagen,
            icon: _subiendoImagen
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: AppColors.granate, strokeWidth: 2))
                : const Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.granate),
            label: Text(
              _subiendoImagen
                  ? 'SUBIENDO...'
                  : (_imagenUrl != null
                      ? 'CAMBIAR IMAGEN'
                      : 'AGREGAR IMAGEN (opcional)'),
              style: const TextStyle(
                  color: AppColors.granate,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 11),
            ),
            style: OutlinedButton.styleFrom(
              side:
                  BorderSide(color: AppColors.granate.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}