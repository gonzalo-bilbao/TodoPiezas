import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/search_provider.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _modeloController = TextEditingController();
  final _anyoController   = TextEditingController();

  bool get _colorEnabled {
    final cat = context.read<SearchProvider>().categoria;
    return cat == null || AppConstants.categoriasConColor.contains(cat);
  }

  @override
  void dispose() {
    _modeloController.dispose();
    _anyoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    // Limpiar color si la categoría no lo admite
    if (!_colorEnabled && provider.color != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setFilter('color', null);
      });
    }

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
            child: const Text('Limpiar', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Vehículo', Icons.directions_car_outlined),
            const SizedBox(height: 12),
            _dropdown(
              value: provider.marca,
              items: AppConstants.marcas,
              hint: 'Selecciona marca',
              onChanged: (v) => provider.setFilter('marca', v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                hintText: 'Ej: Ibiza, Golf, Focus...',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              onChanged: (v) => provider.setFilter('modelo', v.isEmpty ? null : v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _anyoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año',
                hintText: 'Ej: 2015',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onChanged: (v) => provider.setFilter('anyo', int.tryParse(v)),
            ),
            const SizedBox(height: 24),
            _SectionHeader('Pieza', Icons.build_outlined),
            const SizedBox(height: 12),
            _dropdown(
              value: provider.categoria,
              items: AppConstants.categorias,
              hint: 'Selecciona categoría',
              onChanged: (v) => provider.setFilter('categoria', v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    value: _colorEnabled ? provider.color : null,
                    items: AppConstants.colores,
                    hint: _colorEnabled ? 'Color' : 'Sin color',
                    onChanged: _colorEnabled
                        ? (v) => provider.setFilter('color', v)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    value: provider.estado,
                    items: AppConstants.estados,
                    hint: 'Estado',
                    onChanged: (v) => provider.setFilter('estado', v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(provider.error!,
                    style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: provider.loading
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: provider.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('Buscar piezas',
                                      style: GoogleFonts.exo2(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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

class _SectionHeader extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SectionHeader(this.text, this.icon);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: AppTheme.secondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.exo2(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondary,
            ),
          ),
        ],
      );
}
