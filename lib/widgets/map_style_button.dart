import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_style_provider.dart';

class MapStyleButton extends StatelessWidget {
  const MapStyleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MapStyleProvider>();
    return PopupMenuButton<String>(
      tooltip: 'Cambiar mapa',
      onSelected: (id) => context.read<MapStyleProvider>().setStyle(id),
      itemBuilder: (_) => MapStyleProvider.styles.map((s) => PopupMenuItem(
        value: s.id,
        child: Row(
          children: [
            Icon(s.icon, color: p.currentId == s.id ? Theme.of(context).colorScheme.primary : null),
            const SizedBox(width: 8),
            Text(s.name),
            if (p.currentId == s.id) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
            ],
          ],
        ),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Icon(p.current.icon, size: 22),
      ),
    );
  }
}
