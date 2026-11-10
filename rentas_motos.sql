-- Base de datos: rentas_motos
-- Motor: MySQL 8.0
-- Tablas: clientes, motos, rentas, pagos, mantenimientos (10 registros cada una)

CREATE DATABASE IF NOT EXISTS rentas_motos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE rentas_motos;

CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL,
  apellido VARCHAR(60) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  licencia VARCHAR(20) NOT NULL UNIQUE,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_clientes_email CHECK (email LIKE '%@%')
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS motos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  marca VARCHAR(40) NOT NULL,
  modelo VARCHAR(60) NOT NULL,
  placa VARCHAR(10) NOT NULL UNIQUE,
  anio SMALLINT NOT NULL,
  cilindrada SMALLINT NOT NULL,
  precio_dia DECIMAL(10,2) NOT NULL,
  estado ENUM('disponible', 'rentada', 'mantenimiento') NOT NULL DEFAULT 'disponible',
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_motos_anio CHECK (anio BETWEEN 1990 AND 2100),
  CONSTRAINT chk_motos_cilindrada CHECK (cilindrada > 0),
  CONSTRAINT chk_motos_precio CHECK (precio_dia > 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS rentas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  moto_id INT NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  estado ENUM('activa', 'finalizada', 'cancelada') NOT NULL DEFAULT 'activa',
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rentas_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rentas_moto FOREIGN KEY (moto_id) REFERENCES motos (id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_rentas_fechas CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT chk_rentas_total CHECK (total >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pagos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  renta_id INT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  metodo ENUM('efectivo', 'tarjeta', 'transferencia') NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  referencia VARCHAR(30) NOT NULL UNIQUE,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pagos_renta FOREIGN KEY (renta_id) REFERENCES rentas (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_pagos_monto CHECK (monto > 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS mantenimientos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  moto_id INT NOT NULL,
  fecha DATE NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  costo DECIMAL(10,2) NOT NULL,
  realizado_por VARCHAR(80),
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mantenimientos_moto FOREIGN KEY (moto_id) REFERENCES motos (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_mantenimientos_costo CHECK (costo >= 0)
) ENGINE = InnoDB;

CREATE INDEX idx_rentas_estado ON rentas (estado);
CREATE INDEX idx_pagos_fecha ON pagos (fecha_pago);
CREATE INDEX idx_mantenimientos_fecha ON mantenimientos (fecha);

-- -------------------------
-- Datos de prueba (10 filas)
-- -------------------------
INSERT IGNORE INTO clientes (id, nombre, apellido, email, telefono, licencia) VALUES
  (1,  'Ana',     'Torres',   'ana.torres@example.com',      '555-1001', 'LIC-1001'),
  (2,  'Luis',    'Ramirez',  'luis.ramirez@example.com',    '555-1002', 'LIC-1002'),
  (3,  'Maria',   'Gomez',    'maria.gomez@example.com',     '555-1003', 'LIC-1003'),
  (4,  'Carlos',  'Mendez',   'carlos.mendez@example.com',   '555-1004', 'LIC-1004'),
  (5,  'Sofia',   'Herrera',  'sofia.herrera@example.com',   '555-1005', 'LIC-1005'),
  (6,  'Diego',   'Castillo', 'diego.castillo@example.com',  '555-1006', 'LIC-1006'),
  (7,  'Valeria', 'Rojas',    'valeria.rojas@example.com',   '555-1007', 'LIC-1007'),
  (8,  'Jorge',   'Morales',  'jorge.morales@example.com',   '555-1008', 'LIC-1008'),
  (9,  'Camila',  'Vega',     'camila.vega@example.com',     '555-1009', 'LIC-1009'),
  (10, 'Andres',  'Navarro',  'andres.navarro@example.com',  '555-1010', 'LIC-1010');

INSERT IGNORE INTO motos (id, marca, modelo, placa, anio, cilindrada, precio_dia, estado) VALUES
  (1,  'Honda',         'CB 190R',          'MOTO-001', 2023, 190, 35.00, 'disponible'),
  (2,  'Yamaha',        'FZ 25',            'MOTO-002', 2024, 250, 40.00, 'disponible'),
  (3,  'Suzuki',        'Gixxer 250',       'MOTO-003', 2023, 250, 42.00, 'rentada'),
  (4,  'Bajaj',         'Pulsar NS 200',    'MOTO-004', 2022, 200, 30.00, 'disponible'),
  (5,  'KTM',           'Duke 200',         'MOTO-005', 2024, 200, 45.00, 'mantenimiento'),
  (6,  'Honda',         'XR 150',           'MOTO-006', 2023, 150, 28.00, 'disponible'),
  (7,  'Yamaha',        'XTZ 150',          'MOTO-007', 2022, 150, 32.00, 'disponible'),
  (8,  'TVS',           'Apache RTR 200',   'MOTO-008', 2024, 200, 38.00, 'rentada'),
  (9,  'Benelli',       'TNT 150',          'MOTO-009', 2023, 150, 30.00, 'disponible'),
  (10, 'Royal Enfield', 'Hunter 350',       'MOTO-010', 2024, 350, 55.00, 'disponible');

INSERT IGNORE INTO rentas (id, cliente_id, moto_id, fecha_inicio, fecha_fin, total, estado) VALUES
  (1,  1,  1,  '2026-11-01', '2026-11-03', 70.00,  'finalizada'),
  (2,  2,  2,  '2026-11-02', '2026-11-05', 120.00, 'finalizada'),
  (3,  3,  3,  '2026-11-03', '2026-11-07', 168.00, 'activa'),
  (4,  4,  4,  '2026-11-04', '2026-11-06', 60.00,  'finalizada'),
  (5,  5,  5,  '2026-11-05', '2026-11-08', 135.00, 'cancelada'),
  (6,  6,  6,  '2026-11-06', '2026-11-09', 84.00,  'finalizada'),
  (7,  7,  7,  '2026-11-07', '2026-11-10', 96.00,  'activa'),
  (8,  8,  8,  '2026-11-08', '2026-11-12', 152.00, 'activa'),
  (9,  9,  9,  '2026-11-09', '2026-11-11', 60.00,  'activa'),
  (10, 10, 10, '2026-11-10', '2026-11-14', 220.00, 'activa');

INSERT IGNORE INTO pagos (id, renta_id, monto, metodo, fecha_pago, referencia) VALUES
  (1,  1,  70.00,  'tarjeta',       '2026-11-01 10:30:00', 'PAGO-001'),
  (2,  2,  120.00, 'transferencia', '2026-11-02 09:15:00', 'PAGO-002'),
  (3,  3,  168.00, 'tarjeta',       '2026-11-03 11:00:00', 'PAGO-003'),
  (4,  4,  60.00,  'efectivo',      '2026-11-04 08:45:00', 'PAGO-004'),
  (5,  5,  135.00, 'tarjeta',       '2026-11-05 12:20:00', 'PAGO-005'),
  (6,  6,  84.00,  'transferencia', '2026-11-06 10:05:00', 'PAGO-006'),
  (7,  7,  96.00,  'efectivo',      '2026-11-07 09:40:00', 'PAGO-007'),
  (8,  8,  152.00, 'tarjeta',       '2026-11-08 11:10:00', 'PAGO-008'),
  (9,  9,  60.00,  'transferencia', '2026-11-09 08:55:00', 'PAGO-009'),
  (10, 10, 220.00, 'tarjeta',       '2026-11-10 10:00:00', 'PAGO-010');

INSERT IGNORE INTO mantenimientos (id, moto_id, fecha, descripcion, costo, realizado_por) VALUES
  (1,  1,  '2026-10-15', 'Cambio de aceite y filtro',      45.00,  'Taller MotoPro'),
  (2,  2,  '2026-10-16', 'Revision de frenos',             60.00,  'Taller MotoPro'),
  (3,  3,  '2026-10-17', 'Cambio de cadena y pinon',       120.00, 'MotoService'),
  (4,  4,  '2026-10-18', 'Ajuste de valvulas',             80.00,  'MotoService'),
  (5,  5,  '2026-10-19', 'Reparacion de suspension',       250.00, 'Taller MotoPro'),
  (6,  6,  '2026-10-20', 'Cambio de neumatico trasero',    95.00,  'Llantas del Sur'),
  (7,  7,  '2026-10-21', 'Limpieza de carburador',         55.00,  'MotoService'),
  (8,  8,  '2026-10-22', 'Cambio de aceite',               40.00,  'Taller MotoPro'),
  (9,  9,  '2026-10-23', 'Revision electrica',             70.00,  'MotoService'),
  (10, 10, '2026-10-24', 'Cambio de pastillas de freno',   110.00, 'Llantas del Sur');
