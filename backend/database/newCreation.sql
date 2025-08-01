-- Bảng: Branches
-- Đại diện cho một địa điểm nhà thuốc vật lý.
CREATE TABLE `Branches` (
    `branch_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL UNIQUE,
    `address` VARCHAR(255) NOT NULL,
    `phone_number` VARCHAR(20)
);

-- Bảng: Staff
-- Đại diện cho nhân viên nói chung, làm cơ sở cho các vai trò chuyên biệt.
-- Quyền truy cập dựa trên vai trò được quản lý thông qua cột 'role'.
CREATE TABLE `Staff` (
    `staff_id` INT AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(100) NOT NULL,
    `last_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `phone_number` VARCHAR(20),
    `image_url` VARCHAR(255), 
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff') NOT NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    `branch_id` INT,
    FOREIGN KEY (`branch_id`) REFERENCES `Branches`(`branch_id`) ON DELETE SET NULL
);

-- Bảng: Customers
-- Đại diện cho người dùng cuối tìm kiếm sản phẩm, đặt hàng và tải đơn thuốc.
CREATE TABLE `Customers` (
    `customer_id` INT AUTO_INCREMENT PRIMARY KEY,
    `first_name` VARCHAR(100) NOT NULL,
    `last_name` VARCHAR(100) NOT NULL,
    `gender` ENUM('Male', 'Female'),
    `dob` DATE,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `phone_number` VARCHAR(20),
    `address` VARCHAR(255),
    `image_url` VARCHAR(255),
    `registration_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    `is_active` BOOLEAN DEFAULT TRUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `has_prescription` BOOLEAN DEFAULT FALSE
);

-- Bảng: Products
-- Đại diện cho các mặt hàng liên quan đến sức khỏe có sẵn để mua.
CREATE TABLE `Products` (
    `product_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL UNIQUE,
    `manufacturer` VARCHAR(255),
    `description` TEXT,
    `price` DECIMAL(10, 2) NOT NULL,
    `category` VARCHAR(100),
    `image_url` VARCHAR(255),
    `is_prescription_required` BOOLEAN DEFAULT FALSE
);

-- Bảng: ProductStock
-- Quản lý mức tồn kho theo thời gian thực trên các chi nhánh và nhà kho.
-- Bảng này có khóa chính tổng hợp (branch_id, product_id)
CREATE TABLE `ProductStock` (
    `branch_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `stock_quantity` INT DEFAULT 0 CHECK (`stock_quantity` >= 0), -- Tồn kho không thể âm
    `min_stock_level` INT DEFAULT 10 CHECK (`min_stock_level` >= 0), -- Ngưỡng tồn kho tối thiểu
    `last_updated` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`branch_id`, `product_id`),
    FOREIGN KEY (`branch_id`) REFERENCES `Branches`(`branch_id`) ON DELETE CASCADE,
    FOREIGN KEY (`product_id`) REFERENCES `Products`(`product_id`) ON DELETE CASCADE
);

-- Bảng: Prescriptions
-- Quản lý đơn thuốc kỹ thuật số để xác nhận.
CREATE TABLE `Prescriptions` (
    `prescription_id` INT AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT NOT NULL,
    `upload_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    `file_path` VARCHAR(255),
    `validation_status` ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    `pharmacist_id` INT, -- Dược sĩ đã xác nhận đơn thuốc này HOẶC được gán để xác nhận
    `validation_date` TIMESTAMP ,
    `customer_notes` TEXT,
    `pharmacist_notes` TEXT,
    FOREIGN KEY (`customer_id`) REFERENCES `Customers`(`customer_id`) ON DELETE CASCADE,
    FOREIGN KEY (`pharmacist_id`) REFERENCES `Staff`(`staff_id`) ON DELETE SET NULL
);

-- Bảng: Deliveries
-- Xử lý chi tiết giao hàng cho các đơn hàng.
CREATE TABLE `Deliveries` (
    `delivery_id` INT AUTO_INCREMENT PRIMARY KEY,
    `delivery_address` VARCHAR(255) NOT NULL,
    `delivery_status` ENUM('Scheduled', 'On The Way', 'Delivered', 'Cancelled') DEFAULT 'Scheduled',
    `delivery_party` ENUM('Shopee', 'Grab', 'Be', 'XanhSM'),
    `estimated_delivery_date` TIMESTAMP ,
    `tracking_number` VARCHAR(100)
);

-- Bảng: Orders
-- Đóng gói yêu cầu sản phẩm của khách hàng.
CREATE TABLE `Orders` (
    `order_id` INT AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT NOT NULL,
    `branch_id` INT NOT NULL, -- Chi nhánh mà đơn hàng được thực hiện
    `order_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    `total_amount` DECIMAL(10, 2) DEFAULT 0.00, -- Sẽ được cập nhật bởi trigger/procedure
    `order_status` ENUM('Pending', 'Paid', 'Processing', 'Ready for Pickup', 'Delivered', 'Cancelled', 'Rejected-Refund') DEFAULT 'Pending',
    `prescription_id` INT UNIQUE, -- Một đơn hàng có thể có tối đa một đơn thuốc
    `delivery_id` INT UNIQUE, -- Một đơn hàng có thể có tối đa một giao hàng
    `discount_amount` DECIMAL(10,2) DEFAULT 0.00,
    `order_source` ENUM('In-store', 'Online'),
    `cashier_id` INT, -- Thêm cột cashier_id vào đây
    FOREIGN KEY (`customer_id`) REFERENCES `Customers`(`customer_id`) ON DELETE CASCADE,
    FOREIGN KEY (`branch_id`) REFERENCES `Branches`(`branch_id`) ON DELETE CASCADE,
    FOREIGN KEY (`prescription_id`) REFERENCES `Prescriptions`(`prescription_id`) ON DELETE SET NULL,
    FOREIGN KEY (`delivery_id`) REFERENCES `Deliveries`(`delivery_id`) ON DELETE SET NULL,
    FOREIGN KEY (`cashier_id`) REFERENCES `Staff`(`staff_id`) ON DELETE SET NULL -- Khóa ngoại cho cashier_id
);

-- Bảng: OrderItems
-- Đại diện cho một mặt hàng trong một đơn hàng, liên kết sản phẩm với số lượng và các đơn hàng cụ thể.
CREATE TABLE `OrderItems` (
    `order_item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL CHECK (`quantity` > 0),
    `unit_price` DECIMAL(10, 2) NOT NULL, -- Giá tại thời điểm đặt hàng
    FOREIGN KEY (`order_id`) REFERENCES `Orders`(`order_id`) ON DELETE CASCADE,
    FOREIGN KEY (`product_id`) REFERENCES `Products`(`product_id`) ON DELETE CASCADE
);

-- Bảng: Payments
-- Quản lý giao dịch tài chính cho các đơn hàng.
CREATE TABLE `Payments` (
    `payment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL UNIQUE, -- Mối quan hệ một-một với Order
    `payment_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    `amount` DECIMAL(10, 2) NOT NULL,
    `payment_method` ENUM('Cash', 'Credit Card', 'Debit Card', 'E-Wallet') NOT NULL,
    `transaction_status` ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    FOREIGN KEY (`order_id`) REFERENCES `Orders`(`order_id`) ON DELETE CASCADE
);

-- Bảng: Receipts
-- Tạo xác nhận giao dịch.
CREATE TABLE `Receipts` (
    `receipt_id` INT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` INT NOT NULL UNIQUE, -- Mối quan hệ một-một với Payment
    `receipt_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    `receipt_details` TEXT, -- Có thể là chuỗi của các chi tiết liên quan ví dụ 10 x Apple : 100$
    FOREIGN KEY (`payment_id`) REFERENCES `Payments`(`payment_id`) ON DELETE CASCADE
);

-- Bảng: Notifications
-- Xử lý tin nhắn cho khách hàng hoặc nhân viên.
CREATE TABLE `Notifications` (
    `notification_id` INT AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT,
    `staff_id` INT,
    `order_id` INT,
    `prescription_id` INT,
    `product_id` INT, -- Thêm cột product_id vào đây
    `message_content` TEXT NOT NULL,
    `notification_type` ENUM('Order Status', 'Prescription Validation', 'Promotion', 'Product Stock Alert', 'System Message', 'Delivery Status') NOT NULL,
    `delivery_id` INT,
    `sent_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    `branch_id` INT,
    `is_sent` BOOLEAN DEFAULT FALSE, -- Thêm cột này nhằm kiểm soát tin đã được gửi chưa (phục vụ third party)
    FOREIGN KEY (`customer_id`) REFERENCES `Customers`(`customer_id`) ON DELETE CASCADE,
    FOREIGN KEY (`staff_id`) REFERENCES `Staff`(`staff_id`) ON DELETE CASCADE,
    FOREIGN KEY (`order_id`) REFERENCES `Orders`(`order_id`) ON DELETE CASCADE,
    FOREIGN KEY (`prescription_id`) REFERENCES `Prescriptions`(`prescription_id`) ON DELETE CASCADE,
    FOREIGN KEY (`product_id`) REFERENCES `Products`(`product_id`) ON DELETE CASCADE,
    FOREIGN KEY (`delivery_id`) REFERENCES `Deliveries`(`delivery_id`) ON DELETE SET NULL,
    FOREIGN KEY (`branch_id`) REFERENCES `Branches`(`branch_id`) ON DELETE SET NULL
);

-- Bảng: ProductLikes
-- Lưu trữ lượt "thích" của khách hàng đối với sản phẩm.
CREATE TABLE `ProductLikes` (
    `customer_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `liked_date` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`customer_id`, `product_id`), -- Khóa chính tổng hợp ngăn chặn một khách hàng thích sản phẩm nhiều lần
    FOREIGN KEY (`customer_id`) REFERENCES `Customers`(`customer_id`) ON DELETE CASCADE,
    FOREIGN KEY (`product_id`) REFERENCES `Products`(`product_id`) ON DELETE CASCADE
);


-- TRIGGERS

-- Trigger: trg_after_order_item_insert
-- Giảm số lượng tồn kho khi một OrderItem mới được thêm vào.
DELIMITER //
CREATE TRIGGER `trg_after_order_item_insert`
AFTER INSERT ON `OrderItems`
FOR EACH ROW
BEGIN
    UPDATE `ProductStock`
    SET `stock_quantity` = `stock_quantity` - NEW.quantity
    WHERE `branch_id` = (SELECT `branch_id` FROM `Orders` WHERE `order_id` = NEW.order_id)
      AND `product_id` = NEW.product_id;
END //
DELIMITER ;

-- Trigger: trg_after_order_item_update
-- Điều chỉnh số lượng tồn kho khi số lượng của một OrderItem được cập nhật.
DELIMITER //
CREATE TRIGGER `trg_after_order_item_update`
AFTER UPDATE ON `OrderItems`
FOR EACH ROW
BEGIN
    -- Chỉ điều chỉnh nếu số lượng thay đổi
    IF OLD.quantity <> NEW.quantity THEN    
        UPDATE `ProductStock`
        SET `stock_quantity` = `stock_quantity` + OLD.quantity - NEW.quantity
        WHERE `branch_id` = (SELECT `branch_id` FROM `Orders` WHERE `order_id` = NEW.order_id)
          AND `product_id` = NEW.product_id;
    END IF;
END //
DELIMITER ;

-- Trigger: trg_after_order_item_delete
-- Tăng số lượng tồn kho khi một OrderItem bị xóa (ví dụ: hủy một phần đơn hàng).
DELIMITER //
CREATE TRIGGER `trg_after_order_item_delete`
AFTER DELETE ON `OrderItems`
FOR EACH ROW
BEGIN
    UPDATE `ProductStock`
    SET `stock_quantity` = `stock_quantity` + OLD.quantity
    WHERE `branch_id` = (SELECT `branch_id` FROM `Orders` WHERE `order_id` = OLD.order_id)
      AND `product_id` = OLD.product_id;
END //
DELIMITER ;

-- Trigger: trg_update_order_total_amount
-- Cập nhật tổng số tiền của đơn hàng khi các OrderItem thay đổi (INSERT).
DELIMITER //
CREATE TRIGGER `trg_update_order_total_amount`
AFTER INSERT ON `OrderItems`
FOR EACH ROW
BEGIN
    UPDATE `Orders`
    SET `total_amount` = (SELECT SUM(quantity * unit_price) FROM `OrderItems` WHERE `order_id` = NEW.order_id)
    WHERE `order_id` = NEW.order_id;
END //
DELIMITER ;

-- Trigger: trg_update_order_total_amount_on_update
-- Cập nhật tổng số tiền của đơn hàng khi các OrderItem thay đổi (UPDATE).
DELIMITER //
CREATE TRIGGER `trg_update_order_total_amount_on_update`
AFTER UPDATE ON `OrderItems`
FOR EACH ROW
BEGIN
    UPDATE `Orders`
    SET `total_amount` = (SELECT SUM(quantity * unit_price) FROM `OrderItems` WHERE `order_id` = NEW.order_id)
    WHERE `order_id` = NEW.order_id;
END //
DELIMITER ;

-- Trigger: trg_update_order_total_amount_on_delete
-- Cập nhật tổng số tiền của đơn hàng khi các OrderItem thay đổi (DELETE).
DELIMITER //
CREATE TRIGGER `trg_update_order_total_amount_on_delete`
AFTER DELETE ON `OrderItems`
FOR EACH ROW
BEGIN
    UPDATE `Orders`
    SET `total_amount` = (SELECT COALESCE(SUM(quantity * unit_price), 0) FROM `OrderItems` WHERE `order_id` = OLD.order_id)
    WHERE `order_id` = OLD.order_id;
END //
DELIMITER ;

-- Trigger: trg_after_prescription_validation
-- Tạo thông báo cho khách hàng sau khi đơn thuốc được xác nhận (duyệt/từ chối).
DELIMITER //
CREATE TRIGGER `trg_after_prescription_validation`
AFTER UPDATE ON `Prescriptions`
FOR EACH ROW
BEGIN
    IF OLD.validation_status = 'Pending' AND NEW.validation_status IN ('Approved', 'Rejected') THEN
        INSERT INTO `Notifications` (`customer_id`, `prescription_id`, `message_content`, `notification_type`)
        VALUES (
            NEW.customer_id,
            NEW.prescription_id,
            CONCAT('Đơn thuốc của bạn đã được ', CASE WHEN NEW.validation_status = 'Approved' THEN 'duyệt' ELSE 'từ chối' END, '. Ghi chú của dược sĩ: ', COALESCE(NEW.pharmacist_notes, 'Không có.')),
            'Prescription Validation'
        );
    END IF;
END //
DELIMITER ;

-- Trigger: trg_after_payment_completed (Đã được sửa đổi để thông báo cho BranchManager)
-- Tạo biên lai, cập nhật trạng thái đơn hàng và thông báo cho BranchManager sau khi thanh toán hoàn tất.
DELIMITER //
CREATE TRIGGER `trg_after_payment_completed`
AFTER UPDATE ON `Payments`
FOR EACH ROW
BEGIN
    IF OLD.transaction_status = 'Pending' AND NEW.transaction_status = 'Completed' THEN
        -- Tạo biên lai
        INSERT INTO `Receipts` (`payment_id`, `receipt_details`)
        VALUES (
            NEW.payment_id,
            CONCAT('Biên lai cho Đơn hàng ID: ', NEW.order_id, ', Số tiền: ', NEW.amount, ', Phương thức: ', NEW.payment_method)
        );
        -- Cập nhật trạng thái đơn hàng
        -- Ban đầu đặt là 'Paid', SP_AssignOrderToCashier sẽ chuyển sang 'Processing'
        UPDATE `Orders`
        SET `order_status` = 'Paid'
        WHERE `order_id` = NEW.order_id;

        -- Gửi thông báo cho khách hàng về việc thanh toán thành công
        INSERT INTO `Notifications` (`customer_id`, `order_id`, `message_content`, `notification_type`)
        SELECT `customer_id`, NEW.order_id, CONCAT('Đơn hàng ID: ', NEW.order_id, ' đã được thanh toán thành công. Tổng tiền: ', NEW.amount), 'Order Status'
        FROM `Orders` WHERE `order_id` = NEW.order_id;

        -- Gửi thông báo cho BranchManager về đơn hàng đã thanh toán
        INSERT INTO `Notifications` (`staff_id`, `order_id`, `message_content`, `notification_type`, `branch_id`)
        SELECT
            S.staff_id,
            O.order_id,
            CONCAT('Đơn hàng ID: ', O.order_id, ' (khách hàng ID: ', O.customer_id, ') đã được thanh toán. Cần phân công thu ngân kiểm tra.'),
            'Order Status',
            O.branch_id
        FROM `Orders` O
        JOIN `Staff` S ON O.branch_id = S.branch_id
        WHERE O.order_id = NEW.order_id AND S.role = 'BranchManager' AND S.is_active = TRUE;
    END IF;
END //
DELIMITER ;

-- Trigger: trg_after_order_status_update_notify_customer
-- Tự động tạo thông báo khi trạng thái đơn hàng thay đổi.
DELIMITER //
CREATE TRIGGER `trg_after_order_status_update_notify_customer`
AFTER UPDATE ON `Orders`
FOR EACH ROW
BEGIN
    IF OLD.order_status <> NEW.order_status THEN
        INSERT INTO `Notifications` (`customer_id`, `order_id`, `message_content`, `notification_type`)
        VALUES (
            NEW.customer_id,
            NEW.order_id,
            CONCAT('Trạng thái đơn hàng ID: ', NEW.order_id, ' của bạn đã thay đổi thành: ', NEW.order_status),
            'Order Status'
        );
    END IF;
END //
DELIMITER ;

-- Trigger: trg_after_delivery_status_update_notify_customer
-- Tự động tạo thông báo khi trạng thái giao hàng thay đổi.
DELIMITER //
CREATE TRIGGER `trg_after_delivery_status_update_notify_customer`
AFTER UPDATE ON `Deliveries`
FOR EACH ROW
BEGIN
    IF OLD.delivery_status <> NEW.delivery_status THEN
        INSERT INTO `Notifications` (`customer_id`, `delivery_id`, `message_content`, `notification_type`)
        SELECT
            O.customer_id,
            NEW.delivery_id,
            CONCAT('Trạng thái giao hàng cho đơn hàng ID: ', O.order_id, ' đã thay đổi thành: ', NEW.delivery_status),
            'Delivery Status'
        FROM `Orders` O
        WHERE O.delivery_id = NEW.delivery_id;
    END IF;
END //
DELIMITER ;

-- Trigger: trg_notify_branch_manager_on_new_prescription
-- Thông báo cho BranchManager khi có đơn thuốc mới được tải lên
DELIMITER //
CREATE TRIGGER `trg_notify_branch_manager_on_new_prescription`
AFTER INSERT ON `Prescriptions`
FOR EACH ROW
BEGIN
    IF NEW.validation_status = 'Pending' THEN
        -- Giả định thông báo này được gửi tới tất cả các BranchManager để họ có thể thấy và phân công.
        -- Nếu có logic gán đơn thuốc theo chi nhánh, cần điều chỉnh SELECT.
        INSERT INTO `Notifications` (`staff_id`, `prescription_id`, `message_content`, `notification_type`)
        SELECT
            S.staff_id,
            NEW.prescription_id,
            CONCAT('Có đơn thuốc mới ID: ', NEW.prescription_id, ' từ khách hàng ID: ', NEW.customer_id, ' cần được phân công xác nhận.'),
            'Prescription Validation'
        FROM `Staff` S
        WHERE S.role = 'BranchManager' AND S.is_active = TRUE;
    END IF;
END //
DELIMITER ;

-- Trigger: trg_notify_assigned_pharmacist
-- Thông báo cho Dược sĩ khi họ được gán một đơn thuốc để xác nhận
DELIMITER //
CREATE TRIGGER `trg_notify_assigned_pharmacist`
AFTER UPDATE ON `Prescriptions`
FOR EACH ROW
BEGIN
    -- Chỉ khi pharmacist_id thay đổi và đơn thuốc vẫn đang chờ xử lý
    IF NEW.pharmacist_id IS NOT NULL AND (OLD.pharmacist_id IS NULL OR OLD.pharmacist_id <> NEW.pharmacist_id) AND NEW.validation_status = 'Pending' THEN
        INSERT INTO `Notifications` (`staff_id`, `prescription_id`, `message_content`, `notification_type`)
        VALUES (
            NEW.pharmacist_id,
            NEW.prescription_id,
            CONCAT('Bạn đã được gán đơn thuốc ID: ', NEW.prescription_id, ' cần xác nhận.'),
            'Prescription Validation'
        );
    END IF;
END //
DELIMITER ;

-- Trigger: trg_notify_assigned_cashier
-- Thông báo cho Thu ngân khi họ được gán một đơn hàng để kiểm tra
DELIMITER //
CREATE TRIGGER `trg_notify_assigned_cashier`
AFTER UPDATE ON `Orders`
FOR EACH ROW
BEGIN
    -- Chỉ khi cashier_id thay đổi và đơn hàng đang ở trạng thái 'Processing'
    IF NEW.cashier_id IS NOT NULL AND (OLD.cashier_id IS NULL OR OLD.cashier_id <> NEW.cashier_id) AND NEW.order_status = 'Processing' THEN
        INSERT INTO `Notifications` (`staff_id`, `order_id`, `message_content`, `notification_type`)
        VALUES (
            NEW.cashier_id,
            NEW.order_id,
            CONCAT('Bạn đã được gán đơn hàng ID: ', NEW.order_id, ' cần kiểm tra cuối cùng và hoàn tất.'),
            'Order Status'
        );
    END IF;
END //
DELIMITER ;

-- Trigger: trg_low_stock_notify_warehouse_staff
-- Thông báo cho WarehouseStaff khi sản phẩm xuống dưới ngưỡng tồn kho tối thiểu
DELIMITER //
CREATE TRIGGER `trg_low_stock_notify_warehouse_staff`
AFTER UPDATE ON `ProductStock`
FOR EACH ROW
BEGIN
    -- Chỉ gửi thông báo nếu tồn kho giảm xuống dưới mức tối thiểu HOẶC nếu nó đã dưới mức tối thiểu và tiếp tục giảm
    IF NEW.stock_quantity <= NEW.min_stock_level AND NEW.stock_quantity < OLD.stock_quantity THEN
        INSERT INTO `Notifications` (`staff_id`, `branch_id`, `product_id`, `message_content`, `notification_type`)
        SELECT
            S.staff_id,
            NEW.branch_id,
            NEW.product_id,
            CONCAT('Sản phẩm "', P.name, '" (ID: ', NEW.product_id, ') tại chi nhánh ID: ', NEW.branch_id, ' đang dưới mức tồn kho tối thiểu. Tồn kho hiện tại: ', NEW.stock_quantity),
            'Product Stock Alert'
        FROM `Staff` S
        LEFT JOIN `Products` P ON NEW.product_id = P.product_id
        WHERE S.role = 'WarehouseStaff'
          AND S.is_active = TRUE;
          -- Có thể thêm S.branch_id = NEW.branch_id nếu WarehouseStaff được phân công theo chi nhánh cụ thể
    END IF;
END //
DELIMITER ;


-- Procedures

-- Procedure: SP_PlaceOrder
-- Đặt một đơn hàng mới, bao gồm việc thêm các mặt hàng và cập nhật tồn kho.
DELIMITER //
CREATE PROCEDURE `SP_PlaceOrder`(
    IN p_customer_id INT,
    IN p_branch_id INT,
    IN p_product_details JSON, -- Mảng JSON của {product_id: INT, quantity: INT}
    IN p_prescription_id INT,
    IN p_delivery_address VARCHAR(255),
    IN p_delivery_party ENUM('Shopee', 'Grab', 'Be', 'XanhSM'),
    IN p_estimated_delivery_date TIMESTAMP ,
    IN p_tracking_number VARCHAR(100),
    IN p_discount_amount DECIMAL(10,2),
    IN p_order_source ENUM('In-store', 'Online')
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE i INT DEFAULT 0;
    DECLARE num_products INT;
    DECLARE v_delivery_id INT;
    DECLARE v_total_amount DECIMAL(10, 2) DEFAULT 0.00; -- Biến để tính tổng tiền

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- 1. Tạo một bản ghi Delivery nếu có địa chỉ giao hàng
    IF p_delivery_address IS NOT NULL AND p_delivery_address <> '' THEN
        INSERT INTO `Deliveries` (`delivery_address`, `delivery_status`, `delivery_party`, `estimated_delivery_date`, `tracking_number`)
        VALUES (p_delivery_address, 'Scheduled', p_delivery_party, p_estimated_delivery_date, p_tracking_number);
        SET v_delivery_id = LAST_INSERT_ID();
    ELSE
        SET v_delivery_id = NULL;
    END IF;

    -- 2. Tạo đơn hàng mới
    -- Ban đầu đặt total_amount là 0, sẽ được cập nhật bởi trigger hoặc tính toán sau
    INSERT INTO `Orders` (`customer_id`, `branch_id`, `prescription_id`, `delivery_id`, `order_status`, `discount_amount`, `order_source`, `total_amount`)
    VALUES (p_customer_id, p_branch_id, p_prescription_id, v_delivery_id, 'Pending', p_discount_amount, p_order_source, 0.00);
    SET v_order_id = LAST_INSERT_ID();

    -- 3. Thêm các mặt hàng vào đơn hàng và cập nhật tồn kho
    SET num_products = JSON_LENGTH(p_product_details);
    WHILE i < num_products DO
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_product_details, CONCAT('$[', i, '].product_id')));
        SET v_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_product_details, CONCAT('$[', i, '].quantity')));

        -- Lấy giá sản phẩm hiện tại
        SELECT `price` INTO v_unit_price FROM `Products` WHERE `product_id` = v_product_id;

        -- Kiểm tra tồn kho trước khi thêm OrderItem
        SELECT stock_quantity INTO @current_stock FROM `ProductStock` WHERE `branch_id` = p_branch_id AND `product_id` = v_product_id;
        IF @current_stock IS NULL OR @current_stock < v_quantity THEN
            -- Rollback và báo lỗi nếu không đủ tồn kho
            ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không đủ sản phẩm trong kho hoặc sản phẩm không tồn tại tại chi nhánh này.';
        END IF;

        INSERT INTO `OrderItems` (`order_id`, `product_id`, `quantity`, `unit_price`)
        VALUES (v_order_id, v_product_id, v_quantity, v_unit_price);

        -- Cập nhật tổng tiền tạm thời (trigger sẽ cập nhật chính xác sau khi tất cả order_items được chèn)
        SET v_total_amount = v_total_amount + (v_quantity * v_unit_price);

        SET i = i + 1;
    END WHILE;

    -- 4. Tạo một bản ghi Payments cho đơn hàng này với trạng thái Pending.
    -- Tổng số tiền sẽ được lấy từ Orders sau khi trigger cập nhật
    INSERT INTO `Payments` (`order_id`, `amount`, `payment_method`, `transaction_status`)
    VALUES (v_order_id, v_total_amount - p_discount_amount, 'Cash', 'Pending'); -- Mặc định là Cash, sẽ được cập nhật sau bởi SP_ProcessPayment

    -- 5. Cập nhật tổng số tiền cuối cùng của đơn hàng sau khi các OrderItems đã được chèn và trigger đã chạy.
    -- (Hoặc có thể để trigger trg_update_order_total_amount xử lý, nhưng việc tính toán ở đây cũng không thừa)
    UPDATE `Orders`
    SET `total_amount` = v_total_amount - p_discount_amount
    WHERE `order_id` = v_order_id;

    -- Cập nhật has_prescription của khách hàng thành FALSE sau khi tạo đơn hàng (nếu có đơn thuốc)
    IF p_prescription_id IS NOT NULL THEN
        UPDATE `Customers`
        SET `has_prescription` = FALSE
        WHERE `customer_id` = p_customer_id;
    END IF;

    -- Kết thúc giao dịch
    COMMIT;

    -- Trả về ID đơn hàng mới tạo
    SELECT v_order_id AS new_order_id;

END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `SP_ProcessPayment`(
    IN p_order_id INT,
    IN p_payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'E-Wallet')
)
BEGIN
    DECLARE v_total_amount DECIMAL(10, 2);
    DECLARE v_payment_id INT;

    -- Lấy tổng số tiền của đơn hàng từ bảng Orders
    SELECT `total_amount` INTO v_total_amount FROM `Orders` WHERE `order_id` = p_order_id;

    IF v_total_amount IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy đơn hàng.';
    ELSE
        -- Tìm payment_id liên quan đến order_id này
        SELECT `payment_id` INTO v_payment_id FROM `Payments` WHERE `order_id` = p_order_id;

        IF v_payment_id IS NULL THEN
            -- Nếu chưa có bản ghi Payments, tạo mới với trạng thái Pending trước đó bởi SP_PlaceOrder
            -- Trong trường hợp này, SP_PlaceOrder đã tạo bản ghi Payments nên đoạn này có thể không cần thiết
            -- Nhưng nếu có lý do nào đó mà Payments chưa được tạo, đây là fallback.
            INSERT INTO `Payments` (`order_id`, `amount`, `payment_method`, `transaction_status`)
            VALUES (p_order_id, v_total_amount, p_payment_method, 'Completed');
        ELSE
            -- Cập nhật bản ghi Payments hiện có. Trigger trg_after_payment_completed sẽ được kích hoạt.
            UPDATE `Payments`
            SET
                `amount` = v_total_amount, -- Tự động lấy total_amount từ Orders
                `payment_method` = p_payment_method,
                `transaction_status` = 'Completed',
                `payment_date` = CURRENT_TIMESTAMP
            WHERE `payment_id` = v_payment_id;
        END IF;
    END IF;
END //
DELIMITER ;

-- Procedure: SP_ValidatePrescription
-- Cập nhật trạng thái xác nhận của đơn thuốc.
DELIMITER //
CREATE PROCEDURE `SP_ValidatePrescription`(
    IN p_prescription_id INT,
    IN p_pharmacist_id INT,
    IN p_validation_status ENUM('Approved', 'Rejected'),
    IN p_pharmacist_notes TEXT
)
BEGIN
    DECLARE v_customer_id INT;

    -- Lấy customer_id liên quan đến đơn thuốc
    SELECT `customer_id` INTO v_customer_id FROM `Prescriptions` WHERE `prescription_id` = p_prescription_id;

    UPDATE `Prescriptions`
    SET
        `validation_status` = p_validation_status,
        `pharmacist_id` = p_pharmacist_id,
        `validation_date` = CURRENT_TIMESTAMP,
        `pharmacist_notes` = p_pharmacist_notes
    WHERE `prescription_id` = p_prescription_id;

    -- Cập nhật cột has_prescription trong bảng Customers
    IF p_validation_status = 'Approved' THEN
        UPDATE `Customers`
        SET `has_prescription` = TRUE
        WHERE `customer_id` = v_customer_id;
    -- ELSE (nếu là 'Rejected') thì giữ nguyên giá trị hiện có (mặc định là FALSE)
    END IF;
    -- Trigger sẽ xử lý Notification
END //
DELIMITER ;

-- Procedure: SP_RestockProductStock
-- Cập nhật số lượng tồn kho cho một sản phẩm tại một chi nhánh.
DELIMITER //
CREATE PROCEDURE `SP_RestockProductStock`(
    IN p_branch_id INT,
    IN p_product_id INT,
    IN p_quantity_to_add INT
)
BEGIN
    DECLARE v_product_name VARCHAR(255);

    -- Lấy tên sản phẩm để sử dụng trong thông báo
    SELECT `name` INTO v_product_name FROM `Products` WHERE `product_id` = p_product_id;

    INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`)
    VALUES (p_branch_id, p_product_id, p_quantity_to_add)
    ON DUPLICATE KEY UPDATE `stock_quantity` = `stock_quantity` + p_quantity_to_add;

    -- Thêm logic thông báo cho WarehouseStaff khi restock thành công
    INSERT INTO `Notifications` (`staff_id`, `branch_id`, `product_id`, `message_content`, `notification_type`)
    SELECT
        S.staff_id,
        p_branch_id,
        p_product_id,
        CONCAT('Đã thêm thành công sản phẩm "', v_product_name, '" (ID: ', p_product_id, ') vào tồn kho của chi nhánh ID: ', p_branch_id, '. Số lượng thêm là: ', p_quantity_to_add, '.'),
        'Product Stock Alert' -- Có thể tạo một loại 'Restock Confirmation' nếu muốn tách biệt
    FROM `Staff` S
    WHERE S.role = 'WarehouseStaff'
      AND S.is_active = TRUE
      AND S.branch_id = p_branch_id; -- Chỉ thông báo cho WarehouseStaff của chi nhánh đó
END //
DELIMITER ;

-- Procedure: SP_GenerateSalesReport
-- Tạo báo cáo doanh số bán hàng cho một chi nhánh trong một khoảng thời gian.
DELIMITER //
CREATE PROCEDURE `SP_GenerateSalesReport`(
    IN p_branch_id INT,
    IN p_start_date TIMESTAMP ,
    IN p_end_date TIMESTAMP 
)
BEGIN
    SELECT
        P.name AS product_name,
        SUM(OI.quantity) AS total_quantity_sold,
        SUM(OI.quantity * OI.unit_price) AS total_revenue
    FROM
        `Orders` O
    JOIN
        `OrderItems` OI ON O.order_id = OI.order_id
    JOIN
        `Products` P ON OI.product_id = P.product_id
    WHERE
        O.branch_id = p_branch_id
        AND O.order_date BETWEEN p_start_date AND p_end_date
        AND O.order_status IN ('Paid', 'Processing', 'Ready for Pickup', 'Delivered') -- Only count completed orders
    GROUP BY
        P.product_id, P.name
    ORDER BY
        total_revenue DESC;
END //
DELIMITER ;

-- Procedure: SP_RegisterNewStaff
-- Đăng ký một nhân viên mới vào hệ thống và tạo thông báo.
DELIMITER //
CREATE PROCEDURE `SP_RegisterNewStaff`(
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_phone_number VARCHAR(20),
    IN p_raw_password VARCHAR(255),
    IN p_role ENUM('Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff'),
    IN p_branch_id INT,
    IN p_image_url VARCHAR(255)
)
BEGIN
    DECLARE v_new_staff_id INT;

    INSERT INTO `Staff` (`first_name`, `last_name`, `email`, `phone_number`, `password_hash`, `role`, `branch_id`, `image_url`)
    VALUES (p_first_name, p_last_name, p_email, p_phone_number, p_raw_password, p_role, p_branch_id, p_image_url);

    SET v_new_staff_id = LAST_INSERT_ID();
    SELECT v_new_staff_id AS new_staff_id;

    -- Thêm thông báo cho nhân viên mới
    INSERT INTO `Notifications` (`staff_id`, `message_content`, `notification_type`, `branch_id`)
    VALUES (
        v_new_staff_id,
        CONCAT('Tài khoản nhân viên của bạn đã được tạo với vai trò ', p_role, '.'),
        'System Message',
        p_branch_id
    );
END //
DELIMITER ;

-- Procedure: SP_RegisterNewCustomer
-- Đăng ký một khách hàng mới vào hệ thống và tạo thông báo.
DELIMITER //
CREATE PROCEDURE `SP_RegisterNewCustomer`(
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_phone_number VARCHAR(20),
    IN p_address VARCHAR(255),
    IN p_raw_password VARCHAR(255),
    IN p_image_url VARCHAR(255)
)
BEGIN
    DECLARE v_new_customer_id INT;

    INSERT INTO `Customers` (`first_name`, `last_name`, `email`, `phone_number`, `address`, `password_hash`, `image_url`)
    VALUES (p_first_name, p_last_name, p_email, p_phone_number, p_address, p_raw_password, p_image_url);

    SET v_new_customer_id = LAST_INSERT_ID();
    SELECT v_new_customer_id AS new_customer_id;

    -- Thêm thông báo cho khách hàng mới
    INSERT INTO `Notifications` (`customer_id`, `message_content`, `notification_type`)
    VALUES (
        v_new_customer_id,
        'Tài khoản khách hàng của bạn đã được tạo thành công.',
        'System Message'
    );
END //
DELIMITER ;

-- Procedure: SP_ImportNewProduct
-- Tạo một sản phẩm mới vào hệ thống và thông báo cho WarehouseStaff.
DELIMITER //
CREATE PROCEDURE `SP_ImportNewProduct`(
    IN p_name VARCHAR(255),
    IN p_manufacturer VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10, 2),
    IN p_category VARCHAR(100),
    IN p_is_prescription_required BOOLEAN,
    IN p_image_url VARCHAR(255)
)
BEGIN
    DECLARE v_new_product_id INT;

    INSERT INTO `Products` (`name`, `manufacturer`, `description`, `price`, `category`, `is_prescription_required`, `image_url`)
    VALUES (p_name, p_manufacturer, p_description, p_price, p_category, p_is_prescription_required, p_image_url);

    SET v_new_product_id = LAST_INSERT_ID();
    SELECT v_new_product_id AS new_product_id;

    -- Thêm thông báo cho tất cả WarehouseStaff
    INSERT INTO `Notifications` (`staff_id`, `product_id`, `message_content`, `notification_type`)
    SELECT
        S.staff_id,
        v_new_product_id,
        CONCAT('Sản phẩm mới "', p_name, '" (ID: ', v_new_product_id, ') đã được nhập vào hệ thống.'),
        'Product Stock Alert'
    FROM `Staff` S
    WHERE S.role = 'WarehouseStaff' AND S.is_active = TRUE;
END //
DELIMITER ;

-- Procedure: SP_UpdateProduct
-- Cập nhật thông tin sản phẩm hiện có và thông báo cho WarehouseStaff.
DELIMITER //
CREATE PROCEDURE `SP_UpdateProduct`(
    IN p_product_id INT,
    IN p_name VARCHAR(255),
    IN p_manufacturer VARCHAR(255),
    IN p_description TEXT,
    IN p_price DECIMAL(10, 2),
    IN p_category VARCHAR(100),
    IN p_is_prescription_required BOOLEAN,
    IN p_image_url VARCHAR(255)
)
BEGIN
    DECLARE v_product_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_old_name VARCHAR(255);

    -- Kiểm tra xem sản phẩm có tồn tại không
    SELECT TRUE, `name` INTO v_product_exists, v_old_name
    FROM `Products`
    WHERE `product_id` = p_product_id;

    IF v_product_exists THEN
        UPDATE `Products`
        SET
            `name` = p_name,
            `manufacturer` = p_manufacturer,
            `description` = p_description,
            `price` = p_price,
            `category` = p_category,
            `is_prescription_required` = p_is_prescription_required,
            `image_url` = p_image_url
        WHERE `product_id` = p_product_id;

        -- Thêm thông báo cho tất cả WarehouseStaff
        INSERT INTO `Notifications` (`staff_id`, `product_id`, `message_content`, `notification_type`)
        SELECT
            S.staff_id,
            p_product_id,
            CONCAT('Thông tin sản phẩm "', p_name, '" (ID: ', p_product_id, ') đã được cập nhật.'),
            'Product Stock Alert' -- Hoặc 'System Message' tùy theo mức độ quan trọng
        FROM `Staff` S
        WHERE S.role = 'WarehouseStaff' AND S.is_active = TRUE;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sản phẩm không tồn tại để cập nhật.';
    END IF;
END //
DELIMITER ;

-- Procedure: SP_GetCustomerOrderHistory
-- Lấy lịch sử đơn hàng của một khách hàng cụ thể.
DELIMITER //
CREATE PROCEDURE `SP_GetCustomerOrderHistory`(
    IN p_customer_id INT
)
BEGIN
    SELECT
        O.order_id,
        O.order_date,
        O.total_amount,
        O.order_status,
        P.name AS product_name,
        OI.quantity,
        OI.unit_price,
        B.name AS branch_name,
        D.delivery_status,
        D.delivery_party, -- Added new delivery detail
        D.estimated_delivery_date, -- Added new delivery detail
        D.tracking_number, -- Added new delivery detail
        Pres.validation_status AS prescription_status,
        Pres.pharmacist_notes -- Updated column name
    FROM
        `Orders` O
    JOIN
        `OrderItems` OI ON O.order_id = OI.order_id
    JOIN
        `Products` P ON OI.product_id = P.product_id
    JOIN
        `Branches` B ON O.branch_id = B.branch_id
    LEFT JOIN
        `Deliveries` D ON O.delivery_id = D.delivery_id
    LEFT JOIN
        `Prescriptions` Pres ON O.prescription_id = Pres.prescription_id
    WHERE
        O.customer_id = p_customer_id
    ORDER BY
        O.order_date DESC, O.order_id, P.name;
END //
DELIMITER ;

-- Procedure: SP_GetBranchProductStockStatus
-- Lấy trạng thái tồn kho của tất cả sản phẩm tại một chi nhánh cụ thể, bao gồm cả ngưỡng tồn kho tối thiểu.
DELIMITER //
CREATE PROCEDURE `SP_GetBranchProductStockStatus`(
    IN p_branch_id INT
)
BEGIN
    SELECT
        P.product_id,
        P.name AS product_name,
        P.category,
        I.stock_quantity,
        I.min_stock_level, -- Added min_stock_level column
        I.last_updated,
        CASE
            WHEN I.stock_quantity <= I.min_stock_level THEN 'Dưới ngưỡng'
            ELSE 'Đủ'
        END AS stock_status_alert -- Added stock alert column
    FROM
        `ProductStock` I
    JOIN
        `Products` P ON I.product_id = P.product_id
    WHERE
        I.branch_id = p_branch_id
    ORDER BY
        P.name;
END //
DELIMITER ;

-- Procedure: SP_GetPharmacistPendingPrescriptions
-- Lấy danh sách các đơn thuốc đang chờ xác nhận cho một dược sĩ cụ thể (đã được gán).
DELIMITER //
CREATE PROCEDURE `SP_GetPharmacistPendingPrescriptions`(
    IN p_pharmacist_id INT
)
BEGIN
    SELECT
        P.prescription_id,
        P.customer_id,
        C.first_name AS customer_first_name,
        C.last_name AS customer_last_name,
        P.upload_date,
        P.file_path, -- Changed from medication_details as per your schema
        P.validation_status,
        P.customer_notes, -- Added customer_notes
        P.pharmacist_notes -- Updated column name
    FROM
        `Prescriptions` P
    JOIN
        `Customers` C ON P.customer_id = C.customer_id
    WHERE
        P.validation_status = 'Pending'
        AND P.pharmacist_id = p_pharmacist_id -- Filter by assigned pharmacist
    ORDER BY
        P.upload_date ASC;
END //
DELIMITER ;

-- Procedure: SP_AssignPrescriptionToPharmacist
-- Cho phép BranchManager gán một đơn thuốc 'Pending' cho một Pharmacist cụ thể
DELIMITER //
CREATE PROCEDURE `SP_AssignPrescriptionToPharmacist`(
    IN p_prescription_id INT,
    IN p_pharmacist_id INT,
    IN p_branch_manager_id INT -- Tùy chọn: để ghi nhận ai là người gán
)
BEGIN
    DECLARE v_current_status ENUM('Pending', 'Approved', 'Rejected');

    -- Kiểm tra trạng thái hiện tại của đơn thuốc
    SELECT validation_status INTO v_current_status
    FROM `Prescriptions`
    WHERE prescription_id = p_prescription_id;

    IF v_current_status = 'Pending' THEN
        UPDATE `Prescriptions`
        SET
            `pharmacist_id` = p_pharmacist_id,
            `pharmacist_notes` = CONCAT('Đã được BranchManager (Staff ID: ', p_branch_manager_id, ') gán để xác nhận.')
        WHERE `prescription_id` = p_prescription_id;

        -- Trigger trg_notify_assigned_pharmacist sẽ tự động kích hoạt sau UPDATE
    ELSEIF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy đơn thuốc này.';
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn thuốc này đã được xử lý hoặc không ở trạng thái chờ.';
    END IF;
END //
DELIMITER ;

-- Procedure: SP_AssignOrderToCashier
-- Cho phép BranchManager gán một đơn hàng đã "Paid" cho một Cashier cụ thể để kiểm tra
DELIMITER //
CREATE PROCEDURE `SP_AssignOrderToCashier`(
    IN p_order_id INT,
    IN p_cashier_id INT,
    IN p_branch_manager_id INT -- Tùy chọn: để ghi nhận ai là người gán
)
BEGIN
    DECLARE v_current_status ENUM('Pending', 'Paid', 'Processing', 'Ready for Pickup', 'Delivered', 'Cancelled', 'Rejected-Refund');

    -- Kiểm tra trạng thái hiện tại của đơn hàng
    SELECT order_status INTO v_current_status
    FROM `Orders`
    WHERE order_id = p_order_id;

    IF v_current_status = 'Paid' THEN -- Chỉ gán khi đơn hàng đã thanh toán và chờ xử lý
        UPDATE `Orders`
        SET
            `cashier_id` = p_cashier_id,
            `order_status` = 'Processing' -- Chuyển sang trạng thái đang xử lý/kiểm tra bởi thu ngân
        WHERE `order_id` = p_order_id;

        -- Trigger trg_notify_assigned_cashier sẽ tự động kích hoạt sau UPDATE
    ELSEIF v_current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không tìm thấy đơn hàng này.';
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn hàng này không ở trạng thái cần phân công thu ngân kiểm tra (chỉ các đơn đã "Paid" mới được phân công).';
    END IF;
END //
DELIMITER ;

DELIMITER //

CREATE PROCEDURE `SP_GetCashierOrdersForCashier`(
    IN p_cashier_id INT
)
BEGIN
    -- Lấy danh sách tất cả các đơn hàng được gán cho thu ngân này và đang ở trạng thái 'Processing'
    SELECT
        O.order_id,
        O.customer_id,
        C.first_name AS customer_first_name,
        C.last_name AS customer_last_name,
        O.order_date,
        O.total_amount,
        O.order_status,
        O.prescription_id,
        P.file_path AS prescription_file_path -- Đường dẫn file đơn thuốc nếu có
    FROM
        `Orders` O
    JOIN
        `Customers` C ON O.customer_id = C.customer_id
    LEFT JOIN
        `Prescriptions` P ON O.prescription_id = P.prescription_id
    WHERE
        O.cashier_id = p_cashier_id AND O.order_status = 'Processing'
    ORDER BY
        O.order_date ASC;

    -- Lấy chi tiết các mặt hàng cho TẤT CẢ các đơn hàng được gán cho thu ngân này và đang ở trạng thái 'Processing'
    SELECT
        OI.order_id,
        OI.order_item_id,
        Pr.product_id,
        Pr.name AS product_name,
        OI.quantity,
        OI.unit_price,
        Pr.is_prescription_required -- Cần kiểm tra xem sản phẩm có yêu cầu đơn thuốc không
    FROM
        `OrderItems` OI
    JOIN
        `Products` Pr ON OI.product_id = Pr.product_id
    JOIN
        `Orders` O ON OI.order_id = O.order_id
    WHERE
        O.cashier_id = p_cashier_id AND O.order_status = 'Processing'
    ORDER BY
        OI.order_id, Pr.name;

END //

DELIMITER ;

DELIMITER //
-- Tạo PROCEDURE SP_CancelOrder để hủy một đơn hàng
CREATE PROCEDURE `SP_CancelOrder`(
    IN p_order_id INT -- ID của đơn hàng cần hủy
)
BEGIN
    -- Khai báo các biến cục bộ để lưu trữ thông tin đơn hàng
    DECLARE v_current_order_status ENUM('Pending', 'Paid', 'Processing', 'Ready for Pickup', 'Delivered', 'Cancelled', 'Rejected-Refund');
    DECLARE v_payment_id INT;
    DECLARE v_delivery_id INT;
    DECLARE v_customer_id INT;
    DECLARE v_branch_id INT;
    DECLARE v_error_message VARCHAR(255); -- Biến để chứa thông báo lỗi

    -- Lấy thông tin hiện tại của đơn hàng từ bảng Orders
    SELECT
        `order_status`,
        `delivery_id`,
        `customer_id`,
        `branch_id`
    INTO
        v_current_order_status,
        v_delivery_id,
        v_customer_id,
        v_branch_id
    FROM `Orders`
    WHERE `order_id` = p_order_id;

    -- Lấy payment_id từ bảng Payments (nếu có)
    SELECT `payment_id`
    INTO v_payment_id
    FROM `Payments`
    WHERE `order_id` = p_order_id;

    -- Kiểm tra nếu đơn hàng không tồn tại
    IF v_current_order_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đơn hàng không tồn tại.';
    END IF;

    -- Kiểm tra nếu đơn hàng ở trạng thái không thể hủy
    -- Các trạng thái 'Delivered', 'Cancelled', 'Rejected-Refund' không cho phép hủy
    IF v_current_order_status IN ('Delivered', 'Cancelled', 'Rejected-Refund') THEN
        SET v_error_message = CONCAT('Không thể hủy đơn hàng có trạng thái hiện tại là: ', v_current_order_status, '.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END IF;

    -- Bắt đầu giao dịch để đảm bảo tính toàn vẹn dữ liệu
    START TRANSACTION;

    -- 1. Cập nhật trạng thái đơn hàng thành 'Cancelled'
    -- Trigger `trg_after_order_status_update_notify_customer` sẽ tự động xử lý thông báo cho khách hàng
    UPDATE `Orders`
    SET `order_status` = 'Cancelled'
    WHERE `order_id` = p_order_id;

    -- 2. Hoàn lại tồn kho cho các sản phẩm trong đơn hàng
    -- Tăng số lượng `stock_quantity` trong bảng `ProductStock` cho từng mặt hàng trong đơn hàng
    UPDATE `ProductStock` PS
    JOIN `OrderItems` OI ON PS.product_id = OI.product_id
    SET PS.stock_quantity = PS.stock_quantity + OI.quantity -- SET clause moved before WHERE
    WHERE OI.order_id = p_order_id AND PS.branch_id = v_branch_id;

    -- 3. Cập nhật trạng thái thanh toán nếu có bản ghi thanh toán
    IF v_payment_id IS NOT NULL THEN
        -- Lấy trạng thái giao dịch hiện tại của thanh toán
        SELECT transaction_status INTO @current_payment_status FROM `Payments` WHERE payment_id = v_payment_id;

        -- Nếu thanh toán đã "Completed", chuyển sang "Refunded"
        IF @current_payment_status = 'Completed' THEN
            UPDATE `Payments`
            SET
                `transaction_status` = 'Refunded',
                `payment_date` = CURRENT_TIMESTAMP -- Cập nhật thời gian hoàn tiền
            WHERE `payment_id` = v_payment_id;

            -- Gửi thông báo cụ thể về việc hoàn tiền cho khách hàng
            -- (Trigger `trg_after_payment_completed` không xử lý trạng thái 'Refunded' nên cần thông báo riêng)
            INSERT INTO `Notifications` (`customer_id`, `order_id`, `message_content`, `notification_type`)
            VALUES (v_customer_id, p_order_id, CONCAT('Thanh toán cho đơn hàng ID: ', p_order_id, ' đã được hoàn tiền.'), 'Order Status');
        -- Nếu thanh toán đang "Pending", chuyển sang "Cancelled"
        ELSEIF @current_payment_status = 'Pending' THEN
            UPDATE `Payments`
            SET `transaction_status` = 'Cancelled'
            WHERE `payment_id` = v_payment_id;
        END IF;
    END IF;

    -- 4. Cập nhật trạng thái giao hàng nếu có bản ghi giao hàng
    -- Trigger `trg_after_delivery_status_update_notify_customer` sẽ tự động xử lý thông báo cho khách hàng
    IF v_delivery_id IS NOT NULL THEN
        UPDATE `Deliveries`
        SET `delivery_status` = 'Cancelled'
        WHERE `delivery_id` = v_delivery_id;
    END IF;

    -- Kết thúc giao dịch
    COMMIT;

END //
DELIMITER ;