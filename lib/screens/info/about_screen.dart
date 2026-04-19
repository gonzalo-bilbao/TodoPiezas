import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre nosotros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo + título
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.build_circle, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'TodoPiezas',
                    style: GoogleFonts.exo2(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tu desguace, en tu bolsillo',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _SectionCard(
              icon: Icons.lightbulb_outline,
              title: '¿Qué es TodoPiezas?',
              content:
                  'TodoPiezas es una aplicación multiplataforma que conecta a particulares '
                  'y talleres con desguaces cercanos, permitiendo buscar piezas de recambio '
                  'para vehículos de forma rápida, intuitiva y desde cualquier dispositivo. '
                  'Olvídate de llamar uno por uno a los desguaces — aquí lo tienes todo en tu bolsillo.',
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.school_outlined,
              title: 'El proyecto',
              content:
                  'Este proyecto nace como Trabajo Fin de Grado del ciclo de Desarrollo de '
                  'Aplicaciones Multiplataforma en el IES Alonso de Avellaneda. Está desarrollado '
                  'con Flutter para el frontend y PHP + MySQL para el backend.',
            ),
            const SizedBox(height: 16),
            Text(
              'El equipo',
              style: GoogleFonts.exo2(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            const _MemberCard(
              nombre: 'Gonzalo Bilbao Alcázar',
              rol: 'Backend y gestión de proyecto',
            ),
            const SizedBox(height: 8),
            const _MemberCard(
              nombre: 'Vicente Mena',
              rol: 'Frontend y pruebas',
            ),
            const SizedBox(height: 8),
            const _MemberCard(
              nombre: 'Alberto Luque',
              rol: 'Frontend y diseño',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Junio 2026 · IES Alonso de Avellaneda',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _SectionCard({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String nombre;
  final String rol;
  const _MemberCard({required this.nombre, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Text(
            nombre[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(rol, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
