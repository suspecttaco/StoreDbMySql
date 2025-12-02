# Base de Datos - Tiendita POS Ultimate

Esquema relacional diseñado para integridad transaccional, auditoría y escalabilidad.

## Tecnologías
* **Motor:** MySQL 8.0 (InnoDB).
* **Encoding:** `utf8mb4` (Soporte completo para caracteres internacionales y emojis).

## Estructura del Esquema (Tablas Principales)

### 1. Seguridad y Acceso
* **`users`**: Almacena credenciales (hash), roles (admin/cajero) y estado.

### 2. Inventario y Catálogos
* **`products`**: Catálogo principal. Maneja stock decimal (para granel), precios y relación con categorías.
* **`categories`**: Clasificación jerárquica de productos.
* **`suppliers`**: Directorio de proveedores.
* **`stock_alerts`**: Registro histórico de alertas de stock bajo generadas por el sistema.

### 3. Operaciones Comerciales
* **`customers`**: Cartera de clientes con límite de crédito.
* **`sales`**: Encabezado de la transacción (Total, Fecha, Usuario, Cliente).
* **`sale_details`**: Renglones de la venta. Relaciona la venta con los productos y guarda el precio histórico al momento de la venta.

---

## Despliegue e Inicialización

### 1. Script de Creación
Se incluye el archivo `DbSchema.sql` que contiene:
1.  Borrado de base de datos anterior (si existe).
2.  Creación de tablas con claves foráneas e índices.
3.  Inserción de datos semilla (Admin por defecto y productos de prueba).

### 2. Ejecución
Puede ejecutar el script utilizando cualquier cliente MySQL (Workbench, DataGrip, DBeaver) o por línea de comandos:

```bash
mysql -u root -p < UltimateDbSchema.sql