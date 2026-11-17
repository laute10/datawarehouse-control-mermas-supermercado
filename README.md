# Data Warehouse para el control de mermas en supermercados

Proyecto de **Business Intelligence** para una cadena de supermercados: diseño de un Data Warehouse con **modelo estrella**, un proceso **ETL en SQL** que limpia datos cargados a mano y la definición de **KPIs** y de un tablero para detectar dónde y por qué se pierde mercadería.

Trabajo de la materia **Base de Datos II** · Universidad Champagnat · Autor: Lautaro Espejo.

## El problema de negocio

En un supermercado el margen por producto es muy bajo, así que cada pérdida pesa. Parte de la mercadería se pierde antes de venderse (lo que en el rubro se llama **merma**) por tres motivos:

- **Vencimiento en góndola:** productos, sobre todo frescos, que vencen antes de venderse.
- **Rotura en depósito:** mala manipulación en la logística.
- **Robo hormiga:** faltantes sin registro.

Esas pérdidas se registraban en planillas de Excel completadas a mano por los auditores, sin una forma de analizarlas en conjunto. El objetivo es responder preguntas como: **¿qué sucursal pierde más? ¿por qué causa? ¿qué productos y categorías concentran las pérdidas?**

Está pensado para dos usuarios: la **Gerencia de Operaciones y Logística** (fallas en depósitos y sucursales) y **Compras** (productos que se vencen por sobrestock, para renegociar con proveedores).

## Modelo estrella

![Modelo estrella](Modelo%20Estrella.png)

- **Tabla de hechos `Hechos_Mermas`:** una fila por cada merma registrada, con la cantidad perdida, el costo, el valor de venta y el margen financiero perdido.
- **`Dim_Producto`:** nombre, categoría, costo y precio de venta.
- **`Dim_Sucursal`:** nombre y dirección de cada local.
- **`Dim_Tipo_Perdida`:** la causa (vencimiento, rotura o robo).
- **`Dim_Tiempo`:** la fecha separada en año, trimestre, mes y día, con una clave `AAAAMMDD`.

## Proceso ETL

Los datos de origen ([`control_merma.csv`](control_merma.csv), exportado de la planilla de los auditores) venían con los errores típicos de la carga manual:

| Problema en el origen | Ejemplo | Solución en SQL |
|---|---|---|
| Nombres escritos de distintas formas | `Sucursal Centro`, `sucursal centro` | `UPPER()` y `SUBSTRING_INDEX()` para unificar y cruzar con las dimensiones |
| Fechas en formatos mezclados | `10/4/2026`, `2026.03.02` | `CASE` con `REGEXP` que detecta cada formato y lo convierte con `STR_TO_DATE()` |
| Montos guardados como texto | `$ 4.369,10` | Limpieza de `$` y espacios con `REPLACE()` y conversión con `CAST()` a `DECIMAL` |
| Registros incompletos | costo en `NULL` | Se descartan antes de llegar a la tabla de hechos |

El flujo es:

1. **Extracción:** el CSV se carga tal cual en una tabla de *staging* (`Mermas_Staging_Raw`) con todas las columnas como texto, para que ningún dato sucio frene la importación.
2. **Transformación y carga:** un `INSERT … SELECT` limpia cada columna, la cruza con las dimensiones y calcula el margen perdido (`venta − costo`).
3. **Control:** se eliminan los registros sin costo y se verifican la cantidad de filas cargadas y el costo total.

Todo está en [`Control de mermas.sql`](Control%20de%20mermas.sql).

## KPIs definidos

| Indicador | Cálculo | Para qué sirve |
|---|---|---|
| **Tasa de merma sobre el costo (TMC)** | costo de las mermas ÷ costo total de la mercadería comprada × 100 | Mide qué parte de lo invertido en mercadería se pierde. En el rubro, lo aceptable suele estar por debajo del 1,5 % – 2 %. |
| **Índice de pérdida por vencimiento en góndola (IPVG)** | costo de las mermas por vencimiento ÷ costo total de las mermas × 100 | Un valor alto indica sobrestock o que no se aplica bien la rotación de productos (FIFO). |
| **Margen financiero perdido (MFE)** | suma de (valor de venta − costo) de las mermas | La ganancia que la empresa dejó de obtener porque el producto no llegó a venderse. |

## Prototipo del tablero

> **Aclaración:** el tablero es un **prototipo de diseño (maqueta)** para mostrar cómo se explotaría la información del Data Warehouse. No está conectado a la base de datos y sus cifras son **ilustrativas**: no surgen del CSV de muestra.

![Prototipo del tablero de control de mermas](Dashboard%201.png)

El prototipo muestra los KPIs principales, el costo de las mermas por sucursal, causa y categoría, su evolución mensual y los productos con mayor pérdida. Las demás pantallas simulan el uso de los filtros:

| Filtro por causa | Filtro por mes | Filtro por sucursal | Filtro por categoría |
|---|---|---|---|
| ![Filtro por causa](Dashboard%202.png) | ![Filtro por mes](Dashboard%203.png) | ![Filtro por sucursal](Dashboard%204.png) | ![Filtro por categoría](Dashboard%205.png) |

En el [informe completo](Business%20Intelligence%20Aplicado%20a%20la%20Gesti%C3%B3n%20de%20Mermas%20Operativas.pdf) se recorre el tablero como lo usaría un director de operaciones y se proponen decisiones de negocio a partir de lo que muestra.

## Cómo ejecutarlo

**Requisitos:** MySQL 8 y MySQL Workbench (o cualquier cliente de MySQL).

1. Copiá `control_merma.csv` a la carpeta desde la que MySQL permite importar archivos. En Windows suele ser `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`. Para confirmarla, ejecutá `SHOW VARIABLES LIKE 'secure_file_priv';`.
2. Renombrá la copia a `control_mermas.csv`, que es el nombre que usa el script (o cambiá la ruta en la sección 6 del script).
3. Ejecutá `Control de mermas.sql` completo. El script borra y vuelve a crear la base `dw_supermercado_mermas`, carga las dimensiones, importa el CSV, corre el ETL y muestra al final la cantidad de registros cargados y el costo total.

Los datos son **ficticios** y forman una muestra chica (14 registros) pensada para probar cada regla de limpieza.

## Archivos

| Archivo | Contenido |
|---|---|
| `Control de mermas.sql` | Creación del modelo, staging, ETL y controles |
| `control_merma.csv` | Datos de origen sin limpiar (muestra ficticia) |
| `Modelo Estrella.png` | Diagrama del modelo |
| `Dashboard 1.png` … `Dashboard 5.png` | Prototipo del tablero |
| `Business Intelligence Aplicado a la Gestión de Mermas Operativas.pdf` | Informe completo: problema, modelo, ETL, consultas analíticas, KPIs, tablero y conclusiones |

## Tecnologías

MySQL · SQL (`REGEXP`, `CASE`, `STR_TO_DATE`, `CAST`) · Modelado dimensional · ETL · Excel
