-- ============================================================
-- TodoPiezas - Esquema de base de datos
-- Motor: MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS todopiezas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE todopiezas;

-- ------------------------------------------------------------
-- Tabla: desguaces  (los negocios que usan la app)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS desguaces (
    id         INT            PRIMARY KEY AUTO_INCREMENT,
    nombre     VARCHAR(100)   NOT NULL,
    direccion  VARCHAR(200)   NOT NULL,
    telefono   VARCHAR(20)    NOT NULL,
    whatsapp   VARCHAR(20)    NULL,
    email      VARCHAR(100)   UNIQUE NOT NULL,
    password   VARCHAR(255)   NOT NULL,
    lat        DECIMAL(10,8)  NOT NULL DEFAULT 40.41650000,
    lng        DECIMAL(11,8)  NOT NULL DEFAULT -3.70380000,
    horario    VARCHAR(100)   DEFAULT 'Lun-Vie 9:00-18:00',
    created_at TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Tabla: usuarios  (clientes que buscan piezas)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id         INT          PRIMARY KEY AUTO_INCREMENT,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    password   VARCHAR(255) NOT NULL,
    telefono   VARCHAR(20),
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Tabla: piezas  (inventario de cada desguace)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS piezas (
    id          INT                   PRIMARY KEY AUTO_INCREMENT,
    nombre      VARCHAR(100)          NOT NULL,
    descripcion TEXT,
    precio      DECIMAL(10,2)         NOT NULL,
    estado      ENUM('Nuevo','Usado') DEFAULT 'Usado',
    imagen      VARCHAR(255),
    color       VARCHAR(50)           DEFAULT '',
    stock       INT                   DEFAULT 1,
    categoria   VARCHAR(50)           NOT NULL,
    marca       VARCHAR(50)           NOT NULL,
    modelo      VARCHAR(50)           NOT NULL,
    anyo        SMALLINT UNSIGNED     NOT NULL,
    desguace_id INT                   NOT NULL,
    created_at  TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (desguace_id) REFERENCES desguaces(id) ON DELETE CASCADE,
    INDEX idx_marca      (marca),
    INDEX idx_categoria  (categoria),
    INDEX idx_desguace   (desguace_id)
);

-- ------------------------------------------------------------
-- Tabla: pedidos  (cuando un cliente contacta por una pieza)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    id          INT       PRIMARY KEY AUTO_INCREMENT,
    usuario_id  INT       NOT NULL,
    pieza_id    INT       NOT NULL,
    desguace_id INT       NOT NULL,
    estado      ENUM('pendiente','confirmado','entregado','cancelado')
                          DEFAULT 'pendiente',
    mensaje     TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id)  REFERENCES usuarios(id),
    FOREIGN KEY (pieza_id)    REFERENCES piezas(id),
    FOREIGN KEY (desguace_id) REFERENCES desguaces(id),
    INDEX idx_usuario (usuario_id),
    INDEX idx_estado  (estado)
);

-- ============================================================
-- DATOS DE EJEMPLO
-- Contraseña de todos: password
-- ============================================================

INSERT INTO desguaces (nombre, direccion, telefono, email, password, lat, lng, horario) VALUES
  ('Desguace El Motor',
   'Calle Industrial 15, Polígono Norte, Madrid', '912345678',
   'motor@desguace.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   40.47360000, -3.56990000, 'Lun-Sáb 8:00-19:00'),

  ('Piezas García',
   'Polígono Sur, Nave 7, Sevilla', '954321098',
   'garcia@piezas.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   37.36130000, -5.96590000, 'Lun-Vie 9:00-18:00'),

  ('AutoRecambios Valencia',
   'Avenida del Cid 45, Valencia', '963456789',
   'info@autorecambios.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   39.46990000, -0.37630000, 'Lun-Vie 8:30-17:30, Sáb 9:00-14:00');

INSERT INTO usuarios (nombre, email, password, telefono) VALUES
  ('Carlos López',    'carlos@email.com',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '600111222'),
  ('María Fernández', 'maria@email.com',    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '600333444'),
  ('Javier Ruiz',     'javier@email.com',   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '611222333'),
  ('Laura Martínez',  'laura@email.com',    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '622444555'),
  ('Pedro Sánchez',   'pedro@email.com',    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '633555666');

INSERT INTO piezas (nombre, descripcion, precio, estado, color, stock, categoria, marca, modelo, anyo, desguace_id) VALUES
  -- Desguace 1 - El Motor (Madrid)
  ('Alternador',              'Probado, funciona perfectamente',        85.00, 'Usado', 'Gris',    2, 'Eléctrico',   'Seat',       'Ibiza',      2015, 1),
  ('Puerta delantera izq.',   'Sin golpes, pintura original',          120.00, 'Usado', 'Rojo',    1, 'Carrocería',  'Seat',       'Ibiza',      2015, 1),
  ('Motor completo 1.6 TDI',  'Baja millas, 98.000 km',               950.00, 'Usado', 'Negro',   1, 'Motor',       'Volkswagen', 'Golf',       2018, 1),
  ('Salpicadero completo',    'Sin fisuras, con airbag',               220.00, 'Usado', 'Gris',    1, 'Interior',    'Peugeot',    '308',        2016, 1),
  ('Radiador agua',           'En perfecto estado, sin fugas',          95.00, 'Usado', 'Gris',    2, 'Motor',       'Seat',       'León',       2017, 1),
  ('Bomba de combustible',    'Original, desmontada de vehículo 80km',  65.00, 'Usado', 'Negro',   3, 'Motor',       'Volkswagen', 'Passat',     2016, 1),
  ('Luna delantera',          'Sin fisuras ni astillas',               180.00, 'Usado', 'Gris',    1, 'Carrocería',  'Renault',    'Clio',       2019, 1),
  ('Asiento conductor',       'Cuero negro, regulable eléctricamente', 250.00, 'Usado', 'Negro',   1, 'Interior',    'BMW',        'Serie 5',    2018, 1),

  -- Desguace 2 - Piezas García (Sevilla)
  ('Paragolpes delantero',    'Pequeño arañazo inferior',               75.00, 'Usado', 'Blanco',  1, 'Carrocería',  'Renault',    'Megane',     2016, 2),
  ('Caja de cambios manual',  '5 velocidades, funciona perfecta',      380.00, 'Usado', 'Gris',    1, 'Transmisión', 'Ford',       'Focus',      2014, 2),
  ('Turbo 1.9 TDI',           'Reparado y probado en banco',           320.00, 'Usado', 'Negro',   1, 'Motor',       'Volkswagen', 'Golf',       2013, 2),
  ('Capó delantero',          'Sin abolladuras, necesita pintura',      90.00, 'Usado', 'Azul',    1, 'Carrocería',  'Ford',       'Focus',      2015, 2),
  ('Centralita motor',        'Original, compatible 1.6 gasolina',    160.00, 'Usado', 'Negro',   2, 'Eléctrico',   'Renault',    'Laguna',     2012, 2),
  ('Diferencial trasero',     'Baja millas, excelente estado',         280.00, 'Usado', 'Gris',    1, 'Transmisión', 'BMW',        'Serie 3',    2016, 2),
  ('Retrovisor derecho',      'Eléctrico, con intermitente',            55.00, 'Usado', 'Plata',   2, 'Carrocería',  'Toyota',     'Auris',      2017, 2),
  ('Compresor aire acond.',   'Funciona correctamente',                195.00, 'Usado', 'Gris',    1, 'Motor',       'Seat',       'Alhambra',   2015, 2),

  -- Desguace 3 - AutoRecambios Valencia
  ('Faro delantero derecho',  'Nuevo, nunca montado',                  145.00, 'Nuevo', 'Gris',    3, 'Eléctrico',   'BMW',        'Serie 3',    2019, 3),
  ('Amortiguador trasero',    'Par completo',                          110.00, 'Usado', 'Negro',   2, 'Suspensión',  'Toyota',     'Corolla',    2017, 3),
  ('Motor arranque',          'Revisado, garantía 3 meses',             70.00, 'Usado', 'Gris',    2, 'Eléctrico',   'Opel',       'Astra',      2014, 3),
  ('Maletero completo',       'Con paragolpes y cerradura',            310.00, 'Usado', 'Negro',   1, 'Carrocería',  'Audi',       'A4',         2018, 3),
  ('Suspensión delantera',    'Brazos y muelles, kit completo',        220.00, 'Usado', 'Gris',    1, 'Suspensión',  'Mercedes',   'Clase C',    2017, 3),
  ('Volante con airbag',      'Original, sin disparar',                175.00, 'Usado', 'Negro',   1, 'Interior',    'Volkswagen', 'Tiguan',     2019, 3),
  ('Catalizador',             'Sin roturas internas',                   85.00, 'Usado', 'Gris',    2, 'Motor',       'Toyota',     'Yaris',      2016, 3),
  ('Cuadro de instrumentos',  'Digital, todos los indicadores ok',     130.00, 'Usado', 'Negro',   1, 'Eléctrico',   'Ford',       'Mondeo',     2017, 3);

INSERT INTO pedidos (usuario_id, pieza_id, desguace_id, estado, mensaje) VALUES
  (1,  1, 1, 'pendiente',   '¿Sigue disponible el alternador?'),
  (2, 17, 3, 'confirmado',  'Reservo el faro, paso esta semana.'),
  (1,  3, 1, 'cancelado',   'Al final no lo necesito, gracias.'),
  (3, 10, 2, 'entregado',   'Recogido ayer, todo perfecto.'),
  (4, 18, 3, 'pendiente',   'Necesito los dos amortiguadores.'),
  (5,  5, 1, 'confirmado',  '¿Puedo pasar el lunes por la mañana?'),
  (2, 12, 2, 'pendiente',   '¿Tiene el capó en otro color?'),
  (3, 22, 3, 'entregado',   'El volante llegó en perfecto estado.'),
  (1, 15, 2, 'cancelado',   'Ya encontré uno más cerca, disculpa.'),
  (4,  8, 1, 'confirmado',  'Reservo el asiento, voy el viernes.');

-- ============================================================
-- Tabla: usuarios_particulares  (clientes que usan la app)
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios_particulares (
  id         INT          PRIMARY KEY AUTO_INCREMENT,
  email      VARCHAR(100) NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL,
  nombre     VARCHAR(100) NOT NULL,
  foto       VARCHAR(255) NULL,
  marca      VARCHAR(50)  NULL,
  modelo     VARCHAR(50)  NULL,
  anyo       INT          NULL,
  created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Tabla: favoritos  (piezas guardadas por un usuario particular)
-- ============================================================
CREATE TABLE IF NOT EXISTS favoritos (
  id         INT       PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT       NOT NULL,
  pieza_id   INT       NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_fav (usuario_id, pieza_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios_particulares(id) ON DELETE CASCADE,
  FOREIGN KEY (pieza_id)   REFERENCES piezas(id)                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- Tabla: vehiculos_usuario  (los coches de cada usuario, varios por usuario)
-- ============================================================
CREATE TABLE IF NOT EXISTS vehiculos_usuario (
  id          INT          PRIMARY KEY AUTO_INCREMENT,
  usuario_id  INT          NOT NULL,
  alias       VARCHAR(50)  NULL,
  marca       VARCHAR(50)  NOT NULL,
  modelo      VARCHAR(50)  NOT NULL,
  anyo        INT          NULL,
  foto        VARCHAR(255) NULL,
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios_particulares(id) ON DELETE CASCADE,
  INDEX idx_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
