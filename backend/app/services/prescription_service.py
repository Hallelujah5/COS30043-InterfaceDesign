from app.repositories.prescription_repository import PrescriptionRepository
from typing import Dict, Any, List, Optional
from datetime import datetime

class PrescriptionService:
    def __init__(self):
        self.prescription_repo = PrescriptionRepository()

    # Đã sửa: 'image_url' -> 'file_path' trong tham số
    def upload_prescription(self, customer_id: int, file_path: str, notes: Optional[str]) -> Dict[str, Any]:
        """
        Logic nghiệp vụ cho việc tải lên đơn thuốc.
        """
        prescription_id = self.prescription_repo.upload_prescription(customer_id, file_path, notes)
        
        prescription_info = self.prescription_repo.get_prescription_by_id(prescription_id)
        if not prescription_info:
            raise Exception("Failed to retrieve newly uploaded prescription details.")

        return {
            "message": "Prescription uploaded successfully.",
            "prescription_id": prescription_info['prescription_id'],
            "status": prescription_info['status'],
            "uploaded_at": prescription_info['uploaded_at']
        }

    def validate_prescription(self, prescription_id: int, pharmacist_id: int, validation_status: str, notes: Optional[str]) -> Dict[str, Any]:
        """
        Logic nghiệp vụ cho việc xác nhận hoặc từ chối đơn thuốc.
        """
        existing_prescription = self.prescription_repo.get_prescription_by_id(prescription_id)
        if not existing_prescription:
            raise ValueError(f"Prescription with ID {prescription_id} not found.")
        
        # Đã thêm kiểm tra role (ví dụ: chỉ Pharmacist mới có quyền validate)
        # Nếu bạn có AuthService, bạn sẽ kiểm tra quyền ở tầng route.
        # Ở đây chỉ kiểm tra trạng thái của đơn thuốc.
        if existing_prescription['status'] not in ['Pending', 'Assigned']:
            raise ValueError(f"Prescription {prescription_id} cannot be validated. Current status: {existing_prescription['status']}.")

        self.prescription_repo.validate_prescription(prescription_id, pharmacist_id, validation_status, notes)
        
        updated_prescription = self.prescription_repo.get_prescription_by_id(prescription_id)
        if not updated_prescription:
            raise Exception("Failed to retrieve updated prescription details after validation.")

        return {
            "message": f"Prescription {prescription_id} {validation_status.lower()} successfully.",
            "prescription_id": updated_prescription['prescription_id'],
            "status": updated_prescription['status'],
            "validated_by_pharmacist_id": updated_prescription['assigned_pharmacist_id'],
            "validation_notes": updated_prescription['validation_notes']
        }

    def get_pending_prescriptions(self) -> List[Dict[str, Any]]:
        """
        Logic nghiệp vụ để lấy danh sách các đơn thuốc đang chờ duyệt.
        (Không yêu cầu pharmacist_id cụ thể, lấy tất cả các đơn pending)
        """
        prescriptions_data = self.prescription_repo.get_pending_prescriptions()
        
        return [
            {
                "prescription_id": p['prescription_id'],
                "customer_id": p['customer_id'],
                "file_path": p['file_path'],
                "status": p['status'],
                "uploaded_at": p['uploaded_at'],
                "notes": p['notes'],
                "assigned_pharmacist_id": p.get('assigned_pharmacist_id'),
                "validated_by_pharmacist_id": p.get('validated_by_pharmacist_id'),
                "validation_notes": p.get('validation_notes'),
                "validation_date": p.get('validation_date')
            } for p in prescriptions_data
        ]

    def get_pharmacist_pending_prescriptions(self, pharmacist_id: int) -> List[Dict[str, Any]]:
        """
        Logic nghiệp vụ để lấy danh sách các đơn thuốc đang chờ xác nhận cho một dược sĩ cụ thể.
        """
        prescriptions_data = self.prescription_repo.get_pharmacist_pending_prescriptions(pharmacist_id)
        
        return [
            {
                "prescription_id": p['prescription_id'],
                "customer_id": p['customer_id'],
                "customer_first_name": p['customer_first_name'],
                "customer_last_name": p['customer_last_name'],
                "upload_date": p['upload_date'],
                "file_path": p['file_path'],
                "validation_status": p['validation_status'],
                "customer_notes": p['customer_notes'],
                "pharmacist_notes": p['pharmacist_notes']
            } for p in prescriptions_data
        ]

    def assign_pharmacist(self, prescription_id: int, pharmacist_id: int) -> Dict[str, Any]:
        """
        Logic nghiệp vụ để gán đơn thuốc cho dược sĩ.
        """
        existing_prescription = self.prescription_repo.get_prescription_by_id(prescription_id)
        if not existing_prescription:
            raise ValueError(f"Prescription with ID {prescription_id} not found.")
        
        if existing_prescription['status'] not in ['Pending']:
            raise ValueError(f"Prescription {prescription_id} cannot be assigned. Current status: {existing_prescription['status']}. Only 'Pending' prescriptions can be assigned.")
        
        self.prescription_repo.assign_pharmacist_to_prescription(prescription_id, pharmacist_id)
        
        updated_prescription = self.prescription_repo.get_prescription_by_id(prescription_id)
        if not updated_prescription:
            raise Exception("Failed to retrieve updated prescription details after assignment.")

        return {
            "message": f"Prescription {prescription_id} assigned to pharmacist {pharmacist_id} successfully.",
            "prescription_id": updated_prescription['prescription_id'],
            "assigned_pharmacist_id": updated_prescription['assigned_pharmacist_id']
        }