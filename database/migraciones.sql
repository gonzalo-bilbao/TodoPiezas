-- =====================================================
-- MIGRACIÓN: Añadir columna whatsapp a desguaces
-- =====================================================
ALTER TABLE desguaces
  ADD COLUMN whatsapp VARCHAR(20) NULL AFTER telefono;

-- =====================================================
-- NUEVA TABLA: usuarios_particulares
-- (clientes que usan la app para buscar piezas)
-- =====================================================
CREATE TABLE IF NOT EXISTS usuarios_particulares (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  foto VARCHAR(255) NULL,
  marca VARCHAR(50) NULL,
  modelo VARCHAR(50) NULL,
  anyo INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- NUEVA TABLA: favoritos
-- =====================================================
CREATE TABLE IF NOT EXISTS favoritos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  pieza_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_fav (usuario_id, pieza_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios_particulares(id) ON DELETE CASCADE,
  FOREIGN KEY (pieza_id) REFERENCES piezas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Carpeta para fotos de perfil de usuarios
-- Crear manualmente: /uploads/usuarios/
-- =====================================================
