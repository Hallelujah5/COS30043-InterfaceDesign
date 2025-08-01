-- SeedData.sql
-- Chứa dữ liệu mẫu để điền vào cơ sở dữ liệu pharmacy_db
-- Luôn ưu tiên sử dụng Stored Procedure để thêm dữ liệu nếu có thể.

USE `pharmacy_db`;

-- Thêm dữ liệu vào bảng Branches
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Chi nhánh Trung Tâm', '123 Đường Nguyễn Huệ, Quận 1, TP.HCM', '0281112222'),
('Chi nhánh Gò Vấp', '456 Đường Quang Trung, Quận Gò Vấp, TP.HCM', '0283334444'),
('Chi nhánh Thủ Đức', '789 Đường Võ Văn Ngân, TP. Thủ Đức, TP.HCM', '0285556666'),
('Chi nhánh Quận 7', '101 Nguyễn Thị Thập, Quận 7, TP.HCM', '0287778888'),
('Chi nhánh Bình Thạnh', '20 Phan Đăng Lưu, Quận Bình Thạnh, TP.HCM', '0289990000');

-- Thêm dữ liệu vào bảng Staff bằng SP_RegisterNewStaff
-- Lưu ý: Mật khẩu ở đây là văn bản thô, trong ứng dụng thực tế sẽ được hash trước khi gọi SP.
-- Giả sử branch_id: 1=Trung Tâm, 2=Gò Vấp, 3=Thủ Đức, 4=Quận 7, 5=Bình Thạnh

-- Chi nhánh 1: Trung Tâm (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Nguyễn', 'Lan Anh', 'lananh.bm@pharmacy.com', '0901234567', 'passlananh', 'BranchManager', 1, 'https://example.com/staff/lananh.jpg');
CALL `SP_RegisterNewStaff`('Trần', 'Minh', 'minh.pharma@pharmacy.com', '0907654321', 'passminh', 'Pharmacist', 1, 'https://example.com/staff/minh.jpg');
CALL `SP_RegisterNewStaff`('Lê', 'Thị Mai', 'mai.cashier@pharmacy.com', '0912345678', 'passmai', 'Cashier', 1, 'https://example.com/staff/mai.jpg');
CALL `SP_RegisterNewStaff`('Phạm', 'Văn Hùng', 'hung.warehouse@pharmacy.com', '0918765432', 'passhung', 'WarehouseStaff', 1, 'https://example.com/staff/hung.jpg');
CALL `SP_RegisterNewStaff`('Vũ', 'Thị Hoa', 'hoa.cashier@pharmacy.com', '0919876543', 'passhoa', 'Cashier', 1, 'https://example.com/staff/hoa.jpg');
CALL `SP_RegisterNewStaff`('Đỗ', 'Văn Tâm', 'tam.pharma@pharmacy.com', '0920987654', 'passtam', 'Pharmacist', 1, 'https://example.com/staff/tam.jpg');
CALL `SP_RegisterNewStaff`('Ngô', 'Thị Linh', 'linh.cashier@pharmacy.com', '0921098765', 'passlinh', 'Cashier', 1, 'https://example.com/staff/linh.jpg');
CALL `SP_RegisterNewStaff`('Hoàng', 'Văn Đức', 'duc.warehouse@pharmacy.com', '0922109876', 'passduc', 'WarehouseStaff', 1, 'https://example.com/staff/duc.jpg');
CALL `SP_RegisterNewStaff`('Lý', 'Thị Kim', 'kim.pharma@pharmacy.com', '0923210987', 'passkim', 'Pharmacist', 1, 'https://example.com/staff/kim.jpg');
CALL `SP_RegisterNewStaff`('Trương', 'Văn Long', 'long.warehouse@pharmacy.com', '0924321098', 'passlong', 'WarehouseStaff', 1, 'https://example.com/staff/long.jpg');

-- Chi nhánh 2: Gò Vấp (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Hoàng', 'Thị Yến', 'yen.bm@pharmacy.com', '0934567890', 'passyen', 'BranchManager', 2, 'https://example.com/staff/yen.jpg');
CALL `SP_RegisterNewStaff`('Võ', 'Thị Thu', 'thu.cashier@pharmacy.com', '0919998888', 'passthucash', 'Cashier', 2, 'https://example.com/staff/thu.jpg');
CALL `SP_RegisterNewStaff`('Phan', 'Văn Nam', 'nam.pharma@pharmacy.com', '0935678901', 'passnam', 'Pharmacist', 2, 'https://example.com/staff/nam.jpg');
CALL `SP_RegisterNewStaff`('Đinh', 'Thị Lan', 'lan.warehouse@pharmacy.com', '0936789012', 'passlan', 'WarehouseStaff', 2, 'https://example.com/staff/lan.jpg');
CALL `SP_RegisterNewStaff`('Bùi', 'Văn Sơn', 'son.cashier@pharmacy.com', '0937890123', 'passon', 'Cashier', 2, 'https://example.com/staff/son.jpg');
CALL `SP_RegisterNewStaff`('Tạ', 'Thị Hương', 'huong.pharma@pharmacy.com', '0938901234', 'passhuong', 'Pharmacist', 2, 'https://example.com/staff/huong.jpg');
CALL `SP_RegisterNewStaff`('Dương', 'Văn Quân', 'quan.cashier@pharmacy.com', '0939012345', 'passquan', 'Cashier', 2, 'https://example.com/staff/quan.jpg');
CALL `SP_RegisterNewStaff`('Lưu', 'Thị Nga', 'nga.warehouse@pharmacy.com', '0940123456', 'passnga', 'WarehouseStaff', 2, 'https://example.com/staff/nga.jpg');
CALL `SP_RegisterNewStaff`('Cao', 'Văn Phúc', 'phuc.pharma@pharmacy.com', '0941234567', 'passphuc', 'Pharmacist', 2, 'https://example.com/staff/phuc.jpg');
CALL `SP_RegisterNewStaff`('Mã', 'Thị Oanh', 'oanh.warehouse@pharmacy.com', '0942345678', 'passoanh', 'WarehouseStaff', 2, 'https://example.com/staff/oanh.jpg');

-- Chi nhánh 3: Thủ Đức (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Đặng', 'Quốc Bảo', 'bao.bm@pharmacy.com', '0987654321', 'passbao', 'BranchManager', 3, 'https://example.com/staff/bao.jpg');
CALL `SP_RegisterNewStaff`('Đinh', 'Văn Chung', 'chung.warehouse@pharmacy.com', '0945678901', 'passchung', 'WarehouseStaff', 3, 'https://example.com/staff/chung.jpg');
CALL `SP_RegisterNewStaff`('Lê', 'Thị Thuỷ', 'thuy.cashier@pharmacy.com', '0946789012', 'passthuy', 'Cashier', 3, 'https://example.com/staff/thuy.jpg');
CALL `SP_RegisterNewStaff`('Nguyễn', 'Văn Hải', 'hai.pharma@pharmacy.com', '0947890123', 'passhai', 'Pharmacist', 3, 'https://example.com/staff/hai.jpg');
CALL `SP_RegisterNewStaff`('Trần', 'Thị Vân', 'van.cashier@pharmacy.com', '0948901234', 'passvan', 'Cashier', 3, 'https://example.com/staff/van.jpg');
CALL `SP_RegisterNewStaff`('Phạm', 'Văn Tuấn', 'tuan.warehouse@pharmacy.com', '0949012345', 'passtuan', 'WarehouseStaff', 3, 'https://example.com/staff/tuan.jpg');
CALL `SP_RegisterNewStaff`('Hoàng', 'Thị Ly', 'ly.pharma@pharmacy.com', '0950123456', 'passly', 'Pharmacist', 3, 'https://example.com/staff/ly.jpg');
CALL `SP_RegisterNewStaff`('Võ', 'Văn Khôi', 'khoi.cashier@pharmacy.com', '0951234567', 'passkhoi', 'Cashier', 3, 'https://example.com/staff/khoi.jpg');
CALL `SP_RegisterNewStaff`('Lý', 'Thị Diệu', 'dieu.warehouse@pharmacy.com', '0952345678', 'passdieu', 'WarehouseStaff', 3, 'https://example.com/staff/dieu.jpg');
CALL `SP_RegisterNewStaff`('Bùi', 'Văn Hiếu', 'hieu.pharma@pharmacy.com', '0953456789', 'passhieu', 'Pharmacist', 3, 'https://example.com/staff/hieu.jpg');

-- Chi nhánh 4: Quận 7 (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Ngô', 'Thanh Tuyền', 'tuyen.bm@pharmacy.com', '0967890123', 'passtuyen', 'BranchManager', 4, 'https://example.com/staff/tuyen.jpg');
CALL `SP_RegisterNewStaff`('Trịnh', 'Đình Tú', 'tu.cashier@pharmacy.com', '0978901234', 'passtucash', 'Cashier', 4, 'https://example.com/staff/tu.jpg');
CALL `SP_RegisterNewStaff`('Đỗ', 'Thị Nhung', 'nhung.pharma@pharmacy.com', '0954567890', 'passnhung', 'Pharmacist', 4, 'https://example.com/staff/nhung.jpg');
CALL `SP_RegisterNewStaff`('Lê', 'Văn Thiện', 'thien.warehouse@pharmacy.com', '0955678901', 'passthien', 'WarehouseStaff', 4, 'https://example.com/staff/thien.jpg');
CALL `SP_RegisterNewStaff`('Nguyễn', 'Thị Xuân', 'xuan.cashier@pharmacy.com', '0956789012', 'passxuan', 'Cashier', 4, 'https://example.com/staff/xuan.jpg');
CALL `SP_RegisterNewStaff`('Trần', 'Văn Đạt', 'dat.pharma@pharmacy.com', '0957890123', 'passdat', 'Pharmacist', 4, 'https://example.com/staff/dat.jpg');
CALL `SP_RegisterNewStaff`('Phạm', 'Thị Hồng', 'hong.cashier@pharmacy.com', '0958901234', 'passhong', 'Cashier', 4, 'https://example.com/staff/hong.jpg');
CALL `SP_RegisterNewStaff`('Hoàng', 'Văn Thắng', 'thang.warehouse@pharmacy.com', '0959012345', 'passthang', 'WarehouseStaff', 4, 'https://example.com/staff/thang.jpg');
CALL `SP_RegisterNewStaff`('Võ', 'Thị Mai', 'mai2.pharma@pharmacy.com', '0960123456', 'passmai2', 'Pharmacist', 4, 'https://example.com/staff/mai2.jpg');
CALL `SP_RegisterNewStaff`('Lý', 'Văn Dũng', 'dung.warehouse@pharmacy.com', '0961234567', 'passdung', 'WarehouseStaff', 4, 'https://example.com/staff/dung.jpg');

-- Chi nhánh 5: Bình Thạnh (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Bùi', 'Minh Phương', 'phuong.bm@pharmacy.com', '0989012345', 'passphuong', 'BranchManager', 5, 'https://example.com/staff/phuong.jpg');
CALL `SP_RegisterNewStaff`('Trương', 'Thị An', 'an.cashier@pharmacy.com', '0962345678', 'passan', 'Cashier', 5, 'https://example.com/staff/an.jpg');
CALL `SP_RegisterNewStaff`('Đặng', 'Văn Thông', 'thong.pharma@pharmacy.com', '0963456789', 'passthong', 'Pharmacist', 5, 'https://example.com/staff/thong.jpg');
CALL `SP_RegisterNewStaff`('Lưu', 'Thị Bích', 'bich.warehouse@pharmacy.com', '0964567890', 'passbich', 'WarehouseStaff', 5, 'https://example.com/staff/bich.jpg');
CALL `SP_RegisterNewStaff`('Cao', 'Thị Diễm', 'diem.cashier@pharmacy.com', '0965678901', 'passdiem', 'Cashier', 5, 'https://example.com/staff/diem.jpg');
CALL `SP_RegisterNewStaff`('Mã', 'Văn Toàn', 'toan.pharma@pharmacy.com', '0966789012', 'passtoan', 'Pharmacist', 5, 'https://example.com/staff/toan.jpg');
CALL `SP_RegisterNewStaff`('Phan', 'Thị Nga', 'nga2.cashier@pharmacy.com', '0967890123', 'passnga2', 'Cashier', 5, 'https://example.com/staff/nga2.jpg');
CALL `SP_RegisterNewStaff`('Tạ', 'Văn Minh', 'minh2.warehouse@pharmacy.com', '0968901234', 'passminh2', 'WarehouseStaff', 5, 'https://example.com/staff/minh2.jpg');
CALL `SP_RegisterNewStaff`('Dương', 'Thị Thu', 'thu2.pharma@pharmacy.com', '0969012345', 'passthu2', 'Pharmacist', 5, 'https://example.com/staff/thu2.jpg');
CALL `SP_RegisterNewStaff`('Đinh', 'Văn Lâm', 'lam.warehouse@pharmacy.com', '0970123456', 'passlam', 'WarehouseStaff', 5, 'https://example.com/staff/lam.jpg');


-- Thêm dữ liệu vào bảng Customers bằng SP_RegisterNewCustomer
-- Chỉ tạo 1 khách hàng đại diện cho mua hàng tại quầy
CALL `SP_RegisterNewCustomer`('Instore', 'Purchase', 'instore@pharmacy.com', '0987123456', 'Tại quầy nhà thuốc', 'instore123', 'https://example.com/customer/instore.jpg');

-- Cập nhật thông tin khách hàng
UPDATE `Customers` SET `gender` = 'Male', `dob` = '1990-01-01' WHERE `customer_id` = 1;


-- Thêm dữ liệu vào bảng Products bằng SP_ImportNewProduct (Dồi dào hơn)
-- Thuốc giảm đau, hạ sốt
CALL `SP_ImportNewProduct`('Paracetamol 500mg', 'Stada', 'Thuốc giảm đau, hạ sốt.', 15000.00, 'Thuốc giảm đau', FALSE, 'http://localhost:8000/static/paracetamol.jpg');
-- ID 2
CALL `SP_ImportNewProduct`('Ibuprofen 400mg', 'Stellapharm', 'Thuốc chống viêm, giảm đau.', 22000.00, 'Thuốc giảm đau', FALSE, 'http://localhost:8000/static/ibuprofen.jpg');
-- ID 3
CALL `SP_ImportNewProduct`('Amoxicillin 250mg', 'Domesco', 'Kháng sinh phổ rộng.', 30000.00, 'Kháng sinh', TRUE, 'http://localhost:8000/static/amoxicillin.jpg');
-- ID 4
CALL `SP_ImportNewProduct`('Vitamin C 1000mg', 'Bayer', 'Bổ sung Vitamin C tăng cường sức đề kháng.', 80000.00, 'Vitamin', FALSE, 'http://localhost:8000/static/vitaminc.jpg');
-- ID 5
CALL `SP_ImportNewProduct`('Vitamin Tổng Hợp One A Day', 'Bayer', 'Hỗ trợ sức khỏe tổng thể.', 250000.00, 'Vitamin', FALSE, 'http://localhost:8000/static/multivi.jpg');
-- ID 6
CALL `SP_ImportNewProduct`('Vitamin D3 2000IU', 'Nature Made', 'Bổ sung Vitamin D3.', 450000.00, 'Vitamin', FALSE, 'http://localhost:8000/static/vitamind3.jpg');
-- ID 7
CALL `SP_ImportNewProduct`('Thuốc nhỏ mắt V.Rohto', 'Rohto-Mentholatum', 'Giúp làm dịu và giảm mỏi mắt.', 45000.00, 'Chăm sóc mắt', FALSE, 'http://localhost:8000/static/vrohto.jpg');
-- ID 8
CALL `SP_ImportNewProduct`('Khẩu trang y tế 4 lớp', 'Nam Anh', 'Bảo vệ khỏi bụi và vi khuẩn.', 50000.00, 'Vật tư y tế', FALSE, 'http://localhost:8000/static/khautrang.jpg');
-- ID 9
CALL `SP_ImportNewProduct`('Siro ho Astex', 'OPC', 'Giảm ho, long đờm.', 65000.00, 'Thuốc ho', FALSE, 'http://localhost:8000/static/siro.jpg');
-- ID 10
CALL `SP_ImportNewProduct`('Fexofenadine 120mg', 'Sanofi', 'Điều trị triệu chứng viêm mũi dị ứng.', 95000.00, 'Thuốc dị ứng', TRUE, 'http://localhost:8000/static/fexo.jpg');
-- ID 11
CALL `SP_ImportNewProduct`('Omeprazole 20mg', 'Stada', 'Thuốc ức chế bơm proton.', 75000.00, 'Thuốc tiêu hóa', TRUE, 'http://localhost:8000/static/omepraz.jpg');
-- ID 12
CALL `SP_ImportNewProduct`('Panadol Extra', 'GSK', 'Giảm đau nhanh, hạ sốt hiệu quả.', 18000.00, 'Thuốc giảm đau', FALSE, 'http://localhost:8000/static/panadol_extra.jpg');
-- ID 13
CALL `SP_ImportNewProduct`('Omega-3 Fish Oil', 'Puritan''s Pride', 'Hỗ trợ sức khỏe tim mạch và não bộ.', 180000.00, 'Thực phẩm chức năng', FALSE, 'http://localhost:8000/static/omega3.jpg');
-- ID 14
CALL `SP_ImportNewProduct`('Nhiệt kế điện tử', 'Omron', 'Đo nhiệt độ cơ thể.', 150000.00, 'Vật tư y tế', FALSE, 'http://localhost:8000/static/nhietke.jpg');
-- ID 15
CALL `SP_ImportNewProduct`('Men tiêu hóa Enterogermina', 'Sanofi', 'Hỗ trợ tiêu hóa.', 110000.00, 'Thuốc tiêu hóa', FALSE, 'http://localhost:8000/static/enterogermina.jpg');


-- Thêm dữ liệu tồn kho cho các chi nhánh (chỉ cho 15 sản phẩm đã giữ lại)
-- Branch 1: Chi nhánh Trung Tâm
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 150, 30), (1, 2, 60, 15), (1, 3, 30, 8), (1, 4, 200, 50), (1, 5, 70, 15),
(1, 6, 120, 25), (1, 7, 75, 15), (1, 8, 85, 18), (1, 9, 140, 30), (1, 10, 25, 5),
(1, 11, 75, 15), (1, 12, 120, 25), (1, 13, 90, 20), (1, 14, 95, 20), (1, 15, 110, 25);

-- Branch 2: Chi nhánh Gò Vấp
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(2, 1, 100, 25), (2, 2, 45, 10), (2, 3, 20, 5), (2, 4, 150, 40), (2, 5, 50, 12),
(2, 6, 90, 20), (2, 7, 55, 12), (2, 8, 65, 15), (2, 9, 110, 24), (2, 10, 20, 4),
(2, 11, 60, 13), (2, 12, 90, 20), (2, 13, 70, 15), (2, 14, 75, 16), (2, 15, 85, 18);

-- Branch 3: Chi nhánh Thủ Đức
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(3, 1, 120, 28), (3, 2, 50, 12), (3, 3, 25, 6), (3, 4, 170, 38), (3, 5, 60, 14),
(3, 6, 100, 22), (3, 7, 65, 14), (3, 8, 75, 17), (3, 9, 120, 26), (3, 10, 22, 5),
(3, 11, 70, 16), (3, 12, 100, 22), (3, 13, 80, 18), (3, 14, 85, 19), (3, 15, 95, 21);

