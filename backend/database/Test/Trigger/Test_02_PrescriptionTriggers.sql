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
CALL `SP_RegisterNewStaff`('Nguyen', 'Van A', 'nguyenvana@longchau.com', '0901111111', 'pass_a_raw', 'BranchManager', 1);
CALL `SP_RegisterNewStaff`('Le', 'Thi B', 'lethib@longchau.com', '0902222222', 'pass_b_raw', 'Pharmacist', 1);
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_notify_branch_manager_on_new_prescription
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_notify_branch_manager_on_new_prescription ---' AS 'Info';
-- Trigger này: Thông báo cho BranchManager khi có đơn thuốc mới được tải lên.
-- Hành động kích hoạt: INSERT vào bảng `Prescriptions` với status 'Pending'.
-- Kết quả mong đợi:
--   - Một thông báo sẽ được gửi tới tất cả BranchManager (hiện tại là Staff ID 1).
INSERT INTO `Prescriptions` (`customer_id`, `file_path`, `validation_status`, `customer_notes`) VALUES (1, '/prescriptions/file1.pdf', 'Pending', 'Xin vui lòng kiểm tra đơn thuốc này.'); -- prescription_id = 1
SELECT 'Sau khi tạo đơn thuốc ID 1 (Pending):' AS 'Info';
SELECT `notification_id`, `staff_id`, `prescription_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_notify_assigned_pharmacist
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_notify_assigned_pharmacist ---' AS 'Info';
-- Trigger này: Thông báo cho Dược sĩ khi họ được gán một đơn thuốc để xác nhận.
-- Hành động kích hoạt: UPDATE `pharmacist_id` trong bảng `Prescriptions` (đơn thuốc vẫn 'Pending').
-- Kết quả mong đợi:
--   - Một thông báo sẽ được gửi tới Dược sĩ ID 2.
CALL `SP_AssignPrescriptionToPharmacist`(1, 2, 1); -- BranchManager ID 1 gán Prescription ID 1 cho Pharmacist ID 2

SELECT 'Sau khi gán đơn thuốc ID 1 cho Dược sĩ ID 2:' AS 'Info';
SELECT `prescription_id`, `pharmacist_id`, `pharmacist_notes` FROM `Prescriptions` WHERE `prescription_id` = 1;
SELECT `notification_id`, `staff_id`, `prescription_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_prescription_validation
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_prescription_validation ---' AS 'Info';
-- Trigger này: Tạo thông báo cho khách hàng sau khi đơn thuốc được xác nhận (duyệt/từ chối).
-- Hành động kích hoạt: UPDATE `validation_status` của bảng `Prescriptions` từ 'Pending' sang 'Approved' hoặc 'Rejected'.
-- Kết quả mong đợi:
--   - Một bản ghi mới sẽ được thêm vào bảng `Notifications` với `notification_type` là 'Prescription Validation'.
--   - `has_prescription` của Customer ID 1 sẽ được cập nhật thành TRUE.
CALL `SP_ValidatePrescription`(1, 2, 'Approved', 'Đơn thuốc hợp lệ, khách hàng có thể đặt mua.');

SELECT 'Sau khi xác nhận đơn thuốc ID 1 (Approved) bởi Dược sĩ ID 2:' AS 'Info';
SELECT `prescription_id`, `validation_status`, `pharmacist_notes` FROM `Prescriptions` WHERE `prescription_id` = 1;
SELECT `customer_id`, `has_prescription` FROM `Customers` WHERE `customer_id` = 1;
SELECT `notification_id`, `customer_id`, `prescription_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;