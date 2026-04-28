class Vehiculo {
  final int id;
  final String? alias;
  final String marca;
  final String modelo;
  final int? anyo;

  Vehiculo({
    required this.id,
    this.alias,
    required this.marca,
    required this.modelo,
    this.anyo,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) => Vehiculo(
        id: int.parse(json['id'].toString()),
        alias: json['alias'],
        marca: json['marca'] ?? '',
        modelo: json['modelo'] ?? '',
        anyo: json['anyo'] == null ? null : int.tryParse(json['anyo'].toString()),
      );

  String get displayName {
    if (alias != null && alias!.isNotEmpty) return alias!;
    return '$marca $modelo${anyo != null ? " ($anyo)" : ""}';
  }
}
