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
ALTER TABLE `Payments` AUTO_INCREMENT = 1;
ALTER TABLE `OrderItems` AUTO_INCREMENT = 1;
ALTER TABLE `Receipts` AUTO_INCREMENT = 1;
ALTER TABLE `Notifications` AUTO_INCREMENT = 1;

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_ProcessPayment
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567');

INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`) VALUES
('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', SHA2('pass_f_raw', 256)); -- Customer ID 1

-- Thêm Branch Manager cho thông báo trigger
INSERT INTO `Staff` (`first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role`, `branch_id`) VALUES
('Nguyen', 'Van A', 'nguyenvana@longchau.com', '0901111111', SHA2('pass_a_raw', 256), 'BranchManager', 1); -- Staff ID 1

INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE); -- Product ID 1

INSERT INTO `Inventory` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 100, 20);

SELECT '--- TẠO ĐƠN HÀNG MỚI BẰNG SP_PlaceOrder ĐỂ KIỂM THỬ SP_ProcessPayment ---' AS 'Info';

-- Gọi SP_PlaceOrder để tạo một đơn hàng với các mặt hàng và thanh toán trạng thái Pending
CALL `SP_PlaceOrder`(
    1, -- p_customer_id
    1, -- p_branch_id
    '[{"product_id": 1, "quantity": 10}]', -- p_product_details (Paracetamol 10 viên)
    NULL, -- p_prescription_id (không cần đơn thuốc cho test này)
    NULL, -- p_delivery_address (không cần giao hàng cho test này)
    NULL, -- p_delivery_party
    NULL, -- p_estimated_delivery_date
    NULL, -- p_tracking_number
    0.00, -- p_discount_amount
    'In-store' -- p_order_source
);

-- Lấy order_id vừa được tạo bởi SP_PlaceOrder
SET @new_order_id = (SELECT `order_id` FROM `Orders` ORDER BY `order_id` DESC LIMIT 1);


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_ProcessPayment ---' AS 'Info';
-- Procedure này: Xử lý thanh toán cho một đơn hàng bằng cách cập nhật bản ghi Payments hiện có.
-- Mục đích: Cập nhật `transaction_status` của bản ghi Payments từ 'Pending' sang 'Completed'.
-- Đầu vào: p_order_id, p_payment_method.
-- Expected output:
--   - `transaction_status` của Payment liên quan sẽ là 'Completed'.
--   - `order_status` của Order liên quan sẽ thay đổi thành 'Paid' (qua trigger).
--   - Một bản ghi Receipt mới sẽ được tạo (qua trigger).
--   - Ba bản ghi Notification mới sẽ được tạo:
--     1. Thông báo cho khách hàng về thanh toán thành công (từ trg_after_payment_completed).
--     2. Thông báo cho BranchManager về đơn hàng đã thanh toán (từ trg_after_payment_completed).
--     3. Thông báo cho khách hàng về thay đổi trạng thái đơn hàng (từ trg_after_order_status_update_notify_customer).

SELECT 'Trước khi gọi SP_ProcessPayment (Order ID ', @new_order_id, '):' AS 'Info';
SELECT `order_id`, `total_amount`, `order_status` FROM `Orders` WHERE `order_id` = @new_order_id;
SELECT `payment_id`, `order_id`, `amount`, `payment_method`, `transaction_status` FROM `Payments` WHERE `order_id` = @new_order_id;
SELECT COUNT(*) AS total_receipts FROM `Receipts`;
SELECT COUNT(*) AS total_notifications FROM `Notifications`;


-- LƯU Ý QUAN TRỌNG: SP_ProcessPayment không còn nhận p_amount nữa.
-- Nó tự động lấy total_amount từ bảng Orders.
CALL `SP_ProcessPayment`(
    @new_order_id, -- p_order_id
    'Credit Card' -- p_payment_method
);

SELECT 'Sau khi gọi SP_ProcessPayment (Order ID ', @new_order_id, '):' AS 'Info';
SELECT * FROM `Payments` WHERE `order_id` = @new_order_id;
SELECT * FROM `Orders` WHERE `order_id` = @new_order_id;
SELECT * FROM `Receipts` WHERE `payment_id` = (SELECT `payment_id` FROM `Payments` WHERE `order_id` = @new_order_id);
-- Kiểm tra các thông báo được tạo
SELECT `notification_id`, `customer_id`, `staff_id`, `order_id`, `message_content`, `notification_type`, `branch_id`, `is_sent` FROM `Notifications` ORDER BY `notification_id` DESC;

-- KIỂM TRA TRƯỜNG HỢP LỖI: Thanh toán cho đơn hàng không tồn tại
SELECT '--- KIỂM TRA LỖI: Thanh toán cho đơn hàng không tồn tại ---' AS 'Info';
-- Expected result: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy đơn hàng.';
-- CALL `SP_ProcessPayment`(9999, 'Cash');