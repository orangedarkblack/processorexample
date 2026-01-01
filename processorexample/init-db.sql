-- Crear base de datos `nifi_db` sólo si no existe
-- Esto evita errores cuando el script se ejecuta en entornos ya inicializados
SELECT 'CREATE DATABASE nifi_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'nifi_db')\gexec

-- Conectar a la base de datos nifi
\c nifi_db;

-- Crear tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INTEGER,
    city VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo
INSERT INTO users (name, email, age, city) VALUES
('Juan Pérez', 'juan.perez@example.com', 28, 'Madrid'),
('María García', 'maria.garcia@example.com', 32, 'Barcelona'),
('Carlos López', 'carlos.lopez@example.com', 25, 'Valencia'),
('Ana Martínez', 'ana.martinez@example.com', 29, 'Bilbao'),
('Pedro Sánchez', 'pedro.sanchez@example.com', 35, 'Sevilla'),
('Laura Rodríguez', 'laura.rodriguez@example.com', 26, 'Malaga'),
('Miguel Fernández', 'miguel.fernandez@example.com', 31, 'Alicante'),
('Isabel González', 'isabel.gonzalez@example.com', 27, 'Córdoba');

-- Crear tabla de órdenes
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar órdenes de ejemplo
INSERT INTO orders (user_id, product, amount, status) VALUES
(1, 'Laptop', 1200.00, 'completed'),
(2, 'Mouse', 25.00, 'completed'),
(3, 'Teclado', 80.00, 'pending'),
(1, 'Monitor', 350.00, 'pending'),
(4, 'Webcam', 60.00, 'completed'),
(5, 'USB-C Cable', 15.00, 'completed'),
(2, 'Headphones', 120.00, 'pending');

-- Crear tabla para resultados procesados por Flink (CORREGIDA)
CREATE TABLE IF NOT EXISTS flink_results (
    user_name VARCHAR(255) PRIMARY KEY,
    total_orders BIGINT,
    total_amount DECIMAL(10, 2)
);

-- Fin del script de inicialización (base de datos de ejemplo: nifi_db)
