import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_style_provider.dart';
import '../providers/preload_provider.dart';

/// Renderiza un FlutterMap diminuto e invisible para que el navegador
/// descargue las tiles principales en segundo plano. Cuando el usuario
/// entre al mapa real, las tiles ya estarán en cache HTTP.
class MapWarmup extends StatelessWidget {
  const MapWarmup({super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.watch<MapStyleProvider>().current;
    final pre = context.watch<PreloadProvider>();
    // Centramos en la posición del usuario si está, o España.
    final center = pre.userPosition != null
        ? LatLng(pre.userPosition!.latitude, pre.userPosition!.longitude)
        : const LatLng(40.4165, -3.7038);

    return Offstage(
      offstage: true,
      child: SizedBox(
        width: 256,
        height: 256,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 11),
          children: [
            TileLayer(
              urlTemplate: style.urlTemplate,
              subdomains: style.subdomains ?? const [],
              userAgentPackageName: 'com.todopiezas.todopiezas_app',
            ),
          ],
        ),
      ),
    );
  }
}
