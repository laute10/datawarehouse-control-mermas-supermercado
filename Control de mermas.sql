-- ============================================================================
-- 1. BORRADO Y CREACIÓN DE LA BASE DE DATOS DESDE CERO
-- ============================================================================
DROP DATABASE IF EXISTS dw_supermercado_mermas;
CREATE DATABASE dw_supermercado_mermas;
USE dw_supermercado_mermas;

-- ============================================================================
-- 2. CREACIÓN DE LAS TABLAS DEL MODELO ESTRELLA (DIMENSIONES)
-- ============================================================================
CREATE TABLE Dim_Sucursal (
    ID_Sucursal INT PRIMARY KEY,
    Nombre_Sucursal VARCHAR(100) NOT NULL,
    Direccion VARCHAR(150)
);

CREATE TABLE Dim_Tipo_Perdida (
    ID_Tipo_Perdida INT PRIMARY KEY,
    Causa_Merma VARCHAR(50) NOT NULL,
    Descripcion_Causa VARCHAR(255)
);

CREATE TABLE Dim_Producto (
    ID_Producto INT PRIMARY KEY,
    Nombre_Producto VARCHAR(150) NOT NULL,
    Categoria VARCHAR(50) NOT NULL,
    Precio_Costo_Unitario DECIMAL(10,2) NOT NULL,
    Precio_Venta_Unitario DECIMAL(10,2) NOT NULL
);

CREATE TABLE Dim_Tiempo (
    ID_Fecha INT PRIMARY KEY, -- Formato inteligente AAAAMMDD
    Fecha DATE NOT NULL,
    Anio INT NOT NULL,
    Mes INT NOT NULL,
    Nombre_Mes VARCHAR(20) NOT NULL,
    Dia INT NOT NULL,
    Trimestre VARCHAR(2) NOT NULL
);

-- ============================================================================
-- 3. TABLA DE STAGING (Datos operacionales crudos del CSV)
-- ============================================================================
CREATE TABLE Mermas_Staging_Raw (
    ID_Reporte INT,
    Fecha_Registro VARCHAR(50),      
    Sucursal_Origen VARCHAR(150),    
    Producto_Nombre VARCHAR(150),
    Categoria_Producto VARCHAR(50),
    Causa_Merma VARCHAR(50),
    Cantidad_Unidades INT,
    Costo_Unitario_Raw VARCHAR(50),
    Monto_Costo_Total_Raw VARCHAR(50), 
    Monto_Venta_Total_Raw VARCHAR(50),
    Operario_Auditor VARCHAR(50)
);

-- ============================================================================
-- 4. LA TABLA DESTINO (Data Warehouse / Hechos centralizada)
-- ============================================================================
CREATE TABLE Hechos_Mermas (
    ID_Merma INT AUTO_INCREMENT PRIMARY KEY,
    ID_Fecha INT,
    ID_Producto INT,
    ID_Sucursal INT,
    ID_Tipo_Perdida INT,
    Cantidad_Perdida INT NOT NULL,
    Monto_Perdida_Costo DECIMAL(12,2) NOT NULL,
    Monto_Perdida_Venta DECIMAL(12,2) NOT NULL,
    Margen_Financiero_Perdido DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (ID_Fecha) REFERENCES Dim_Tiempo(ID_Fecha),
    FOREIGN KEY (ID_Producto) REFERENCES Dim_Producto(ID_Producto),
    FOREIGN KEY (ID_Sucursal) REFERENCES Dim_Sucursal(ID_Sucursal),
    FOREIGN KEY (ID_Tipo_Perdida) REFERENCES Dim_Tipo_Perdida(ID_Tipo_Perdida)
);

-- ============================================================================
-- 5. CARGA DE CATÁLOGOS MAESTROS (DIMENSIONES)
-- ============================================================================
INSERT INTO Dim_Sucursal VALUES
(1, 'SUCURSAL CENTRO', 'Av. San Martín 1240'),
(2, 'SUCURSAL PALMARES', 'Panamericana 2750'),
(3, 'SUCURSAL VILLANUEVA', 'Acceso Este 4100'),
(4, 'SUCURSAL QUINTA SECCIÓN', 'Arístides 320');

INSERT INTO Dim_Tipo_Perdida VALUES
(1, 'Vencimiento en góndola', 'Expiración física del producto'),
(2, 'Rotura en depósito', 'Mala manipulación logística'),
(3, 'Robo hormiga', 'Sustracción ilegal sin registro');

INSERT INTO Dim_Producto VALUES
(1, 'ASADO DE TIRA NOVILLITO 1KG', 'CARNICERÍA', 6889.98, 9925.42),
(2, 'JAMÓN COCIDO BOCATTI 1KG', 'FIAMBRERÍA Y QUESOS', 3153.61, 4436.87),
(3, 'DETERGENTE SINTÉTICO ALA LIMÓN 750ML', 'LIMPIEZA', 4042.74, 5678.93),
(4, 'MILANESA DE CARNE PREPARADA 1KG', 'CARNICERÍA', 5014.14, 7184.29),
(5, 'MORTADELA CON PISTACHO PALADINI 1KG', 'FIAMBRERÍA Y QUESOS', 5871.41, 8609.83),
(6, 'MANTECA PRIMER PREMIO 200G', 'LÁCTEOS Y FRESCOS', 3598.04, 5234.14),
(7, 'YERBA MATE PLAYADITO 1KG', 'ALMACÉN', 1237.28, 1763.92),
(8, 'DESODORANTE DE AMBIENTES POETT 360ML', 'LIMPIEZA', 4092.14, 5898.24),
(9, 'LIMPIADOR DE PISOS PROCENEX 1L', 'LIMPIEZA', 2184.55, 3187.90),
(10, 'PURÉ DE TOMATE ALCO 520G', 'ALMACÉN', 2584.36, 3522.59),
(11, 'LECHE ENTERA LA SERENÍSIMA 1L', 'LÁCTEOS Y FRESCOS', 1783.37, 2487.15),
(12, 'PECHUGA DE POLLO FRESCA 1KG', 'CARNICERÍA', 5644.91, 8444.60),
(13, 'QUESO TYBO BARRA BARRAZA 1KG', 'FIAMBRERÍA Y QUESOS', 6458.09, 9338.40);

INSERT INTO Dim_Tiempo VALUES
(20260302, '2026-03-02', 2026, 3, 'Marzo', 2, 'T1'),
(20260307, '2026-03-07', 2026, 3, 'Marzo', 7, 'T1'),
(20260312, '2026-03-12', 2026, 3, 'Marzo', 12, 'T1'),
(20260316, '2026-03-16', 2026, 3, 'Marzo', 16, 'T1'),
(20260317, '2026-03-17', 2026, 3, 'Marzo', 17, 'T1'),
(20260319, '2026-03-19', 2026, 3, 'Marzo', 19, 'T1'),
(20260329, '2026-03-29', 2026, 3, 'Marzo', 29, 'T1'),
(20260330, '2026-03-30', 2026, 3, 'Marzo', 30, 'T1'),
(20260407, '2026-04-07', 2026, 4, 'Abril', 7, 'T2'),
(20260408, '2026-04-08', 2026, 4, 'Abril', 8, 'T2'),
(20260409, '2026-04-09', 2026, 4, 'Abril', 9, 'T2'),
(20260410, '2026-04-10', 2026, 4, 'Abril', 10, 'T2'),
(20260411, '2026-04-11', 2026, 4, 'Abril', 11, 'T2'),
(20260412, '2026-04-12', 2026, 4, 'Abril', 12, 'T2'),
(20260514, '2026-05-14', 2026, 5, 'Mayo', 14, 'T2'),
(20260518, '2026-05-18', 2026, 5, 'Mayo', 18, 'T2'),
(20260521, '2026-05-21', 2026, 5, 'Mayo', 21, 'T2'),
(20260522, '2026-05-22', 2026, 5, 'Mayo', 22, 'T2'),
(20260525, '2026-05-25', 2026, 5, 'Mayo', 25, 'T2');

-- Metemos un lote más grande de fechas para asegurarnos de que no falte ninguna
INSERT IGNORE INTO Dim_Tiempo VALUES
(20260410, '2026-04-10', 2026, 4, 'Abril', 10, 'T2'),
(20260514, '2026-05-14', 2026, 5, 'Mayo', 14, 'T2'),
(20260321, '2026-03-21', 2026, 3, 'Marzo', 21, 'T1'),
(20260302, '2026-03-02', 2026, 3, 'Marzo', 20, 'T1'),
(20260301, '2026-03-01', 2026, 3, 'Marzo', 1, 'T1'),
(20260521, '2026-05-21', 2026, 5, 'Mayo', 21, 'T2'),
(20260409, '2026-04-09', 2026, 4, 'Abril', 9, 'T2'),
(20260317, '2026-03-17', 2026, 3, 'Marzo', 17, 'T1'),
(20260525, '2026-05-25', 2026, 5, 'Mayo', 25, 'T2'),
(20260330, '2026-03-30', 2026, 3, 'Marzo', 30, 'T1'),
(20260412, '2026-04-12', 2026, 4, 'Abril', 12, 'T2'),
(20260319, '2026-03-19', 2026, 3, 'Marzo', 19, 'T1'),
(20260504, '2026-05-04', 2026, 5, 'Mayo', 4, 'T2');

-- ============================================================================
-- 6. IMPORTACIÓN REAL DEL CSV (Tu sintaxis y tu nuevo nombre)
-- ============================================================================
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
SELECT VERSION();

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/control_mermas.csv'
INTO TABLE Mermas_Staging_Raw
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- ============================================================================
-- 7. PIPELINE ETL HACIA EL DATA WAREHOUSE (Tu lógica de REGEXP y CAST)
-- ============================================================================
INSERT INTO Hechos_Mermas (ID_Fecha, ID_Producto, ID_Sucursal, ID_Tipo_Perdida, Cantidad_Perdida, Monto_Perdida_Costo, Monto_Perdida_Venta, Margen_Financiero_Perdido)
SELECT 
    -- Tu lógica exacta de CASE con REGEXP para estandarizar las fechas del Excel
    CAST(DATE_FORMAT(
        CASE
            -- YYYY/MM/DD
            WHEN s.Fecha_Registro REGEXP '^[0-9]{4}/' 
                THEN STR_TO_DATE(s.Fecha_Registro, '%Y/%m/%d')
            -- DD/MM/YYYY
            WHEN s.Fecha_Registro REGEXP '^[0-9]{2}/' 
                THEN STR_TO_DATE(s.Fecha_Registro, '%d/%m/%Y')
            -- YYYY.MM.DD
            WHEN s.Fecha_Registro LIKE '%.%' 
                THEN STR_TO_DATE(s.Fecha_Registro, '%Y.%m.%d')
            -- YYYY-MM-DD
            WHEN s.Fecha_Registro REGEXP '^[0-9]{4}-' 
                THEN STR_TO_DATE(s.Fecha_Registro, '%Y-%m-%d')
            -- DD-MM-YYYY
            WHEN s.Fecha_Registro REGEXP '^[0-9]{2}-' 
                THEN STR_TO_DATE(s.Fecha_Registro, '%d-%m-%Y')
            ELSE NULL
        END, '%Y%m%d') AS UNSIGNED) AS ID_Fecha,

    p.ID_Producto,
    suc.ID_Sucursal,
    tp.ID_Tipo_Perdida,
    s.Cantidad_Unidades,
    
    -- Limpieza quirúrgica de caracteres monetarios ($) y pasaje a tipo DECIMAL
    CAST(REPLACE(REPLACE(s.Monto_Costo_Total_Raw, '$', ''), ' ', '') AS DECIMAL(10,2)) AS Monto_Perdida_Costo,
    CAST(REPLACE(REPLACE(s.Monto_Venta_Total_Raw, '$', ''), ' ', '') AS DECIMAL(10,2)) AS Monto_Perdida_Venta,
    
    -- Métrica calculada en caliente (Venta - Costo)
    (CAST(REPLACE(REPLACE(s.Monto_Venta_Total_Raw, '$', ''), ' ', '') AS DECIMAL(10,2)) - 
     CAST(REPLACE(REPLACE(s.Monto_Costo_Total_Raw, '$', ''), ' ', '') AS DECIMAL(10,2))) AS Margen_Financiero_Perdido

FROM Mermas_Staging_Raw s
INNER JOIN Dim_Producto p ON UPPER(s.Producto_Nombre) = p.Nombre_Producto
INNER JOIN Dim_Sucursal suc ON UPPER(SUBSTRING_INDEX(s.Sucursal_Origen, ' -', 1)) = suc.Nombre_Sucursal
INNER JOIN Dim_Tipo_Perdida tp ON s.Causa_Merma = tp.Causa_Merma
WHERE s.Monto_Costo_Total_Raw IS NOT NULL 
  AND s.Monto_Costo_Total_Raw <> 'NULL' 
  AND s.Monto_Costo_Total_Raw <> '';

-- ============================================================================
-- 8. DEPURACIÓN DE REGISTROS INVÁLIDOS (Igual que en tu TP)
-- ============================================================================
DELETE FROM Hechos_Mermas
WHERE Monto_Perdida_Costo IS NULL OR Monto_Perdida_Costo = 0;

-- ============================================================================
-- 9. COMPROBACIONES FINALES EN PANTALLA
-- ============================================================================
SELECT COUNT(*) AS total_registros_cargados FROM Hechos_Mermas;
SELECT SUM(Monto_Perdida_Costo) AS costo_total_merma_empresa FROM Hechos_Mermas;
SELECT * FROM Hechos_Mermas;

SELECT * FROM Mermas_Staging_Raw;

SELECT * FROM Hechos_Mermas LIMIT 10;