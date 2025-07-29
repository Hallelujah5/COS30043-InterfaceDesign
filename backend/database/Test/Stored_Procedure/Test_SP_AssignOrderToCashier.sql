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
CALL `SP_RegisterNewStaff`('Tran', 'Van C', 'tranvanc@longchau.com', '0903333333', 'pass_c_raw', 'Cashier', 1);
SET @cashier_id = LAST_INSERT_ID();
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');
SET @customer_id = LAST_INSERT_ID();
INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES ('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE);
SET @product_id = LAST_INSERT_ID();
CALL `SP_RestockInventory`(1, @product_id, 100);

-- Tạo một đơn hàng
CALL `SP_PlaceOrder`(
    @customer_id,
    1, -- branch_id
    CONCAT('[{"product_id": ', @product_id, ', "quantity": 10}]'),
    NULL, -- prescription_id
    '789 Vo Van Tan, HCMC',
    'Shopee',
    '2025-07-20 10:00:00',
    'TRK12345',
    0.00,
    'Online'
);
SET @order_id = LAST_INSERT_ID();

-- Cần cập nhật trạng thái của đơn hàng thành 'Paid' để có thể gán cho thu ngân.
-- Ưu tiên gọi SP_ProcessPayment để kích hoạt trigger trg_after_payment_completed.
SELECT '--- GỌI SP_ProcessPayment ĐỂ CẬP NHẬT ĐƠN HÀNG THÀNH "Paid" ---' AS 'Info';
CALL `SP_ProcessPayment`(@order_id, 'Credit Card');
-- Sau khi gọi SP_ProcessPayment, trigger trg_after_payment_completed sẽ tự động cập nhật Orders.order_status thành 'Paid'


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_AssignOrderToCashier ---' AS 'Info';
-- Procedure này: Cho phép BranchManager gán một đơn hàng đã "Paid" cho một Cashier cụ thể để kiểm tra.
-- Mục đích: Cập nhật `cashier_id` và `order_status` thành 'Processing' trong bảng `Orders`.
-- Đầu vào: p_order_id, p_cashier_id, p_branch_manager_id.
-- Expected output: Không có output trực tiếp từ procedure, nhưng dữ liệu trong bảng `Orders` sẽ thay đổi.
-- Triggers được kích hoạt: `trg_notify_assigned_cashier`.

SELECT 'Trước khi gọi SP_AssignOrderToCashier:' AS 'Info';
SELECT `order_id`, `cashier_id`, `order_status` FROM `Orders` WHERE `order_id` = @order_id;
SELECT COUNT(*) AS total_notifications_before FROM `Notifications` WHERE notification_type = 'Order Status' AND staff_id IS NOT NULL; -- Đếm notifications cho staff

CALL `SP_AssignOrderToCashier`(@order_id, @cashier_id, @branch_manager_id);

SELECT 'Sau khi gọi SP_AssignOrderToCashier:' AS 'Info';
SELECT `order_id`, `cashier_id`, `order_status` FROM `Orders` WHERE `order_id` = @order_id;
SELECT `notification_id`, `staff_id`, `order_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;

-- KIỂM TRA TRƯỜNG HỢP LỖI: Gán đơn hàng không tồn tại
SELECT '--- KIỂM TRA LỖI: Gán đơn hàng không tồn tại ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy đơn hàng này.';
-- CALL `SP_AssignOrderToCashier`(9999, @cashier_id, @branch_manager_id);

-- KIỂM TRA TRƯỜNG HỢP LỖI: Gán đơn hàng chưa 'Paid'
-- Để kiểm tra lỗi này, chúng ta cần một đơn hàng mới chưa được thanh toán
CALL `SP_PlaceOrder`(
    @customer_id,
    1, -- branch_id
    CONCAT('[{"product_id": ', @product_id, ', "quantity": 5}]'),
    NULL, -- prescription_id
    NULL, NULL, NULL, NULL, 0.00, 'In-store'
);
SET @new_unpaid_order_id = LAST_INSERT_ID();
-- Đơn hàng này có status là 'Pending' (mặc định từ SP_PlaceOrder)
SELECT '--- KIỂM TRA LỖI: Gán đơn hàng chưa Paid (Order ID ', @new_unpaid_order_id, ') ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn hàng này không ở trạng thái cần phân công thu ngân kiểm tra (chỉ các đơn đã "Paid" mới được phân công).';
-- CALL `SP_AssignOrderToCashier`(@new_unpaid_order_id, @cashier_id, @branch_manager_id);