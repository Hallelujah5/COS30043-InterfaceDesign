from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.services.receipt_service import ReceiptService
from app.utils.db import get_db
from app.schemas.receipt import Receipt as ReceiptSchema
from typing import Dict, Any

router = APIRouter(prefix="/receipts", tags=["Receipts"])

# Dependency to get ReceiptService instance
def get_receipt_service() -> ReceiptService:
    return ReceiptService()

@router.get("/{receipt_id}", response_model=ReceiptSchema)
async def get_receipt_details(
    receipt_id: int,
    receipt_service: ReceiptService = Depends(get_receipt_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves detailed information of a specific receipt.
    """
    try:
        receipt = receipt_service.get_receipt_details(db, receipt_id)
        return receipt
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")