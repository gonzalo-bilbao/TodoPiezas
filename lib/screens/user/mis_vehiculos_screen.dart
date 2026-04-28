import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/vehiculo.dart';
import '../../providers/vehiculos_provider.dart';

class MisVehiculosScreen extends StatefulWidget {
  const MisVehiculosScreen({super.key});

  @override
  State<MisVehiculosScreen> createState() => _MisVehiculosScreenState();
}

class _MisVehiculosScreenState extends State<MisVehiculosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculosProvider>().load();
    });
  }

  Future<void> _showForm({Vehiculo? v}) async {
    await showDialog(
      context: context,
      builder: (_) => _VehiculoFormDialog(vehiculo: v),
    );
  }

  Future<void> _confirmDelete(Vehiculo v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text('¿Eliminar "${v.displayName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<VehiculosProvider>().delete(v.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VehiculosProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.vehiculos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('Aún no tienes vehículos'),
                      const SizedBox(height: 8),
                      const Text('Añade el primero pulsando el botón naranja',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: p.vehiculos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final v = p.vehiculos[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, color: AppTheme.primary),
                        title: Text(
                          v.alias != null && v.alias!.isNotEmpty
                              ? v.alias!
                              : '${v.marca} ${v.modelo}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${v.marca} ${v.modelo}${v.anyo != null ? " · ${v.anyo}" : ""}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showForm(v: v),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _confirmDelete(v),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _VehiculoFormDialog extends StatefulWidget {
  final Vehiculo? vehiculo;
  const _VehiculoFormDialog({this.vehiculo});

  @override
  State<_VehiculoFormDialog> createState() => _VehiculoFormDialogState();
}

class _VehiculoFormDialogState extends State<_VehiculoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _alias;
  late final TextEditingController _modelo;
  late final TextEditingController _anyo;
  String? _marca;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculo;
    _alias  = TextEditingController(text: v?.alias ?? '');
    _modelo = TextEditingController(text: v?.modelo ?? '');
    _anyo   = TextEditingController(text: v?.anyo?.toString() ?? '');
    _marca  = v?.marca;
  }

  @override
  void dispose() {
    _alias.dispose();
    _modelo.dispose();
    _anyo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<VehiculosProvider>();
    final ok = widget.vehiculo == null
        ? await p.add(
            alias: _alias.text.trim().isEmpty ? null : _alias.text.trim(),
            marca: _marca!,
            modelo: _modelo.text.trim(),
            anyo: int.tryParse(_anyo.text),
          )
        : await p.update(
            widget.vehiculo!.id,
            alias: _alias.text.trim().isEmpty ? null : _alias.text.trim(),
            marca: _marca!,
            modelo: _modelo.text.trim(),
            anyo: int.tryParse(_anyo.text),
          );
    setState(() => _saving = false);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vehiculo == null ? 'Nuevo vehículo' : 'Editar vehículo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _alias,
                decoration: const InputDecoration(
                  labelText: 'Alias (opcional)',
                  hintText: 'Ej: Coche del trabajo',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _marca,
                decoration: const InputDecoration(labelText: 'Marca *'),
                items: AppConstants.marcas.map(
                  (m) => DropdownMenuItem(value: m, child: Text(m)),
                ).toList(),
                onChanged: (v) => setState(() => _marca = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelo,
                decoration: const InputDecoration(labelText: 'Modelo *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anyo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Año'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16, width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
