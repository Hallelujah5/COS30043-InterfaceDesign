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


-- Dữ liệu mẫu tối thiểu cần thiết cho SP_RegisterNewStaff
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567');

SELECT '--- KIỂM TRA STORED PROCEDURE: SP_RegisterNewStaff ---' AS 'Info';
-- Procedure này: Đăng ký một nhân viên mới vào hệ thống.
-- Mục đích: Thêm một bản ghi mới vào bảng `Staff`.
-- Đầu vào: p_first_name, p_last_name, p_email, p_phone_number, p_raw_password, p_role, p_branch_id.
-- Expected output: Trả về `new_staff_id` của nhân viên vừa tạo.
-- Triggers được kích hoạt: KHÔNG CÓ trigger nào được kích hoạt trực tiếp bởi INSERT vào bảng `Staff`.

SELECT 'Trước khi gọi SP_RegisterNewStaff:' AS 'Info';
SELECT COUNT(*) AS total_staff FROM `Staff`;

CALL `SP_RegisterNewStaff`('Nguyen', 'Thi K', 'nguyenthik@longchau.com', '0906666666', 'password_k_raw', 'Cashier', 1);

SELECT 'Sau khi gọi SP_RegisterNewStaff:' AS 'Info';
SELECT `staff_id`, `first_name`, `last_name`, `email`, `role`, `password_hash` FROM `Staff` ORDER BY `staff_id` DESC LIMIT 1;