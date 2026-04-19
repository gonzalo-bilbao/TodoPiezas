import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/favoritos_provider.dart';
import '../../services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nombre = TextEditingController();
  final _modelo = TextEditingController();
  final _anyo = TextEditingController();
  String? _marca;
  Uint8List? _fotoBytes;
  String? _fotoFilename;

  @override
  void initState() {
    super.initState();
    final u = context.read<UserProvider>().usuario;
    if (u != null) {
      _nombre.text = u.nombre;
      _modelo.text = u.modelo ?? '';
      _anyo.text = u.anyo?.toString() ?? '';
      _marca = u.marca;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _modelo.dispose();
    _anyo.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoFilename = picked.name;
      });
    }
  }

  Future<void> _save() async {
    final user = context.read<UserProvider>();
    String? fotoPath;
    try {
      if (_fotoBytes != null && _fotoFilename != null) {
        fotoPath = await ApiService.uploadUserImage(_fotoBytes!, _fotoFilename!);
      }
      final ok = await user.updateProfile(
        nombre: _nombre.text.trim(),
        marca: _marca,
        modelo: _modelo.text.trim().isEmpty ? null : _modelo.text.trim(),
        anyo: int.tryParse(_anyo.text),
        foto: fotoPath,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Perfil actualizado' : (user.error ?? 'Error'))),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _logout() async {
    await context.read<UserProvider>().logout();
    await context.read<FavoritosProvider>().setToken(null);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final u = user.usuario;
    if (u == null) return const SizedBox.shrink();

    ImageProvider? avatar;
    if (_fotoBytes != null) {
      avatar = MemoryImage(_fotoBytes!);
    } else if (u.foto != null && u.foto!.isNotEmpty) {
      avatar = NetworkImage('${AppConstants.apiBaseUrl}/${u.foto}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                      backgroundImage: avatar,
                      child: avatar == null
                          ? Text(
                              u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                              style: GoogleFonts.exo2(
                                fontSize: 36, fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                u.email,
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            Text('Datos personales', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            Text('Mi vehículo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _marca,
              decoration: const InputDecoration(
                labelText: 'Marca',
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('—')),
                ...AppConstants.marcas.map(
                  (m) => DropdownMenuItem(value: m, child: Text(m)),
                ),
              ],
              onChanged: (v) => setState(() => _marca = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelo,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                prefixIcon: Icon(Icons.airline_seat_recline_normal),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _anyo,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Año',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: user.loading ? null : _save,
              icon: const Icon(Icons.save),
              label: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
