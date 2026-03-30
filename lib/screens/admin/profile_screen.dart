import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> desguace;

  const ProfileScreen({super.key, required this.desguace});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _direccion;
  late final TextEditingController _telefono;
  late final TextEditingController _horario;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.desguace;
    _nombre    = TextEditingController(text: d['nombre']?.toString() ?? '');
    _direccion = TextEditingController(text: d['direccion']?.toString() ?? '');
    _telefono  = TextEditingController(text: d['telefono']?.toString() ?? '');
    _horario   = TextEditingController(text: d['horario']?.toString() ?? '');
    _lat       = TextEditingController(text: d['lat']?.toString() ?? '');
    _lng       = TextEditingController(text: d['lng']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _telefono.dispose();
    _horario.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() => _saving = true);

    try {
      await ApiService.updateDesguace(auth.desguaceId!, {
        'nombre':    _nombre.text.trim(),
        'direccion': _direccion.text.trim(),
        'telefono':  _telefono.text.trim(),
        'horario':   _horario.text.trim(),
        'lat':       double.tryParse(_lat.text) ?? 0.0,
        'lng':       double.tryParse(_lng.text) ?? 0.0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del desguace')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Información general'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration:
                    const InputDecoration(labelText: 'Nombre del desguace *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horario,
                decoration: const InputDecoration(
                  labelText: 'Horario',
                  hintText: 'Ej: Lun-Vie 8:00-18:00',
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Ubicación GPS'),
              const SizedBox(height: 8),
              const Text(
                'Busca tu dirección en Google Maps, haz clic derecho → "¿Qué hay aquí?" y copia las coordenadas.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                          const InputDecoration(labelText: 'Latitud *'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Número inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                          const InputDecoration(labelText: 'Longitud *'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Número inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondary,
        ),
      );
}
