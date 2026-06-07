# Data Quality Report

## Summary

Found 11 issues across 4 tables during Week 3 testing.

## Issues Found

### 1. Future Order Date

- **Table:** raw_orders
- **Row:** order_id = 1201
- **Issue:** order_date is 2099-12-31 (future date)
- **Test:** test_no_future_orders.sql
- **Recommended Fix:** Filter out in staging layer or validate dates upstream

---

### 2. Duplicate Order ID

- **Table:** raw_orders
- **Row:** order_id = 1050 (appears twice)
- **Issue:** Duplicate primary key
- **Test:** unique_stg_orders_order_id
- **Recommended Fix:** Deduplicate in staging using ROW_NUMBER()

---

### 3. Negative Shipping Fee

- **Table:** raw_orders
- **Row:** order_id = 1204
- **Issue:** shipping fee is -10.00
- **Test:** test_positive_shipping.sql
- **Recommended Fix:** Filter out or set default value to 0 in staging layer

---

### 4. Missing Customer Email

- **Table:** raw_customers
- **Row:** customer_id = C-230
- **Issue:** email is NULL
- **Test:** not_null_stg_customers_email
- **Recommended Fix:** Populate missing email or remove invalid record

---

### 5. Missing Customer Reference

- **Table:** raw_orders
- **Row:** order_id = 1200
- **Issue:** customer_id is NULL
- **Test:** relationships_stg_orders_customer_id__customer_id__ref_stg_customers_
- **Recommended Fix:** Ensure customer_id is mandatory in source system

---

### 6. Invalid Customer Reference

- **Table:** raw_orders
- **Row:** order_id = 1203
- **Issue:** customer_id = C-999 does not exist
- **Test:** relationships_stg_orders_customer_id__customer_id__ref_stg_customers_
- **Recommended Fix:** Fix customer mapping or create missing customer record

---

### 7. Missing Product Reference

- **Table:** raw_order_items
- **Row:** order_item_id = 312
- **Issue:** product_id = P-999 does not exist
- **Test:** relationships_stg_order_items_product_id__product_id__ref_stg_products_
- **Recommended Fix:** Fix product mapping or add missing product record

---

### 8. Negative Quantity

- **Table:** raw_order_items
- **Row:** order_item_id = 309
- **Issue:** quantity is -2
- **Test:** test_positive_quantities.sql
- **Recommended Fix:** Enforce quantity > 0 in staging or source validation

---

### 9. Invalid Discount Percentage

- **Table:** raw_order_items
- **Row:** order_item_id = 311
- **Issue:** discount_pct = 150 (outside valid range 0–100)
- **Test:** test_valid_discount_range.sql
- **Recommended Fix:** Validate discount values before ingestion

---

### 10. Duplicate Order Item ID

- **Table:** raw_order_items
- **Row:** order_item_id = 1 (duplicate)
- **Issue:** Primary key violation
- **Test:** unique_stg_order_items_order_item_id
- **Recommended Fix:** Deduplicate using ROW_NUMBER() or fix source extraction

---

### 11. Negative Cost Price

- **Table:** raw_products
- **Row:** product_id = P-035
- **Issue:** cost_price = -5.00
- **Test:** test_positive_cost_price.sql
- **Recommended Fix:** Enforce non-negative pricing rules at source system