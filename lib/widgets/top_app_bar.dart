import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
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
        // Usuario (avatar con punto verde si está logueado)
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => user.isLoggedIn
                      ? const UserProfileScreen()
                      : const UserLoginScreen(),
                ),
              ),
              child: Tooltip(
                message: user.isLoggedIn
                    ? 'Sesión iniciada: ${user.usuario?.nombre ?? ""}'
                    : 'Iniciar sesión',
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (user.isLoggedIn)
                      _LoggedAvatar(user: user)
                    else
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.person_outline),
                      ),
                    if (user.isLoggedIn)
                      Positioned(
                        right: 2, bottom: 2,
                        child: Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoggedAvatar extends StatelessWidget {
  final UserProvider user;
  const _LoggedAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = user.usuario!;
    final inicial = u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?';
    final hasFoto = u.foto != null && u.foto!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: AppTheme.primary,
        backgroundImage: hasFoto ? NetworkImage(AppConstants.imageUrl(u.foto)) : null,
        child: hasFoto
            ? null
            : Text(
                inicial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
