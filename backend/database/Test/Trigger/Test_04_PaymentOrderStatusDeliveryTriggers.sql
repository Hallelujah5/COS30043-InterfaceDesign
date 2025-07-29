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
CALL `SP_RegisterNewCustomer`('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', 'pass_f_raw');
CALL `SP_RegisterNewStaff`('Tran', 'Van C', 'tranvanc@longchau.com', '0903333333', 'pass_c_raw', 'Cashier', 1);
-- Capture the Staff ID of the created Cashier
SET @cashier_id_for_test = LAST_INSERT_ID();

CALL `SP_RegisterNewStaff`('Nguyen', 'Van A', 'nguyenvana@longchau.com', '0901111111', 'pass_a_raw', 'BranchManager', 1);
SET @branch_manager_id_for_test = LAST_INSERT_ID(); -- Also capture BranchManager ID if needed dynamically

INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE);
CALL `SP_RestockInventory`(1, 1, 100);

-- Create an order that will be used for payment and status updates
CALL `SP_PlaceOrder`(
    1, -- p_customer_id
    1, -- p_branch_id
    '[{"product_id": 1, "quantity": 10}]', -- p_product_details
    NULL, -- p_prescription_id
    '789 Vo Van Tan, HCMC', -- p_delivery_address
    'Shopee', -- p_delivery_party
    '2025-07-15 10:00:00', -- p_estimated_delivery_date
    'SPX98765', -- p_tracking_number
    0.00, -- p_discount_amount
    'Online' -- p_order_source
);
SET @order_to_test_id = LAST_INSERT_ID();
SET @delivery_to_test_id = (SELECT delivery_id FROM Orders WHERE order_id = @order_to_test_id);


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_payment_completed
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_payment_completed ---' AS 'Info';
-- Trigger này: Tạo biên lai, cập nhật trạng thái đơn hàng và thông báo cho BranchManager sau khi thanh toán hoàn tất.
-- Hành động kích hoạt: UPDATE `transaction_status` của bảng `Payments` từ 'Pending' sang 'Completed' (bởi SP_ProcessPayment).
-- Kết quả mong đợi:
--   - Một bản ghi mới sẽ được thêm vào bảng `Receipts` cho Order ID.
--   - `order_status` của Order ID sẽ thay đổi thành 'Paid'.
--   - Một thông báo cho khách hàng và một thông báo cho BranchManager sẽ được tạo.

CALL `SP_ProcessPayment`(@order_to_test_id, 'Credit Card');

SELECT 'Sau khi hoàn tất thanh toán cho Order ID ', @order_to_test_id, ':' AS 'Info';
SELECT `order_id`, `order_status` FROM `Orders` WHERE `order_id` = @order_to_test_id;
SELECT `payment_id`, `transaction_status` FROM `Payments` WHERE `order_id` = @order_to_test_id;
SELECT `receipt_id`, `payment_id`, `receipt_details` FROM `Receipts` ORDER BY `receipt_id` DESC LIMIT 1;
SELECT `notification_id`, `customer_id`, `staff_id`, `order_id`, `message_content`, `notification_type`, `branch_id` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 2;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_notify_assigned_cashier
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_notify_assigned_cashier ---' AS 'Info';
-- Trigger này: Thông báo cho Thu ngân khi họ được gán một đơn hàng để kiểm tra.
-- Hành động kích hoạt: UPDATE `cashier_id` và `order_status` thành 'Processing' trong bảng `Orders` (bởi SP_AssignOrderToCashier).
-- Kết quả mong đợi:
--   - Một thông báo sẽ được gửi tới Thu ngân.

CALL `SP_AssignOrderToCashier`(@order_to_test_id, @cashier_id_for_test, @branch_manager_id_for_test); 

SELECT 'Sau khi gán Order ID ', @order_to_test_id, ' cho Cashier ID ', @cashier_id_for_test, ':' AS 'Info';
SELECT `order_id`, `cashier_id`, `order_status` FROM `Orders` WHERE `order_id` = @order_to_test_id;
SELECT `notification_id`, `staff_id`, `order_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_order_status_update_notify_customer
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_order_status_update_notify_customer ---' AS 'Info';
-- Trigger này: Tự động tạo thông báo khi trạng thái đơn hàng thay đổi.
-- Hành động kích hoạt: UPDATE `order_status` của bảng `Orders`.
-- Kết quả mong đợi:
--   - Một bản ghi mới sẽ được thêm vào bảng `Notifications` với `notification_type` là 'Order Status'.

UPDATE `Orders` SET `order_status` = 'Delivered' WHERE `order_id` = @order_to_test_id;

SELECT 'Sau khi cập nhật trạng thái đơn hàng ID ', @order_to_test_id, ' thành "Delivered":' AS 'Info';
SELECT `order_id`, `order_status` FROM `Orders` WHERE `order_id` = @order_to_test_id;
SELECT `notification_id`, `customer_id`, `order_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;


-- =====================================================================================================================
-- KIỂM TRA TRIGGER: trg_after_delivery_status_update_notify_customer
-- =====================================================================================================================
SELECT '--- KIỂM TRA trg_after_delivery_status_update_notify_customer ---' AS 'Info';
-- Trigger này: Tự động tạo thông báo khi trạng thái giao hàng thay đổi.
-- Hành động kích hoạt: UPDATE `delivery_status` của bảng `Deliveries`.
-- Kết quả mong đợi:
--   - Một bản ghi mới sẽ được thêm vào bảng `Notifications` với `notification_type` là 'Delivery Status'.

UPDATE `Deliveries` SET `delivery_status` = 'Delivered' WHERE `delivery_id` = @delivery_to_test_id;

SELECT 'Sau khi cập nhật trạng thái giao hàng cho Order ID ', @order_to_test_id, ' thành "Delivered":' AS 'Info';
SELECT `delivery_id`, `delivery_status` FROM `Deliveries` WHERE `delivery_id` = @delivery_to_test_id;
SELECT `notification_id`, `customer_id`, `delivery_id`, `message_content`, `notification_type` FROM `Notifications` ORDER BY `notification_id` DESC LIMIT 1;