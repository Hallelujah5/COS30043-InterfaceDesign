import os
import shutil
from fastapi import APIRouter, Depends, HTTPException, status, Path, Body, UploadFile, File, Form
from app.services.prescription_service import PrescriptionService
from typing import Optional
from app.schemas.prescription import (
    UploadPrescriptionRequest, UploadPrescriptionResponse,
    ValidatePrescriptionRequest, ValidatePrescriptionResponse,
    GetPendingPrescriptionsResponse,
    AssignPharmacistRequest, AssignPharmacistResponse,
    PrescriptionSummary, # Giữ lại nếu bạn vẫn dùng ở đâu đó
    GetPharmacistPendingPrescriptionsResponse, # Import schema mới
    PharmacistPrescriptionSummary # Import schema mới
)
from typing import List

router = APIRouter(prefix="/prescriptions", tags=["Prescriptions"])

def get_prescription_service() -> PrescriptionService:
    return PrescriptionService()


@router.post("/upload", response_model=UploadPrescriptionResponse, status_code=status.HTTP_201_CREATED)
async def upload_prescription(
    customer_id: int = Form(...),
    notes: Optional[str] = Form(None),
    file: UploadFile = File(...),
    prescription_service: PrescriptionService = Depends(get_prescription_service)
):
    try:
        ext = os.path.splitext(file.filename)[1].lower()
        if ext not in [".png", ".jpg"] or file.content_type not in ["image/png", "image/jpeg"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only .png and .jpg image files are allowed."
            )
        
        # 1. Save file to disk
        upload_dir = "app/static/prescription"
        os.makedirs(upload_dir, exist_ok=True)

        filename = file.filename
        file_path = os.path.join(upload_dir, filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # 2. Pass saved file path to service (relative path for web access)
        relative_file_path = f"http://localhost:8000/static/prescription/{filename}"
        result = prescription_service.upload_prescription(customer_id, relative_file_path, notes)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to upload prescription: {e}"
        )

@router.put("/{prescriptionId}/validate", response_model=ValidatePrescriptionResponse, status_code=status.HTTP_200_OK)
async def validate_prescription(
    prescription_id: int = Path(..., alias="prescriptionId", description="ID của đơn thuốc cần xác nhận/từ chối"),
    request: ValidatePrescriptionRequest = Body(...),
    prescription_service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Xác nhận hoặc từ chối một đơn thuốc bởi dược sĩ.
    """
    try:
        result = prescription_service.validate_prescription(
            prescription_id,
            request.pharmacist_id,
            request.validation_status,
            request.notes
        )
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND if "not found" in str(e).lower() else status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to validate prescription: {e}"
        )

@router.get("/pending-pharmacist-review", response_model=GetPendingPrescriptionsResponse, status_code=status.HTTP_200_OK)
async def get_all_pending_prescriptions(
    prescription_service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Lấy danh sách TẤT CẢ các đơn thuốc đang chờ dược sĩ xác nhận.
    API này trả về TẤT CẢ các đơn thuốc có trạng thái 'Pending'.
    """
    try:
        prescriptions = prescription_service.get_pending_prescriptions()
        return {"message": "All pending prescriptions retrieved successfully.", "prescriptions": prescriptions}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve all pending prescriptions: {e}"
        )

@router.get("/pharmacist/{pharmacistId}/pending-review", response_model=GetPharmacistPendingPrescriptionsResponse, status_code=status.HTTP_200_OK)
async def get_pharmacist_pending_prescriptions(
    pharmacist_id: int = Path(..., alias="pharmacistId", description="ID của dược sĩ để lấy đơn thuốc đang chờ xử lý"),
    prescription_service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Lấy danh sách các đơn thuốc đang chờ xác nhận được gán cho một dược sĩ cụ thể.
    """
    try:
        prescriptions = prescription_service.get_pharmacist_pending_prescriptions(pharmacist_id)
        return {"message": f"Pending prescriptions for pharmacist {pharmacist_id} retrieved successfully.", "prescriptions": prescriptions}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve pending prescriptions for pharmacist {pharmacist_id}: {e}"
        )

@router.put("/{prescriptionId}/assign-pharmacist", response_model=AssignPharmacistResponse, status_code=status.HTTP_200_OK)
async def assign_pharmacist(
    prescription_id: int = Path(..., alias="prescriptionId", description="ID của đơn thuốc cần gán"),
    request: AssignPharmacistRequest = Body(...),
    prescription_service: PrescriptionService = Depends(get_prescription_service)
):
    """
    Gán một đơn thuốc cho một dược sĩ cụ thể.
    """
    try:
        result = prescription_service.assign_pharmacist(prescription_id, request.pharmacist_id)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND if "not found" in str(e).lower() else status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to assign pharmacist to prescription: {e}"
        )