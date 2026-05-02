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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final desguaceColor = isDark ? AppTheme.primaryEnd : AppTheme.secondary;
    final imgBg = isDark ? const Color(0xFF252538) : Colors.grey[100];

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
                  color: imgBg,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pieza.marca} ${pieza.modelo} · ${pieza.categoria}',
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pieza.desguaceNombre,
                          style: TextStyle(
                            fontSize: 12,
                            color: desguaceColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pieza.distancia != null)
                          Text(
                            '${pieza.distancia!.toStringAsFixed(1)} km',
                            style: TextStyle(fontSize: 11, color: subtitleColor),
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
