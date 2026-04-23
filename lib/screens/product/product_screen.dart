import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/pieza.dart';
import '../../providers/favoritos_provider.dart';
import '../../widgets/top_app_bar.dart';

class ProductScreen extends StatelessWidget {
  final Pieza pieza;

  const ProductScreen({super.key, required this.pieza});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritosProvider>();
    final esFav = favs.isFavorito(pieza.id);

    return Scaffold(
      appBar: TopAppBar(
        title: pieza.nombre,
        extraActions: [
          IconButton(
            tooltip: esFav ? 'Quitar de favoritos' : 'Añadir a favoritos',
            icon: Icon(
              esFav ? Icons.favorite : Icons.favorite_border,
              color: esFav ? Colors.red : null,
            ),
            onPressed: () => context.read<FavoritosProvider>().toggle(pieza.id),
          ),
          IconButton(
            tooltip: 'Compartir',
            icon: const Icon(Icons.share),
            onPressed: () => _share(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey[100],
              child: pieza.imagen != null && pieza.imagen!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        '${AppConstants.apiBaseUrl}/${pieza.imagen}',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.car_repair, size: 80, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.car_repair, size: 80, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          pieza.nombre,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${pieza.precio.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(
                        pieza.estado,
                        pieza.estado == 'Nuevo' ? Colors.green : Colors.orange,
                      ),
                      _chip('Stock: ${pieza.stock}', Colors.blueGrey),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pieza.descripcion.isNotEmpty)
                    Text(pieza.descripcion,
                        style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 28),
                  _infoRow(Icons.directions_car_outlined,
                      '${pieza.marca} ${pieza.modelo} (${pieza.anyo})'),
                  _infoRow(Icons.category_outlined, pieza.categoria),
                  _infoRow(Icons.palette_outlined, pieza.color),
                  if (pieza.distancia != null)
                    _infoRow(Icons.near_me,
                        '${pieza.distancia!.toStringAsFixed(1)} km del desguace'),
                  const Divider(height: 28),
                  const Text(
                    'Desguace',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.business, pieza.desguaceNombre),
                  _infoRow(Icons.location_on_outlined, pieza.desguaceDireccion),
                  _infoRow(Icons.phone_outlined, pieza.desguaceTelefono),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _call(pieza.desguaceTelefono),
                          icon: const Icon(Icons.phone),
                          label: const Text('Llamar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _navigate(pieza.desguaceLat, pieza.desguaceLng),
                          icon: const Icon(Icons.navigation),
                          label: const Text('Navegar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (pieza.desguaceWhatsapp != null &&
                              pieza.desguaceWhatsapp!.isNotEmpty)
                          ? () {
                              final num = pieza.desguaceWhatsapp!
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              final msg = Uri.encodeComponent(
                                  'Hola, me interesa la pieza "${pieza.nombre}" (${pieza.marca} ${pieza.modelo}) que he visto en TodoPiezas.');
                              launchUrl(
                                Uri.parse('https://wa.me/$num?text=$msg'),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.chat),
                      label: Text(
                        (pieza.desguaceWhatsapp != null &&
                                pieza.desguaceWhatsapp!.isNotEmpty)
                            ? 'WhatsApp'
                            : 'WhatsApp (no disponible)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[400],
                        disabledForegroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    final texto =
        '¡Mira esta pieza en TodoPiezas!\n\n'
        '${pieza.nombre}\n'
        '${pieza.marca} ${pieza.modelo} (${pieza.anyo})\n'
        'Precio: ${pieza.precio.toStringAsFixed(2)} €\n'
        'Estado: ${pieza.estado}\n'
        'Desguace: ${pieza.desguaceNombre}';
    Share.share(texto, subject: pieza.nombre);
  }

  Widget _chip(String label, Color color) => Chip(
        label: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: color,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _navigate(double lat, double lng) async {
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      await launchUrl(
        Uri.parse('https://maps.google.com/?q=$lat,$lng'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
