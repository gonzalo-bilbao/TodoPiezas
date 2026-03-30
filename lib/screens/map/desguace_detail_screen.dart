import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/desguace.dart';
import '../../services/api_service.dart';

class DesguaceDetailScreen extends StatefulWidget {
  final Desguace desguace;

  const DesguaceDetailScreen({super.key, required this.desguace});

  @override
  State<DesguaceDetailScreen> createState() => _DesguaceDetailScreenState();
}

class _DesguaceDetailScreenState extends State<DesguaceDetailScreen> {
  List<Map<String, dynamic>> _piezas = [];
  bool _loadingPiezas = true;

  @override
  void initState() {
    super.initState();
    _loadPiezas();
  }

  Future<void> _loadPiezas() async {
    try {
      final piezas = await ApiService.getDesguacePiezas(widget.desguace.id);
      if (mounted) setState(() { _piezas = piezas; _loadingPiezas = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPiezas = false);
    }
  }

  Future<void> _navigate() async {
    final lat = widget.desguace.lat;
    final lng = widget.desguace.lng;
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.desguace;

    return Scaffold(
      appBar: AppBar(title: Text(d.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini-mapa
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(d.lat, d.lng),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.todopiezas.todopiezas_app',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(d.lat, d.lng),
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.location_pin,
                          color: AppTheme.primary, size: 44),
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.nombre, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  _InfoRow(Icons.location_on_outlined, d.direccion),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.schedule_outlined,
                      d.horario.isEmpty ? 'Horario no disponible' : d.horario),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.phone_outlined, d.telefono),
                  if (d.distancia != null) ...[
                    const SizedBox(height: 10),
                    _InfoRow(Icons.near_me_outlined,
                        '${d.distancia!.toStringAsFixed(1)} km de distancia'),
                  ],
                  const SizedBox(height: 24),
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(Uri.parse('tel:${d.telefono}')),
                          icon: const Icon(Icons.phone),
                          label: const Text('Llamar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigate,
                          icon: const Icon(Icons.navigation),
                          label: const Text('Llegar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Tabla de piezas
                  const Text(
                    'Inventario disponible',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 12),
                  _loadingPiezas
                      ? const Center(child: CircularProgressIndicator())
                      : _piezas.isEmpty
                          ? const Text('No hay piezas disponibles',
                              style: TextStyle(color: Colors.grey))
                          : _PiezasTable(piezas: _piezas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      );
}

class _PiezasTable extends StatelessWidget {
  final List<Map<String, dynamic>> piezas;
  const _PiezasTable({required this.piezas});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              SizedBox(width: 44),
              Expanded(flex: 3, child: Text('Nombre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text('Estado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text('Precio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
              Expanded(flex: 1, child: Text('Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...piezas.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final imagen = p['imagen'] as String?;
          final isNuevo = (p['estado'] ?? '') == 'Nuevo';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // Foto
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: imagen != null && imagen.isNotEmpty
                        ? Image.network(
                            '${AppConstants.apiBaseUrl}/$imagen',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200],
                                    child: const Icon(Icons.car_repair, size: 18, color: Colors.grey)),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.car_repair, size: 18, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(p['nombre'] ?? '',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isNuevo ? Colors.green[600] : AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(p['estado'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${double.tryParse(p['precio'].toString())?.toStringAsFixed(0) ?? '-'} €',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text('${p['stock'] ?? '-'}',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
