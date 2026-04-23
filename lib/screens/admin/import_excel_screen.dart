import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Campos destino a los que se pueden mapear las columnas del Excel.
const _camposDestino = [
  'nombre',
  'descripcion',
  'marca',
  'modelo',
  'anyo',
  'categoria',
  'estado',
  'color',
  'precio',
  'stock',
];

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  List<String> _columnasExcel = [];
  List<List<String?>> _filas = [];
  // mapeo: columna Excel -> campo destino (o null para ignorar)
  final Map<int, String?> _mapeo = {};
  bool _loading = false;
  String? _filename;

  /// Extrae el valor de una celda de Excel 4.x (sealed class CellValue).
  String? _cellText(Data? cell) {
    if (cell == null) return null;
    final v = cell.value;
    if (v == null) return null;
    if (v is TextCellValue) return v.value.text;
    if (v is IntCellValue) return v.value.toString();
    if (v is DoubleCellValue) return v.value.toString();
    if (v is BoolCellValue) return v.value.toString();
    if (v is DateCellValue) return '${v.year}-${v.month}-${v.day}';
    return v.toString();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final bytes = result.files.single.bytes!;
    _filename = result.files.single.name;
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        _showError('El Excel no tiene hojas');
        return;
      }
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null || sheet.rows.isEmpty) {
        _showError('El archivo está vacío');
        return;
      }
      // Primera fila = cabecera
      final header = sheet.rows.first.map((c) => _cellText(c) ?? '').toList();
      final datos = sheet.rows.skip(1).map(
        (row) => row.map(_cellText).toList(),
      ).toList();

      setState(() {
        _columnasExcel = header;
        _filas = datos;
        _mapeo.clear();
        // Auto-mapeo por similitud
        for (var i = 0; i < header.length; i++) {
          final h = header[i].toLowerCase().trim();
          final encontrado = _camposDestino.firstWhere(
            (c) => c == h || h.contains(c),
            orElse: () => '',
          );
          _mapeo[i] = encontrado.isEmpty ? null : encontrado;
        }
      });
    } catch (e) {
      _showError('Error al leer Excel: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _importar() async {
    // Validar que haya mapeo para campos obligatorios
    final mapeados = _mapeo.values.whereType<String>().toSet();
    if (!mapeados.contains('nombre') || !mapeados.contains('precio')) {
      _showError('Debes mapear al menos "nombre" y "precio"');
      return;
    }

    // Construir lista de piezas
    final piezas = <Map<String, dynamic>>[];
    for (final fila in _filas) {
      final p = <String, dynamic>{};
      _mapeo.forEach((colIdx, campo) {
        if (campo == null || colIdx >= fila.length) return;
        p[campo] = fila[colIdx];
      });
      if ((p['nombre'] ?? '').toString().trim().isNotEmpty) {
        piezas.add(p);
      }
    }

    if (piezas.isEmpty) {
      _showError('No hay filas válidas para importar');
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final data = await ApiService.importExcel(
        token: ApiService.tokenValue ?? '',
        piezas: piezas,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${data['insertadas']} piezas importadas')),
      );
      if ((data['errores'] as List?)?.isNotEmpty ?? false) {
        _showError('Algunas filas dieron error');
      }
      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar inventario (Excel)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de archivo
            if (_columnasExcel.isEmpty) ...[
              const SizedBox(height: 40),
              Icon(Icons.table_view, size: 80, color: AppTheme.primary.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'Selecciona un archivo Excel (.xlsx) con tu inventario. '
                'La primera fila debe ser la cabecera con los nombres de columna.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar archivo'),
              ),
            ] else ...[
              // Cabecera del archivo cargado
              Card(
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(_filename ?? 'Archivo'),
                  subtitle: Text(
                      '${_columnasExcel.length} columnas · ${_filas.length} filas'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _columnasExcel = [];
                      _filas = [];
                      _mapeo.clear();
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Asigna cada columna del Excel a un campo de la pieza:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _columnasExcel.length,
                  itemBuilder: (context, i) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Columna Excel',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Text(
                                  _columnasExcel[i],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _mapeo[i],
                              isDense: true,
                              decoration: const InputDecoration(
                                labelText: 'Campo destino',
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                    value: null, child: Text('(ignorar)')),
                                ..._camposDestino.map(
                                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                                ),
                              ],
                              onChanged: (v) => setState(() => _mapeo[i] = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loading ? null : _importar,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload),
                label: const Text('Importar al inventario'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
