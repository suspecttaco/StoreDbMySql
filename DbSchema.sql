CREATE database storeDb;
use storeDb;

CREATE TABLE users(
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role enum('admin', 'cashier', 'manager') DEFAULT 'cashier',
    active BOOLEAN DEFAULT TRUE,
    create_at TIMESTAMP DEFAULT current_timestamp,
    INDEX username_idx (username)
) ENGINE = InnoDB;

CREATE TABLE products(
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    buy_price DECIMAL(10,2),
    sell_price DECIMAL(10,2) NOT NULL,
    actual_stock DECIMAL(10,2) DEFAULT 0,
    minimum_stock DECIMAL(10,2) DEFAULT 5,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT current_timestamp,
    updated_at TIMESTAMP DEFAULT current_timestamp ON UPDATE current_timestamp,
    INDEX name_idx (name),
    INDEX code_id (code),
    INDEX active_idx (active)
) ENGINE = InnoDB;

CREATE TABLE sales(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL ,
    total DECIMAL(10,2) NOT NULL,
    date TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX date_idx (date),
    INDEX user_idx (user_id)
) ENGINE = InnoDB;

CREATE TABLE sales_detail(
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    amount INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX sale_idx (sale_id),
    INDEX product_idx (product_id)
) ENGINE = InnoDB;

CREATE TABLE stock_alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    actual_stock INT,
    alert_date TIMESTAMP DEFAULT current_timestamp,
    resolved BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX product_idx (product_id),
    INDEX resolved_idx (resolved)
) ENGINE = InnoDB;

INSERT INTO users (username, password, full_name, role)
VALUES ('admin', 'admin123', 'Administrador Principal', 'admin'),
       ('cajero1', 'cajero123', 'Juan Campos', 'cashier');

INSERT INTO products (code, name, description, buy_price, sell_price, actual_stock, minimum_stock)
VALUES ('7501055301904', 'Coca Cola 600ml', 'Refresco de cola 600ml', 8.50, 15.00, 50, 10),
       ('7501030401020', 'Sabritas Originales', 'Papas 45g', 10.00, 18.00, 35, 10),
       ('7501000123456', 'Tortillas 1kg', 'Tortillas de maíz', 15.00, 22.00, 20, 5);
