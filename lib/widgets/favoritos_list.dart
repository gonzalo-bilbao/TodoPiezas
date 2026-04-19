import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/pieza.dart';
import '../providers/favoritos_provider.dart';
import '../screens/product/product_screen.dart';
import '../services/api_service.dart';

class FavoritosList extends StatefulWidget {
  const FavoritosList({super.key});

  @override
  State<FavoritosList> createState() => _FavoritosListState();
}

class _FavoritosListState extends State<FavoritosList> {
  List<Pieza> _piezas = [];
  bool _loading = false;
  Set<int> _lastIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshIfNeeded();
  }

  Future<void> _refreshIfNeeded() async {
    final ids = context.read<FavoritosProvider>().ids;
    if (ids.length == _lastIds.length && ids.containsAll(_lastIds)) return;
    _lastIds = Set.from(ids);
    if (ids.isEmpty) {
      setState(() => _piezas = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final piezas = await ApiService.getPiezasByIds(ids.toList());
      if (mounted) setState(() { _piezas = piezas; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FavoritosProvider>(); // Escucha cambios
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIfNeeded());

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_piezas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.grey[400], size: 18),
            const SizedBox(width: 6),
            Text(
              'Aún no tienes piezas favoritas',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _piezas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _FavCard(pieza: _piezas[i]),
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Pieza pieza;
  const _FavCard({required this.pieza});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductScreen(pieza: pieza)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: pieza.imagen != null && pieza.imagen!.isNotEmpty
                      ? Image.network(
                          '${AppConstants.apiBaseUrl}/${pieza.imagen}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.car_repair, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.car_repair, color: Colors.grey),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pieza.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pieza.precio.toStringAsFixed(0)} €',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
