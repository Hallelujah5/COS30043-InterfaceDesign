from app.utils.db import get_db_connection
from typing import Dict, Any, List, Optional

class PrescriptionRepository:
    # Đã sửa: 'image_url' -> 'file_path' trong tham số
    def upload_prescription(self, customer_id: int, file_path: str, notes: Optional[str]) -> int:
        """
        Ghi lại thông tin đơn thuốc mới với trạng thái 'Pending'.
        Trả về ID của đơn thuốc mới được tạo.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                sql = """
                INSERT INTO Prescriptions (
                    customer_id,
                    file_path,            -- Đã sửa: 'image_url' -> 'file_path'
                    validation_status,    -- Đã sửa: 'status' -> 'validation_status'
                    customer_notes,       -- Đã sửa: 'notes' -> 'customer_notes'
                    upload_date           -- Đã sửa: 'uploaded_at' -> 'upload_date'
                )
                VALUES (%s, %s, 'Pending', %s, NOW())
                """
                cursor.execute(sql, (customer_id, file_path, notes)) # Tham số truyền vào đã đúng
                connection.commit()
                prescription_id = cursor.lastrowid
                return prescription_id
        except Exception as e:
            print(f"Error uploading prescription: {e}")
            raise
        finally:
            connection.close()

    def validate_prescription(self, prescription_id: int, pharmacist_id: int, validation_status: str, notes: Optional[str]) -> None:
        """
        Sử dụng SP_ValidatePrescription để dược sĩ duyệt hoặc từ chối đơn thuốc.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc('SP_ValidatePrescription', (prescription_id, pharmacist_id, validation_status, notes))
                connection.commit()
        except Exception as e:
            print(f"Error validating prescription {prescription_id}: {e}")
            raise
        finally:
            connection.close()

    def get_pending_prescriptions(self) -> List[Dict[str, Any]]:
        """
        Lấy danh sách các đơn thuốc đang chờ duyệt (Pending), không cần gán cho dược sĩ cụ thể.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                sql = """
                SELECT
                    prescription_id,
                    customer_id,
                    upload_date AS uploaded_at,
                    file_path,
                    validation_status AS status,
                    pharmacist_id AS assigned_pharmacist_id,
                    validation_date,
                    customer_notes AS notes,
                    pharmacist_notes AS validation_notes
                FROM Prescriptions
                WHERE validation_status = 'Pending'
                ORDER BY upload_date ASC;
                """
                cursor.execute(sql)
                results = cursor.fetchall()
                return results
        except Exception as e:
            print(f"Error getting pending prescriptions: {e}")
            raise
        finally:
            connection.close()

    def get_pharmacist_pending_prescriptions(self, pharmacist_id: int) -> List[Dict[str, Any]]:
        """
        Lấy danh sách các đơn thuốc đang chờ xác nhận cho một dược sĩ cụ thể bằng cách gọi stored procedure SP_GetPharmacistPendingPrescriptions.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc('SP_GetPharmacistPendingPrescriptions', (pharmacist_id,))
                results = cursor.fetchall()
                return results
        except Exception as e:
            print(f"Error getting pending prescriptions for pharmacist {pharmacist_id}: {e}")
            raise
        finally:
            connection.close()

    def assign_pharmacist_to_prescription(self, prescription_id: int, pharmacist_id: int) -> None:
        """
        Sử dụng SP_AssignPrescriptionToPharmacist để gán đơn thuốc cho dược sĩ.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # Giả định p_branch_manager_id là 1 cho mục đích kiểm thử/minh họa.
                # Trong ứng dụng thực tế, giá trị này nên được lấy từ thông tin người dùng đã xác thực.
                cursor.callproc('SP_AssignPrescriptionToPharmacist', (prescription_id, pharmacist_id, 1))
                connection.commit()
        except Exception as e:
            print(f"Error assigning pharmacist {pharmacist_id} to prescription {prescription_id}: {e}")
            raise
        finally:
            connection.close()

    def get_prescription_by_id(self, prescription_id: int) -> Optional[Dict[str, Any]]:
        """
        Lấy thông tin chi tiết của một đơn thuốc dựa trên ID, ánh xạ tên cột database.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                sql = """
                SELECT
                    prescription_id,
                    customer_id,
                    upload_date AS uploaded_at,
                    file_path,
                    validation_status AS status,
                    pharmacist_id AS assigned_pharmacist_id,
                    validation_date,
                    customer_notes AS notes,
                    pharmacist_notes AS validation_notes
                FROM Prescriptions
                WHERE prescription_id = %s
                """
                cursor.execute(sql, (prescription_id,))
                result = cursor.fetchone()
                return result
        except Exception as e:
            print(f"Error fetching prescription {prescription_id}: {e}")
            raise
        finally:
            connection.close()