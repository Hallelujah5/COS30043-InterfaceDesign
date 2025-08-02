-- SeedData.sql
-- Contains sample data to populate the pharmacy_db database
-- Always prioritize using Stored Procedures to insert data when possible.

-- USE `pharmacy_db`;

-- Insert data into Branches table
INSERT INTO `Branches` (`name`, `address`, `phone_number`) VALUES
('Central Branch', '123 Nguyen Hue Street, District 1, Ho Chi Minh City', '0281112222'),
('Go Vap Branch', '456 Quang Trung Street, Go Vap District, Ho Chi Minh City', '0283334444'),
('Thu Duc Branch', '789 Vo Van Ngan Street, Thu Duc City, Ho Chi Minh City', '0285556666'),
('District 7 Branch', '101 Nguyen Thi Thap Street, District 7, Ho Chi Minh City', '0287778888'),
('Binh Thanh Branch', '20 Phan Dang Luu Street, Binh Thanh District, Ho Chi Minh City', '0289990000');

-- Insert data into Staff using SP_RegisterNewStaff
-- Note: Passwords here are plain text; in a real application they should be hashed before calling SP.
-- Assume branch_id: 1=Central, 2=Go Vap, 3=Thu Duc, 4=District 7, 5=Binh Thanh

-- Branch 1: Central (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Nguyen', 'Lan Anh', 'lananh.bm@pharmacy.com', '0901234567', 'passlananh', 'BranchManager', 1, 'https://example.com/staff/lananh.jpg');
CALL `SP_RegisterNewStaff`('Tran', 'Minh', 'minh.pharma@pharmacy.com', '0907654321', 'passminh', 'Pharmacist', 1, 'https://example.com/staff/minh.jpg');
CALL `SP_RegisterNewStaff`('Le', 'Thi Mai', 'mai.cashier@pharmacy.com', '0912345678', 'passmai', 'Cashier', 1, 'https://example.com/staff/mai.jpg');
CALL `SP_RegisterNewStaff`('Pham', 'Van Hung', 'hung.warehouse@pharmacy.com', '0918765432', 'passhung', 'WarehouseStaff', 1, 'https://example.com/staff/hung.jpg');
CALL `SP_RegisterNewStaff`('Vu', 'Thi Hoa', 'hoa.cashier@pharmacy.com', '0919876543', 'passhoa', 'Cashier', 1, 'https://example.com/staff/hoa.jpg');
CALL `SP_RegisterNewStaff`('Do', 'Van Tam', 'tam.pharma@pharmacy.com', '0920987654', 'passtam', 'Pharmacist', 1, 'https://example.com/staff/tam.jpg');
CALL `SP_RegisterNewStaff`('Ngo', 'Thi Linh', 'linh.cashier@pharmacy.com', '0921098765', 'passlinh', 'Cashier', 1, 'https://example.com/staff/linh.jpg');
CALL `SP_RegisterNewStaff`('Hoang', 'Van Duc', 'duc.warehouse@pharmacy.com', '0922109876', 'passduc', 'WarehouseStaff', 1, 'https://example.com/staff/duc.jpg');
CALL `SP_RegisterNewStaff`('Ly', 'Thi Kim', 'kim.pharma@pharmacy.com', '0923210987', 'passkim', 'Pharmacist', 1, 'https://example.com/staff/kim.jpg');
CALL `SP_RegisterNewStaff`('Truong', 'Van Long', 'long.warehouse@pharmacy.com', '0924321098', 'passlong', 'WarehouseStaff', 1, 'https://example.com/staff/long.jpg');

-- Branch 2: Go Vap (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Hoang', 'Thi Yen', 'yen.bm@pharmacy.com', '0934567890', 'passyen', 'BranchManager', 2, 'https://example.com/staff/yen.jpg');
CALL `SP_RegisterNewStaff`('Vo', 'Thi Thu', 'thu.cashier@pharmacy.com', '0919998888', 'passthucash', 'Cashier', 2, 'https://example.com/staff/thu.jpg');
CALL `SP_RegisterNewStaff`('Phan', 'Van Nam', 'nam.pharma@pharmacy.com', '0935678901', 'passnam', 'Pharmacist', 2, 'https://example.com/staff/nam.jpg');
CALL `SP_RegisterNewStaff`('Dinh', 'Thi Lan', 'lan.warehouse@pharmacy.com', '0936789012', 'passlan', 'WarehouseStaff', 2, 'https://example.com/staff/lan.jpg');
CALL `SP_RegisterNewStaff`('Bui', 'Van Son', 'son.cashier@pharmacy.com', '0937890123', 'passon', 'Cashier', 2, 'https://example.com/staff/son.jpg');
CALL `SP_RegisterNewStaff`('Ta', 'Thi Huong', 'huong.pharma@pharmacy.com', '0938901234', 'passhuong', 'Pharmacist', 2, 'https://example.com/staff/huong.jpg');
CALL `SP_RegisterNewStaff`('Duong', 'Van Quan', 'quan.cashier@pharmacy.com', '0939012345', 'passquan', 'Cashier', 2, 'https://example.com/staff/quan.jpg');
CALL `SP_RegisterNewStaff`('Luu', 'Thi Nga', 'nga.warehouse@pharmacy.com', '0940123456', 'passnga', 'WarehouseStaff', 2, 'https://example.com/staff/nga.jpg');
CALL `SP_RegisterNewStaff`('Cao', 'Van Phuc', 'phuc.pharma@pharmacy.com', '0941234567', 'passphuc', 'Pharmacist', 2, 'https://example.com/staff/phuc.jpg');
CALL `SP_RegisterNewStaff`('Ma', 'Thi Oanh', 'oanh.warehouse@pharmacy.com', '0942345678', 'passoanh', 'WarehouseStaff', 2, 'https://example.com/staff/oanh.jpg');

-- Branch 3: Thu Duc (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Dang', 'Quoc Bao', 'bao.bm@pharmacy.com', '0987654321', 'passbao', 'BranchManager', 3, 'https://example.com/staff/bao.jpg');
CALL `SP_RegisterNewStaff`('Dinh', 'Van Chung', 'chung.warehouse@pharmacy.com', '0945678901', 'passchung', 'WarehouseStaff', 3, 'https://example.com/staff/chung.jpg');
CALL `SP_RegisterNewStaff`('Le', 'Thi Thuy', 'thuy.cashier@pharmacy.com', '0946789012', 'passthuy', 'Cashier', 3, 'https://example.com/staff/thuy.jpg');
CALL `SP_RegisterNewStaff`('Nguyen', 'Van Hai', 'hai.pharma@pharmacy.com', '0947890123', 'passhai', 'Pharmacist', 3, 'https://example.com/staff/hai.jpg');
CALL `SP_RegisterNewStaff`('Tran', 'Thi Van', 'van.cashier@pharmacy.com', '0948901234', 'passvan', 'Cashier', 3, 'https://example.com/staff/van.jpg');
CALL `SP_RegisterNewStaff`('Pham', 'Van Tuan', 'tuan.warehouse@pharmacy.com', '0949012345', 'passtuan', 'WarehouseStaff', 3, 'https://example.com/staff/tuan.jpg');
CALL `SP_RegisterNewStaff`('Hoang', 'Thi Ly', 'ly.pharma@pharmacy.com', '0950123456', 'passly', 'Pharmacist', 3, 'https://example.com/staff/ly.jpg');
CALL `SP_RegisterNewStaff`('Vo', 'Van Khoi', 'khoi.cashier@pharmacy.com', '0951234567', 'passkhoi', 'Cashier', 3, 'https://example.com/staff/khoi.jpg');
CALL `SP_RegisterNewStaff`('Ly', 'Thi Dieu', 'dieu.warehouse@pharmacy.com', '0952345678', 'passdieu', 'WarehouseStaff', 3, 'https://example.com/staff/dieu.jpg');
CALL `SP_RegisterNewStaff`('Bui', 'Van Hieu', 'hieu.pharma@pharmacy.com', '0953456789', 'passhieu', 'Pharmacist', 3, 'https://example.com/staff/hieu.jpg');

-- Branch 4: District 7 (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Ngo', 'Thanh Tuyen', 'tuyen.bm@pharmacy.com', '0967890123', 'passtuyen', 'BranchManager', 4, 'https://example.com/staff/tuyen.jpg');
CALL `SP_RegisterNewStaff`('Trinh', 'Dinh Tu', 'tu.cashier@pharmacy.com', '0978901234', 'passtucash', 'Cashier', 4, 'https://example.com/staff/tu.jpg');
CALL `SP_RegisterNewStaff`('Do', 'Thi Nhung', 'nhung.pharma@pharmacy.com', '0954567890', 'passnhung', 'Pharmacist', 4, 'https://example.com/staff/nhung.jpg');
CALL `SP_RegisterNewStaff`('Le', 'Van Thien', 'thien.warehouse@pharmacy.com', '0955678901', 'passthien', 'WarehouseStaff', 4, 'https://example.com/staff/thien.jpg');
CALL `SP_RegisterNewStaff`('Nguyen', 'Thi Xuan', 'xuan.cashier@pharmacy.com', '0956789012', 'passxuan', 'Cashier', 4, 'https://example.com/staff/xuan.jpg');
CALL `SP_RegisterNewStaff`('Tran', 'Van Dat', 'dat.pharma@pharmacy.com', '0957890123', 'passdat', 'Pharmacist', 4, 'https://example.com/staff/dat.jpg');
CALL `SP_RegisterNewStaff`('Pham', 'Thi Hong', 'hong.cashier@pharmacy.com', '0958901234', 'passhong', 'Cashier', 4, 'https://example.com/staff/hong.jpg');
CALL `SP_RegisterNewStaff`('Hoang', 'Van Thang', 'thang.warehouse@pharmacy.com', '0959012345', 'passthang', 'WarehouseStaff', 4, 'https://example.com/staff/thang.jpg');
CALL `SP_RegisterNewStaff`('Vo', 'Thi Mai', 'mai2.pharma@pharmacy.com', '0960123456', 'passmai2', 'Pharmacist', 4, 'https://example.com/staff/mai2.jpg');
CALL `SP_RegisterNewStaff`('Ly', 'Van Dung', 'dung.warehouse@pharmacy.com', '0961234567', 'passdung', 'WarehouseStaff', 4, 'https://example.com/staff/dung.jpg');

-- Branch 5: Binh Thanh (1 BM, 3 Cashier, 3 Pharmacist, 3 Warehouse)
CALL `SP_RegisterNewStaff`('Bui', 'Minh Phuong', 'phuong.bm@pharmacy.com', '0989012345', 'passphuong', 'BranchManager', 5, 'https://example.com/staff/phuong.jpg');
CALL `SP_RegisterNewStaff`('Truong', 'Thi An', 'an.cashier@pharmacy.com', '0962345678', 'passan', 'Cashier', 5, 'https://example.com/staff/an.jpg');
CALL `SP_RegisterNewStaff`('Dang', 'Van Thong', 'thong.pharma@pharmacy.com', '0963456789', 'passthong', 'Pharmacist', 5, 'https://example.com/staff/thong.jpg');
CALL `SP_RegisterNewStaff`('Luu', 'Thi Bich', 'bich.warehouse@pharmacy.com', '0964567890', 'passbich', 'WarehouseStaff', 5, 'https://example.com/staff/bich.jpg');
CALL `SP_RegisterNewStaff`('Cao', 'Thi Diem', 'diem.cashier@pharmacy.com', '0965678901', 'passdiem', 'Cashier', 5, 'https://example.com/staff/diem.jpg');
CALL `SP_RegisterNewStaff`('Ma', 'Van Toan', 'toan.pharma@pharmacy.com', '0966789012', 'passtoan', 'Pharmacist', 5, 'https://example.com/staff/toan.jpg');
CALL `SP_RegisterNewStaff`('Phan', 'Thi Nga', 'nga2.cashier@pharmacy.com', '0967890123', 'passnga2', 'Cashier', 5, 'https://example.com/staff/nga2.jpg');
CALL `SP_RegisterNewStaff`('Ta', 'Van Minh', 'minh2.warehouse@pharmacy.com', '0968901234', 'passminh2', 'WarehouseStaff', 5, 'https://example.com/staff/minh2.jpg');
CALL `SP_RegisterNewStaff`('Duong', 'Thi Thu', 'thu2.pharma@pharmacy.com', '0969012345', 'passthu2', 'Pharmacist', 5, 'https://example.com/staff/thu2.jpg');
CALL `SP_RegisterNewStaff`('Dinh', 'Van Lam', 'lam.warehouse@pharmacy.com', '0970123456', 'passlam', 'WarehouseStaff', 5, 'https://example.com/staff/lam.jpg');

-- Insert data into Customers using SP_RegisterNewCustomer
-- Create only 1 representative customer for in-store purchases
CALL `SP_RegisterNewCustomer`('Instore', 'Purchase', 'instore@pharmacy.com', '0987123456', 'In-store purchase', 'instore123', 'https://example.com/customer/instore.jpg');

-- Update customer information
UPDATE `Customers` SET `gender` = 'Male', `dob` = '1990-01-01' WHERE `customer_id` = 1;

-- Insert data into Products using SP_ImportNewProduct
CALL `SP_ImportNewProduct`('Paracetamol 500mg', 'Stada', 'Pain relief and fever reduction.', 15000.00, 'Pain Relief', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/Paracetamol.jpg');
CALL `SP_ImportNewProduct`('Ibuprofen 400mg', 'Stellapharm', 'Anti-inflammatory and pain relief.', 22000.00, 'Pain Relief', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/ibuprofen.jpg');
CALL `SP_ImportNewProduct`('Amoxicillin 250mg', 'Domesco', 'Broad-spectrum antibiotic.', 30000.00, 'Antibiotic', TRUE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/amoxicillin.jpg');
CALL `SP_ImportNewProduct`('Vitamin C 1000mg', 'Bayer', 'Vitamin C supplement to boost immunity.', 80000.00, 'Vitamin', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/vitaminC.jpg');
CALL `SP_ImportNewProduct`('One A Day Multivitamin', 'Bayer', 'Supports overall health.', 250000.00, 'Vitamin', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/multivi.jpg');
CALL `SP_ImportNewProduct`('Vitamin D3 2000IU', 'Nature Made', 'Vitamin D3 supplement.', 450000.00, 'Vitamin', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/vitamind3.jpg');
CALL `SP_ImportNewProduct`('V.Rohto Eye Drops', 'Rohto-Mentholatum', 'Soothes and relieves eye strain.', 45000.00, 'Eye Care', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/vrohto.jpg');
CALL `SP_ImportNewProduct`('4-Layer Medical Mask', 'Nam Anh', 'Protects against dust and bacteria.', 50000.00, 'Medical Supplies', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/khautrang.jpg');
CALL `SP_ImportNewProduct`('Astex Cough Syrup', 'OPC', 'Relieves cough and loosens phlegm.', 65000.00, 'Cough Medicine', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/siro.jpg');
CALL `SP_ImportNewProduct`('Fexofenadine 120mg', 'Sanofi', 'Treats allergic rhinitis symptoms.', 95000.00, 'Allergy Medicine', TRUE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/fexo.jpg');
CALL `SP_ImportNewProduct`('Omeprazole 20mg', 'Stada', 'Proton pump inhibitor.', 75000.00, 'Digestive Medicine', TRUE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/omepraz.jpg');
CALL `SP_ImportNewProduct`('Panadol Extra', 'GSK', 'Fast pain relief and fever reduction.', 18000.00, 'Pain Relief', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/panadol_extra.jpg');
CALL `SP_ImportNewProduct`('Omega-3 Fish Oil', 'Puritan''s Pride', 'Supports heart and brain health.', 180000.00, 'Supplements', FALSE, 'https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/omega3.jpg');
CALL `SP_ImportNewProduct`('Digital Thermometer', 'Omron', 'Measures body temperature.', 150000.
