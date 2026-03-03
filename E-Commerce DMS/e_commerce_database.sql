-- -- -- -- -- -- -- -- --
## Creating a Database ##
-- -- -- -- -- -- -- -- --

CREATE DATABASE ECommerceProject;

-- -- -- -- -- -- -- --
## Creating Tables ##
-- -- -- -- -- -- -- --

## DE States ##
CREATE TABLE states(
	state_id INT AUTO_INCREMENT PRIMARY KEY,
    state_name VARCHAR(50) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE
);

## Team Types ##
CREATE TABLE team_types(
	team_type_id INT AUTO_INCREMENT PRIMARY KEY,
    team_type_name VARCHAR(50) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE
);

## Locations ##
CREATE TABLE locations(
	location_id INT AUTO_INCREMENT PRIMARY KEY,
	postal_code VARCHAR(10),
	city VARCHAR(50) NOT NULL,
	state_id INT,
    FOREIGN KEY(state_id) REFERENCES states(state_id)
);

## Customers ##
-- Vertical partitioning for GDPR Compliance.

-- Parent table for analytics and no PII. This is the permanent customers table and anonymized.
CREATE TABLE customers(
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
	location_id INT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    pii_deleted_at DATETIME,
	FOREIGN KEY(location_id) REFERENCES locations(location_id)
);

-- Child table with customer PII, temporary table - rows are deleted in accordance to GDPR.
CREATE TABLE customers_pii(
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(150) UNIQUE NOT NULL,
	telephone VARCHAR(50) NOT NULL UNIQUE,
	street_address VARCHAR(200),
	FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

## Company Teams ##
CREATE TABLE teams(
	team_id INT AUTO_INCREMENT PRIMARY KEY,
	team_name VARCHAR(100) NOT NULL UNIQUE,
	team_type_id INT NOT NULL,
    assigned_state_id INT,
    FOREIGN KEY(team_type_id) REFERENCES team_types(team_type_id),
	FOREIGN KEY(assigned_state_id) REFERENCES states(state_id)
);

## Employees ##
-- Vertical partitioning for GDPR Compliance.

-- Parent table for analytics and no PII. This is the permanent employees table and anonymized.
CREATE TABLE employees(
	employee_id INT AUTO_INCREMENT PRIMARY KEY,
	location_id INT,
	team_id INT NOT NULL,
    pii_deleted_at DATETIME,
	FOREIGN KEY(team_id) REFERENCES teams(team_id),
	FOREIGN KEY(location_id) REFERENCES locations(location_id)
);

-- Child table with employee PII, temporary table - rows are deleted in accordance to GDPR.
CREATE TABLE employees_pii(
	employee_id INT PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	telephone VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(75) NOT NULL UNIQUE,
    street_address VARCHAR(200),
    FOREIGN KEY(employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);
    
## Warehouses ##
CREATE TABLE warehouses(
	warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
	warehouse_name VARCHAR(100) NOT NULL UNIQUE,
	street_address VARCHAR(200) NOT NULL,
	location_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    assigned_employee_id INT NOT NULL,
	FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY(assigned_employee_id) REFERENCES employees(employee_id)
);

## Product Departments ##
CREATE TABLE prod_departments(
	department_id INT AUTO_INCREMENT PRIMARY KEY,
	department_name VARCHAR(100) UNIQUE NOT NULL,
	description VARCHAR(270),
	is_active BOOLEAN DEFAULT TRUE
);

## Products ##
CREATE TABLE products(
	product_id INT AUTO_INCREMENT PRIMARY KEY,
	sku VARCHAR(50) NOT NULL UNIQUE,
	product_name VARCHAR(200) NOT NULL,
	department_id INT NOT NULL,
	cost_price DECIMAL(18,2) NOT NULL,
	retail_price DECIMAL(18,2) NOT NULL,
	is_active BOOLEAN DEFAULT TRUE,
	FOREIGN KEY(department_id) REFERENCES prod_departments(department_id)
);

## Order Status ##
CREATE TABLE order_statuses(
	status_id INT AUTO_INCREMENT PRIMARY KEY,
	status_name VARCHAR(50) NOT NULL UNIQUE,
    is_terminal BOOLEAN DEFAULT FALSE
);

## Orders ##
CREATE TABLE orders(
	order_id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	order_status_id INT NOT NULL,
	FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY(order_status_id) REFERENCES order_statuses(status_id)
);

## Order Items ##

-- First many-to-many relationship: Product and Order
CREATE TABLE order_items(
	order_item_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT NOT NULL,
	product_id INT NOT NULL,
	quantity INT NOT NULL CHECK (quantity > 0),
	unit_price DECIMAL(18,2) NOT NULL,
    line_total DECIMAL(18,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
	FOREIGN KEY(order_id) REFERENCES orders(order_id),
	FOREIGN KEY(product_id) REFERENCES products(product_id),
	UNIQUE(order_id, product_id)
);

## Inventory ##
-- Second many-to-many relationship: Warehouse and Product
CREATE TABLE inventory(
	product_id INT NOT NULL,
	warehouse_id INT NOT NULL,
	quantity_on_hand INT NOT NULL DEFAULT 0,
	reorder_threshold INT NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(product_id, warehouse_id),
	CONSTRAINT chk_positive_stock CHECK (quantity_on_hand >= 0),
	FOREIGN KEY(product_id) REFERENCES products(product_id),
	FOREIGN KEY(warehouse_id) REFERENCES warehouses(warehouse_id)
);

## Payment Status ##
CREATE TABLE payment_statuses(
	status_id INT AUTO_INCREMENT PRIMARY KEY,
	status_name VARCHAR(50) NOT NULL UNIQUE,
	is_terminal BOOLEAN DEFAULT FALSE
);

## Payment Methods ##
CREATE TABLE payment_methods(
	method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT FALSE
);

## Payments ##
CREATE TABLE payments(
	payment_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT NOT NULL,
	payment_method_id INT NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	amount DECIMAL(18,2) NOT NULL,
	payment_status_id INT NOT NULL,
	FOREIGN KEY(order_id) REFERENCES orders(order_id),
	FOREIGN KEY(payment_status_id) REFERENCES payment_statuses(status_id),
	FOREIGN KEY(payment_method_id) REFERENCES payment_methods(method_id)
);

## Shipment Statuses ##
CREATE TABLE shipment_statuses(
	status_id INT AUTO_INCREMENT PRIMARY KEY,
	status_name VARCHAR(50) NOT NULL UNIQUE,
    is_terminal BOOLEAN DEFAULT FALSE
);

## Carriers ##
CREATE TABLE carriers(
	carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(200) NOT NULL UNIQUE,
    contact_email VARCHAR(200) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

## Shipment ##
CREATE TABLE shipments(
	shipment_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT NOT NULL,
	warehouse_id INT NOT NULL,
	shipment_status_id INT NOT NULL,
    carrier_id INT NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	delivered_at DATETIME,
	FOREIGN KEY(order_id) REFERENCES orders(order_id),
	FOREIGN KEY(warehouse_id) REFERENCES warehouses(warehouse_id),
	FOREIGN KEY(shipment_status_id) REFERENCES shipment_statuses(status_id),
    FOREIGN KEY(carrier_id) REFERENCES carriers(carrier_id)
);

## Product Reviews ##
CREATE TABLE reviews(
	review_id INT AUTO_INCREMENT PRIMARY KEY,
	customer_id INT NOT NULL,
	product_id INT NOT NULL,
	rating INT NOT NULL,
    review_title VARCHAR(150),
	review_comment TEXT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	UNIQUE(customer_id, product_id),
	FOREIGN KEY(product_id) REFERENCES products(product_id),              
	FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
	CONSTRAINT chk_rating_scale CHECK(rating BETWEEN 1 AND 5)
);

## Return Status ##
CREATE TABLE return_statuses(
	status_id INT AUTO_INCREMENT PRIMARY KEY,
	status_name VARCHAR(50) NOT NULL UNIQUE,
    is_terminal BOOLEAN DEFAULT FALSE
);

## Returns ##
CREATE TABLE returns(
	return_id INT AUTO_INCREMENT PRIMARY KEY,
	order_id INT NOT NULL,
	warehouse_id INT NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	return_status_id INT NOT NULL,
	refund_amount DECIMAL(18,2),
	FOREIGN KEY(order_id) REFERENCES orders(order_id),
	FOREIGN KEY(return_status_id) REFERENCES return_statuses(status_id),
	FOREIGN KEY(warehouse_id) REFERENCES warehouses(warehouse_id)
);

## Return Reasons ##
CREATE TABLE return_reasons(
	return_reason_id INT AUTO_INCREMENT PRIMARY KEY,
    reason_label VARCHAR(100) NOT NULL UNIQUE,
    is_merchant_fault BOOLEAN DEFAULT FALSE
);

## Return Items ##

-- Third many-to-many relationship: Returns and Products
CREATE TABLE return_items(
	return_id INT NOT NULL,
	order_item_id INT NOT NULL,
	quantity INT NOT NULL,
	return_reason_id INT NOT NULL,
    description TEXT,
	PRIMARY KEY(return_id, order_item_id),
	FOREIGN KEY(return_id) REFERENCES returns(return_id),
	FOREIGN KEY(order_item_id) REFERENCES order_items(order_item_id),
    FOREIGN KEY(return_reason_id) REFERENCES return_reasons(return_reason_id)
);


-- -- -- -- -- -- -- -- --
## Stored Procedures ##
-- -- -- -- -- -- -- -- --

## Customer Registration ##

DELIMITER //

CREATE PROCEDURE new_customer(
	IN p_location_id INT,
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_telephone VARCHAR(50),
    IN p_street_address VARCHAR(200)
)

BEGIN
	DECLARE new_customer_id INT;
    
    IF NOT EXISTS
		(SELECT 1 FROM locations WHERE location_id = p_location_id)
        THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided postal code does not exist in the locations table. Please provide the location first.';
	END IF;
    
    START TRANSACTION;
    INSERT INTO customers(location_id)
    VALUES(p_location_id);
    
    SET new_customer_id = LAST_INSERT_ID();
    INSERT INTO customers_pii(customer_id, first_name, last_name, email, telephone, street_address)
    VALUES (new_customer_id, p_first_name, p_last_name, p_email, p_telephone, p_street_address);
    
    COMMIT;
END //

DELIMITER ;

## Employee Registration ##

DELIMITER //

CREATE PROCEDURE new_employee(
	IN p_location_id INT,
    IN p_team_id INT,
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(150),
    IN p_telephone VARCHAR(50),
    IN p_street_address VARCHAR(200)
)

BEGIN
	DECLARE new_employee_id INT;
    
    IF NOT EXISTS (
		SELECT 1 FROM locations WHERE location_id = p_location_id)
        THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided location_id does not exist in the locations table. Please provide the location_id first.';
	END IF;
    
    IF NOT EXISTS (
		SELECT 1 FROM teams WHERE team_id = p_team_id)
        THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The provided team_id does not exists in the teams table. Please provide the team_id first.';
	END IF;
    
    START TRANSACTION;
    INSERT INTO employees(location_id, team_id)
    VALUES (p_location_id, p_team_id);
    
    SET new_employee_id = LAST_INSERT_ID();
    INSERT INTO employees_pii(employee_id, first_name, last_name, email, telephone, street_address)
    VALUES (new_employee_id, p_first_name, p_last_name, p_email, p_telephone, p_street_address);
    
    COMMIT;
    
END //

DELIMITER ;

## Customer Offboarding ##

DELIMITER //

CREATE PROCEDURE customer_offboarding(
	IN p_customer_id INT
)

BEGIN
	START TRANSACTION;
    UPDATE customers
    SET pii_deleted_at = CURRENT_TIMESTAMP
    WHERE customer_id = p_customer_id;
    
    DELETE FROM customers_pii
    WHERE customer_id = p_customer_id;
    
    COMMIT;
END //

DELIMITER ;

## Employee Offboarding ##

DELIMITER //

CREATE PROCEDURE employee_offboarding(
	IN p_employee_id INT
)

BEGIN
	START TRANSACTION;
    UPDATE employees
    SET pii_deleted_at = CURRENT_TIMESTAMP
    WHERE employee_id = p_employee_id;
    
    DELETE FROM employees_pii
    WHERE employee_id = p_employee_id;
    
    COMMIT;
END //

DELIMITER ;

## Return Process Check ##

DELIMITER //

CREATE TRIGGER validate_return_quantity
BEFORE INSERT ON return_items
FOR EACH ROW
BEGIN
	DECLARE ordered_qty INT;
    DECLARE previous_return_qty INT;
    
    SELECT quantity INTO ordered_qty
    FROM order_items
    WHERE order_item_id = NEW.order_item_id;
    
    SELECT COALESCE(SUM(quantity), 0) INTO previous_return_qty
    FROM return_items
    WHERE order_item_id = NEW.order_item_id;
    
    IF (previous_return_qty + NEW.quantity) > ordered_qty THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Return quantity must not exceed the original quantity!';
	END IF;
END; //

DELIMITER ;