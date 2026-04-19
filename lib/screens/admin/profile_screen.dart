import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
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
  late final TextEditingController _whatsapp;
  late final TextEditingController _horario;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  bool _saving = false;

  // Import SQL
  String? _sqlFileName;
  String? _sqlContent;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    final d = widget.desguace;
    _nombre    = TextEditingController(text: d['nombre']?.toString() ?? '');
    _direccion = TextEditingController(text: d['direccion']?.toString() ?? '');
    _telefono  = TextEditingController(text: d['telefono']?.toString() ?? '');
    _whatsapp  = TextEditingController(text: d['whatsapp']?.toString() ?? '');
    _horario   = TextEditingController(text: d['horario']?.toString() ?? '');
    _lat       = TextEditingController(text: d['lat']?.toString() ?? '');
    _lng       = TextEditingController(text: d['lng']?.toString() ?? '');
    _lat.addListener(() => setState(() {}));
    _lng.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _telefono.dispose();
    _whatsapp.dispose();
    _horario.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  double? get _parsedLat => double.tryParse(_lat.text);
  double? get _parsedLng => double.tryParse(_lng.text);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() => _saving = true);
    try {
      await ApiService.updateDesguace(auth.desguaceId!, {
        'nombre':    _nombre.text.trim(),
        'direccion': _direccion.text.trim(),
        'telefono':  _telefono.text.trim(),
        'whatsapp':  _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickSqlFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sql'],
      withData: true,
    );
    if (result == null) return;
    final file = result.files.first;
    final content = String.fromCharCodes(file.bytes ?? []);
    setState(() {
      _sqlFileName = file.name;
      _sqlContent = content;
    });
  }

  Future<void> _importSql() async {
    if (_sqlContent == null) return;
    final auth = context.read<AuthProvider>();
    setState(() => _importing = true);
    try {
      final result = await ApiService.importSql(auth.desguaceId!, _sqlContent!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Importadas: ${result['insertadas']} piezas. Errores: ${result['errores']}',
            ),
          ),
        );
        setState(() { _sqlFileName = null; _sqlContent = null; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      setState(() => _importing = false);
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
                decoration: const InputDecoration(labelText: 'Nombre del desguace *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp (opcional)',
                  hintText: 'Ej: 34612345678',
                  prefixIcon: Icon(Icons.chat, color: Color(0xFF25D366)),
                ),
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
              // Mini-mapa
              if (_parsedLat != null && _parsedLng != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 180,
                    child: FlutterMap(
                      key: ValueKey('${_parsedLat}_${_parsedLng}'),
                      options: MapOptions(
                        initialCenter: LatLng(_parsedLat!, _parsedLng!),
                        initialZoom: 14,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.todopiezas.todopiezas_app',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(_parsedLat!, _parsedLng!),
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.location_pin,
                                color: AppTheme.primary, size: 44),
                          ),
                        ]),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Introduce coordenadas para ver el mapa',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(labelText: 'Latitud *'),
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
                      decoration: const InputDecoration(labelText: 'Longitud *'),
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
              const SizedBox(height: 32),
              // ── Importar inventario ──────────────────────────────────
              const _SectionTitle('Importar inventario (.sql)'),
              const SizedBox(height: 8),
              const Text(
                'Selecciona un archivo .sql con sentencias INSERT para importar piezas a tu inventario.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickSqlFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar archivo .sql'),
              ),
              if (_sqlFileName != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.insert_drive_file,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_sqlFileName!,
                          style: const TextStyle(fontSize: 13)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () =>
                          setState(() { _sqlFileName = null; _sqlContent = null; }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _importing ? null : _importSql,
                    child: _importing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Importar piezas'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
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
