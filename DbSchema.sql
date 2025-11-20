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
    actual_stock INT DEFAULT 0,
    minimum_stock INT DEFAULT 5,
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

)