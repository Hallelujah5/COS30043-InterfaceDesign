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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_ValidatePrescription
INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`, `has_prescription`) VALUES
('Tran', 'Van G', 'tranvang@example.com', '0987654321', '101 Hoang Hoa Tham, Hanoi', SHA2('pass_g_raw', 256), FALSE), -- Customer ID 1
('Le', 'Thi H', 'lethih@example.com', '0912987654', '202 Nguyen Trai, HCMC', SHA2('pass_h_raw', 256), FALSE); -- Customer ID 2

INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ha Noi', '456 Le Duan, Hanoi', '0249876543');

INSERT INTO `Staff` (`first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role`, `branch_id`) VALUES
('Hoang', 'Van E', 'hoangvane@longchau.com', '0905555555', SHA2('pass_e_raw', 256), 'Pharmacist', 1); -- Pharmacist ID 1

-- Tạo một đơn thuốc đang chờ để kiểm tra (sẽ được Approved)
INSERT INTO `Prescriptions` (`customer_id`, `upload_date`, `file_path`, `validation_status`, `customer_notes`) VALUES
(1, '2025-07-07 10:00:00', '/prescriptions/sample_prescription_2.pdf', 'Pending', 'Tôi có thắc mắc về liều lượng.'); -- prescription_id = 1

-- Tạo một đơn thuốc đang chờ khác (sẽ được Rejected)
INSERT INTO `Prescriptions` (`customer_id`, `upload_date`, `file_path`, `validation_status`, `customer_notes`) VALUES
(2, '2025-07-07 11:00:00', '/prescriptions/sample_prescription_3.pdf', 'Pending', 'Đơn thuốc này cho con tôi.'); -- prescription_id = 2


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_ValidatePrescription ---' AS 'Info';
-- Procedure này: Cập nhật trạng thái xác nhận của đơn thuốc.
-- Mục đích: Thay đổi `validation_status` của một đơn thuốc.
-- Đầu vào: p_prescription_id, p_pharmacist_id, p_validation_status, p_pharmacist_notes.
-- Expected output:
--   - `validation_status` của Prescription sẽ thay đổi.
--   - `pharmacist_id`, `validation_date`, `pharmacist_notes` sẽ được cập nhật.
--   - Cột `has_prescription` của khách hàng sẽ được đặt thành TRUE nếu 'Approved', giữ nguyên FALSE nếu 'Rejected'.
--   - Một bản ghi Notification mới sẽ được tạo cho khách hàng với `is_sent` là FALSE (mặc định).
-- Triggers được kích hoạt:
--   - `trg_after_prescription_validation`: Tạo thông báo cho khách hàng sau khi xác nhận.

SELECT 'Trước khi gọi SP_ValidatePrescription (Prescription ID 1 và 2):' AS 'Info';
SELECT * FROM `Prescriptions` WHERE `prescription_id` IN (1, 2);
SELECT `customer_id`, `has_prescription` FROM `Customers` WHERE `customer_id` IN (1, 2); -- Kiểm tra trước khi gọi SP
SELECT COUNT(*) AS total_notifications FROM `Notifications`;

-- TEST CASE 1: Duyệt đơn thuốc
SELECT '--- TEST CASE 1: Duyệt đơn thuốc (Prescription ID 1) ---' AS 'Info';
CALL `SP_ValidatePrescription`(
    1, -- p_prescription_id (Prescription ID 1)
    1, -- p_pharmacist_id (Pharmacist ID 1 - Hoang Van E)
    'Approved', -- p_validation_status
    'Đơn thuốc hợp lệ, liều lượng chính xác.' -- p_pharmacist_notes
);

SELECT 'Sau khi gọi SP_ValidatePrescription (Prescription ID 1 - Approved):' AS 'Info';
SELECT * FROM `Prescriptions` WHERE `prescription_id` = 1;
SELECT `customer_id`, `has_prescription` FROM `Customers` WHERE `customer_id` = 1; -- Kiểm tra sau khi duyệt: Nên là TRUE
SELECT `notification_id`, `customer_id`, `prescription_id`, `message_content`, `notification_type`, `is_sent` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1; -- Bao gồm is_sent


-- TEST CASE 2: Từ chối đơn thuốc
SELECT '--- TEST CASE 2: Từ chối đơn thuốc (Prescription ID 2) ---' AS 'Info';
CALL `SP_ValidatePrescription`(
    2, -- p_prescription_id (Prescription ID 2)
    1, -- p_pharmacist_id (Pharmacist ID 1 - Hoang Van E)
    'Rejected', -- p_validation_status
    'Đơn thuốc không rõ ràng, cần thông tin thêm.' -- p_pharmacist_notes
);

SELECT 'Sau khi gọi SP_ValidatePrescription (Prescription ID 2 - Rejected):' AS 'Info';
SELECT * FROM `Prescriptions` WHERE `prescription_id` = 2;
SELECT `customer_id`, `has_prescription` FROM `Customers` WHERE `customer_id` = 2; -- Kiểm tra sau khi từ chối: Nên là FALSE
SELECT `notification_id`, `customer_id`, `prescription_id`, `message_content`, `notification_type`, `is_sent` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1; -- Bao gồm is_sent