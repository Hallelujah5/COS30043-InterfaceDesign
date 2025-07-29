USE `pharmacy_db`;

-- Xóa dữ liệu cũ để đảm bảo môi trường kiểm tra sạch cho riêng file này
DELETE FROM `Notifications`;
DELETE FROM `Receipts`;
DELETE FROM `Payments`;
DELETE FROM `OrderItems`;
DELETE FROM `Orders`;
DELETE FROM `Deliveries`;
DELETE FROM `Prescriptions`;
DELETE FROM `Inventory`;
DELETE FROM `Products`;
DELETE FROM `Customers`;
DELETE FROM `Staff`;
DELETE FROM `Branches`;

-- Đặt lại AUTO_INCREMENT cho các bảng
ALTER TABLE `Branches` AUTO_INCREMENT = 1;
ALTER TABLE `Staff` AUTO_INCREMENT = 1;
ALTER TABLE `Customers` AUTO_INCREMENT = 1;
ALTER TABLE `Products` AUTO_INCREMENT = 1;
ALTER TABLE `Prescriptions` AUTO_INCREMENT = 1;
ALTER TABLE `Deliveries` AUTO_INCREMENT = 1;
ALTER TABLE `Orders` AUTO_INCREMENT = 1;
ALTER TABLE `OrderItems` AUTO_INCREMENT = 1;
ALTER TABLE `Payments` AUTO_INCREMENT = 1;
ALTER TABLE `Receipts` AUTO_INCREMENT = 1;
ALTER TABLE `Notifications` AUTO_INCREMENT = 1;

-- Dữ liệu cơ bản cần thiết cho test này
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES ('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567');
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');
INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE),
('Amoxicillin 250mg', 'Kháng sinh', 50000.00, 'Thuốc', TRUE),
('Vitamin C 1000mg', 'Thực phẩm chức năng', 120000.00, 'Thực phẩm chức năng', FALSE);
CALL `SP_RestockInventory`(1, 1, 100); -- Tồn kho Paracetamol
CALL `SP_RestockInventory`(1, 2, 50);  -- Tồn kho Amoxicillin
CALL `SP_RestockInventory`(1, 3, 75);  -- Tồn kho Vitamin C
INSERT INTO `Prescriptions` (`customer_id`, `file_path`, `validation_status`, `customer_notes`) VALUES (1, '/prescriptions/file1.pdf', 'Approved', 'Đơn thuốc hợp lệ.');
CALL `SP_RegisterNewStaff`('Pham', 'Thi D', 'phamthid@longchau.com', '0904444444', 'pass_d_raw', 'WarehouseStaff', 1);

-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_order_item_insert & trg_update_order_total_amount
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_order_item_insert & trg_update_order_total_amount ---' AS 'Info';
-- Trigger `trg_after_order_item_insert`: Giảm số lượng tồn kho khi một OrderItem mới được thêm vào.
-- Trigger `trg_update_order_total_amount`: Cập nhật tổng số tiền của đơn hàng khi OrderItems thay đổi (INSERT).
-- Hành động kích hoạt: Gọi SP_PlaceOrder.
-- Kết quả mong đợi:
--   - Một đơn hàng mới sẽ được tạo.
--   - Delivery và Payments sẽ được tạo.
--   - `stock_quantity` của Product ID 1 (Paracetamol) tại Branch 1 sẽ giảm 50 (từ 100 xuống 50).
--   - `stock_quantity` của Product ID 3 (Vitamin C) tại Branch 1 sẽ giảm 10 (từ 75 xuống 65).
--   - `total_amount` của đơn hàng sẽ được tính toán và cập nhật.
--   - `has_prescription` của Customer ID 1 sẽ trở lại FALSE (nếu có đơn thuốc được sử dụng).

CALL `SP_PlaceOrder`(
    1, -- p_customer_id
    1, -- p_branch_id
    '[{"product_id": 1, "quantity": 50}, {"product_id": 3, "quantity": 10}]', -- p_product_details
    1, -- p_prescription_id (sử dụng đơn thuốc đã duyệt)
    '789 Vo Van Tan, HCMC', -- p_delivery_address
    'Shopee', -- p_delivery_party
    '2025-07-15 10:00:00', -- p_estimated_delivery_date
    'SPX98765', -- p_tracking_number
    5000.00, -- p_discount_amount
    'Online' -- p_order_source
);
SET @new_order_id = LAST_INSERT_ID();

SELECT 'Sau khi đặt Order mới (Order ID ', @new_order_id, ') với 2 OrderItems:' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND (`product_id` = 1 OR `product_id` = 3);
SELECT `order_id`, `total_amount`, `order_status` FROM `Orders` WHERE `order_id` = @new_order_id;
SELECT `customer_id`, `has_prescription` FROM `Customers` WHERE `customer_id` = 1;
SELECT `delivery_id`, `delivery_status` FROM `Deliveries` WHERE `delivery_id` = (SELECT delivery_id FROM Orders WHERE order_id = @new_order_id);
SELECT `payment_id`, `order_id`, `amount`, `transaction_status` FROM `Payments` WHERE `order_id` = @new_order_id;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_low_stock_notify_warehouse_staff
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_low_stock_notify_warehouse_staff ---' AS 'Info';
-- Trigger này: Thông báo cho WarehouseStaff khi sản phẩm xuống dưới ngưỡng tồn kho tối thiểu.
-- Hành động kích hoạt: UPDATE `stock_quantity` trong bảng `Inventory` khiến nó <= `min_stock_level` và giảm so với cũ.
-- Kết quả mong đợi:
--   - Một thông báo sẽ được gửi tới tất cả WarehouseStaff (hiện tại là Staff ID 4).

-- Giả định Paracetamol (product_id=1, branch_id=1) có min_stock_level là 20. Stock hiện tại là 50.
-- Giảm thêm 35 để nó xuống 5, thấp hơn 20.
UPDATE `Inventory` SET `stock_quantity` = 5 WHERE `branch_id` = 1 AND `product_id` = 1;

SELECT 'Sau khi tồn kho Paracetamol tại Branch 1 giảm xuống 5 (dưới min_stock_level 10):' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 1;
SELECT `notification_id`, `staff_id`, `product_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_order_item_update & trg_update_order_total_amount_on_update
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_order_item_update & trg_update_order_total_amount_on_update ---' AS 'Info';
-- Trigger `trg_after_order_item_update`: Điều chỉnh số lượng tồn kho khi số lượng của một OrderItem được cập nhật.
-- Trigger `trg_update_order_total_amount_on_update`: Cập nhật tổng số tiền của đơn hàng khi OrderItems thay đổi (UPDATE).
-- Hành động kích hoạt: UPDATE `quantity` của một OrderItem.
-- Kết quả mong đợi:
--   - `stock_quantity` của Product ID 3 (Vitamin C) tại Branch 1 sẽ giảm thêm 5 (từ 65 xuống 60)
--     vì số lượng OrderItem đã tăng từ 10 lên 15.
--   - `total_amount` của đơn hàng sẽ được cập nhật.

SELECT `order_item_id` INTO @order_item_id_prod3 FROM `OrderItems` WHERE `order_id` = @new_order_id AND `product_id` = 3;
UPDATE `OrderItems` SET `quantity` = 15 WHERE `order_item_id` = @order_item_id_prod3;

SELECT 'Sau khi cập nhật OrderItem của Vitamin C (từ 10 lên 15 cái) trong Order ID ', @new_order_id, ':' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 3;
SELECT `order_id`, `total_amount`, `order_status` FROM `Orders` WHERE `order_id` = @new_order_id;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_order_item_delete & trg_update_order_total_amount_on_delete
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_order_item_delete & trg_update_order_total_amount_on_delete ---' AS 'Info';
-- Trigger `trg_after_order_item_delete`: Tăng số lượng tồn kho khi một OrderItem bị xóa.
-- Trigger `trg_update_order_total_amount_on_delete`: Cập nhật tổng số tiền của đơn hàng khi OrderItems thay đổi (DELETE).
-- Hành động kích hoạt: DELETE một OrderItem.
-- Kết quả mong đợi:
--   - `stock_quantity` của Product ID 1 (Paracetamol) tại Branch 1 sẽ tăng 50 (từ 15 lên 65).
--   - `total_amount` của đơn hàng sẽ được cập nhật (giảm đi giá trị của Paracetamol).

DELETE FROM `OrderItems` WHERE `order_id` = @new_order_id AND `product_id` = 1;

SELECT 'Sau khi xóa OrderItem của Paracetamol từ Order ID ', @new_order_id, ':' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 1;
SELECT `order_id`, `total_amount`, `order_status` FROM `Orders` WHERE `order_id` = @new_order_id;