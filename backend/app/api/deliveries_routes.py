from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.services.deliveries_service import DeliveriesService
from app.utils.db import get_db
from app.schemas.deliveries import Deliveries as DeliveriesSchema, DeliveriesStatusUpdate
from typing import List, Dict, Any

router = APIRouter(prefix="/deliveries", tags=["Deliveries"])

# Dependency to get DeliveryService instance
def get_delivery_service() -> DeliveriesService:
    return DeliveriesService()

@router.get("/{delivery_id}", response_model=DeliveriesSchema)
async def get_delivery_details(
    delivery_id: int,
    delivery_service: DeliveriesService = Depends(get_delivery_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves detailed information about a specific delivery.
    """
    try:
        delivery = delivery_service.get_delivery_details(db, delivery_id)
        return delivery
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{delivery_id}/status", response_model=Dict[str, str])
async def update_delivery_status(
    delivery_id: int,
    request: DeliveriesStatusUpdate,
    delivery_service: DeliveriesService = Depends(get_delivery_service),
    db: Session = Depends(get_db)
):
    """
    Updates the delivery status of a specific delivery (e.g., 'On The Way', 'Delivered').
    """
    try:
        success = delivery_service.update_delivery_status(db, delivery_id, request.delivery_status)
        if success:
            return {"message": f"Delivery ID {delivery_id} status updated to {request.delivery_status} successfully."}
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Failed to update status for delivery {delivery_id}.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")