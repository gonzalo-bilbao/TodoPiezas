class UsuarioParticular {
  final int id;
  final String email;
  final String nombre;
  final String? foto;
  final String? marca;
  final String? modelo;
  final int? anyo;

  UsuarioParticular({
    required this.id,
    required this.email,
    required this.nombre,
    this.foto,
    this.marca,
    this.modelo,
    this.anyo,
  });

  factory UsuarioParticular.fromJson(Map<String, dynamic> json) => UsuarioParticular(
        id: int.parse(json['id'].toString()),
        email: json['email'] ?? '',
        nombre: json['nombre'] ?? '',
        foto: json['foto'],
        marca: json['marca'],
        modelo: json['modelo'],
        anyo: json['anyo'] == null ? null : int.tryParse(json['anyo'].toString()),
      );
}
