-- DATABASE INITIALIZATION
DROP DATABASE IF EXISTS storeDb;
CREATE DATABASE storeDb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE storeDb;

-- ==========================================
-- 1. CORE CATALOGS & USERS
-- ==========================================

-- Permissions for granular access control
CREATE TABLE permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
) ENGINE = InnoDB;

-- Users Table (Extended)
CREATE TABLE users(
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role ENUM('admin', 'cashier', 'manager') DEFAULT 'cashier',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT current_timestamp,
    INDEX username_idx (username)
) ENGINE = InnoDB;

-- User Permissions (Many-to-Many)
CREATE TABLE user_permissions (
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (user_id, permission_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- Audit Log for security
CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    table_affected VARCHAR(50),
    record_id INT,
    details TEXT,
    created_at TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE = InnoDB;

-- Categories (Hierarchical)
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id INT NULL,
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
) ENGINE = InnoDB;

-- Suppliers
CREATE TABLE suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT current_timestamp
) ENGINE = InnoDB;

-- Customers (For credit/fiado)
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    credit_limit DECIMAL(10,2) DEFAULT 0,
    current_balance DECIMAL(10,2) DEFAULT 0, -- Positive means they owe money
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT current_timestamp
) ENGINE = InnoDB;

-- ==========================================
-- 2. INVENTORY & PRODUCTS
-- ==========================================

CREATE TABLE products(
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category_id INT,
    buy_price DECIMAL(10,2),
    sell_price DECIMAL(10,2) NOT NULL,
    actual_stock DECIMAL(10,3) DEFAULT 0.000, -- 3 decimals for weight (kg)
    minimum_stock DECIMAL(10,3) DEFAULT 5.000,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT current_timestamp,
    updated_at TIMESTAMP DEFAULT current_timestamp ON UPDATE current_timestamp,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX name_idx (name),
    INDEX code_idx (code),
    INDEX active_idx (active)
) ENGINE = InnoDB;

-- Stock Alerts
CREATE TABLE stock_alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    actual_stock DECIMAL(10,3),
    alert_date TIMESTAMP DEFAULT current_timestamp,
    resolved BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX product_idx (product_id),
    INDEX resolved_idx (resolved)
) ENGINE = InnoDB;

-- Promotions
CREATE TABLE promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type ENUM('percentage', 'fixed_amount', 'buy_x_get_y'),
    value DECIMAL(10,2) NOT NULL,
    start_date DATE,
    end_date DATE,
    active BOOLEAN DEFAULT TRUE
) ENGINE = InnoDB;

CREATE TABLE product_promotions (
    promotion_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (promotion_id, product_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE = InnoDB;

-- ==========================================
-- 3. OPERATIONS (Purchases, Shifts, Sales)
-- ==========================================

-- Purchases from Suppliers
CREATE TABLE purchases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    user_id INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    date TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE = InnoDB;

CREATE TABLE purchase_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(10,3) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE = InnoDB;

-- Cash Shifts (Corte de Caja)
CREATE TABLE shifts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_amount DECIMAL(10,2) NOT NULL,
    end_amount DECIMAL(10,2),
    expected_amount DECIMAL(10,2),
    difference DECIMAL(10,2),
    start_time TIMESTAMP DEFAULT current_timestamp,
    end_time TIMESTAMP NULL,
    closed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE = InnoDB;

CREATE TABLE cash_withdrawals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    concept VARCHAR(200),
    created_at TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (shift_id) REFERENCES shifts(id)
) ENGINE = InnoDB;

-- SALES HEADER
CREATE TABLE sales(
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    customer_id INT NULL, -- Linked if sale is credit/loyalty
    shift_id INT NULL,    -- Linked to current open shift
    total DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'card', 'credit') DEFAULT 'cash',
    date TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    INDEX date_idx (date),
    INDEX user_idx (user_id)
) ENGINE = InnoDB;

-- SALES DETAILS
CREATE TABLE sale_details(
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(10,3) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    promotion_id INT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(id),
    INDEX sale_idx (sale_id),
    INDEX product_idx (product_id)
) ENGINE = InnoDB;

-- Returns / Refunds
CREATE TABLE returns (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    user_id INT NOT NULL,
    authorized_by INT, -- Supervisor ID
    reason TEXT,
    total DECIMAL(10,2) NOT NULL,
    date TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (authorized_by) REFERENCES users(id)
) ENGINE = InnoDB;

CREATE TABLE return_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    return_id INT NOT NULL,
    product_id INT NOT NULL,
    amount DECIMAL(10,3) NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (return_id) REFERENCES returns(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE = InnoDB;

-- Credit Accounts (Cuentas por Cobrar)
CREATE TABLE accounts_receivable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    sale_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    paid_amount DECIMAL(10,2) DEFAULT 0,
    pending_balance DECIMAL(10,2) NOT NULL,
    due_date DATE,
    is_paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (sale_id) REFERENCES sales(id)
) ENGINE = InnoDB;

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT current_timestamp,
    FOREIGN KEY (account_id) REFERENCES accounts_receivable(id)
) ENGINE = InnoDB;

-- ==========================================
-- 4. SEED DATA
-- ==========================================

INSERT INTO categories (name, description) VALUES
('Bebidas', 'Refrescos, jugos y aguas'),
('Botanas', 'Papas, frituras y cacahuates'),
('Granel', 'Productos por peso (tortillas, jamon, etc)');

INSERT INTO products (code, name, description, category_id, buy_price, sell_price, actual_stock, minimum_stock)
VALUES 
('COCA400', 'Coca Cola 400ml', 'Refresco de cola 400ml', 1, 8.50, 15.00, 50, 10),
('SAB45', 'Sabritas Originales', 'Papas 45g', 2, 10.00, 18.00, 35, 10),
('TORT1', 'Tortillas Maiz', 'Venta por Kg', 3, 15.00, 22.00, 20.500, 5.000);