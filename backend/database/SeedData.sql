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
CALL `SP_ImportNewProduct`('Paracetamol 500mg', 'Stada', 'Thuốc giảm đau, hạ sốt.', 15000.00, 'Thuốc giảm đau', FALSE, 'https://example.com/products/paracetamol.jpg');
CALL `SP_ImportNewProduct`('Efferalgan 500mg', 'UPSA', 'Thuốc giảm đau, hạ sốt dạng sủi.', 25000.00, 'Thuốc giảm đau', FALSE, 'https://example.com/products/efferalgan.jpg');
CALL `SP_ImportNewProduct`('Panadol Extra', 'GSK', 'Giảm đau nhanh, hạ sốt hiệu quả.', 18000.00, 'Thuốc giảm đau', FALSE, 'https://example.com/products/panadol_extra.jpg');
CALL `SP_ImportNewProduct`('Ibuprofen 400mg', 'Stellapharm', 'Thuốc chống viêm, giảm đau.', 22000.00, 'Thuốc giảm đau', FALSE, 'https://example.com/products/ibuprofen.jpg');
CALL `SP_ImportNewProduct`('Aspirin 500mg', 'Bayer', 'Thuốc giảm đau, chống viêm.', 30000.00, 'Thuốc giảm đau', FALSE, 'https://example.com/products/aspirin.jpg');

-- Kháng sinh
CALL `SP_ImportNewProduct`('Amoxicillin 250mg', 'Domesco', 'Kháng sinh phổ rộng.', 30000.00, 'Kháng sinh', TRUE, 'https://example.com/products/amoxicillin.jpg');
CALL `SP_ImportNewProduct`('Augmentin 625mg', 'GSK', 'Kháng sinh kết hợp Amoxicillin và Clavulanate.', 120000.00, 'Kháng sinh', TRUE, 'https://example.com/products/augmentin.jpg');
CALL `SP_ImportNewProduct`('Cephalexin 500mg', 'Imexpharm', 'Kháng sinh thế hệ 1.', 45000.00, 'Kháng sinh', TRUE, 'https://example.com/products/cephalexin.jpg');
CALL `SP_ImportNewProduct`('Erythromycin 250mg', 'DHG Pharma', 'Kháng sinh macrolide.', 35000.00, 'Kháng sinh', TRUE, 'https://example.com/products/erythromycin.jpg');
CALL `SP_ImportNewProduct`('Clindamycin 150mg', 'Hasan Dermapharm', 'Kháng sinh lincosamide.', 55000.00, 'Kháng sinh', TRUE, 'https://example.com/products/clindamycin.jpg');

-- Vitamin & Thực phẩm chức năng
CALL `SP_ImportNewProduct`('Vitamin C 1000mg', 'Bayer', 'Bổ sung Vitamin C tăng cường sức đề kháng.', 80000.00, 'Vitamin', FALSE, 'https://example.com/products/vitaminc.jpg');
CALL `SP_ImportNewProduct`('Vitamin Tổng Hợp One A Day', 'Bayer', 'Hỗ trợ sức khỏe tổng thể.', 250000.00, 'Vitamin', FALSE, 'https://example.com/products/oneaday.jpg');
CALL `SP_ImportNewProduct`('Omega-3 Fish Oil', 'Puritan''s Pride', 'Hỗ trợ sức khỏe tim mạch và não bộ.', 180000.00, 'Thực phẩm chức năng', FALSE, 'https://example.com/products/omega3.jpg');
CALL `SP_ImportNewProduct`('Glucosamine 1500mg', 'Kirkland', 'Hỗ trợ khớp và sụn.', 320000.00, 'Thực phẩm chức năng', FALSE, 'https://example.com/products/glucosamine.jpg');
CALL `SP_ImportNewProduct`('Vitamin D3 2000IU', 'Nature Made', 'Bổ sung Vitamin D3.', 450000.00, 'Vitamin', FALSE, 'https://example.com/products/vitamind3.jpg');
CALL `SP_ImportNewProduct`('Vitamin B Complex', 'Blackmores', 'Vitamin B tổng hợp.', 280000.00, 'Vitamin', FALSE, 'https://example.com/products/vitaminb.jpg');
CALL `SP_ImportNewProduct`('Calcium + Vitamin D', 'Caltrate', 'Bổ sung canxi và vitamin D.', 350000.00, 'Thực phẩm chức năng', FALSE, 'https://example.com/products/calcium.jpg');

-- Chăm sóc mắt
CALL `SP_ImportNewProduct`('Thuốc nhỏ mắt V.Rohto', 'Rohto-Mentholatum', 'Giúp làm dịu và giảm mỏi mắt.', 45000.00, 'Chăm sóc mắt', FALSE, 'https://example.com/products/vrohto.jpg');
CALL `SP_ImportNewProduct`('Nước mắt nhân tạo Systane Ultra', 'Alcon', 'Giảm khô mắt, bôi trơn mắt.', 70000.00, 'Chăm sóc mắt', FALSE, 'https://example.com/products/systane.jpg');
CALL `SP_ImportNewProduct`('Thuốc nhỏ mắt Refresh', 'Allergan', 'Điều trị khô mắt.', 85000.00, 'Chăm sóc mắt', FALSE, 'https://example.com/products/refresh.jpg');

-- Vật tư y tế
CALL `SP_ImportNewProduct`('Khẩu trang y tế 4 lớp', 'Nam Anh', 'Bảo vệ khỏi bụi và vi khuẩn.', 50000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/khautrang.jpg');
CALL `SP_ImportNewProduct`('Băng gạc y tế', 'Urgo', 'Băng vết thương.', 20000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/banggac.jpg');
CALL `SP_ImportNewProduct`('Nhiệt kế điện tử', 'Omron', 'Đo nhiệt độ cơ thể.', 150000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/nhietke.jpg');
CALL `SP_ImportNewProduct`('Máy đo huyết áp', 'Omron', 'Đo huyết áp tự động.', 1200000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/maydohuyetap.jpg');
CALL `SP_ImportNewProduct`('Máy đo đường huyết', 'Accu-Chek', 'Đo đường huyết tại nhà.', 800000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/mayduonghuyết.jpg');
CALL `SP_ImportNewProduct`('Băng cá nhân Urgo', 'Urgo', 'Băng vết thương nhỏ.', 15000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/bancanhan.jpg');

-- Thuốc ho
CALL `SP_ImportNewProduct`('Siro ho Astex', 'OPC', 'Giảm ho, long đờm.', 65000.00, 'Thuốc ho', FALSE, 'https://example.com/products/astex.jpg');
CALL `SP_ImportNewProduct`('Thuốc ho Prospan', 'Engelhard', 'Thuốc ho thảo dược.', 90000.00, 'Thuốc ho', FALSE, 'https://example.com/products/prospan.jpg');
CALL `SP_ImportNewProduct`('Siro ho Bổ phế', 'Traphaco', 'Thuốc ho từ thảo dược Việt Nam.', 45000.00, 'Thuốc ho', FALSE, 'https://example.com/products/bophe.jpg');

-- Thuốc chống dị ứng
CALL `SP_ImportNewProduct`('Fexofenadine 120mg', 'Sanofi', 'Điều trị triệu chứng viêm mũi dị ứng.', 95000.00, 'Thuốc dị ứng', TRUE, 'https://example.com/products/fexofenadine.jpg');
CALL `SP_ImportNewProduct`('Loratadine 10mg', 'Stella', 'Điều trị triệu chứng dị ứng.', 25000.00, 'Thuốc dị ứng', FALSE, 'https://example.com/products/loratadine.jpg');
CALL `SP_ImportNewProduct`('Cetirizine 10mg', 'UCB Pharma', 'Thuốc chống dị ứng.', 35000.00, 'Thuốc dị ứng', FALSE, 'https://example.com/products/cetirizine.jpg');

-- Sản phẩm chăm sóc cá nhân
CALL `SP_ImportNewProduct`('Nước muối sinh lý Natri Clorid 0.9%', 'Pharma', 'Vệ sinh mũi, rửa mắt.', 10000.00, 'Chăm sóc cá nhân', FALSE, 'https://example.com/products/nuocmuoi.jpg');
CALL `SP_ImportNewProduct`('Kem đánh răng P/S Bảo vệ 12', 'Unilever', 'Bảo vệ răng miệng toàn diện.', 35000.00, 'Chăm sóc cá nhân', FALSE, 'https://example.com/products/kemdanhrang.jpg');
CALL `SP_ImportNewProduct`('Dầu gội Clear Men', 'Unilever', 'Dầu gội trị gàu cho nam.', 120000.00, 'Chăm sóc cá nhân', FALSE, 'https://example.com/products/cleardau.jpg');
CALL `SP_ImportNewProduct`('Kem dưỡng da Vaseline', 'Unilever', 'Kem dưỡng ẩm toàn thân.', 65000.00, 'Chăm sóc cá nhân', FALSE, 'https://example.com/products/vaseline.jpg');

-- Thuốc tiêu hóa
CALL `SP_ImportNewProduct`('Men tiêu hóa Enterogermina', 'Sanofi', 'Hỗ trợ tiêu hóa.', 110000.00, 'Thuốc tiêu hóa', FALSE, 'https://example.com/products/enterogermina.jpg');
CALL `SP_ImportNewProduct`('Thuốc trị đau dạ dày Maalox', 'Sanofi', 'Giảm triệu chứng khó tiêu, ợ nóng.', 85000.00, 'Thuốc tiêu hóa', FALSE, 'https://example.com/products/maalox.jpg');
CALL `SP_ImportNewProduct`('Omeprazole 20mg', 'Stada', 'Thuốc ức chế bơm proton.', 75000.00, 'Thuốc tiêu hóa', TRUE, 'https://example.com/products/omeprazole.jpg');
CALL `SP_ImportNewProduct`('Domperidone 10mg', 'Teva', 'Thuốc chống nôn.', 45000.00, 'Thuốc tiêu hóa', FALSE, 'https://example.com/products/domperidone.jpg');

-- Thuốc cảm cúm
CALL `SP_ImportNewProduct`('Thuốc nhỏ mũi Xylometazolin', 'Mediplantex', 'Giảm nghẹt mũi.', 30000.00, 'Thuốc cảm cúm', FALSE, 'https://example.com/products/xylometazolin.jpg');
CALL `SP_ImportNewProduct`('Coldflu', 'Pymepharco', 'Thuốc cảm cúm tổng hợp.', 25000.00, 'Thuốc cảm cúm', FALSE, 'https://example.com/products/coldflu.jpg');
CALL `SP_ImportNewProduct`('Tylenol Cold & Flu', 'Johnson & Johnson', 'Thuốc cảm cúm nhập khẩu.', 85000.00, 'Thuốc cảm cúm', FALSE, 'https://example.com/products/tylenol.jpg');

-- Sản phẩm chăm sóc trẻ em
CALL `SP_ImportNewProduct`('Siro Paracetamol cho trẻ em', 'Stada', 'Hạ sốt cho trẻ em.', 45000.00, 'Thuốc trẻ em', FALSE, 'https://example.com/products/paracetamol_tre.jpg');
CALL `SP_ImportNewProduct`('Vitamin D3 drops cho trẻ', 'Carlson', 'Bổ sung Vitamin D3 cho trẻ.', 280000.00, 'Thuốc trẻ em', FALSE, 'https://example.com/products/vitamind_tre.jpg');
CALL `SP_ImportNewProduct`('Tã Huggies size M', 'Kimberly-Clark', 'Tã em bé cao cấp.', 350000.00, 'Chăm sóc trẻ em', FALSE, 'https://example.com/products/huggies.jpg');

-- Sản phẩm khác
CALL `SP_ImportNewProduct`('Gel rửa tay khô Lifebuoy', 'Unilever', 'Sát khuẩn tay nhanh.', 40000.00, 'Chăm sóc cá nhân', FALSE, 'https://example.com/products/gelruatay.jpg');
CALL `SP_ImportNewProduct`('Máy xông mũi họng', 'Omron', 'Điều trị bệnh hô hấp.', 1500000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/mayxong.jpg');
CALL `SP_ImportNewProduct`('Dung dịch sát khuẩn Betadine', 'Mundipharma', 'Sát khuẩn vết thương.', 55000.00, 'Vật tư y tế', FALSE, 'https://example.com/products/betadine.jpg');
CALL `SP_ImportNewProduct`('Thuốc ngủ Melatonin', 'Nature Made', 'Hỗ trợ giấc ngủ tự nhiên.', 320000.00, 'Thực phẩm chức năng', FALSE, 'https://example.com/products/melatonin.jpg');
CALL `SP_ImportNewProduct`('Probiotics', 'Culturelle', 'Men vi sinh hỗ trợ tiêu hóa.', 450000.00, 'Thực phẩm chức năng', FALSE, 'https://example.com/products/probiotics.jpg');


-- Thêm dữ liệu tồn kho cho tất cả các chi nhánh (dồi dào hơn)
-- Cần biết product_id của các sản phẩm đã thêm ở trên. Nếu bạn chạy lại, các product_id sẽ là 1, 2, 3...
-- Giả sử product_id hiện tại là từ 1 đến 44
-- Branch 1: Chi nhánh Trung Tâm
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(1, 1, 150, 30), (1, 2, 80, 20), (1, 3, 120, 25), (1, 4, 60, 15), (1, 5, 40, 10),
(1, 6, 30, 8), (1, 7, 25, 5), (1, 8, 35, 8), (1, 9, 20, 5), (1, 10, 15, 3),
(1, 11, 200, 50), (1, 12, 70, 15), (1, 13, 90, 20), (1, 14, 50, 10), (1, 15, 120, 25),
(1, 16, 100, 20), (1, 17, 180, 40), (1, 18, 75, 15), (1, 19, 55, 12), (1, 20, 45, 10),
(1, 21, 85, 18), (1, 22, 65, 15), (1, 23, 95, 20), (1, 24, 220, 50), (1, 25, 130, 30),
(1, 26, 160, 35), (1, 27, 140, 30), (1, 28, 110, 25), (1, 29, 85, 18), (1, 30, 70, 15),
(1, 31, 90, 20), (1, 32, 120, 25), (1, 33, 100, 20), (1, 34, 80, 18), (1, 35, 150, 30),
(1, 36, 60, 12), (1, 37, 40, 8), (1, 38, 200, 45), (1, 39, 75, 15), (1, 40, 25, 5),
(1, 41, 180, 40), (1, 42, 35, 8), (1, 43, 90, 20), (1, 44, 50, 10);

-- Branch 2: Chi nhánh Gò Vấp
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(2, 1, 100, 25), (2, 2, 60, 15), (2, 3, 90, 20), (2, 4, 45, 10), (2, 5, 30, 8),
(2, 6, 20, 5), (2, 7, 18, 4), (2, 8, 25, 6), (2, 9, 15, 3), (2, 10, 12, 3),
(2, 11, 150, 40), (2, 12, 50, 12), (2, 13, 70, 15), (2, 14, 35, 8), (2, 15, 90, 20),
(2, 16, 80, 18), (2, 17, 130, 30), (2, 18, 55, 12), (2, 19, 40, 9), (2, 20, 35, 8),
(2, 21, 65, 15), (2, 22, 50, 12), (2, 23, 75, 16), (2, 24, 180, 40), (2, 25, 100, 22),
(2, 26, 120, 28), (2, 27, 110, 24), (2, 28, 85, 18), (2, 29, 65, 14), (2, 30, 55, 12),
(2, 31, 70, 16), (2, 32, 95, 20), (2, 33, 80, 17), (2, 34, 65, 14), (2, 35, 120, 26),
(2, 36, 45, 10), (2, 37, 30, 7), (2, 38, 160, 35), (2, 39, 60, 13), (2, 40, 20, 4),
(2, 41, 140, 32), (2, 42, 28, 6), (2, 43, 70, 16), (2, 44, 40, 9);

-- Branch 3: Chi nhánh Thủ Đức
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(3, 1, 120, 28), (3, 2, 70, 16), (3, 3, 100, 22), (3, 4, 50, 12), (3, 5, 35, 9),
(3, 6, 25, 6), (3, 7, 20, 5), (3, 8, 30, 7), (3, 9, 18, 4), (3, 10, 14, 3),
(3, 11, 170, 38), (3, 12, 60, 14), (3, 13, 80, 18), (3, 14, 40, 9), (3, 15, 100, 22),
(3, 16, 90, 20), (3, 17, 150, 34), (3, 18, 65, 14), (3, 19, 45, 10), (3, 20, 40, 9),
(3, 21, 75, 17), (3, 22, 60, 14), (3, 23, 85, 19), (3, 24, 200, 44), (3, 25, 110, 24),
(3, 26, 140, 32), (3, 27, 120, 26), (3, 28, 95, 21), (3, 29, 75, 17), (3, 30, 65, 14),
(3, 31, 80, 18), (3, 32, 105, 23), (3, 33, 90, 20), (3, 34, 75, 17), (3, 35, 140, 31),
(3, 36, 55, 12), (3, 37, 35, 8), (3, 38, 180, 40), (3, 39, 70, 16), (3, 40, 22, 5),
(3, 41, 160, 36), (3, 42, 32, 7), (3, 43, 80, 18), (3, 44, 45, 10);

-- Branch 4: Chi nhánh Quận 7
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(4, 1, 110, 26), (4, 2, 65, 15), (4, 3, 95, 21), (4, 4, 48, 11), (4, 5, 32, 8),
(4, 6, 22, 5), (4, 7, 19, 4), (4, 8, 28, 6), (4, 9, 16, 4), (4, 10, 13, 3),
(4, 11, 160, 36), (4, 12, 55, 13), (4, 13, 75, 17), (4, 14, 38, 9), (4, 15, 95, 21),
(4, 16, 85, 19), (4, 17, 140, 32), (4, 18, 60, 14), (4, 19, 42, 10), (4, 20, 37, 8),
(4, 21, 70, 16), (4, 22, 55, 13), (4, 23, 80, 18), (4, 24, 190, 42), (4, 25, 105, 23),
(4, 26, 130, 29), (4, 27, 115, 25), (4, 28, 90, 20), (4, 29, 70, 16), (4, 30, 60, 14),
(4, 31, 75, 17), (4, 32, 100, 22), (4, 33, 85, 19), (4, 34, 70, 16), (4, 35, 130, 29),
(4, 36, 50, 11), (4, 37, 32, 7), (4, 38, 170, 38), (4, 39, 65, 15), (4, 40, 21, 5),
(4, 41, 150, 34), (4, 42, 30, 7), (4, 43, 75, 17), (4, 44, 42, 10);

-- Branch 5: Chi nhánh Bình Thạnh
INSERT INTO `ProductStock` (`branch_id`, `product_id`, `stock_quantity`, `min_stock_level`) VALUES
(5, 1, 130, 29), (5, 2, 75, 17), (5, 3, 105, 23), (5, 4, 55, 13), (5, 5, 38, 9),
(5, 6, 28, 7), (5, 7, 22, 5), (5, 8, 32, 8), (5, 9, 20, 5), (5, 10, 16, 4),
(5, 11, 180, 40), (5, 12, 65, 15), (5, 13, 85, 19), (5, 14, 45, 10), (5, 15, 110, 24),
(5, 16, 95, 21), (5, 17, 160, 36), (5, 18, 70, 16), (5, 19, 50, 12), (5, 20, 42, 10),
(5, 21, 80, 18), (5, 22, 65, 15), (5, 23, 90, 20), (5, 24, 210, 46), (5, 25, 120, 26),
(5, 26, 150, 34), (5, 27, 130, 29), (5, 28, 100, 22), (5, 29, 80, 18), (5, 30, 70, 16),
(5, 31, 85, 19), (5, 32, 115, 25), (5, 33, 95, 21), (5, 34, 80, 18), (5, 35, 150, 34),
(5, 36, 60, 14), (5, 37, 40, 9), (5, 38, 190, 42), (5, 39, 75, 17), (5, 40, 25, 6),
(5, 41, 170, 38), (5, 42, 35, 8), (5, 43, 85, 19), (5, 44, 50, 11);

