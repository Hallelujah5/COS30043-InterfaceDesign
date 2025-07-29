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


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_RegisterNewCustomer ---' AS 'Info';
-- Procedure này: Đăng ký một khách hàng mới vào hệ thống.
-- Mục đích: Thêm một bản ghi mới vào bảng `Customers`.
-- Đầu vào: p_first_name, p_last_name, p_email, p_phone_number, p_address, p_raw_password.
-- Expected output: Trả về `new_customer_id` của khách hàng vừa tạo.
-- Triggers được kích hoạt: KHÔNG CÓ trigger nào được kích hoạt trực tiếp bởi INSERT vào bảng `Customers`.

SELECT 'Trước khi gọi SP_RegisterNewCustomer:' AS 'Info';
SELECT COUNT(*) AS total_customers FROM `Customers`;

CALL `SP_RegisterNewCustomer`('Le', 'Van L', 'levanl@example.com', '0917777777', '123 Le Loi, HCMC', 'password_l_raw');

SELECT 'Sau khi gọi SP_RegisterNewCustomer:' AS 'Info';
SELECT `customer_id`, `first_name`, `last_name`, `email`, `password_hash` FROM `Customers` ORDER BY `customer_id` DESC LIMIT 1;