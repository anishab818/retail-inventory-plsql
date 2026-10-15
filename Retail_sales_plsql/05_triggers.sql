-- =====================================================================
-- Retail Inventory & Sales Management System (Oracle PL/SQL)
-- Script 05: Triggers
-- IMPORTANT: run this AFTER the historical data is loaded, otherwise
-- the order_items trigger would change stock while loading old orders.
-- =====================================================================

-- Logs every change to products.stock_qty
CREATE OR REPLACE TRIGGER trg_stock_log
AFTER UPDATE OF stock_qty ON products
FOR EACH ROW
WHEN (OLD.stock_qty <> NEW.stock_qty)
BEGIN
  INSERT INTO stock_log (product_id, old_qty, new_qty, reason)
  VALUES (
    :OLD.product_id,
    :OLD.stock_qty,
    :NEW.stock_qty,
    CASE WHEN :NEW.stock_qty < :OLD.stock_qty THEN 'SALE' ELSE 'RESTOCK' END
  );
END trg_stock_log;
/

-- Blocks an order line when stock is short, otherwise reduces stock
CREATE OR REPLACE TRIGGER trg_order_item_stock
BEFORE INSERT ON order_items
FOR EACH ROW
DECLARE
  v_stock products.stock_qty%TYPE;
BEGIN
  SELECT stock_qty INTO v_stock
  FROM products
  WHERE product_id = :NEW.product_id
  FOR UPDATE;

  IF v_stock < :NEW.quantity THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Insufficient stock for ' || :NEW.product_id ||
      ' (available: ' || v_stock || ')');
  END IF;

  UPDATE products
  SET stock_qty = stock_qty - :NEW.quantity
  WHERE product_id = :NEW.product_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'Product not found: ' || :NEW.product_id);
END trg_order_item_stock;
/
