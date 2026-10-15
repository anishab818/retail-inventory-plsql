-- =====================================================================
-- Retail Inventory & Sales Management System (Oracle PL/SQL)
-- Script 04: Procedures
-- Requires: 03_functions.sql (calc_line_amount)
-- =====================================================================

-- Places a single-product order.
--   Validates the customer, looks up the price, creates the order and
--   order line, and saves. Stock checks and stock reduction are done by
--   the trigger trg_order_item_stock (05_triggers.sql).
CREATE OR REPLACE PROCEDURE place_order(
  p_customer_id VARCHAR2,
  p_product_id  VARCHAR2,
  p_qty         NUMBER,
  p_discount    NUMBER DEFAULT 0
) IS
  v_cust_count NUMBER;
  v_price      products.unit_price%TYPE;
  v_order_id   orders.order_id%TYPE;
  v_total      NUMBER;
BEGIN
  -- 1. validate customer
  SELECT COUNT(*) INTO v_cust_count
  FROM customers
  WHERE customer_id = p_customer_id;

  IF v_cust_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Invalid customer: ' || p_customer_id);
  END IF;

  -- 2. look up price (raises NO_DATA_FOUND if product does not exist)
  SELECT unit_price INTO v_price
  FROM products
  WHERE product_id = p_product_id;

  -- 3. create order header
  v_order_id := 'ORD-' || order_seq.NEXTVAL;

  INSERT INTO orders (order_id, customer_id, order_date, ship_mode, total_amount)
  VALUES (v_order_id, p_customer_id, SYSDATE, 'Standard Class', 0);

  -- 4. create order line (trigger checks and reduces stock)
  INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount)
  VALUES (item_seq.NEXTVAL, v_order_id, p_product_id, p_qty, v_price, p_discount);

  -- 5. update order total and save
  v_total := calc_line_amount(p_qty, v_price, p_discount);
  UPDATE orders SET total_amount = v_total WHERE order_id = v_order_id;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Order placed: ' || v_order_id || ' | Total: ' || v_total);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: product not found - ' || p_product_id);
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Order failed: ' || SQLERRM);
END place_order;
/
