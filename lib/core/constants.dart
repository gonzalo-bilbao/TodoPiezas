import 'package:flutter/foundation.dart';

class AppConstants {
  // Web (Chrome) usa localhost, Android emulator usa 10.0.2.2
  static String get apiBaseUrl => kIsWeb
      ? 'http://localhost/todopiezas'
      : 'http://10.0.2.2/todopiezas';

  static const List<String> marcas = [
    'Seat', 'Volkswagen', 'Ford', 'Renault', 'Peugeot',
    'BMW', 'Mercedes', 'Audi', 'Toyota', 'Hyundai',
    'Opel', 'Citroën', 'Fiat', 'Honda', 'Nissan',
    'Kia', 'Mazda', 'Skoda', 'Dacia', 'Alfa Romeo',
  ];

  static const List<String> categorias = [
    'Motor', 'Carrocería', 'Interior', 'Suspensión',
    'Frenos', 'Eléctrico', 'Transmisión', 'Escape',
    'Dirección', 'Climatización',
  ];

  static const List<String> estados = ['Usado', 'Nuevo'];

  // Solo estas categorías tienen color visible
  static const List<String> categoriasConColor = ['Carrocería', 'Interior'];

  static const List<String> colores = [
    'Blanco', 'Negro', 'Gris', 'Rojo', 'Azul',
    'Verde', 'Amarillo', 'Naranja', 'Marrón', 'Plateado',
  ];
}