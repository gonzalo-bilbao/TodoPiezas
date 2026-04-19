import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../screens/info/about_screen.dart';
import '../screens/user/user_login_screen.dart';
import '../screens/user/user_profile_screen.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? extraActions;
  const TopAppBar({super.key, required this.title, this.extraActions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final user = context.watch<UserProvider>();

    return AppBar(
      title: Text(title),
      actions: [
        ...?extraActions,
        // Modo oscuro
        IconButton(
          tooltip: theme.isDark ? 'Modo claro' : 'Modo oscuro',
          icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => context.read<ThemeProvider>().toggle(),
        ),
        // Sobre nosotros
        IconButton(
          tooltip: 'Sobre nosotros',
          icon: const Icon(Icons.info_outline),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
        // Usuario
        IconButton(
          tooltip: user.isLoggedIn ? 'Mi perfil' : 'Iniciar sesión',
          icon: Icon(user.isLoggedIn ? Icons.account_circle : Icons.person_outline),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => user.isLoggedIn
                  ? const UserProfileScreen()
                  : const UserLoginScreen(),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
