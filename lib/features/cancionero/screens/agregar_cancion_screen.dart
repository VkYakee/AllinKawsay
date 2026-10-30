// lib/features/cancionero/screens/agregar_cancion_screen.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';

import '../../../models/bloque_audio.dart';
import '../../../models/cancion.dart';
import '../../../models/categoria.dart';
import '../../../models/numerofonia.dart';

import '../../../services/cancion_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/permisos_service.dart';
import '../../../services/storage_service.dart';

// Widgets viejos que aún no migramos (traen su propio AppCard interno)
import '../../../widgets/editor_letras.dart';
import '../../../widgets/editor_numerofonia.dart';
import '../../../widgets/cancion_form/cancion_form_basico.dart';
import '../../../widgets/cancion_form/cancion_form_media.dart';
import '../../../screens/grabar_setlist_screen.dart';

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
  final _tagsCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  String _tipo = 'original';
  String _categoriaId = '';
  List<EstrofaNumerofonia> _estrofas = [];
  List<Letra> _letras = [];
  List<BloqueAudio> _setlist = [];
  String? _imagenUrl;
  String? _audioUrl;
  String? _audioNombre;

  bool _subiendoImagen = false;
  bool _subiendoAudio = false;
  bool _guardando = false;
  bool _cargandoCategorias = true;
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    CategoriaService().listar().listen((lista) {
      if (mounted) {
        setState(() {
          _categorias = lista;
          _cargandoCategorias = false;
        });
      }
    });
    if (widget.cancion != null) {
      final c = widget.cancion!;
      _tituloCtrl.text = c.titulo;
      _autorCtrl.text = c.autor;
      _ritmoCtrl.text = c.ritmo;
      _regionCtrl.text = c.region;
      _tagsCtrl.text = c.tags.join(', ');
      _videoCtrl.text = c.videoUrl;
      _tipo = c.tipo;
      _categoriaId = c.categoriaId;
      _imagenUrl = c.imagenUrl.isNotEmpty ? c.imagenUrl : null;
      _audioUrl = c.audioUrl.isNotEmpty ? c.audioUrl : null;
      _estrofas = c.estrofas.map((e) => e.copy()).toList();
      _letras = c.letras.map((l) => l.copy()).toList();
      _setlist = c.setlist.map((b) => b.copy()).toList();
    }
    if (_letras.isEmpty) _letras.add(Letra());
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _autorCtrl.dispose();
    _ritmoCtrl.dispose();
    _regionCtrl.dispose();
    _tagsCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  Future<void> _subirImagen() async {
    if (!await PermisosService.pedirGaleria(context)) return;
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() => _subiendoImagen = true);
    try {
      _imagenUrl = await StorageService()
          .subirFoto(File(x.path), 'imagenes_canciones');
    } finally {
      if (mounted) setState(() => _subiendoImagen = false);
    }
  }

  Future<void> _subirAudio() async {
    if (!await PermisosService.pedirAudio(context)) return;
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res == null || res.files.single.path == null) return;
    setState(() => _subiendoAudio = true);
    try {
      _audioUrl = await StorageService().subirAudio(
        File(res.files.single.path!),
        widget.cancion?.id ?? 'nueva',
      );
      _audioNombre = res.files.single.name;
    } finally {
      if (mounted) setState(() => _subiendoAudio = false);
    }
  }

  Future<void> _abrirSetlist() async {
    if (_audioUrl == null) return;
    final c = Cancion(
      id: widget.cancion?.id ?? '',
      titulo: _tituloCtrl.text,
      autor: _autorCtrl.text,
      tipo: _tipo,
      ritmo: _ritmoCtrl.text,
      region: _regionCtrl.text,
      numerofonia: '',
      estrofas: _estrofas,
      letra: '',
      letras: _letras,
      setlist: _setlist,
      imagenUrl: _imagenUrl ?? '',
      audioUrl: _audioUrl!,
      descripcion: '',
      tags: [],
      creadoPor: '',
      creadorNombre: '',
    );
    final r = await Navigator.push<List<BloqueAudio>>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarSetlistScreen(
          cancion: c,
          setlistInicial: _setlist,
        ),
      ),
    );
    if (r != null && mounted) setState(() => _setlist = r);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final c = Cancion(
        id: widget.cancion?.id ?? '',
        titulo: _tituloCtrl.text.trim(),
        autor: _autorCtrl.text.trim(),
        tipo: _tipo,
        ritmo: _ritmoCtrl.text.trim(),
        region: _regionCtrl.text.trim(),
        numerofonia: '',
        estrofas: _estrofas,
        letra: _letras.map((l) => l.texto).join('\n\n'),
        letras: _letras,
        setlist: _setlist,
        imagenUrl: _imagenUrl ?? '',
        audioUrl: _audioUrl ?? '',
        videoUrl: _videoCtrl.text.trim(),
        descripcion: '',
        tags: _tagsCtrl.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        categoriaId: _categoriaId,
        creadoPor: widget.cancion?.creadoPor ?? user.uid,
        creadorNombre: widget.cancion?.creadorNombre ??
            user.displayName ??
            'Admin',
        reproducciones: widget.cancion?.reproducciones ?? 0,
      );
      if (widget.cancion == null) {
        await CancionService().agregar(c);
      } else {
        await CancionService()
            .actualizar(widget.cancion!.id, c.toMapEditar());
      }
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          widget.cancion == null ? 'Nueva Canción' : 'Editar Canción',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.fondoOscuro,
        iconTheme: const IconThemeData(color: AppColors.dorado),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.dorado),
            onPressed: _guardando ? null : _guardar,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Sp.lg),
          children: [
            // Información básica — el widget viejo ya trae AppCard interno
            CancionFormBasico(
              tituloCtrl: _tituloCtrl,
              autorCtrl: _autorCtrl,
              ritmoCtrl: _ritmoCtrl,
              regionCtrl: _regionCtrl,
              tagsCtrl: _tagsCtrl,
              tipo: _tipo,
              onTipoChanged: (v) => setState(() => _tipo = v),
              categoriaId: _categoriaId,
              categorias: _categorias,
              cargandoCategorias: _cargandoCategorias,
              onCategoriaChanged: (v) =>
                  setState(() => _categoriaId = v ?? ''),
            ),
            const SizedBox(height: Sp.md),

            // Numerofonía — envuelta en AppCard(glass)
            AppCard(
              glass: true,
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NUMEROFONÍA',
                    style: AppText.label.copyWith(
                      color: AppColors.dorado,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: Sp.sm),
                  EditorNumerofonia(
                    estrofas: _estrofas,
                    onChanged: (v) => _estrofas = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.md),

            // Letras — envuelta en AppCard(glass)
            AppCard(
              glass: true,
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LETRAS',
                    style: AppText.label.copyWith(
                      color: AppColors.dorado,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: Sp.sm),
                  EditorLetras(letras: _letras),
                ],
              ),
            ),
            const SizedBox(height: Sp.md),

            // Multimedia — el widget viejo ya trae AppCard interno
            CancionFormMedia(
              imagenUrl: _imagenUrl,
              audioUrl: _audioUrl,
              audioNombre: _audioNombre,
              subiendoImagen: _subiendoImagen,
              subiendoAudio: _subiendoAudio,
              onSubirImagen: _subirImagen,
              onSubirAudio: _subirAudio,
              onLimpiarImagen: () => setState(() => _imagenUrl = null),
              onLimpiarAudio: () => setState(() {
                _audioUrl = null;
                _setlist = [];
              }),
              videoCtrl: _videoCtrl,
            ),
            const SizedBox(height: Sp.md),

            // Setlist
            AppButton(
              label: 'MARCAR SETLIST',
              icon: Icons.queue_music,
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: _audioUrl != null ? _abrirSetlist : null,
            ),
            const SizedBox(height: Sp.xxl),

            // Guardar
            AppButton(
              label: _guardando ? 'GUARDANDO...' : 'GUARDAR CANCIÓN',
              fullWidth: true,
              loading: _guardando,
              onPressed: _guardar,
            ),
            const SizedBox(height: Sp.xxxl),
          ],
        ),
      ),
    );
  }
}