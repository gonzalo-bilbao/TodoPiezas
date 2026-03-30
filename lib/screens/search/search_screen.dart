import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/search_provider.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _modeloController = TextEditingController();
  final _anyoController = TextEditingController();

  @override
  void dispose() {
    _modeloController.dispose();
    _anyoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Piezas'),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearFilters();
              _modeloController.clear();
              _anyoController.clear();
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Marca'),
            _dropdown(
              value: provider.marca,
              items: AppConstants.marcas,
              hint: 'Selecciona marca',
              onChanged: (v) => provider.setFilter('marca', v),
            ),
            const SizedBox(height: 16),
            _label('Modelo'),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(hintText: 'Ej: Ibiza, Golf, Focus...'),
              onChanged: (v) => provider.setFilter('modelo', v.isEmpty ? null : v),
            ),
            const SizedBox(height: 16),
            _label('Año'),
            TextField(
              controller: _anyoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ej: 2015'),
              onChanged: (v) => provider.setFilter('anyo', int.tryParse(v)),
            ),
            const SizedBox(height: 16),
            _label('Categoría'),
            _dropdown(
              value: provider.categoria,
              items: AppConstants.categorias,
              hint: 'Selecciona categoría',
              onChanged: (v) => provider.setFilter('categoria', v),
            ),
            const SizedBox(height: 16),
            _label('Color'),
            _dropdown(
              value: provider.color,
              items: AppConstants.colores,
              hint: 'Cualquier color',
              onChanged: (v) => provider.setFilter('color', v),
            ),
            const SizedBox(height: 16),
            _label('Estado'),
            _dropdown(
              value: provider.estado,
              items: AppConstants.estados,
              hint: 'Nuevo o usado',
              onChanged: (v) => provider.setFilter('estado', v),
            ),
            const SizedBox(height: 32),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.loading
                    ? null
                    : () async {
                        await provider.search();
                        if (provider.error == null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ResultsScreen()),
                          );
                        }
                      },
                icon: provider.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  provider.loading ? 'Buscando...' : 'Buscar piezas',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(),
        hint: Text(hint),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      );
}
