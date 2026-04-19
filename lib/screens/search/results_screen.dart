import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/search_provider.dart';
import '../../widgets/pieza_card.dart';
import '../../widgets/top_app_bar.dart';
import '../map/map_screen.dart';
import '../product/product_screen.dart';
import '../../models/pieza.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _sortBy = 'distancia'; // distancia, precio_asc, precio_desc
  String _filterEstado = 'Todos'; // Todos, Nuevo, Usado

  List<Pieza> _applyFilters(List<Pieza> results) {
    var filtered = List<Pieza>.from(results);

    // Filtro por estado
    if (_filterEstado != 'Todos') {
      filtered = filtered.where((p) => p.estado == _filterEstado).toList();
    }

    // Ordenar
    switch (_sortBy) {
      case 'precio_asc':
        filtered.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case 'precio_desc':
        filtered.sort((a, b) => b.precio.compareTo(a.precio));
        break;
      case 'distancia':
      default:
        filtered.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final results = _applyFilters(provider.results);

    return Scaffold(
      appBar: TopAppBar(
        title: '${results.length} resultado${results.length != 1 ? 's' : ''}',
        extraActions: [
          if (provider.results.isNotEmpty)
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
      body: provider.results.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No se encontraron piezas',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Prueba con otros filtros',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : Column(
              children: [
                // Barra de filtros
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Ordenar por
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sortBy,
                          decoration: const InputDecoration(
                            labelText: 'Ordenar',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'distancia', child: Text('Distancia', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'precio_asc', child: Text('Precio ↑', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'precio_desc', child: Text('Precio ↓', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setState(() => _sortBy = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filtro estado
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filterEstado,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Todos', child: Text('Todos', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Nuevo', child: Text('Nuevo', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'Usado', child: Text('Usado', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setState(() => _filterEstado = v!),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Lista
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                          child: Text('No hay resultados con estos filtros',
                              style: TextStyle(color: Colors.grey)),
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
                ),
              ],
            ),
    );
  }
}
