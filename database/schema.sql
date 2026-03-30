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
  ('Carlos López',    'carlos@email.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '600111222'),
  ('María Fernández', 'maria@email.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '600333444');

INSERT INTO piezas (nombre, descripcion, precio, estado, color, stock, categoria, marca, modelo, anyo, desguace_id) VALUES
  ('Alternador',              'Probado, funciona perfectamente',   85.00, 'Usado', 'Gris',   2, 'Eléctrico',   'Seat',       'Ibiza',   2015, 1),
  ('Puerta delantera izq.',   'Sin golpes, pintura original',     120.00, 'Usado', 'Rojo',   1, 'Carrocería',  'Seat',       'Ibiza',   2015, 1),
  ('Motor completo 1.6 TDI',  'Baja millas, 98.000 km',          950.00, 'Usado', 'Negro',  1, 'Motor',       'Volkswagen', 'Golf',    2018, 1),
  ('Paragolpes delantero',    'Pequeño arañazo inferior',          75.00, 'Usado', 'Blanco', 1, 'Carrocería',  'Renault',    'Megane',  2016, 2),
  ('Caja de cambios manual',  '5 velocidades, funciona perfecta', 380.00, 'Usado', 'Gris',   1, 'Transmisión', 'Ford',       'Focus',   2014, 2),
  ('Faro delantero derecho',  'Nuevo, nunca montado',             145.00, 'Nuevo', 'Gris',   3, 'Eléctrico',   'BMW',        'Serie 3', 2019, 3),
  ('Amortiguador trasero',    'Par completo',                     110.00, 'Usado', 'Negro',  2, 'Suspensión',  'Toyota',     'Corolla', 2017, 3),
  ('Salpicadero completo',    'Sin fisuras, con airbag',          220.00, 'Usado', 'Gris',   1, 'Interior',    'Peugeot',    '308',     2016, 1);

INSERT INTO pedidos (usuario_id, pieza_id, desguace_id, estado, mensaje) VALUES
  (1, 1, 1, 'pendiente',  '¿Sigue disponible el alternador?'),
  (2, 6, 3, 'confirmado', 'Reservo el faro, paso esta semana.'),
  (1, 3, 1, 'cancelado',  'Al final no lo necesito, gracias.');
