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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_GetPharmacistPendingPrescriptions
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ha Noi', '456 Le Duan, Hanoi', '0249876543');

INSERT INTO `Staff` (`first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role`, `branch_id`) VALUES
('Le', 'Thi B', 'lethib@longchau.com', '0902222222', SHA2('pass_b_raw', 256), 'Pharmacist', 1), -- Pharmacist ID 1
('Hoang', 'Van E', 'hoangvane@longchau.com', '0905555555', SHA2('pass_e_raw', 256), 'Pharmacist', 1); -- Pharmacist ID 2

INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`) VALUES
('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', SHA2('pass_f_raw', 256)),
('Tran', 'Van G', 'tranvang@example.com', '0987654321', '101 Hoang Hoa Tham, Hanoi', SHA2('pass_g_raw', 256));

INSERT INTO `Prescriptions` (`customer_id`, `upload_date`, `file_path`, `validation_status`, `pharmacist_id`, `customer_notes`) VALUES
(1, '2025-07-01 09:00:00', '/prescriptions/customer1_rx1.pdf', 'Pending', 1, 'Cần xác nhận nhanh.'), -- Assigned to Pharmacist 1
(1, '2025-07-02 10:00:00', '/prescriptions/customer1_rx2.pdf', 'Approved', 1, 'Đơn thuốc cũ.'),
(2, '2025-07-03 11:00:00', '/prescriptions/customer2_rx1.pdf', 'Pending', 2, 'Tôi muốn mua thuốc này.'), -- Assigned to Pharmacist 2
(2, '2025-07-04 12:00:00', '/prescriptions/customer2_rx2.pdf', 'Pending', 1, 'Kiểm tra giúp tôi loại thuốc này.'); -- Assigned to Pharmacist 1

SELECT '--- KIỂM TRA STORED PROCEDURE: SP_GetPharmacistPendingPrescriptions ---' AS 'Info';
-- Procedure này: Lấy danh sách các đơn thuốc đang chờ xác nhận cho một dược sĩ cụ thể (đã được gán).
-- Mục đích: Hiển thị các đơn thuốc cần dược sĩ xác nhận.
-- Đầu vào: p_pharmacist_id.
-- Expected output: Danh sách các đơn thuốc đang chờ.
-- Triggers được kích hoạt: KHÔNG CÓ trigger nào được kích hoạt.

SELECT 'Đơn thuốc đang chờ xác nhận cho Pharmacist ID 1 (Le Thi B):' AS 'Info';
CALL `SP_GetPharmacistPendingPrescriptions`(1);

SELECT 'Đơn thuốc đang chờ xác nhận cho Pharmacist ID 2 (Hoang Van E):' AS 'Info';
CALL `SP_GetPharmacistPendingPrescriptions`(2);

SELECT 'Đơn thuốc đang chờ xác nhận cho Pharmacist ID không tồn tại (ví dụ: 99):' AS 'Info';
CALL `SP_GetPharmacistPendingPrescriptions`(99);