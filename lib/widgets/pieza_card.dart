import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/pieza.dart';

class PiezaCard extends StatelessWidget {
  final Pieza pieza;
  final VoidCallback onTap;

  const PiezaCard({super.key, required this.pieza, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Barra naranja izquierda
                Container(width: 4, color: AppTheme.primary),
                // Imagen / placeholder
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[100],
                  child: _buildImage(),
                ),
                const SizedBox(width: 12),
                // Información
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pieza.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pieza.marca} ${pieza.modelo} · ${pieza.categoria}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pieza.desguaceNombre,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.secondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pieza.distancia != null)
                          Text(
                            '${pieza.distancia!.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                // Precio y estado
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${pieza.precio.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _EstadoBadge(estado: pieza.estado),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (pieza.imagen != null && pieza.imagen!.isNotEmpty) {
      return Image.network(
        AppConstants.imageUrl(pieza.imagen),
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.car_repair,
          color: Colors.grey,
          size: 36,
        ),
      );
    }
    return const Icon(Icons.car_repair, color: Colors.grey, size: 36);
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final isNuevo = estado == 'Nuevo';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNuevo ? Colors.green[600] : AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
