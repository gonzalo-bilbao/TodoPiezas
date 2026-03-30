class AppConstants {
  // Cambia esta URL por la IP/dominio real de tu servidor PHP
  // En emulador Android: 10.0.2.2 apunta a localhost del PC
  static const String apiBaseUrl = 'http://10.0.2.2/todopiezas/api';

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

  static const List<String> colores = [
    'Blanco', 'Negro', 'Gris', 'Rojo', 'Azul',
    'Verde', 'Amarillo', 'Naranja', 'Marrón', 'Plateado',
  ];
}
