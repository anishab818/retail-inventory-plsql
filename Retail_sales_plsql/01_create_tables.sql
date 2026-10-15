-- =====================================================================
-- Retail Inventory & Sales Management System (Oracle PL/SQL)
-- Script 01: Create tables and sequences
-- Run this FIRST, once, in a fresh schema.
-- =====================================================================

CREATE TABLE customers (
  customer_id  VARCHAR2(20) PRIMARY KEY,
  cust_name    VARCHAR2(100) NOT NULL,
  segment      VARCHAR2(30),
  city         VARCHAR2(60),
  country      VARCHAR2(60),
  joined_date  DATE
);

CREATE TABLE suppliers (
  supplier_id   NUMBER PRIMARY KEY,
  supplier_name VARCHAR2(100) NOT NULL,
  city          VARCHAR2(50)
);

CREATE TABLE products (
  product_id    VARCHAR2(30) PRIMARY KEY,
  product_name  VARCHAR2(200) NOT NULL,
  category      VARCHAR2(50),
  sub_category  VARCHAR2(50),
  unit_price    NUMBER(10,2) CHECK (unit_price > 0),
  stock_qty     NUMBER DEFAULT 0 CHECK (stock_qty >= 0),
  reorder_level NUMBER DEFAULT 20,
  supplier_id   NUMBER REFERENCES suppliers(supplier_id)
);

CREATE TABLE orders (
  order_id      VARCHAR2(30) PRIMARY KEY,
  customer_id   VARCHAR2(20) REFERENCES customers(customer_id),
  order_date    DATE,
  ship_mode     VARCHAR2(30),
  total_amount  NUMBER(12,2) DEFAULT 0
);

CREATE TABLE order_items (
  item_id     NUMBER PRIMARY KEY,
  order_id    VARCHAR2(30) REFERENCES orders(order_id),
  product_id  VARCHAR2(30) REFERENCES products(product_id),
  quantity    NUMBER CHECK (quantity > 0),
  unit_price  NUMBER(10,2),
  discount    NUMBER(4,2) DEFAULT 0
);

CREATE TABLE stock_log (
  log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id  VARCHAR2(30),
  old_qty     NUMBER,
  new_qty     NUMBER,
  changed_on  DATE DEFAULT SYSDATE,
  reason      VARCHAR2(50)
);

CREATE SEQUENCE order_seq START WITH 5001;
CREATE SEQUENCE item_seq  START WITH 100000;
