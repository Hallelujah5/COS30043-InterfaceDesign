-- Đảm bảo sử dụng đúng database
USE `pharmacy_db`;

-- Xóa dữ liệu cũ để đảm bảo môi trường kiểm tra sạch
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

-- Đặt lại AUTO_INCREMENT cho các bảng để ID luôn bắt đầu từ 1
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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_RestockInventory
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567');

-- THÊM DỮ LIỆU NHÂN VIÊN KHO (WarehouseStaff)
CALL `SP_RegisterNewStaff`('Pham', 'Thi D', 'phamthid@longchau.com', '0904444444', 'pass_d_raw', 'WarehouseStaff', 1);
SET @warehouse_staff_id = LAST_INSERT_ID(); -- Lưu ID của WarehouseStaff

INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE); -- Product ID 1

INSERT INTO `Inventory` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 100, 20); -- Branch 1, Paracetamol


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_RestockInventory ---' AS 'Info';
-- Procedure này: Cập nhật số lượng tồn kho cho một sản phẩm tại một chi nhánh.
-- Mục đích: Tăng số lượng `stock_quantity` của một sản phẩm trong `Inventory`.
-- Đầu vào: p_branch_id, p_product_id, p_quantity_to_add.
-- Expected output: `stock_quantity` của Product ID 1 tại Branch 1 sẽ tăng lên.
-- Triggers được kích hoạt:
--   - SP_RestockInventory tự tạo Notification.
--   - `trg_low_stock_notify_warehouse_staff` nếu số lượng mới sau restock vẫn dưới ngưỡng (không xảy ra trong test restock tăng).

SELECT 'Tồn kho Paracetamol (Product ID 1) tại Branch ID 1 trước khi restock:' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 1;
SELECT COUNT(*) AS total_notifications_before FROM `Notifications`;


CALL `SP_RestockInventory`(1, 1, 50); -- Bổ sung 50 Paracetamol vào Branch 1

SELECT 'Sau khi gọi SP_RestockInventory (Branch 1, Product 1, thêm 50):' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 1;
-- Kiểm tra thông báo được tạo bởi SP_RestockInventory
SELECT `notification_id`, `staff_id`, `branch_id`, `product_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;

-- Kiểm tra trường hợp sản phẩm chưa có trong kho chi nhánh (nếu cần)
INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Bandage', 'Băng gạc', 5000.00, 'Vật tư y tế', FALSE); -- Product ID 2

SELECT 'Tồn kho Bandage (Product ID 2) tại Branch ID 1 trước khi restock (không tồn tại):' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 2;

CALL `SP_RestockInventory`(1, 2, 200); -- Thêm 200 Bandage vào Branch 1 (tạo bản ghi mới)

SELECT 'Sau khi gọi SP_RestockInventory (Branch 1, Product 2, thêm 200):' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` = 2;
-- Kiểm tra thông báo mới cho Bandage
SELECT `notification_id`, `staff_id`, `branch_id`, `product_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;