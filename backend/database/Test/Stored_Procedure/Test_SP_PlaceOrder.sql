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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_PlaceOrder
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567');

INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`, `has_prescription`) VALUES
('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', SHA2('pass_f_raw', 256), FALSE); -- Customer ID 1, mặc định FALSE

-- Chèn Products trước. AUTO_INCREMENT sẽ gán ID 1 và 2 cho Paracetamol và Vitamin C.
INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE), -- Product ID sẽ là 1
('Vitamin C 1000mg', 'Thực phẩm chức năng', 120000.00, 'Thực phẩm chức năng', FALSE); -- Product ID sẽ là 2

-- CHỈNH SỬA: Đảm bảo product_id trong Inventory khớp với ID thực tế sau khi Products được chèn.
-- Product ID 1 (Paracetamol), Product ID 2 (Vitamin C)
INSERT INTO `Inventory` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 100, 20), -- Branch 1, Paracetamol (Product ID 1)
(1, 2, 75, 15);  -- Branch 1, Vitamin C (Product ID 2)

-- Tạo một đơn thuốc trước để gán vào đơn hàng (nếu cần đơn thuốc)
INSERT INTO `Prescriptions` (`customer_id`, `upload_date`, `file_path`, `validation_status`, `customer_notes`) VALUES (1, NOW(), '/prescriptions/sample_prescription_1.pdf', 'Pending', 'Tôi cần thuốc này gấp.'); -- prescription_id = 1

SELECT '--- KIỂM TRA STORED PROCEDURE: SP_PlaceOrder ---' AS 'Info';
-- Procedure này: Đặt một đơn hàng mới, bao gồm việc thêm các mặt hàng và cập nhật tồn kho.
-- Mục đích: Tạo bản ghi trong `Orders`, `Deliveries` (nếu có), `OrderItems`, và `Payments` (trạng thái Pending), đồng thời kiểm tra tồn kho.
-- Đầu vào: p_customer_id, p_branch_id, p_product_details (JSON array), p_prescription_id, p_delivery_address, p_delivery_party, p_estimated_delivery_date, p_tracking_number, p_discount_amount, p_order_source.
-- Expected output:
--   - Một đơn hàng mới (Order ID 1) sẽ được tạo.
--   - Nếu có địa chỉ giao hàng, một bản ghi Delivery mới (Delivery ID 1) sẽ được tạo.
--   - Các OrderItem sẽ được thêm vào.
--   - `stock_quantity` của các sản phẩm trong `Inventory` sẽ giảm.
--   - `total_amount` của đơn hàng sẽ được tính toán và cập nhật.
--   - Một bản ghi Payments (Payment ID 1) sẽ được tạo với `transaction_status` là 'Pending'.
--   - Cột `has_prescription` của khách hàng sẽ được đặt thành FALSE nếu có `p_prescription_id` được cung cấp.
-- Triggers được kích hoạt:
--   - `trg_after_order_item_insert`: Giảm tồn kho khi OrderItem được thêm.
--   - `trg_update_order_total_amount`: Cập nhật tổng tiền đơn hàng khi OrderItem được thêm.

SELECT 'Tồn kho trước khi đặt hàng (Paracetamol ID 1, Vitamin C ID 2 tại Branch 1):' AS 'Info';
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` IN (1, 2);
SELECT 'Số lượng đơn hàng, đơn hàng chi tiết, giao hàng và thanh toán trước khi đặt hàng:' AS 'Info';
SELECT COUNT(*) AS total_orders FROM `Orders`;
SELECT COUNT(*) AS total_order_items FROM `OrderItems`;
SELECT COUNT(*) AS total_deliveries FROM `Deliveries`;
SELECT COUNT(*) AS total_payments FROM `Payments`;
SELECT `has_prescription` FROM `Customers` WHERE `customer_id` = 1; -- Kiểm tra trước khi gọi SP

CALL `SP_PlaceOrder`(
    1, -- p_customer_id (Nguyen Thi F)
    1, -- p_branch_id (Long Chau Ho Chi Minh)
    '[{"product_id": 1, "quantity": 10}, {"product_id": 2, "quantity": 5}]', 
    1, -- p_prescription_id (sử dụng đơn thuốc vừa tạo)
    '789 Vo Van Tan, HCMC', -- p_delivery_address
    'Shopee', -- p_delivery_party
    '2025-07-09 10:00:00', -- p_estimated_delivery_date
    'TRACKXYZ789', -- p_tracking_number
    10000.00, -- p_discount_amount
    'Online' -- p_order_source
);

SELECT 'Sau khi gọi SP_PlaceOrder (Order ID 1):' AS 'Info';
SELECT * FROM `Orders` WHERE `order_id` = 1;
SELECT * FROM `OrderItems` WHERE `order_id` = 1;
SELECT `product_id`, `stock_quantity`, `min_stock_level` FROM `Inventory` WHERE `branch_id` = 1 AND `product_id` IN (1, 2);
SELECT * FROM `Deliveries` WHERE `delivery_id` = 1;
SELECT * FROM `Payments` WHERE `order_id` = 1; -- Kiểm tra bản ghi Payments mới với trạng thái Pending
SELECT `has_prescription` FROM `Customers` WHERE `customer_id` = 1; -- Kiểm tra sau khi gọi SP: Nên là FALSE