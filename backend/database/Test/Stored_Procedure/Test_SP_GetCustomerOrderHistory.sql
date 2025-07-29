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

-- Dữ liệu mẫu tối thiểu cần thiết cho SP_GetCustomerOrderHistory
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Long Chau Ho Chi Minh', '123 Nguyen Van Linh, HCMC', '0281234567'),
('Long Chau Ha Noi', '456 Le Duan, Hanoi', '0249876543');

INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`) VALUES
('Nguyen', 'Thi F', 'nguyenthif@example.com', '0912345678', '789 Vo Van Tan, HCMC', SHA2('pass_f_raw', 256)), -- Customer ID 1
('Tran', 'Van G', 'tranvang@example.com', '0987654321', '101 Hoang Hoa Tham, Hanoi', SHA2('pass_g_raw', 256)); -- Customer ID 2

INSERT INTO `Products` (`name`, `description`, `price`, `category`, `is_prescription_required`) VALUES
('Paracetamol 500mg', 'Thuốc giảm đau hạ sốt', 15000.00, 'Thuốc', FALSE), -- Product ID 1
('Amoxicillin 250mg', 'Kháng sinh', 50000.00, 'Thuốc', TRUE), -- Product ID 2
('Vitamin C 1000mg', 'Thực phẩm chức năng', 120000.00, 'Thực phẩm chức năng', FALSE); -- Product ID 3

-- Dữ liệu giả định cho Prescription (đã thay đổi 'medication_details' thành 'file_path') và Staff
INSERT INTO `Staff` (`first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role`, `branch_id`) VALUES
('Le', 'Thi B', 'lethib@longchau.com', '0902222222', SHA2('pass_b_raw', 256), 'Pharmacist', 1); -- Pharmacist ID 1

INSERT INTO `Prescriptions` (`customer_id`, `upload_date`, `file_path`, `validation_status`, `pharmacist_id`, `pharmacist_notes`) VALUES
(1, '2025-06-01 09:30:00', '/prescriptions/prescription_A.pdf', 'Approved', 1, 'Đơn thuốc hợp lệ.'), -- Prescription ID 1
(2, '2025-06-05 10:00:00', '/prescriptions/prescription_B.pdf', 'Pending', NULL, NULL); -- Prescription ID 2

INSERT INTO `Deliveries` (`delivery_address`, `delivery_status`, `estimated_delivery_date`, `delivery_party`, `tracking_number`) VALUES
('789 Vo Van Tan, HCMC', 'Delivered', '2025-06-02 10:00:00', 'Shopee', 'SPX12345'), -- Delivery ID 1
('101 Hoang Hoa Tham, Hanoi', 'On The Way', '2025-06-06 15:00:00', 'Grab', 'GRB67890'); -- Delivery ID 2

INSERT INTO `Orders` (`customer_id`, `branch_id`, `order_date`, `total_amount`, `order_status`, `prescription_id`, `delivery_id`, `discount_amount`, `order_source`) VALUES
(1, 1, '2025-06-01 10:00:00', 195000.00, 'Paid', 1, 1, 5000.00, 'Online'), -- Order ID 1 (có prescription, có delivery)
(1, 2, '2025-06-10 11:00:00', 50000.00, 'Processing', NULL, NULL, 0.00, 'In-store'), -- Order ID 2 (không có prescription, không có delivery)
(2, 1, '2025-06-15 14:30:00', 270000.00, 'Pending', 2, 2, 10000.00, 'Online'); -- Order ID 3 (có prescription, có delivery)

INSERT INTO `OrderItems` (`order_id`, `product_id`, `quantity`, `unit_price`) VALUES
(1, 1, 5, 15000.00),   -- Order 1: Paracetamol
(1, 3, 1, 120000.00),  -- Order 1: Vitamin C
(2, 2, 1, 50000.00),   -- Order 2: Amoxicillin
(3, 1, 10, 15000.00),  -- Order 3: Paracetamol
(3, 3, 1, 120000.00);  -- Order 3: Vitamin C


SELECT '--- KIỂM TRA STORED PROCEDURE: SP_GetCustomerOrderHistory ---' AS 'Info';
-- Procedure này: Lấy lịch sử đơn hàng của một khách hàng cụ thể.
-- Mục đích: Trả về chi tiết các đơn hàng của một khách hàng.
-- Đầu vào: p_customer_id.
-- Expected output: Danh sách các đơn hàng và chi tiết.
-- Triggers được kích hoạt: KHÔNG CÓ trigger nào được kích hoạt.

SELECT 'Lịch sử đơn hàng cho Customer ID 1 (Nguyen Thi F):' AS 'Info';
CALL `SP_GetCustomerOrderHistory`(1);

SELECT 'Lịch sử đơn hàng cho Customer ID 2 (Tran Van G):' AS 'Info';
CALL `SP_GetCustomerOrderHistory`(2);

SELECT 'Lịch sử đơn hàng cho Customer ID không tồn tại (ví dụ: 99):' AS 'Info';
CALL `SP_GetCustomerOrderHistory`(99);