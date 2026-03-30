class Vehiculo {
  final int id;
  final String marca;
  final String modelo;
  final int anyo;

  Vehiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anyo,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) => Vehiculo(
        id: int.parse(json['id'].toString()),
        marca: json['marca'] ?? '',
        modelo: json['modelo'] ?? '',
        anyo: int.parse(json['anyo'].toString()),
      );
}
