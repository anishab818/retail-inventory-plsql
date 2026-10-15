-- =====================================================================
-- Retail Inventory & Sales Management System (Oracle PL/SQL)
-- Script 03: Functions
-- Run AFTER the data has been loaded (02_data_part*.sql).
-- =====================================================================

-- Line total after discount (discount as a fraction, e.g. 0.1 = 10%)
CREATE OR REPLACE FUNCTION calc_line_amount(
  p_qty      NUMBER,
  p_price    NUMBER,
  p_discount NUMBER DEFAULT 0
) RETURN NUMBER IS
BEGIN
  RETURN ROUND(p_qty * p_price * (1 - p_discount), 2);
END calc_line_amount;
/

-- Order total including tax (default 18%)
CREATE OR REPLACE FUNCTION get_order_bill(
  p_order_id VARCHAR2,
  p_tax_pct  NUMBER DEFAULT 18
) RETURN NUMBER IS
  v_subtotal NUMBER;
BEGIN
  SELECT NVL(SUM(calc_line_amount(quantity, unit_price, discount)), 0)
  INTO v_subtotal
  FROM order_items
  WHERE order_id = p_order_id;

  RETURN ROUND(v_subtotal * (1 + p_tax_pct / 100), 2);
END get_order_bill;
/

-- Returns 'Y' if enough stock, 'N' if short, 'X' if product not found
CREATE OR REPLACE FUNCTION check_stock(
  p_product_id VARCHAR2,
  p_qty        NUMBER
) RETURN VARCHAR2 IS
  v_stock products.stock_qty%TYPE;
BEGIN
  SELECT stock_qty INTO v_stock
  FROM products
  WHERE product_id = p_product_id;

  IF v_stock >= p_qty THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'X';
END check_stock;
/
