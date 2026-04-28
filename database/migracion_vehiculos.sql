-- ============================================================
-- Migración: tabla vehiculos_usuario (múltiples vehículos por usuario)
-- ============================================================

CREATE TABLE IF NOT EXISTS vehiculos_usuario (
  id          INT          PRIMARY KEY AUTO_INCREMENT,
  usuario_id  INT          NOT NULL,
  alias       VARCHAR(50)  NULL,
  marca       VARCHAR(50)  NOT NULL,
  modelo      VARCHAR(50)  NOT NULL,
  anyo        INT          NULL,
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios_particulares(id) ON DELETE CASCADE,
  INDEX idx_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Migrar los vehículos antiguos a la nueva tabla (si tenían alguno)
INSERT INTO vehiculos_usuario (usuario_id, marca, modelo, anyo, alias)
  SELECT id, marca, modelo, anyo, 'Mi coche'
  FROM usuarios_particulares
  WHERE marca IS NOT NULL AND marca != '';
