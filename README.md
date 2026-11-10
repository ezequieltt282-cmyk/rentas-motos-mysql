# Rentas de Motos — Base de datos MySQL

Base de datos relacional para gestionar el alquiler de motocicletas: clientes, motos, rentas, pagos y mantenimientos.

- **Motor:** MySQL 8.0 (InnoDB, `utf8mb4`)
- **Base:** `rentas_motos`
- **Registros de ejemplo:** 10 por tabla (50 en total)

## Modelo relacional

```
clientes 1 ───── N rentas N ───── 1 motos
                     │                 │
                     1                 1
                     │                 │
                     N                 N
                   pagos        mantenimientos
```

| Relación | Clave foránea |
|---|---|
| `rentas.cliente_id` | → `clientes.id` |
| `rentas.moto_id` | → `motos.id` |
| `pagos.renta_id` | → `rentas.id` |
| `mantenimientos.moto_id` | → `motos.id` |

## Tablas

### `clientes`
| Columna | Tipo | Restricciones |
|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT |
| `nombre` | VARCHAR(60) | NOT NULL |
| `apellido` | VARCHAR(60) | NOT NULL |
| `email` | VARCHAR(120) | NOT NULL, UNIQUE |
| `telefono` | VARCHAR(20) | — |
| `licencia` | VARCHAR(20) | NOT NULL, UNIQUE |
| `creado_en` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

### `motos`
| Columna | Tipo | Restricciones |
|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT |
| `marca` | VARCHAR(40) | NOT NULL |
| `modelo` | VARCHAR(60) | NOT NULL |
| `placa` | VARCHAR(10) | NOT NULL, UNIQUE |
| `anio` | SMALLINT | CHECK entre 1990 y 2100 |
| `cilindrada` | SMALLINT | CHECK > 0 |
| `precio_dia` | DECIMAL(10,2) | CHECK > 0 |
| `estado` | ENUM | `disponible`, `rentada`, `mantenimiento` |
| `creado_en` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

### `rentas`
| Columna | Tipo | Restricciones |
|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT |
| `cliente_id` | INT | FK → `clientes.id` |
| `moto_id` | INT | FK → `motos.id` |
| `fecha_inicio` | DATE | NOT NULL |
| `fecha_fin` | DATE | CHECK `fecha_fin >= fecha_inicio` |
| `total` | DECIMAL(10,2) | CHECK >= 0 |
| `estado` | ENUM | `activa`, `finalizada`, `cancelada` |
| `creado_en` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

### `pagos`
| Columna | Tipo | Restricciones |
|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT |
| `renta_id` | INT | FK → `rentas.id` (ON DELETE CASCADE) |
| `monto` | DECIMAL(10,2) | CHECK > 0 |
| `metodo` | ENUM | `efectivo`, `tarjeta`, `transferencia` |
| `fecha_pago` | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| `referencia` | VARCHAR(30) | NOT NULL, UNIQUE |
| `creado_en` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

### `mantenimientos`
| Columna | Tipo | Restricciones |
|---|---|---|
| `id` | INT | PK, AUTO_INCREMENT |
| `moto_id` | INT | FK → `motos.id` (ON DELETE CASCADE) |
| `fecha` | DATE | NOT NULL |
| `descripcion` | VARCHAR(200) | NOT NULL |
| `costo` | DECIMAL(10,2) | CHECK >= 0 |
| `realizado_por` | VARCHAR(80) | — |
| `creado_en` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

## Puesta en marcha

### 1. Requisitos
- MySQL Server 8.0 o superior
- Cliente `mysql` o MySQL Workbench

### 2. Importar la base

```bash
mysql -u TU_USUARIO -p < rentas_motos.sql
```

El script crea la base `rentas_motos`, las cinco tablas, índices, restricciones y carga los datos de ejemplo.

### 3. Verificar

```sql
USE rentas_motos;

SELECT 'clientes' AS tabla, COUNT(*) AS registros FROM clientes
UNION ALL SELECT 'motos', COUNT(*) FROM motos
UNION ALL SELECT 'rentas', COUNT(*) FROM rentas
UNION ALL SELECT 'pagos', COUNT(*) FROM pagos
UNION ALL SELECT 'mantenimientos', COUNT(*) FROM mantenimientos;
```

Resultado esperado: **10 registros por tabla**.

## Consultas de ejemplo

**Rentas con cliente y moto:**

```sql
SELECT r.id AS renta,
       CONCAT(c.nombre, ' ', c.apellido) AS cliente,
       CONCAT(m.marca, ' ', m.modelo) AS moto,
       m.placa,
       r.fecha_inicio,
       r.fecha_fin,
       r.total,
       r.estado
FROM rentas r
JOIN clientes c ON c.id = r.cliente_id
JOIN motos m    ON m.id = r.moto_id
ORDER BY r.id;
```

**Total facturado por método de pago:**

```sql
SELECT metodo, COUNT(*) AS pagos, SUM(monto) AS total
FROM pagos
GROUP BY metodo
ORDER BY total DESC;
```

**Motos con sus mantenimientos:**

```sql
SELECT m.placa,
       CONCAT(m.marca, ' ', m.modelo) AS moto,
       COUNT(mt.id) AS mantenimientos,
       COALESCE(SUM(mt.costo), 0) AS costo_total
FROM motos m
LEFT JOIN mantenimientos mt ON mt.moto_id = m.id
GROUP BY m.id, m.placa, m.marca, m.modelo
ORDER BY costo_total DESC;
```

**Rentas activas por moto:**

```sql
SELECT m.placa, CONCAT(m.marca, ' ', m.modelo) AS moto, COUNT(*) AS rentas_activas
FROM rentas r
JOIN motos m ON m.id = r.moto_id
WHERE r.estado = 'activa'
GROUP BY m.id, m.placa, m.marca, m.modelo;
```

## Abrir con MySQL Workbench

1. **Database → Manage Connections → New**
2. Configurar:
   - **Hostname:** `127.0.0.1`
   - **Port:** `3306`
   - **Username:** tu usuario de MySQL
   - **Default Schema:** `rentas_motos`
3. Probar la conexión y abrir el esquema.

## Notas

- Los datos son ficticios y sirven para prácticas.
- No incluir contraseñas ni tokens en el repositorio.
- Las claves foráneas usan `ON DELETE RESTRICT` en `rentas` para no perder historial, y `ON DELETE CASCADE` en `pagos` y `mantenimientos`.

## Autor

Ezequiel — práctica de bases de datos con MySQL.
