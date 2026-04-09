import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/pieza.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'profile_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Pieza> _piezas = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPiezas();
  }

  Future<void> _loadPiezas() async {
    final auth = context.read<AuthProvider>();
    setState(() { _loading = true; _error = null; });
    try {
      _piezas = await ApiService.getAdminPiezas(auth.desguaceId!);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deletePieza(Pieza p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar pieza'),
        content: Text('¿Eliminar "${p.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deletePieza(p.id);
      _loadPiezas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.desguaceNombre ?? 'Panel Admin'),
        actions: [
          IconButton(
            onPressed: () async {
              final data = await ApiService.getDesguace(auth.desguaceId!);
              if (context.mounted) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(desguace: data)));
              }
            },
            icon: const Icon(Icons.store_outlined),
            tooltip: 'Perfil del desguace',
          ),
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva pieza'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadPiezas, child: const Text('Reintentar')),
                    ],
                  ),
                )
              : _piezas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No tienes piezas en el inventario',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showForm(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir primera pieza'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPiezas,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _piezas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _buildItem(_piezas[i]),
                      ),
                    ),
    );
  }

  Widget _buildItem(Pieza p) => Card(
        child: ListTile(
          leading: p.imagen != null && p.imagen!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    '${AppConstants.apiBaseUrl}/${p.imagen}',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.car_repair, color: Colors.white),
                    ),
                  ),
                )
              : const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.car_repair, color: Colors.white),
                ),
          title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${p.marca} ${p.modelo} · ${p.precio.toStringAsFixed(2)} €'),
          trailing: PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') _showForm(context, pieza: p);
              if (val == 'delete') _deletePieza(p);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      );

  void _showForm(BuildContext context, {Pieza? pieza}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PiezaFormSheet(pieza: pieza, onSaved: _loadPiezas),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Formulario de creación / edición de pieza
// ─────────────────────────────────────────────────────────────

class _PiezaFormSheet extends StatefulWidget {
  final Pieza? pieza;
  final VoidCallback onSaved;

  const _PiezaFormSheet({this.pieza, required this.onSaved});

  @override
  State<_PiezaFormSheet> createState() => _PiezaFormSheetState();
}

class _PiezaFormSheetState extends State<_PiezaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late final TextEditingController _modelo;
  late final TextEditingController _anyo;
  late final TextEditingController _stock;
  String? _marca;
  String? _categoria;
  String? _color;
  String? _estado;
  bool _saving = false;

  // Imagen
  Uint8List? _imageBytes;
  String? _imageFilename;
  String? _existingImagePath;

  @override
  void initState() {
    super.initState();
    final p = widget.pieza;
    _nombre      = TextEditingController(text: p?.nombre);
    _descripcion = TextEditingController(text: p?.descripcion);
    _precio      = TextEditingController(text: p?.precio.toString());
    _modelo      = TextEditingController(text: p?.modelo);
    _anyo        = TextEditingController(text: p?.anyo.toString());
    _stock       = TextEditingController(text: p?.stock.toString());
    _marca       = p?.marca;
    _categoria   = p?.categoria;
    _color       = p?.color;
    _estado      = p?.estado;
    _existingImagePath = p?.imagen;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _modelo.dispose();
    _anyo.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes   = bytes;
      _imageFilename = picked.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();

    try {
      String? imagePath = _existingImagePath;

      // Subir imagen si se seleccionó una nueva
      if (_imageBytes != null && _imageFilename != null) {
        imagePath = await ApiService.uploadImage(_imageBytes!, _imageFilename!);
      }

      final data = {
        'nombre':      _nombre.text.trim(),
        'descripcion': _descripcion.text.trim(),
        'precio':      double.parse(_precio.text),
        'marca':       _marca,
        'modelo':      _modelo.text.trim(),
        'anyo':        int.parse(_anyo.text),
        'categoria':   _categoria,
        'color':       _color ?? '',
        'estado':      _estado,
        'stock':       int.parse(_stock.text),
        'desguace_id': auth.desguaceId,
        if (imagePath != null) 'imagen': imagePath,
      };

      if (widget.pieza == null) {
        await ApiService.createPieza(data);
      } else {
        await ApiService.updatePieza(widget.pieza!.id, data);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.pieza == null ? 'Nueva pieza' : 'Editar pieza',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Selector de imagen
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : _existingImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${AppConstants.apiBaseUrl}/$_existingImagePath',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imagePlaceholder(),
                              ),
                            )
                          : _imagePlaceholder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre de la pieza *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _marca,
                    decoration: const InputDecoration(labelText: 'Marca *'),
                    items: AppConstants.marcas
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _marca = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _modelo,
                    decoration: const InputDecoration(labelText: 'Modelo *'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _anyo,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Año *'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Precio (€) *'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock *'),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: const InputDecoration(labelText: 'Categoría *'),
                    items: AppConstants.categorias
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: const InputDecoration(labelText: 'Estado *'),
                    items: AppConstants.estados
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _estado = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _color,
                decoration: const InputDecoration(labelText: 'Color'),
                items: AppConstants.colores
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
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
                      : Text(widget.pieza == null ? 'Crear pieza' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey),
          SizedBox(height: 6),
          Text('Añadir foto', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      );
}
