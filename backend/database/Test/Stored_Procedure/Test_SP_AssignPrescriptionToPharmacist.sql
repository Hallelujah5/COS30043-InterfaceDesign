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

-- Dữ liệu mẫu cần thiết cho test này
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES ('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567');
CALL `SP_RegisterNewStaff`('Nguyen', 'Van A', 'nguyenvana@longchau.com', '0901111111', 'pass_a_raw', 'BranchManager', 1);
SET @branch_manager_id = LAST_INSERT_ID();
CALL `SP_RegisterNewStaff`('Le', 'Thi B', 'lethib@longchau.com', '0902222222', 'pass_b_raw', 'Pharmacist', 1);
SET @pharmacist_id = LAST_INSERT_ID();
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');
SET @customer_id = LAST_INSERT_ID();
INSERT INTO `Prescriptions` (`customer_id`, `file_path`, `validation_status`, `customer_notes`) VALUES (@customer_id, '/prescriptions/file_test_assign.pdf', 'Pending', 'Can assign to a pharmacist.');
SET @prescription_id = LAST_INSERT_ID();

SELECT '--- KIỂM TRA STORED PROCEDURE: SP_AssignPrescriptionToPharmacist ---' AS 'Info';
-- Procedure này: Cho phép BranchManager gán một đơn thuốc 'Pending' cho một Pharmacist cụ thể.
-- Mục đích: Cập nhật `pharmacist_id` và `pharmacist_notes` trong bảng `Prescriptions`.
-- Đầu vào: p_prescription_id, p_pharmacist_id, p_branch_manager_id.
-- Expected output: Không có output trực tiếp từ procedure, nhưng dữ liệu trong bảng `Prescriptions` sẽ thay đổi.
-- Triggers được kích hoạt: `trg_notify_assigned_pharmacist`.

SELECT 'Trước khi gọi SP_AssignPrescriptionToPharmacist:' AS 'Info';
SELECT `prescription_id`, `pharmacist_id`, `validation_status`, `pharmacist_notes` FROM `Prescriptions` WHERE `prescription_id` = @prescription_id;
SELECT COUNT(*) AS total_notifications_before FROM `Notifications`;

CALL `SP_AssignPrescriptionToPharmacist`(@prescription_id, @pharmacist_id, @branch_manager_id);

SELECT 'Sau khi gọi SP_AssignPrescriptionToPharmacist:' AS 'Info';
SELECT `prescription_id`, `pharmacist_id`, `validation_status`, `pharmacist_notes` FROM `Prescriptions` WHERE `prescription_id` = @prescription_id;
SELECT `notification_id`, `staff_id`, `prescription_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;

-- KIỂM TRA TRƯỜNG HỢP LỖI: Gán đơn thuốc không tồn tại
SELECT '--- KIỂM TRA LỖI: Gán đơn thuốc không tồn tại ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy đơn thuốc này.';
-- CALL `SP_AssignPrescriptionToPharmacist`(9999, @pharmacist_id, @branch_manager_id);

-- KIỂM TRA TRƯỜNG HỢP LỖI: Gán đơn thuốc đã được xử lý (Approved/Rejected)
UPDATE `Prescriptions` SET `validation_status` = 'Approved' WHERE `prescription_id` = @prescription_id;
SELECT '--- KIỂM TRA LỖI: Gán đơn thuốc đã xử lý ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn thuốc này đã được xử lý hoặc không ở trạng thái chờ.';
-- CALL `SP_AssignPrescriptionToPharmacist`(@prescription_id, @pharmacist_id, @branch_manager_id);