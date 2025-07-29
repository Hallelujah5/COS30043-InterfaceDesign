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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_GetBranchInventoryStatus
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567'), -- Branch ID 1
('Long Chau Ha Noi', '456 Le Duan, Hanoi', '0249876543'); -- Branch ID 2

INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE), -- Product ID 1
('Amoxicillin 250mg', 'Kháng sinh', 50000.00, 'Thuốc', TRUE), -- Product ID 2
('Vitamin C 1000mg', 'Thực phẩm chức năng', 120000.00, 'Thực phẩm chức năng', FALSE), -- Product ID 3
('Băng cá nhân', 'Dụng cụ y tế', 5000.00, 'Vật tư y tế', FALSE); -- Product ID 4

INSERT INTO `Inventory` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 100, 20), -- Branch 1, Paracetamol (Đủ)
(1, 2, 5, 10),    -- Branch 1, Amoxicillin (Dưới ngưỡng)
(1, 3, 15, 15),   -- Branch 1, Vitamin C (Đúng ngưỡng)
(2, 1, 80, 20),   -- Branch 2, Paracetamol (Đủ)
(2, 3, 10, 15);   -- Branch 2, Vitamin C (Dưới ngưỡng)

SELECT '--- KIỂM TRA STORED PROCEDURE: SP_GetBranchInventoryStatus ---' AS 'Info';
-- Procedure này: Lấy trạng thái tồn kho của tất cả sản phẩm tại một chi nhánh cụ thể, bao gồm cả ngưỡng tồn kho tối thiểu.
-- Mục đích: Cung cấp thông tin tồn kho và cảnh báo.
-- Đầu vào: p_branch_id.
-- Expected output: Danh sách tồn kho theo chi nhánh với cột 'stock_status_alert'.
-- Triggers được kích hoạt: KHÔNG CÓ trigger nào được kích hoạt.

SELECT 'Trạng thái tồn kho cho Branch ID 1 (Long Chau Ho Chi Minh):' AS 'Info';
CALL `SP_GetBranchInventoryStatus`(1);

SELECT 'Trạng thái tồn kho cho Branch ID 2 (Long Chau Ha Noi):' AS 'Info';
CALL `SP_GetBranchInventoryStatus`(2);

SELECT 'Trạng thái tồn kho cho Branch ID không tồn tại (ví dụ: 99):' AS 'Info';
CALL `SP_GetBranchInventoryStatus`(99);