import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/pieza.dart';

class ProductScreen extends StatelessWidget {
  final Pieza pieza;

  const ProductScreen({super.key, required this.pieza});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pieza.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey[200],
              child: pieza.imagen != null
                  ? Image.network(pieza.imagen!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.car_repair, size: 80, color: Colors.grey))
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
                  // Chips de estado y stock
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
                  // Info pieza
                  _infoRow(Icons.directions_car_outlined,
                      '${pieza.marca} ${pieza.modelo} (${pieza.anyo})'),
                  _infoRow(Icons.category_outlined, pieza.categoria),
                  _infoRow(Icons.palette_outlined, pieza.color),
                  if (pieza.distancia != null)
                    _infoRow(Icons.near_me,
                        '${pieza.distancia!.toStringAsFixed(1)} km del desguace'),
                  const Divider(height: 28),
                  // Info desguace
                  const Text(
                    'Desguace',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.business, pieza.desguaceNombre),
                  _infoRow(Icons.location_on_outlined, pieza.desguaceDireccion),
                  _infoRow(Icons.phone_outlined, pieza.desguaceTelefono),
                  const SizedBox(height: 20),
                  // Botones de acción
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
