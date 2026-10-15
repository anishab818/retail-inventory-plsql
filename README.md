# Retail Inventory & Sales Management System (Oracle PL/SQL)

A database project that automates order processing, stock control and audit logging for a retail business, built with Oracle SQL and PL/SQL.

## Business problem
Retail businesses lose sales and money when stock runs out unnoticed, orders are accepted for items that aren't available, and stock changes aren't tracked. This project automates those controls inside the database.

## Features
- Orders are validated: invalid customers and unavailable products are rejected
- Stock is reduced automatically when an order line is added
- Orders that exceed available stock are blocked with a clear error message
- Every stock change is recorded in an audit table
- Bill calculation with discount and tax

## Database design
Six tables: `customers`, `suppliers`, `products`, `orders`, `order_items`, `stock_log`.

## PL/SQL objects
| Type | Name | Purpose |
|---|---|---|
| Function | `calc_line_amount` | Line total after discount |
| Function | `get_order_bill` | Order total including tax |
| Function | `check_stock` | Returns Y / N / X for stock availability |
| Procedure | `place_order` | Validates and places an order, with exception handling |
| Trigger | `trg_order_item_stock` | Blocks orders when stock is short, otherwise reduces stock |
| Trigger | `trg_stock_log` | Writes every stock change to `stock_log` |

## How to run
1. Create a free workspace at apex.oracle.com (or use any Oracle database).
2. Run the scripts in order: `01_create_tables.sql`, then each `02_data_part*.sql` once, then `03_functions.sql`, `04_procedures.sql`, `05_triggers.sql`.
3. Run `07_test_cases.sql` in SQL Commands and read the DBMS Output tab.

## Testing
`07_test_cases.sql` runs 10 automated checks covering normal orders, stock reduction, audit logging, rejected orders and the stock-check function.

## Data source
Sample data adapted from the Global Superstore dataset on Kaggle. Supplier names, stock levels and reorder levels were added by me for this project.

## Tools
Oracle APEX (SQL Workshop), Oracle SQL and PL/SQL, Python/pandas (to generate the INSERT scripts).

## Author
ANISHA BANERJEE, PGDM student | https://www.linkedin.com/in/anisha-banerjee-648079217/
