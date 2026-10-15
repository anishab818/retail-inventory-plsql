-- =====================================================================
-- Retail Inventory & Sales Management System (Oracle PL/SQL)
-- Script 07: Automated test cases (10 checks)
-- Run AFTER scripts 01-05.
-- In Oracle APEX: SQL Workshop > SQL Commands > Run, then read the
--   "DBMS Output" tab.
-- In SQL Developer: add  SET SERVEROUTPUT ON  above and run with F5.
-- NOTE: each run places a real order and reduces stock by 2.
-- =====================================================================

DECLARE
  v_cust          customers.customer_id%TYPE;
  v_prod          products.product_id%TYPE;
  v_price         products.unit_price%TYPE;
  v_stock_before  products.stock_qty%TYPE;
  v_stock_after   products.stock_qty%TYPE;
  v_orders_before NUMBER;
  v_orders_after  NUMBER;
  v_log_count     NUMBER;
  v_order_id      orders.order_id%TYPE;
  v_bill          NUMBER;
  v_passed        NUMBER := 0;
  v_failed        NUMBER := 0;

  PROCEDURE report(p_name VARCHAR2, p_ok BOOLEAN) IS
  BEGIN
    IF p_ok THEN
      v_passed := v_passed + 1;
      DBMS_OUTPUT.PUT_LINE('PASS - ' || p_name);
    ELSE
      v_failed := v_failed + 1;
      DBMS_OUTPUT.PUT_LINE('FAIL - ' || p_name);
    END IF;
  END report;

BEGIN
  -- pick a customer and a product with enough stock
  SELECT customer_id INTO v_cust
  FROM customers FETCH FIRST 1 ROWS ONLY;

  SELECT product_id, stock_qty, unit_price
  INTO v_prod, v_stock_before, v_price
  FROM products WHERE stock_qty >= 5 FETCH FIRST 1 ROWS ONLY;

  -- TESTS 1-2: normal order
  SELECT COUNT(*) INTO v_orders_before FROM orders;
  place_order(v_cust, v_prod, 2, 0.1);
  SELECT COUNT(*) INTO v_orders_after FROM orders;
  SELECT stock_qty INTO v_stock_after FROM products WHERE product_id = v_prod;

  report('Test 1: normal order creates one new order',
         v_orders_after = v_orders_before + 1);
  report('Test 2: stock reduced by the ordered quantity',
         v_stock_after = v_stock_before - 2);

  -- TEST 3: trigger logged the stock change
  SELECT COUNT(*) INTO v_log_count
  FROM stock_log
  WHERE product_id = v_prod
    AND old_qty = v_stock_before
    AND new_qty = v_stock_after
    AND reason = 'SALE';
  report('Test 3: stock_log has a SALE entry', v_log_count >= 1);

  -- TEST 4: bill function with 18% tax
  SELECT order_id INTO v_order_id
  FROM orders
  WHERE order_id LIKE 'ORD-%'
  ORDER BY TO_NUMBER(SUBSTR(order_id, 5)) DESC
  FETCH FIRST 1 ROWS ONLY;

  v_bill := get_order_bill(v_order_id, 18);
  report('Test 4: bill with tax matches expected value',
         v_bill = ROUND(calc_line_amount(2, v_price, 0.1) * 1.18, 2));

  -- TESTS 5-6: order larger than available stock must be rejected
  SELECT COUNT(*) INTO v_orders_before FROM orders;
  SELECT stock_qty INTO v_stock_before FROM products WHERE product_id = v_prod;
  place_order(v_cust, v_prod, 99999);
  SELECT COUNT(*) INTO v_orders_after FROM orders;
  SELECT stock_qty INTO v_stock_after FROM products WHERE product_id = v_prod;

  report('Test 5: oversized order is rejected (no new order)',
         v_orders_after = v_orders_before);
  report('Test 6: stock unchanged after rejected order',
         v_stock_after = v_stock_before);

  -- TEST 7: invalid customer must be rejected
  SELECT COUNT(*) INTO v_orders_before FROM orders;
  place_order('XX-00000', v_prod, 1);
  SELECT COUNT(*) INTO v_orders_after FROM orders;
  report('Test 7: invalid customer is rejected',
         v_orders_after = v_orders_before);

  -- TEST 8: check_stock function
  report('Test 8a: check_stock returns Y when stock is enough',
         check_stock(v_prod, 1) = 'Y');
  report('Test 8b: check_stock returns N when stock is short',
         check_stock(v_prod, 99999) = 'N');
  report('Test 8c: check_stock returns X for unknown product',
         check_stock('NO-SUCH-ID', 1) = 'X');

  DBMS_OUTPUT.PUT_LINE('-----------------------------');
  DBMS_OUTPUT.PUT_LINE('Passed: ' || v_passed || ' | Failed: ' || v_failed);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Test script error: ' || SQLERRM);
END;
/
