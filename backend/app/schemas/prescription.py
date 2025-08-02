from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Literal

# Schema cho việc tải lên đơn thuốc mới
class UploadPrescriptionRequest(BaseModel):
    customer_id: int
    # Đã sửa: 'image_url' -> 'file_path'
    file_path: str = Field(..., description="Uploaded image's URL ")
    notes: Optional[str] = Field(None, description="prescriptions's notes")

class UploadPrescriptionResponse(BaseModel):
    message: str
    prescription_id: int
    status: str # Trạng thái validation_status của đơn thuốc
    uploaded_at: datetime # Thời gian upload_date của đơn thuốc

# Schema cho việc xác nhận/từ chối đơn thuốc
class ValidatePrescriptionRequest(BaseModel):
    pharmacist_id: int
    validation_status: Literal['Approved', 'Rejected']
    notes: Optional[str] = Field(None, description="Pharmacist's notes of Approval/Rejection")

class ValidatePrescriptionResponse(BaseModel):
    message: str
    prescription_id: int
    status: str # Trạng thái validation_status của đơn thuốc sau khi validate
    validated_by_pharmacist_id: int
    validation_notes: Optional[str]

# Schema cho việc hiển thị đơn thuốc đang chờ duyệt (chung cho tất cả)
class PrescriptionSummary(BaseModel):
    prescription_id: int
    customer_id: int
    # Đã sửa: 'image_url' -> 'file_path'
    file_path: str
    status: str # Trạng thái validation_status của đơn thuốc
    uploaded_at: datetime # Thời gian upload_date của đơn thuốc
    notes: Optional[str] # customer_notes
    assigned_pharmacist_id: Optional[int]
    validated_by_pharmacist_id: Optional[int]
    validation_notes: Optional[str] # pharmacist_notes
    validation_date: Optional[datetime]

class GetPendingPrescriptionsResponse(BaseModel):
    message: str
    prescriptions: list[PrescriptionSummary]

# Schema mới cho đơn thuốc đang chờ xử lý của dược sĩ
class PharmacistPrescriptionSummary(BaseModel):
    prescription_id: int
    customer_id: int
    customer_first_name: str
    customer_last_name: str
    upload_date: datetime
    file_path: str
    validation_status: str
    customer_notes: Optional[str]
    pharmacist_notes: Optional[str]

class GetPharmacistPendingPrescriptionsResponse(BaseModel):
    message: str
    prescriptions: list[PharmacistPrescriptionSummary]

# Schema cho việc gán đơn thuốc cho dược sĩ
class AssignPharmacistRequest(BaseModel):
    pharmacist_id: int # ID của dược sĩ sẽ được gán

class AssignPharmacistResponse(BaseModel):
    message: str
    prescription_id: int
    assigned_pharmacist_id: int