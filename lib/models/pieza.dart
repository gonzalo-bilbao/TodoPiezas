class Pieza {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String estado; // 'Nuevo' | 'Usado'
  final String? imagen;
  final String color;
  final int stock;
  final String categoria;
  final String marca;
  final String modelo;
  final int anyo;
  final int desguaceId;
  final String desguaceNombre;
  final String desguaceTelefono;
  final double desguaceLat;
  final double desguaceLng;
  final String desguaceDireccion;
  double? distancia; // calculada en cliente (km)

  Pieza({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.estado,
    this.imagen,
    required this.color,
    required this.stock,
    required this.categoria,
    required this.marca,
    required this.modelo,
    required this.anyo,
    required this.desguaceId,
    required this.desguaceNombre,
    required this.desguaceTelefono,
    required this.desguaceLat,
    required this.desguaceLng,
    required this.desguaceDireccion,
    this.distancia,
  });

  factory Pieza.fromJson(Map<String, dynamic> json) => Pieza(
        id: int.parse(json['id'].toString()),
        nombre: json['nombre'] ?? '',
        descripcion: json['descripcion'] ?? '',
        precio: double.parse(json['precio'].toString()),
        estado: json['estado'] ?? 'Usado',
        imagen: json['imagen'],
        color: json['color'] ?? '',
        stock: int.parse(json['stock'].toString()),
        categoria: json['categoria'] ?? '',
        marca: json['marca'] ?? '',
        modelo: json['modelo'] ?? '',
        anyo: int.parse(json['anyo'].toString()),
        desguaceId: int.parse(json['desguace_id'].toString()),
        desguaceNombre: json['desguace_nombre'] ?? '',
        desguaceTelefono: json['desguace_telefono'] ?? '',
        desguaceLat: double.parse(json['desguace_lat'].toString()),
        desguaceLng: double.parse(json['desguace_lng'].toString()),
        desguaceDireccion: json['desguace_direccion'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'estado': estado,
        'color': color,
        'stock': stock,
        'categoria': categoria,
        'marca': marca,
        'modelo': modelo,
        'anyo': anyo,
        'desguace_id': desguaceId,
      };
}
