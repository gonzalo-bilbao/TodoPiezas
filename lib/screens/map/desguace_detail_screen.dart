import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/desguace.dart';
import '../../providers/map_style_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/top_app_bar.dart';

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
    final mapStyle = context.watch<MapStyleProvider>().current;

    return Scaffold(
      appBar: TopAppBar(title: d.nombre),
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
                    urlTemplate: mapStyle.urlTemplate,
                    subdomains: mapStyle.subdomains ?? const [],
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
                  // Botones principales
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
                  const SizedBox(height: 10),
                  // Botón WhatsApp
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (d.whatsapp != null && d.whatsapp!.isNotEmpty)
                          ? () {
                              final num = d.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '');
                              launchUrl(
                                Uri.parse('https://wa.me/$num?text=Hola,%20he%20visto%20su%20desguace%20en%20TodoPiezas'),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.chat),
                      label: Text(
                        (d.whatsapp != null && d.whatsapp!.isNotEmpty)
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
                  const SizedBox(height: 28),
                  // Tabla de piezas
                  Text(
                    'Inventario disponible',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.secondary,
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final divColor = isDark ? const Color(0xFF333344) : Colors.grey[200];
    final placeholderBg = isDark ? const Color(0xFF333344) : Colors.grey[200];

    return Column(
      children: piezas.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final imagen = p['imagen'] as String?;
        final isNuevo = (p['estado'] ?? '') == 'Nuevo';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  // Foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: imagen != null && imagen.isNotEmpty
                          ? Image.network(
                              AppConstants.imageUrl(imagen),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: placeholderBg,
                                child: const Icon(Icons.car_repair, size: 20, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: placeholderBg,
                              child: const Icon(Icons.car_repair, size: 20, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre + estado
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['nombre'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p['estado'] ?? ''} · Stock: ${p['stock'] ?? '-'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isNuevo ? Colors.green[600] : subColor,
                            fontWeight: isNuevo ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Precio
                  Text(
                    '${double.tryParse(p['precio'].toString())?.toStringAsFixed(0) ?? '-'} €',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (i < piezas.length - 1) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: divColor),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
