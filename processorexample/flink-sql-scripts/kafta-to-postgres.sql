-- ============================================================================
-- FLINK SQL SCRIPT: Kafka to PostgreSQL Pipeline (Real-time Streaming) - CORRECTED
-- ============================================================================
-- Descripción:
--   Este script procesa eventos en TIEMPO REAL desde Kafka.
--   Lee los tópicos de usuarios y órdenes, realiza un JOIN y agregación,
--   y guarda los resultados procesados en PostgreSQL para análisis.
--
-- Flujo de datos:
--   Kafka (users-topic + orders-topic) → Flink (JOIN + Agregación) → PostgreSQL (flink_results)
-- ============================================================================

-- Registrar conector Kafka como source para usuarios
CREATE TABLE kafka_users (
    id INT,
    name STRING,
    email STRING,
    age INT,
    city STRING,
    created_at STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'users-topic',
    'properties.bootstrap.servers' = 'kafka:29092',
    'properties.group.id' = 'flink-group-users-2',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
);

-- Crear tabla source para órdenes desde Kafka
CREATE TABLE kafka_orders (
    id INT,
    user_id INT,
    product STRING,
    amount DECIMAL(10, 2),
    status STRING,
    created_at STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'orders-topic',
    'properties.bootstrap.servers' = 'kafka:29092',
    'properties.group.id' = 'flink-group-orders-2',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
);

-- Crear tabla de salida para resultados procesados en PostgreSQL (CORREGIDA)
CREATE TABLE postgres_sink (
    user_name STRING,
    total_orders BIGINT,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (user_name) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://postgres:5432/nifi_db',
    'driver' = 'org.postgresql.Driver',
    'username' = 'nifi',
    'password' = 'nifi123',
    'table-name' = 'flink_results',
    'sink.buffer-flush.max-rows' = '100',
    'sink.buffer-flush.interval' = '5s'
);

-- ============================================================================
-- TRANSFORMACIÓN Y CARGA EN TIEMPO REAL (CORREGIDA)
-- ============================================================================
INSERT INTO postgres_sink
SELECT
    u.name AS user_name,
    COUNT(o.id) AS total_orders,
    SUM(o.amount) AS total_amount
FROM kafka_users u
JOIN kafka_orders o ON u.id = o.user_id
GROUP BY u.name;
