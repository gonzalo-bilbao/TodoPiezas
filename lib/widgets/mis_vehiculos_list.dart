import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/vehiculo.dart';
import '../providers/search_provider.dart';
import '../providers/user_provider.dart';
import '../providers/vehiculos_provider.dart';
import '../screens/search/results_screen.dart';
import '../screens/user/mis_vehiculos_screen.dart';

/// Carrusel horizontal con los coches del usuario (mismo estilo que el
/// carrusel de favoritos). Pulsar una tarjeta busca piezas para ese coche.
class MisVehiculosList extends StatelessWidget {
  /// Controllers de modelo y año del search_screen para sincronizar el texto.
  final TextEditingController? modeloController;
  final TextEditingController? anyoController;

  const MisVehiculosList({super.key, this.modeloController, this.anyoController});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final vp = context.watch<VehiculosProvider>();

    if (!user.isLoggedIn) return const SizedBox.shrink();

    if (vp.vehiculos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.directions_car_outlined, color: Colors.grey[400], size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Aún no tienes coches. Añade uno desde tu perfil para verlos aquí.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MisVehiculosScreen()),
              ),
              child: const Text('Añadir'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vp.vehiculos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _CocheCard(
          vehiculo: vp.vehiculos[i],
          modeloController: modeloController,
          anyoController: anyoController,
        ),
      ),
    );
  }
}

class _CocheCard extends StatelessWidget {
  final Vehiculo vehiculo;
  final TextEditingController? modeloController;
  final TextEditingController? anyoController;

  const _CocheCard({
    required this.vehiculo,
    this.modeloController,
    this.anyoController,
  });

  Future<void> _buscar(BuildContext context) async {
    final provider = context.read<SearchProvider>();
    provider.clearFilters();
    provider.setFilter('marca', vehiculo.marca);
    provider.setFilter('modelo', vehiculo.modelo);
    modeloController?.text = vehiculo.modelo;
    if (vehiculo.anyo != null) {
      provider.setFilter('anyo', vehiculo.anyo);
      anyoController?.text = vehiculo.anyo.toString();
    }
    await provider.search();
    if (provider.error == null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = vehiculo;
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: () => _buscar(context),
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: v.foto != null && v.foto!.isNotEmpty
                      ? Image.network(
                          AppConstants.imageUrl(v.foto),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${v.marca} ${v.modelo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
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

  Widget _placeholder() => Container(
        color: AppTheme.primary.withOpacity(0.1),
        child: const Center(
          child: Icon(Icons.directions_car, color: AppTheme.primary, size: 36),
        ),
      );
}
