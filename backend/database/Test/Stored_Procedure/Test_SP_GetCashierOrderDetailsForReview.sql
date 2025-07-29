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
CALL `SP_RegisterNewStaff`('Tran', 'Van C', 'tranvanc@longchau.com', '0903333333', 'pass_c_raw', 'Cashier', 1);
SET @cashier_id = LAST_INSERT_ID();
CALL `SP_RegisterNewStaff`('Nguyen', 'Van A', 'nguyenvana@longchau.com', '0901111111', 'pass_a_raw', 'BranchManager', 1);
SET @branch_manager_id = LAST_INSERT_ID();
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');
SET @customer_id = LAST_INSERT_ID();
INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE),
('Amoxicillin 250mg', 'Kháng sinh', 50000.00, 'Thuốc', TRUE);
SET @product_id_no_rx = 1;
SET @product_id_rx = 2;
CALL `SP_RestockInventory`(1, @product_id_no_rx, 100);
CALL `SP_RestockInventory`(1, @product_id_rx, 50);

-- Tạo đơn thuốc đã được duyệt (nếu cần cho đơn hàng có thuốc kê đơn)
INSERT INTO `Prescriptions` (`customer_id`, `file_path`, `validation_status`, `customer_notes`) VALUES (@customer_id, '/prescriptions/file_test_review.pdf', 'Approved', 'Valid prescription for review.');
SET @prescription_id = LAST_INSERT_ID();

-- Tạo một đơn hàng có trạng thái 'Processing' và được gán cho Cashier
CALL `SP_PlaceOrder`(
    @customer_id,
    1, -- branch_id
    CONCAT('[{"product_id": ', @product_id_no_rx, ', "quantity": 5}, {"product_id": ', @product_id_rx, ', "quantity": 2}]'),
    @prescription_id, -- prescription_id
    '789 Vo Van Tan, HCMC',
    'Shopee',
    '2025-07-20 10:00:00',
    'TRK67890',
    0.00,
    'Online'
);
SET @order_id = LAST_INSERT_ID();
-- Cần cập nhật trạng thái của đơn hàng thành 'Paid' trước khi gán cho thu ngân
UPDATE `Payments` SET `transaction_status` = 'Completed' WHERE `order_id` = @order_id;
-- Gán đơn hàng cho thu ngân (sẽ chuyển order_status sang 'Processing')
CALL `SP_AssignOrderToCashier`(@order_id, @cashier_id, @branch_manager_id);


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_GetCashierOrderDetailsForReview ---' AS 'Info';
-- Procedure này: Lấy thông tin chi tiết đơn hàng (và đơn thuốc nếu có) cho Thu ngân kiểm tra lần cuối.
-- Mục đích: Truy vấn và trả về thông tin chi tiết của một đơn hàng và các mặt hàng của nó, đặc biệt là các sản phẩm yêu cầu đơn thuốc.
-- Đầu vào: p_order_id, p_cashier_id.
-- Expected output: Hai bảng kết quả: một cho thông tin đơn hàng/đơn thuốc, một cho các mặt hàng trong đơn.
-- Triggers được kích hoạt: KHÔNG CÓ.

SELECT 'Trước khi gọi SP_GetCashierOrderDetailsForReview (kiểm tra trạng thái đơn hàng):' AS 'Info';
SELECT `order_id`, `cashier_id`, `order_status` FROM `Orders` WHERE `order_id` = @order_id;

SELECT 'Sau khi gọi SP_GetCashierOrderDetailsForReview (kiểm tra trạng thái đơn hàng):' AS 'Info';
CALL `SP_GetCashierOrderDetailsForReview`(@order_id, @cashier_id);

-- KIỂM TRA TRƯỜNG HỢP LỖI: Đơn hàng không tồn tại hoặc không được gán cho thu ngân này
SELECT '--- KIỂM TRA LỖI: Đơn hàng không tồn tại hoặc không được gán cho thu ngân này ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn hàng không tồn tại hoặc không được gán cho thu ngân này để kiểm tra.';
-- CALL `SP_GetCashierOrderDetailsForReview`(9999, @cashier_id); -- Đơn hàng không tồn tại
-- CALL `SP_GetCashierOrderDetailsForReview`(@order_id, (@cashier_id + 1)); -- Gán cho thu ngân khác không phải là người được gán

-- KIỂM TRA TRƯỜNG HỢP LỖI: Đơn hàng không ở trạng thái 'Processing'
UPDATE `Orders` SET `order_status` = 'Delivered' WHERE `order_id` = @order_id; -- Đặt lại trạng thái
SELECT '--- KIỂM TRA LỖI: Đơn hàng không ở trạng thái Processing ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn hàng không tồn tại hoặc không được gán cho thu ngân này để kiểm tra.';
-- CALL `SP_GetCashierOrderDetailsForReview`(@order_id, @cashier_id);