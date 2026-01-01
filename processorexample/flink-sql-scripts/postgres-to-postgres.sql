-- ============================================================================
-- FLINK SQL SCRIPT: PostgreSQL to PostgreSQL Pipeline
-- ============================================================================
-- Descripción:
--   Este script procesa datos HISTÓRICOS almacenados en PostgreSQL.
--   Lee las tablas de usuarios y órdenes, realiza un JOIN y agregación,
--   y guarda los resultados procesados en la tabla flink_results.
--
-- Flujo de datos:
--   PostgreSQL (users + orders) → Flink (JOIN + Agregación) → PostgreSQL (flink_results)
--
-- Casos de uso:
--   - Procesamiento batch de datos históricos
--   - Generación de reportes analíticos
--   - Cálculo de métricas acumuladas por usuario
-- ============================================================================

-- Crear tabla source que lee de PostgreSQL (users)
CREATE TABLE postgres_users (
    id INT,
    name STRING,
    email STRING,
    age INT,
    city STRING,
    created_at TIMESTAMP(3)
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://postgres:5432/nifi_db',
    'driver' = 'org.postgresql.Driver',
    'username' = 'nifi',
    'password' = 'nifi123',
    'table-name' = 'users',
    'scan.fetch-size' = '1000'
);

-- Crear tabla source que lee de PostgreSQL (orders)
CREATE TABLE postgres_orders (
    id INT,
    user_id INT,
    product STRING,
    amount DECIMAL(10, 2),
    status STRING,
    created_at TIMESTAMP(3)
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://postgres:5432/nifi_db',
    'driver' = 'org.postgresql.Driver',
    'username' = 'nifi',
    'password' = 'nifi123',
    'table-name' = 'orders',
    'scan.fetch-size' = '1000'
);

-- Crear tabla sink para resultados en PostgreSQL
CREATE TABLE postgres_results (
    id INT,
    name STRING,
    email STRING,
    age INT,
    city STRING,
    product_count INT,
    total_spent DECIMAL(10, 2),
    created_at TIMESTAMP(3),
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://postgres:5432/nifi_db',
    'driver' = 'org.postgresql.Driver',
    'username' = 'nifi',
    'password' = 'nifi123',
    'table-name' = 'flink_results',
    'sink.buffer-flush.max-rows' = '100',
    'sink.buffer-flush.interval' = '5000'
);

-- ============================================================================
-- TRANSFORMACIÓN Y CARGA
-- ============================================================================
-- Esta query realiza las siguientes operaciones:
-- 1. JOIN entre usuarios (u) y órdenes (o) utilizando el user_id
-- 2. LEFT JOIN para incluir usuarios sin órdenes
-- 3. Agrupación por usuario (u.id, nombre, email, etc.)
-- 4. Conteo total de órdenes por usuario (COUNT)
-- 5. Suma total gastado por usuario (SUM del monto)
-- 6. Timestamp actual para auditoría
-- 7. Carga de resultados en flink_results para posterior análisis
INSERT INTO postgres_results
SELECT 
    u.id,
    u.name,
    u.email,
    u.age,
    u.city,
    CAST(COUNT(o.id) AS INT) as product_count,
    CAST(SUM(o.amount) AS DECIMAL(10, 2)) as total_spent,
    CURRENT_TIMESTAMP as created_at
FROM postgres_users u
LEFT JOIN postgres_orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email, u.age, u.city;
