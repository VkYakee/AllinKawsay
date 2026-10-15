import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cancion.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/descarga_service.dart';
import '../services/player_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/cancion/audio_player_compacto.dart';
import '../widgets/cancion/comentarios_section.dart';
import '../widgets/cancion/header_numerofonia.dart';
import '../widgets/cancion/informacion_expandible.dart';
import '../widgets/cancion/nota_personal_card.dart';
import '../widgets/comunes/seccion_card.dart';
import '../widgets/dialogo_descarga.dart';
import '../widgets/tarjeta_video.dart';
import '../widgets/visor_letras.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/watermark_overlay.dart';
import 'compartir_imagen_screen.dart';
import 'presentacion_screen.dart';

class CancionDetalleScreen extends StatefulWidget {
  final Cancion cancion;
  const CancionDetalleScreen({super.key, required this.cancion});

  @override
  State<CancionDetalleScreen> createState() => _CancionDetalleScreenState();
}

class _CancionDetalleScreenState extends State<CancionDetalleScreen> {
  final _player = PlayerService();
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

    final nombreFinal = nombre ??
        DescargaService.nombreConTimestamp(widget.cancion.titulo, 'mp3');

    final resultado = await DialogoDescarga.mostrar(
      context,
      url: url,
      nombre: nombreFinal,
      mime: mime,
      titulo: 'Descargando audio',
    );

    if (!mounted) return;
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.dorado),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Guardado en Descargas: $resultado'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
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

    if (c.tieneLetra) {
      for (int i = 0; i < c.letras.length; i++) {
        final l = c.letras[i];
        if (l.vacia) continue;
        sb.writeln('');
        sb.writeln(
            '📝 ${l.titulo.isNotEmpty ? l.titulo : 'Letra ${i + 1}'}:');
        sb.writeln(l.texto);
      }
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
@override
Widget build(BuildContext context) {
  final c = widget.cancion;
  final puedeDescargar = _usuario?.puedeDescargar ?? false;
  final puedeComentar = _usuario?.puedeComentar ?? false;
  final esFavorito = _usuario?.esFavorito(c.id) ?? false;
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return Scaffold(
    appBar: AppBar(
      title: Text(c.titulo),
      actions: [
        IconButton(
          icon: Icon(esFavorito ? Icons.favorite : Icons.favorite_border),
          tooltip: 'Favorito',
          onPressed: () async {
            await UsuarioService().toggleFavorito(c.id);
            await _cargarUsuario();
          },
        ),
        IconButton(
          icon: const Icon(Icons.slideshow),
          tooltip: 'Modo presentación',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PresentacionScreen(cancion: widget.cancion),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.image),
          tooltip: 'Compartir como imagen',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CompartirImagenScreen(cancion: widget.cancion),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Compartir texto',
          onPressed: _compartir,
        ),
      ],
    ),
    body: WatermarkOverlay(
      opacity: 0.04,
      child: ListView(
        children: [
          _heroTitulo(c, onSurface),
          const SizedBox(height: 20),

          // === NUMEROFONÍA ===
          if (c.tieneNumerofonia) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HeaderNumerofonia(cancion: c),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VisorNumerofonia(estrofas: c.estrofas),
            ),
            const SizedBox(height: 20),
          ] else if (c.tieneNumerofoniaString) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SeccionCard(
                icono: Icons.grid_on,
                titulo: 'Numerofonía',
                child: Text(
                  c.numerofonia,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === AUDIO ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AudioPlayerCompacto(
              cancion: c,
              puedeDescargar: puedeDescargar,
              player: _player,
              onTogglePlay: _togglePlay,
              onDescargar: _descargar,
            ),
          ),
          const SizedBox(height: 16),

          // === LETRAS ===
          if (c.tieneLetra) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VisorLetras(letras: c.letras),
            ),
            const SizedBox(height: 16),
          ],

          // === DESCRIPCIÓN ===
          if (c.descripcion.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SeccionCard(
                icono: Icons.notes,
                titulo: 'Descripción',
                child: Text(
                  c.descripcion,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: onSurface.withOpacity(0.85)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === INFORMACIÓN ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InformacionExpandible(cancion: c),
          ),
          const SizedBox(height: 16),

          // === COMENTARIOS ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _expansionCard(
              context,
              icono: Icons.comment,
              titulo: 'Comentarios',
              child: ComentariosSection(
                cancionId: c.id,
                puedeComentar: puedeComentar,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // === NOTA PERSONAL ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NotaPersonalCard(
              cancionId: c.id,
              usuario: _usuario,
            ),
          ),
          const SizedBox(height: 16),

          // === VIDEO YOUTUBE ===
          if (c.tieneVideo) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TarjetaVideo(url: c.videoUrl, titulo: c.titulo),
            ),
            const SizedBox(height: 32),
          ] else ...[
            const SizedBox(height: 32),
          ],
        ],
      ),
    ),
  );
}
  Widget _heroTitulo(Cancion c, Color onSurface) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granate.withOpacity(0.08),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.titulo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          if (c.autor.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  c.autor,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
          if (c.ritmo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.graphic_eq,
                      size: 12, color: AppColors.granate),
                  const SizedBox(width: 4),
                  Text(
                    c.ritmo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.granate,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _expansionCard(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono,
              color: AppColors.seccionTitulo(context), size: 18),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.seccionTitulo(context),
            letterSpacing: 0.5,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}