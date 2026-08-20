-- Crear el database sobre el que vamos a trabajar

CREATE DATABASE Ventas_Tech_DB;

USE Ventas_Tech_DB;
GO

-- Eliminar las tablas si ya existen

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

-- Crear la tabla categorias

CREATE TABLE categorias 
(id_categoria INT PRIMARY KEY, 
nombre_categoria VARCHAR(50) NOT NULL,
descripcion VARCHAR (200)
)
;

-- Crear tabla clientes

CREATE TABLE clientes
(id_cliente INT PRIMARY KEY,
nombre VARCHAR (100) NOT NULL,
email VARCHAR (100) UNIQUE, 
ciudad VARCHAR (50),
fecha_registro DATE NOT NULL
)
;

-- Crear tabla productos

CREATE TABLE productos
(id_producto INT PRIMARY KEY,
nombre_producto VARCHAR (100) NOT NULL,
id_categoria INT,
precio DECIMAL (10,2) NOT NULL,
stock INT DEFAULT 0,
activo TINYINT DEFAULT 1,

  CONSTRAINT fk_productos_categorias
        FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
)
;

-- Crear tabla VENTAS

CREATE TABLE ventas
(id_venta INT PRIMARY KEY,
id_cliente INT,
id_producto INT,
cantidad INT NOT NULL,
precio_unitario DECIMAL (10,2) NOT NULL,
fecha_venta DATE NOT NULL, 

CONSTRAINT fk_ventas_cliente
FOREIGN KEY (id_cliente)
REFERENCES clientes(id_cliente),

CONSTRAINT fk_ventas_productos
FOREIGN KEY (id_producto)
REFERENCES productos(id_producto)
)
;

-- Cargar los datos a las tablas 

INSERT INTO categorias VALUES (1, 'Computación', 'Laptops, PCs y monitores');
INSERT INTO categorias VALUES (2, 'Accesorios', 'Periféricos y complementos');
INSERT INTO categorias VALUES (3, 'Audio', 'Auriculares y parlantes');
INSERT INTO categorias VALUES (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO clientes VALUES (1, 'María López',   'maria@mail.com',   'Buenos Aires', '2024-01-05');
INSERT INTO clientes VALUES (2, 'Carlos Ruiz',   'carlos@mail.com',  'Córdoba',      '2024-01-10');
INSERT INTO clientes VALUES (3, 'Ana Gómez',     'ana@mail.com',     'Rosario',      '2024-02-01');
INSERT INTO clientes VALUES (4, 'Pedro Sanz',    'pedro@mail.com',   'Mendoza',      '2024-02-15');
INSERT INTO clientes VALUES (5, 'Laura Torres',  'laura@mail.com',   'Tucumán',      '2024-03-01');


INSERT INTO productos VALUES (1, 'Laptop Pro 15',       1, 1200.00, 15, 1);
INSERT INTO productos VALUES (2, 'Mouse Inalámbrico',   2,   28.00, 80, 1);
INSERT INTO productos VALUES (3, 'Monitor 4K 27"',      1,  450.00, 12, 1);
INSERT INTO productos VALUES (4, 'Auriculares BT Pro',  3,  120.00, 35, 1);
INSERT INTO productos VALUES (5, 'SSD Externo 1TB',     4,  130.00, 18, 1);
INSERT INTO productos VALUES (6, 'Teclado Mecánico',    2,   95.00, 40, 1);

INSERT INTO ventas VALUES (1,  1, 1, 2, 1200.00, '2024-03-05');
INSERT INTO ventas VALUES (2,  2, 2, 5,   28.00, '2024-03-06');
INSERT INTO ventas VALUES (3,  3, 3, 1,  450.00, '2024-03-07');
INSERT INTO ventas VALUES (4,  1, 4, 2,  120.00, '2024-03-08');
INSERT INTO ventas VALUES (5,  4, 5, 3,  130.00, '2024-03-10');
INSERT INTO ventas VALUES (6,  2, 6, 4,   95.00, '2024-03-11');
INSERT INTO ventas VALUES (7,  5, 1, 1, 1200.00, '2024-03-12');
INSERT INTO ventas VALUES (8,  3, 2, 8,   28.00, '2024-03-13');
INSERT INTO ventas VALUES (9,  4, 4, 1,  120.00, '2024-03-14');
INSERT INTO ventas VALUES (10, 5, 3, 2,  450.00, '2024-03-15');

-- Confirmá que cada tabla se cargó correctamente

SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;

-- (Más adelante, en el Módulo 5, vas a poder cruzar estas tablas con JOIN
--  para ver las ventas junto al nombre del cliente y del producto.
--  Por ahora alcanza con confirmar que las 4 tablas tienen sus datos.)



--M4.Consulta 1. Resumen ejecutivo mensual

SELECT
MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

--M4.Consulta 2.Resumen ejecutivo mensual

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;

-- M4.Consulta 3. Clientes recurrentes 

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1

-- M4.Consulta 4. Meses por encima/por debajo del promedio

SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    CASE WHEN SUM(cantidad * precio_unitario) >
    (SELECT AVG(total_mensual)
     FROM (SELECT MONTH(fecha_venta) AS mes,
     SUM(cantidad * precio_unitario) AS total_mensual
    FROM ventas
    GROUP BY MONTH(fecha_venta)) AS totales_mensuales )
     THEN 'Por encima'
     ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- M4. Hallazgos
-- 1.El Producto 1 concentra el 55,9% de la facturación ($3.600,00), mientras que el Producto 2 es el líder en volumen (13 unidades).
-- 2.La facturación el mes proviene de 5 clientes recurrentes, los Clientes 1 y 5 representan el 73,5% del total generado.
-- 3.El mes 3 se ubica por debajo del promedio de facturación general de la empresa.