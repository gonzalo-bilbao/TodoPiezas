class Desguace {
  final int id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final double lat;
  final double lng;
  final String horario;
  double? distancia;

  Desguace({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.lat,
    required this.lng,
    required this.horario,
    this.distancia,
  });

  factory Desguace.fromJson(Map<String, dynamic> json) => Desguace(
        id: int.parse(json['id'].toString()),
        nombre: json['nombre'] ?? '',
        direccion: json['direccion'] ?? '',
        telefono: json['telefono'] ?? '',
        email: json['email'] ?? '',
        lat: double.parse(json['lat'].toString()),
        lng: double.parse(json['lng'].toString()),
        horario: json['horario'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'direccion': direccion,
        'telefono': telefono,
        'email': email,
        'lat': lat,
        'lng': lng,
        'horario': horario,
      };
}
