import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/pieza_card.dart';
import '../map/map_screen.dart';
import '../product/product_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final results = provider.results;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${results.length} resultado${results.length != 1 ? 's' : ''}',
        ),
        actions: [
          if (results.isNotEmpty)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapScreen(piezas: results),
                ),
              ),
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Ver en mapa',
            ),
        ],
      ),
      body: results.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron piezas',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Prueba con otros filtros',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => PiezaCard(
                pieza: results[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductScreen(pieza: results[i]),
                  ),
                ),
              ),
            ),
    );
  }
}
