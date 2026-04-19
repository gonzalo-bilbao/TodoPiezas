import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../search/search_screen.dart';
import '../auth/login_screen.dart';
import '../map/nearby_screen.dart';
import '../../core/theme.dart';
import '../../widgets/top_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'TodoPiezas'),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 90, height: 90),
                const SizedBox(height: 16),
                Text(
                  'TodoPiezas',
                  style: GoogleFonts.exo2(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu desguace, en tu bolsillo',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 56),
                // Botones en grid 2+1
                Row(
                  children: [
                    Expanded(
                      child: _HomeButton(
                        icon: Icons.search_rounded,
                        label: 'Buscar\npiezas',
                        gradient: AppTheme.primaryGradient,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SearchScreen())),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _HomeButton(
                        icon: Icons.near_me_rounded,
                        label: 'Desguace\ncercano',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A2E), Color(0xFF2E2E50)],
                        ),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NearbyScreen())),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _HomeButton(
                  icon: Icons.business_rounded,
                  label: 'Acceso desguace',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E2E50), Color(0xFF1A1A2E)],
                  ),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool fullWidth;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: fullWidth ? 16 : 24,
              horizontal: 16,
            ),
            child: fullWidth
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 32),
                      const SizedBox(height: 10),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.exo2(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
