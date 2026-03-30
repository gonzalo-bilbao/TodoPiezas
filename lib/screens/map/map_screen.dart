import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../models/pieza.dart';
import '../product/product_screen.dart';

class MapScreen extends StatefulWidget {
  final List<Pieza> piezas;

  const MapScreen({super.key, required this.piezas});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Pieza? _selected;

  LatLng get _center {
    if (widget.piezas.isEmpty) return const LatLng(40.4168, -3.7038);
    final avgLat = widget.piezas
            .map((p) => p.desguaceLat)
            .reduce((a, b) => a + b) /
        widget.piezas.length;
    final avgLng = widget.piezas
            .map((p) => p.desguaceLng)
            .reduce((a, b) => a + b) /
        widget.piezas.length;
    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.piezas.length} desguace${widget.piezas.length != 1 ? 's' : ''}'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 10,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.todopiezas.todopiezas_app',
              ),
              MarkerLayer(
                markers: widget.piezas
                    .map(
                      (pieza) => Marker(
                        point: LatLng(pieza.desguaceLat, pieza.desguaceLng),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = pieza),
                          child: const Icon(
                            Icons.location_pin,
                            color: AppTheme.primary,
                            size: 44,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          // Popup de pieza seleccionada
          if (_selected != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selected!.desguaceNombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _selected = null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      Text(
                        _selected!.desguaceDireccion,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(_selected!.nombre)),
                          Text(
                            '${_selected!.precio.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_selected!.distancia != null)
                        Text(
                          '${_selected!.distancia!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductScreen(pieza: _selected!),
                            ),
                          ),
                          child: const Text('Ver detalles'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Atribución OpenStreetMap (requerida por su licencia)
          Positioned(
            bottom: _selected != null ? null : 8,
            top: _selected != null ? 8 : null,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.white70,
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
