import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/desguace.dart';
import '../../providers/map_style_provider.dart';
import '../../providers/preload_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/map_style_button.dart';
import '../../widgets/top_app_bar.dart';
import 'desguace_detail_screen.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<Desguace> _desguaces = [];
  Position? _userPos;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Aprovechar precarga si está disponible
    final pre = context.read<PreloadProvider>();
    if (pre.desguacesReady && pre.positionReady) {
      _desguaces = List.from(pre.desguaces);
      _userPos   = pre.userPosition;
      _applyDistance();
      _loading = false;
    } else {
      _load();
    }
  }

  void _applyDistance() {
    if (_userPos != null) {
      for (final d in _desguaces) {
        d.distancia = Geolocator.distanceBetween(
              _userPos!.latitude, _userPos!.longitude, d.lat, d.lng) / 1000;
      }
      _desguaces.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getDesguaces(),
        _getLocation(),
      ]);
      _desguaces = results[0] as List<Desguace>;
      _userPos   = results[1] as Position?;
      if (_userPos != null) {
        for (final d in _desguaces) {
          d.distancia = Geolocator.distanceBetween(
                _userPos!.latitude, _userPos!.longitude, d.lat, d.lng) / 1000;
        }
        _desguaces.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Position?> _getLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return null;
      }
      if (perm == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
    } catch (_) {
      return null;
    }
  }

  LatLng get _center {
    if (_userPos != null) return LatLng(_userPos!.latitude, _userPos!.longitude);
    if (_desguaces.isNotEmpty) return LatLng(_desguaces[0].lat, _desguaces[0].lng);
    return const LatLng(40.4168, -3.7038);
  }

  @override
  Widget build(BuildContext context) {
    final mapStyle = context.watch<MapStyleProvider>().current;
    return Scaffold(
      appBar: const TopAppBar(title: 'Desguaces cercanos'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(initialCenter: _center, initialZoom: 11),
                      children: [
                        TileLayer(
                          urlTemplate: mapStyle.urlTemplate,
                          subdomains: mapStyle.subdomains ?? const [],
                          userAgentPackageName: 'com.todopiezas.todopiezas_app',
                        ),
                        if (_userPos != null)
                          MarkerLayer(markers: [
                            Marker(
                              point: LatLng(_userPos!.latitude, _userPos!.longitude),
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ]),
                        MarkerLayer(
                          markers: _desguaces.map((d) => Marker(
                            point: LatLng(d.lat, d.lng),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                      DesguaceDetailScreen(desguace: d))),
                              child: const Icon(Icons.location_pin,
                                  color: AppTheme.primary, size: 44),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                    // Botón flotante de estilo de mapa
                    const Positioned(
                      top: 16, right: 16,
                      child: MapStyleButton(),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.3,
                      minChildSize: 0.1,
                      maxChildSize: 0.85,
                      snap: true,
                      snapSizes: const [0.1, 0.3, 0.85],
                      builder: (context, scrollController) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
                          ),
                          child: ListView.builder(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: _desguaces.length + 1, // +1 por la cabecera
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Container(
                                        width: 40, height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.store, size: 18, color: AppTheme.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_desguaces.length} desguaces cerca',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1),
                                  ],
                                );
                              }
                              final d = _desguaces[i - 1];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.store,
                                      color: AppTheme.primary, size: 20),
                                ),
                                title: Text(d.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(d.direccion,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: d.distancia != null
                                    ? Text('${d.distancia!.toStringAsFixed(1)} km',
                                        style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold))
                                    : null,
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) =>
                                        DesguaceDetailScreen(desguace: d))),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
