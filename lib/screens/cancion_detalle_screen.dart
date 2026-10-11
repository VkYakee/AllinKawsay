import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cancion.dart';
import '../models/comentario.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/comentario_service.dart';
import '../services/descarga_service.dart';
import '../services/player_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/tarjeta_video.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/watermark_overlay.dart';

import 'compartir_imagen_screen.dart';
import 'numerofonia_fullscreen_screen.dart';
import 'presentacion_screen.dart';

class CancionDetalleScreen extends StatefulWidget {
  final Cancion cancion;

  const CancionDetalleScreen({super.key, required this.cancion});

  @override
  State<CancionDetalleScreen> createState() => _CancionDetalleScreenState();
}

class _CancionDetalleScreenState extends State<CancionDetalleScreen> {
  final _player = PlayerService();
  final _comentarioCtrl = TextEditingController();
  Usuario? _usuario;
  bool _reproduccionContada = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    await _player.toggle(widget.cancion);
    if (!_reproduccionContada && _player.sonando(widget.cancion.id)) {
      _reproduccionContada = true;
      await CancionService().incrementarReproduccion(widget.cancion.id);
    }
  }

  Future<void> _descargar(String url,
      {String? nombre, String mime = 'application/octet-stream'}) async {
    if (url.isEmpty) return;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.dorado,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text('Descargando...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    final nombreFinal = nombre ??
        DescargaService.nombreConTimestamp(widget.cancion.titulo, 'mp3');
    final resultado =
        await DescargaService.descargar(url, nombreFinal, mime);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.dorado),
                const SizedBox(width: 12),
                Expanded(child: Text('Guardado en Descargas: $resultado')),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo descargar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _compartir() async {
    final c = widget.cancion;
    final sb = StringBuffer();
    sb.writeln('🎵 *${c.titulo}*');
    if (c.autor.isNotEmpty) sb.writeln('✍️ Autor: ${c.autor}');
    if (c.ritmo.isNotEmpty) sb.writeln('🎶 Ritmo: ${c.ritmo}');
    if (c.tieneNumerofonia) {
      sb.writeln('');
      sb.writeln('📊 *Numerofonía:*');
      for (int i = 0; i < c.estrofas.length; i++) {
        final e = c.estrofas[i];
        if (e.vacia) continue;
        sb.writeln('');
        sb.writeln('Estrofa ${i + 1}${e.bis ? " (BIS)" : ""}:');
        sb.writeln(e.texto);
      }
    }
    if (c.letra.isNotEmpty) {
      sb.writeln('');
      sb.writeln('📝 Letra:');
      sb.writeln(c.letra);
    }
    sb.writeln('');
    sb.writeln('— Enviado desde Allin Kawsay');

    final texto = Uri.encodeComponent(sb.toString());
    final url = Uri.parse('https://wa.me/?text=$texto');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _enviarComentario() async {
    final texto = _comentarioCtrl.text.trim();
    if (texto.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    await ComentarioService().agregar(
      widget.cancion.id,
      Comentario(
        id: '',
        texto: texto,
        autorUid: user.uid,
        autorNombre: user.displayName ?? user.email ?? 'Anónimo',
      ),
    );
    _comentarioCtrl.clear();
    FocusScope.of(context).unfocus();
  }