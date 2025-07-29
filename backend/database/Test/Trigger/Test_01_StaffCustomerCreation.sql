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

-- Đặt lại AUTO_INCREMENT cho các bảng (đảm bảo ID luôn bắt đầu từ 1 cho mỗi lần chạy test)
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

-- Dữ liệu mẫu cần thiết cho các test và làm nền tảng cho các file khác
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567'),
('Long Chau Ha Noi', '456 Le Duan, Hanoi', '0249876543');

-- Sử dụng SP_RegisterNewStaff để thêm nhân viên
SELECT '--- TEST SP_RegisterNewStaff ---' AS 'Info';
CALL `SP_RegisterNewStaff`('Nguyen', 'Van A', 'nguyenvana@longchau.com', '0901111111', 'pass_a_raw', 'BranchManager', 1);
CALL `SP_RegisterNewStaff`('Le', 'Thi B', 'lethib@longchau.com', '0902222222', 'pass_b_raw', 'Pharmacist', 1);
CALL `SP_RegisterNewStaff`('Tran', 'Van C', 'tranvanc@longchau.com', '0903333333', 'pass_c_raw', 'Cashier', 1);
CALL `SP_RegisterNewStaff`('Pham', 'Thi D', 'phamthid@longchau.com', '0904444444', 'pass_d_raw', 'WarehouseStaff', 1);
CALL `SP_RegisterNewStaff`('Hoang', 'Van E', 'hoangvane@longchau.com', '0905555555', 'pass_e_raw', 'Pharmacist', 2);
SELECT `staff_id`, `first_name`, `last_name`, `email`, `role`, `branch_id` FROM `Staff`;

-- Sử dụng SP_RegisterNewCustomer để thêm khách hàng
SELECT '--- TEST SP_RegisterNewCustomer ---' AS 'Info';
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');
CALL `SP_RegisterNewCustomer`('Tran', 'Van G', 'tranvang@example.com', '0987654321', '101 Hoang Hoa Tham, Hanoi', 'pass_g_raw');
SELECT `customer_id`, `first_name`, `last_name`, `email` FROM `Customers`;

-- Insert Products và tồn kho ban đầu (cần cho các trigger liên quan đến order/inventory)
INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE),
('Amoxicillin 250mg', 'Kháng sinh', 50000.00, 'Thuốc', TRUE),
('Vitamin C 1000mg', 'Thực phẩm chức năng', 120000.00, 'Thực phẩm chức năng', FALSE);

CALL `SP_RestockInventory`(1, 1, 100); -- Chi nhánh 1, Paracetamol
CALL `SP_RestockInventory`(1, 2, 50);  -- Chi nhánh 1, Amoxicillin
CALL `SP_RestockInventory`(1, 3, 75);  -- Chi nhánh 1, Vitamin C
CALL `SP_RestockInventory`(2, 1, 80);  -- Chi nhánh 2, Paracetamol
CALL `SP_RestockInventory`(2, 3, 60);  -- Chi nhánh 2, Vitamin C
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1;