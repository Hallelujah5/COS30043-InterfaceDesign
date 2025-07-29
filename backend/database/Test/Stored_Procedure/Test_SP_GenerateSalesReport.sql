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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_GenerateSalesReport
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567'),
('Long Chau Ha Noi', '456 Le Duan, Hanoi', '0249876543');

INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`) VALUES
('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', SHA2('pass_f_raw', 256)),
('Tran', 'Van G', 'tranvang@example.com', '0987654321', '101 Hoang Hoa Tham, Hanoi', SHA2('pass_g_raw', 256));

INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE), -- Product ID 1
('Amoxicillin 250mg', 'Kháng sinh', 50000.00, 'Thuốc', TRUE), -- Product ID 2
('Vitamin C 1000mg', 'Thực phẩm chức năng', 120000.00, 'Thực phẩm chức năng', FALSE); -- Product ID 3

INSERT INTO `Inventory` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 100, 20),
(1, 2, 50, 10),
(1, 3, 75, 15),
(2, 1, 80, 20),
(2, 3, 60, 15);

-- Thêm dữ liệu đơn hàng đã hoàn tất (Paid, Processing, Ready for Pickup, Delivered) để tạo báo cáo
INSERT INTO `Orders` (`customer_id`, `branch_id`, `order_date`, `total_amount`, `order_status`) VALUES
(1, 1, '2025-06-01 10:00:00', 150000.00, 'Paid'), -- Order ID 1 (Branch 1)
(1, 1, '2025-06-15 11:00:00', 300000.00, 'Delivered'), -- Order ID 2 (Branch 1)
(2, 2, '2025-06-20 14:30:00', 250000.00, 'Processing'); -- Order ID 3 (Branch 2)

INSERT INTO `OrderItems` (`order_id`, `product_id`, `quantity`, `unit_price`) VALUES
(1, 1, 5, 15000.00),   -- Order 1: Paracetamol (75000)
(1, 3, 1, 120000.00),  -- Order 1: Vitamin C (120000) -> Total 195000.00 (Sửa thủ công total_amount nếu trigger tính sai, hoặc tin vào trigger)
(2, 2, 6, 50000.00),   -- Order 2: Amoxicillin (300000)
(3, 1, 10, 15000.00),  -- Order 3: Paracetamol (150000)
(3, 3, 1, 120000.00);  -- Order 3: Vitamin C (120000) -> Total 270000.00

-- Cập nhật lại total_amount cho các đơn hàng để khớp với OrderItems nếu trigger không chạy tự động
UPDATE `Orders` SET `total_amount` = (SELECT SUM(quantity * unit_price) FROM `OrderItems` WHERE `order_id` = 1) WHERE `order_id` = 1; -- Should be 195000.00
UPDATE `Orders` SET `total_amount` = (SELECT SUM(quantity * unit_price) FROM `OrderItems` WHERE `order_id` = 2) WHERE `order_id` = 2; -- Should be 300000.00
UPDATE `Orders` SET `total_amount` = (SELECT SUM(quantity * unit_price) FROM `OrderItems` WHERE `order_id` = 3) WHERE `order_id` = 3; -- Should be 270000.00


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_GenerateSalesReport ---' AS 'Info';
-- Procedure này: Tạo báo cáo doanh số bán hàng cho một chi nhánh trong một khoảng thời gian.
-- Mục đích: Truy vấn dữ liệu từ `Orders`, `OrderItems`, `Products` để tổng hợp doanh số.
-- Đầu vào: p_branch_id, p_start_date, p_end_date.
-- Expected output: Một tập hợp kết quả (result set) chứa `product_name`, `total_quantity_sold`, `total_revenue`.
-- Triggers được kích hoạt: KHÔNG CÓ trigger nào được kích hoạt.

SELECT 'Báo cáo doanh số cho chi nhánh 1 từ 2025-06-01 đến hiện tại (bao gồm Order ID 1, 2):' AS 'Info';
CALL `SP_GenerateSalesReport`(
    1, -- p_branch_id (Branch ID 1)
    '2025-06-01 00:00:00', -- p_start_date
    NOW() -- p_end_date (đến thời điểm hiện tại)
);

SELECT 'Báo cáo doanh số cho chi nhánh 2 từ 2025-06-01 đến hiện tại (bao gồm Order ID 3):' AS 'Info';
CALL `SP_GenerateSalesReport`(
    2, -- p_branch_id (Branch ID 2)
    '2025-06-01 00:00:00', -- p_start_date
    NOW() -- p_end_date (đến thời điểm hiện tại)
);

SELECT 'Báo cáo doanh số cho toàn bộ chi nhánh (kết quả rỗng nếu không có dữ liệu phù hợp với khoảng thời gian hoặc status):' AS 'Info';
-- Sẽ không có kết quả nếu chỉ gọi cho 1 chi nhánh
-- Bạn có thể chạy riêng từng CALL SP_GenerateSalesReport cho mỗi chi nhánh
CALL `SP_GenerateSalesReport`(
    1, -- p_branch_id
    '2024-01-01 00:00:00', -- p_start_date (thời gian cũ, không có order)
    '2024-12-31 23:59:59' -- p_end_date
);