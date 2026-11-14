// lib/features/cancionero/screens/crear_cancion_rapida_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_dialog.dart';
import '../../../core/components/allin_input.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/atril_numerofonia.dart';
import '../../../models/cancion.dart';
import '../../../models/categoria.dart';
import '../../../models/numerofonia.dart';
import '../../../services/cancion_service.dart';
import '../../../services/categoria_service.dart';
import '../../../services/permisos_service.dart';
import '../../../services/storage_service.dart';

class CrearCancionRapidaScreen extends StatefulWidget {
  final Cancion? cancionExistente;
  const CrearCancionRapidaScreen({super.key, this.cancionExistente});

  @override
  State<CrearCancionRapidaScreen> createState() =>
      _CrearCancionRapidaScreenState();
}

class _CrearCancionRapidaScreenState extends State<CrearCancionRapidaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _tituloCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _ritmoCtrl = TextEditingController();
  final _numerofoniaTextoCtrl = TextEditingController();
  final _letraCtrl = TextEditingController();

  String _categoriaId = '';
  List<Categoria> _categorias = [];
  bool _cargandoCategorias = true;

  File? _audioLocal;
  String? _audioNombre;
  String? _audioUrl;

  File? _imagenLocal;
  String? _imagenUrl;

  bool _subiendo = false;
  String _estadoSubida = '';

  // Lista de estrofas parseadas en vivo
  List<EstrofaNumerofonia> _estrofasParseadas = [];

  static const List<String> _ritmosSugeridos = [
    'Huayño',
    'Sikumoreno',
    'Ayarachi',
    'Kantu',
    'Chacota',
    'Diana',
    'Ligero',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));

    _numerofoniaTextoCtrl.addListener(_parsearEnVivo);

    _cargarCategorias();

    if (widget.cancionExistente != null) {
      _cargarDatosExistentes(widget.cancionExistente!);
    } else {
      _verificarBorrador();
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _tituloCtrl.dispose();
    _autorCtrl.dispose();
    _ritmoCtrl.dispose();
    _numerofoniaTextoCtrl.dispose();
    _letraCtrl.dispose();
    super.dispose();
  }

  void _cargarCategorias() {
    CategoriaService().listar().listen((lista) {
      if (mounted) {
        setState(() {
          _categorias = lista;
          _cargandoCategorias = false;
          if (_categoriaId.isEmpty && lista.isNotEmpty) {
            _categoriaId = lista.first.id;
          }
        });
      }
    });
  }

  void _cargarDatosExistentes(Cancion c) {
    _tituloCtrl.text = c.titulo;
    _autorCtrl.text = c.autor;
    _ritmoCtrl.text = c.ritmo;
    _categoriaId = c.categoriaId;
    _audioUrl = c.audioUrl.isNotEmpty ? c.audioUrl : null;
    _imagenUrl = c.imagenUrl.isNotEmpty ? c.imagenUrl : null;
    _letraCtrl.text = c.letra;

    // Convertir estrofas a texto
    final sb = StringBuffer();
    for (int i = 0; i < c.estrofas.length; i++) {
      final e = c.estrofas[i];
      sb.writeln('ESTROFA ${i + 1}: ${e.texto}${e.bis ? ' -- BIS' : ''}');
    }
    _numerofoniaTextoCtrl.text = sb.toString();
  }

  Future<void> _verificarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    final borradorTitulo = prefs.getString('borrador_cancion_titulo');
    final borradorTexto = prefs.getString('borrador_cancion_numerofonia');
    if (borradorTitulo != null && borradorTitulo.isNotEmpty && mounted) {
      final restaurar = await AllinDialog.confirm(
        context,
        title: 'Borrador Encontrado',
        message: '¿Deseas restaurar la canción no guardada "$borradorTitulo"?',
        confirmText: 'Restaurar',
        cancelText: 'Descartar',
        icon: Icons.restore_page_outlined,
      );
      if (restaurar == true && mounted) {
        setState(() {
          _tituloCtrl.text = borradorTitulo;
          _autorCtrl.text = prefs.getString('borrador_cancion_autor') ?? '';
          _ritmoCtrl.text = prefs.getString('borrador_cancion_ritmo') ?? '';
          _numerofoniaTextoCtrl.text = borradorTexto ?? '';
          _letraCtrl.text = prefs.getString('borrador_cancion_letra') ?? '';
        });
      } else {
        _limpiarBorrador();
      }
    }
  }

  Future<void> _guardarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('borrador_cancion_titulo', _tituloCtrl.text);
    await prefs.setString('borrador_cancion_autor', _autorCtrl.text);
    await prefs.setString('borrador_cancion_ritmo', _ritmoCtrl.text);
    await prefs.setString('borrador_cancion_numerofonia', _numerofoniaTextoCtrl.text);
    await prefs.setString('borrador_cancion_letra', _letraCtrl.text);
  }

  Future<void> _limpiarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('borrador_cancion_titulo');
    await prefs.remove('borrador_cancion_autor');
    await prefs.remove('borrador_cancion_ritmo');
    await prefs.remove('borrador_cancion_numerofonia');
    await prefs.remove('borrador_cancion_letra');
  }

  /// Parser inteligente: Interpreta líneas de texto y genera estrofas con filas 7 y 6
  void _parsearEnVivo() {
    final raw = _numerofoniaTextoCtrl.text;
    if (raw.trim().isEmpty) {
      setState(() => _estrofasParseadas = []);
      return;
    }

    final lineas = raw.split('\n');
    final List<EstrofaNumerofonia> resultado = [];
    EstrofaNumerofonia estrofaActual = EstrofaNumerofonia();

    for (final linea in lineas) {
      final trim = linea.trim();
      if (trim.isEmpty) continue;

      // Si indica explícitamente "ESTROFA" o similar, creamos nueva estrofa
      if (RegExp(r'^(estrofa|parte|bloque|\#\#)', caseSensitive: false).hasMatch(trim)) {
        if (estrofaActual.columnas.isNotEmpty) {
          resultado.add(estrofaActual);
          estrofaActual = EstrofaNumerofonia();
        }
        // Verificar si la línea contiene BIS
        if (trim.toUpperCase().contains('BIS')) {
          estrofaActual.bis = true;
        }
        // Si hay notas después de dos puntos (ej. "ESTROFA 1: 43653/2332")
        final partes = trim.split(':');
        if (partes.length > 1 && partes[1].trim().isNotEmpty) {
          final cols = EstrofaNumerofonia.parsearTextoRapido(partes[1].trim());
          estrofaActual.columnas.addAll(cols);
        }
        continue;
      }

      final tieneBis = trim.toUpperCase().contains('BIS') || trim.endsWith('//') || trim.endsWith(':|');
      final lineaSinBis = trim
          .replaceAll(RegExp(r'\bBIS\b', caseSensitive: false), '')
          .replaceAll('//', '')
          .replaceAll(':|', '')
          .trim();

      final cols = EstrofaNumerofonia.parsearTextoRapido(lineaSinBis);
      if (cols.isNotEmpty) {
        if (estrofaActual.columnas.isNotEmpty) {
          // Si ya tenía columnas y encontramos otra línea, la agregamos
          estrofaActual.columnas.addAll(cols);
        } else {
          estrofaActual = EstrofaNumerofonia(columnas: cols);
        }
        if (tieneBis) estrofaActual.bis = true;
      }
    }

    if (estrofaActual.columnas.isNotEmpty) {
      resultado.add(estrofaActual);
    }

    setState(() => _estrofasParseadas = resultado);
    _guardarBorrador();
  }

  void _insertarComando(String cmd) {
    final text = _numerofoniaTextoCtrl.text;
    final selection = _numerofoniaTextoCtrl.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, cmd);
    _numerofoniaTextoCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + cmd.length),
    );
  }

  Future<void> _seleccionarAudio() async {
    if (!await PermisosService.pedirAudio(context)) return;
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res != null && res.files.single.path != null) {
      setState(() {
        _audioLocal = File(res.files.single.path!);
        _audioNombre = res.files.single.name;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    if (!await PermisosService.pedirGaleria(context)) return;
    final res = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (res != null) {
      setState(() => _imagenLocal = File(res.path));
    }
  }

  Future<void> _guardarCancionCompleta() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      _tabCtrl.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el título de la canción.')),
      );
      return;
    }

    setState(() {
      _subiendo = true;
      _estadoSubida = 'Preparando guardado...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final idCancion = widget.cancionExistente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // 1. Subida de audio si fue seleccionado
      String finalAudioUrl = _audioUrl ?? '';
      if (_audioLocal != null) {
        setState(() => _estadoSubida = 'Subiendo audio del tema...');
        finalAudioUrl = await StorageService().subirAudio(_audioLocal!, idCancion);
      }

      // 2. Subida de imagen si fue seleccionada
      String finalImagenUrl = _imagenUrl ?? '';
      if (_imagenLocal != null) {
        setState(() => _estadoSubida = 'Subiendo portada...');
        finalImagenUrl = await StorageService().subirFoto(_imagenLocal!, 'imagenes_canciones');
      }

      // 3. Estructuración del objeto Cancion
      final nuevaCancion = Cancion(
        id: idCancion,
        titulo: _tituloCtrl.text.trim(),
        autor: _autorCtrl.text.trim(),
        tipo: 'original',
        ritmo: _ritmoCtrl.text.trim(),
        region: 'Puno - Juliaca',
        numerofonia: '',
        estrofas: _estrofasParseadas,
        letra: _letraCtrl.text.trim(),
        letras: [Letra(titulo: 'General', texto: _letraCtrl.text.trim())],
        setlist: widget.cancionExistente?.setlist ?? [],
        imagenUrl: finalImagenUrl,
        audioUrl: finalAudioUrl,
        videoUrl: '',
        descripcion: '',
        tags: [_ritmoCtrl.text.trim()],
        categoriaId: _categoriaId,
        creadoPor: widget.cancionExistente?.creadoPor ?? user.uid,
        creadorNombre: widget.cancionExistente?.creadorNombre ?? (user.displayName ?? 'Allin Kawsay'),
        reproducciones: widget.cancionExistente?.reproducciones ?? 0,
      );

      setState(() => _estadoSubida = 'Guardando en cancionero...');
      await CancionService().guardar(nuevaCancion);

      await _limpiarBorrador();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎵 "${nuevaCancion.titulo}" guardada exitosamente'),
            backgroundColor: AppColors.granateSagrado,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AllinDialog.confirm(
          context,
          title: 'Error al Guardar',
          message: 'Ocurrió un problema: $e',
          confirmText: 'Entendido',
          cancelText: null,
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOLED,
      appBar: AppBar(
        backgroundColor: AppColors.fondoOLED,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.oroSolar, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.cancionExistente != null ? 'Editar Canción' : 'Carga Rápida de Canción',
          style: AppText.title.copyWith(
            color: AppColors.oroSolar,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.oroSolar,
          indicatorWeight: 2.5,
          labelColor: AppColors.oroSolar,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline, size: 19), text: '1. Datos'),
            Tab(icon: Icon(Icons.music_note, size: 19), text: '2. Partitura'),
            Tab(icon: Icon(Icons.library_music_outlined, size: 19), text: '3. Medios'),
          ],
        ),
      ),
      body: _subiendo
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.oroSolar),
                  const SizedBox(height: Sp.lg),
                  Text(
                    _estadoSubida,
                    style: AppText.body.copyWith(color: AppColors.oroSolar),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildPaso1Datos(),
                _buildPaso2Partitura(),
                _buildPaso3MediosYPublicar(),
              ],
            ),
    );
  }

  Widget _buildPaso1Datos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AllinInput(
            controller: _tituloCtrl,
            label: 'Título de la canción *',
            hint: 'Ej. Fiesta Patronal, Kantu de Charazani...',
            prefixIcon: Icons.title,
            autofocus: true,
          ),
          const SizedBox(height: Sp.md),
          AllinInput(
            controller: _autorCtrl,
            label: 'Autor / Tradición',
            hint: 'Ej. Tradicional, Allin Kawsay...',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: Sp.md),
          Text(
            'Ritmo Musical',
            style: AppText.caption.copyWith(color: AppColors.oroSolar),
          ),
          const SizedBox(height: Sp.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ritmosSugeridos.map((r) {
              final isSel = _ritmoCtrl.text == r;
              return ChoiceChip(
                label: Text(r),
                selected: isSel,
                selectedColor: AppColors.granateSagrado,
                backgroundColor: AppColors.grafitoCarbon,
                labelStyle: TextStyle(
                  color: isSel ? AppColors.oroReflejo : Colors.white70,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSel ? AppColors.oroSolar : Colors.white12,
                ),
                onSelected: (val) {
                  setState(() => _ritmoCtrl.text = val ? r : '');
                  _guardarBorrador();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: Sp.md),
          AllinInput(
            controller: _ritmoCtrl,
            label: 'Otro Ritmo (opcional)',
            hint: 'Escribe el ritmo si no está arriba',
            prefixIcon: Icons.music_note_outlined,
          ),
          const SizedBox(height: Sp.xxl),
          AllinButton(
            text: 'SIGUIENTE: PARTITURA RÁPIDA ➔',
            onPressed: () => _tabCtrl.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildPaso2Partitura() {
    return Column(
      children: [
        // Barra de atajos para inserción veloz de numerofonía
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 8),
          color: const Color(0xFF14141A),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _btnAtajo('/ (Fila 7)', () => _insertarComando('/')),
                _btnAtajo(r'\ (Fila 6)', () => _insertarComando(r'\')),
                _btnAtajo('. (Punto)', () => _insertarComando('.')),
                _btnAtajo('BIS', () => _insertarComando(' -- BIS\n')),
                _btnAtajo('+ Estrofa', () => _insertarComando('\nESTROFA: ')),
              ],
            ),
          ),
        ),

        // Área dividida: Entrada de texto arriba / Previsualización en Atril abajo
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(Sp.md),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F14),
                borderRadius: Rad.rMd,
                border: Border.all(color: AppColors.oroSolar.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _numerofoniaTextoCtrl,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.4,
                ),
                cursorColor: AppColors.oroSolar,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(Sp.md),
                  border: InputBorder.none,
                  hintText: 'Pega o escribe tu numerofonía aquí:\n\n'
                      'Ejemplo rápido:\n'
                      'ESTROFA 1: 43653/2332 \\ 434 \\ 2323 -- BIS\n'
                      'ESTROFA 2: 123/456 \\ 789',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Título de la vista previa viva
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md),
          child: Row(
            children: [
              const Icon(Icons.remove_red_eye, color: AppColors.oroSolar, size: 14),
              const SizedBox(width: 6),
              Text(
                'VISTA PREVIA EN EL ATRIL VIVO',
                style: AppText.captionXs.copyWith(
                  color: AppColors.oroSolar,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                '${_estrofasParseadas.length} estrofa(s)',
                style: AppText.captionXs.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),

        // Previsualizador en tiempo real con AtrilNumerofonia
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(Sp.md),
            padding: const EdgeInsets.all(Sp.sm),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: Rad.rMd,
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              child: AtrilNumerofonia(
                estrofas: _estrofasParseadas,
                fontSize: 14.0,
                fondoOscuro: true,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(Sp.md),
          child: AllinButton(
            text: 'SIGUIENTE: AUDIO Y PUBLICAR ➔',
            onPressed: () => _tabCtrl.animateTo(2),
          ),
        ),
      ],
    );
  }

  Widget _btnAtajo(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.granateSagrado.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.oroSolar.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.oroReflejo,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaso3MediosYPublicar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de Audio
          Text('Audio de la Canción', style: AppText.h3.copyWith(color: AppColors.oroSolar)),
          const SizedBox(height: Sp.sm),
          Container(
            padding: const EdgeInsets.all(Sp.md),
            decoration: BoxDecoration(
              color: AppColors.grafitoCarbon,
              borderRadius: Rad.rMd,
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Icon(
                  _audioLocal != null || _audioUrl != null
                      ? Icons.audio_file
                      : Icons.music_off,
                  color: AppColors.oroSolar,
                  size: 32,
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _audioNombre ?? (_audioUrl != null ? 'Audio ya cargado en la nube' : 'Sin archivo de audio seleccionado'),
                        style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'MP3, WAV o M4A para el ensayo y reproductor',
                        style: AppText.captionXs.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                AllinButton(
                  text: _audioLocal != null ? 'CAMBIAR' : 'ELEGIR',
                  variant: AllinButtonVariant.glass,
                  fullWidth: false,
                  height: 38,
                  onPressed: _seleccionarAudio,
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),

          // Letra completa
          AllinInput(
            controller: _letraCtrl,
            label: 'Letra Completa del Tema (opcional)',
            hint: 'Pega la letra del huayño o cántico aquí...',
            maxLines: 4,
          ),
          const SizedBox(height: Sp.xxl),

          // Botón final de guardado
          AllinButton(
            text: widget.cancionExistente != null ? 'ACTUALIZAR CANCIÓN' : 'PUBLICAR EN EL CANCIONERO',
            variant: AllinButtonVariant.primary,
            height: 56,
            onPressed: _guardarCancionCompleta,
          ),
        ],
      ),
    );
  }
}
