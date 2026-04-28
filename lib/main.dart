import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/favoritos_provider.dart';
import 'providers/map_style_provider.dart';
import 'providers/preload_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/vehiculos_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  // Permitir que GoogleFonts use las fuentes que vengan empaquetadas en
  // pubspec si las hubiera y no descargue de internet en cada arranque.
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const TodoPiezasApp());
}

class TodoPiezasApp extends StatelessWidget {
  const TodoPiezasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MapStyleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => VehiculosProvider()),
        ChangeNotifierProvider(
          create: (_) => PreloadProvider()..startBackgroundPreload(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) => MaterialApp(
          title: 'TodoPiezas',
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProv.themeMode,
          debugShowCheckedModeBanner: false,
          home: const _AuthBootstrap(child: SplashScreen()),
        ),
      ),
    );
  }
}

/// Cuando UserProvider termina de cargar el token desde SharedPreferences,
/// inyecta ese token en FavoritosProvider y VehiculosProvider para que
/// arranquen su carga sin esperar a que el usuario navegue.
class _AuthBootstrap extends StatefulWidget {
  final Widget child;
  const _AuthBootstrap({required this.child});

  @override
  State<_AuthBootstrap> createState() => _AuthBootstrapState();
}

class _AuthBootstrapState extends State<_AuthBootstrap> {
  String? _appliedToken;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final t = user.token;
    if (t != _appliedToken) {
      _appliedToken = t;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FavoritosProvider>().setToken(t);
        context.read<VehiculosProvider>().setToken(t);
      });
    }
    return widget.child;
  }
}
