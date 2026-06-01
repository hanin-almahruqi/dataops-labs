# Data Quality Report

## Summary

Found 5 issues across 3 tables during Week 3 testing.

## Issues Found

### 1. Future Order Date

- **Table:** raw_orders
- **Row:** order_id = 1201
- **Issue:** order_date is 2099-12-31 (future date)
- **Test:** test_no_future_orders.sql
- **Recommended Fix:** Filter out in staging layer

### 2. Duplicate Order ID

- **Table:** raw_orders
- **Row:** order_id = 1050 (appears twice)
- **Issue:** Duplicate primary key
- **Test:** unique test on order_id
- **Recommended Fix:** Deduplicate in staging using ROW_NUMBER()

### 3. Negative shipping fee

- **Table:** raw_orders
- **Row:** order_id = 1204
- **Issue:** shipping fee is -10.00 
- **Test:** test_positive_shipping.sql
- **Recommended Fix:** filter out in staging layer

### 4. Negative shipping fee

- **Table:** raw_products
- **Row:** product_id = P-035
- **Issue:** cost price is -5.00 
- **Test:** test_positive_cost_price.sql
- **Recommended Fix:** filter out in staging layer

### 5. Negative quantity

- **Table:** raw_order_items
- **Row:** order_item_id = 309
- **Issue:** quantity is -2 
- **Test:** test_positive_quantities.sql
- **Recommended Fix:** filter out in staging layer

### 6. Valid discount range

- **Table:** raw_order_items
- **Row:** order_item_id = 311
- **Issue:** discount range is 150.00 > 100 
- **Test:** test_valid discount_range.sql
- **Recommended Fix:** filter out in staging layer