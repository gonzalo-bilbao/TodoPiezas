class UsuarioParticular {
  final int id;
  final String email;
  final String nombre;
  final String? foto;

  UsuarioParticular({
    required this.id,
    required this.email,
    required this.nombre,
    this.foto,
  });

  factory UsuarioParticular.fromJson(Map<String, dynamic> json) => UsuarioParticular(
        id: int.parse(json['id'].toString()),
        email: json['email'] ?? '',
        nombre: json['nombre'] ?? '',
        foto: json['foto'],
      );
}
