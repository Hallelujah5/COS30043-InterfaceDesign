-- This script will delete all tables, triggers, and procedures from your database.
-- It's used to reset the database to a clean state before running the creation script.

-- Temporarily disable foreign key checks to allow dropping tables in any order.
SET FOREIGN_KEY_CHECKS = 0;

-- Drop all tables if they exist
DROP TABLE IF EXISTS `ProductLikes`;
DROP TABLE IF EXISTS `Notifications`;
DROP TABLE IF EXISTS `Receipts`;
DROP TABLE IF EXISTS `Payments`;
DROP TABLE IF EXISTS `OrderItems`;
DROP TABLE IF EXISTS `Orders`;
DROP TABLE IF EXISTS `Deliveries`;
DROP TABLE IF EXISTS `Prescriptions`;
DROP TABLE IF EXISTS `ProductStock`;
DROP TABLE IF EXISTS `Products`;
DROP TABLE IF EXISTS `Customers`;
DROP TABLE IF EXISTS `Staff`;
DROP TABLE IF EXISTS `Branches`;

-- Drop all triggers if they exist
DROP TRIGGER IF EXISTS `trg_after_order_item_insert`;
DROP TRIGGER IF EXISTS `trg_after_order_item_update`;
DROP TRIGGER IF EXISTS `trg_after_order_item_delete`;
DROP TRIGGER IF EXISTS `trg_update_order_total_amount`;
DROP TRIGGER IF EXISTS `trg_update_order_total_amount_on_update`;
DROP TRIGGER IF EXISTS `trg_update_order_total_amount_on_delete`;
DROP TRIGGER IF EXISTS `trg_after_prescription_validation`;
DROP TRIGGER IF EXISTS `trg_after_payment_completed`;
DROP TRIGGER IF EXISTS `trg_after_order_status_update_notify_customer`;
DROP TRIGGER IF EXISTS `trg_after_delivery_status_update_notify_customer`;
DROP TRIGGER IF EXISTS `trg_notify_branch_manager_on_new_prescription`;
DROP TRIGGER IF EXISTS `trg_notify_assigned_pharmacist`;
DROP TRIGGER IF EXISTS `trg_notify_assigned_cashier`;
DROP TRIGGER IF EXISTS `trg_low_stock_notify_warehouse_staff`;

-- Drop all stored procedures if they exist
DROP PROCEDURE IF EXISTS `SP_PlaceOrder`;
DROP PROCEDURE IF EXISTS `SP_ProcessPayment`;
DROP PROCEDURE IF EXISTS `SP_ValidatePrescription`;
DROP PROCEDURE IF EXISTS `SP_RestockProductStock`;
DROP PROCEDURE IF EXISTS `SP_GenerateSalesReport`;
DROP PROCEDURE IF EXISTS `SP_RegisterNewStaff`;
DROP PROCEDURE IF EXISTS `SP_RegisterNewCustomer`;
DROP PROCEDURE IF EXISTS `SP_ImportNewProduct`;
DROP PROCEDURE IF EXISTS `SP_UpdateProduct`;
DROP PROCEDURE IF EXISTS `SP_GetCustomerOrderHistory`;
DROP PROCEDURE IF EXISTS `SP_GetBranchProductStockStatus`;
DROP PROCEDURE IF EXISTS `SP_GetPharmacistPendingPrescriptions`;
DROP PROCEDURE IF EXISTS `SP_AssignPrescriptionToPharmacist`;
DROP PROCEDURE IF EXISTS `SP_AssignOrderToCashier`;
DROP PROCEDURE IF EXISTS `SP_GetCashierOrdersForCashier`;
DROP PROCEDURE IF EXISTS `SP_CancelOrder`;

-- Re-enable foreign key checks.
SET FOREIGN_KEY_CHECKS = 1;

