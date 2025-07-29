from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from pydantic import BaseModel 
from datetime import date # Keep date for dob in CustomerUpdate
from app.services.customer_service import CustomerService
from app.utils.db import get_db
# Import the Pydantic schemas
from app.schemas.customer import Customer as CustomerSchema, CustomerCreate, CustomerUpdate
from app.schemas.notification import Notification as NotificationSchema # Import Notification schema
from typing import List, Dict, Any, Optional

router = APIRouter(prefix="/customers", tags=["Customers"])

# Pydantic model for password change (can be placed in a common schemas file or kept here)
class PasswordChange(BaseModel):
    old_password: str
    new_password: str

# Dependency to get CustomerService instance
def get_customer_service() -> CustomerService:
    return CustomerService()

@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register_customer(
    request: CustomerCreate, # Use Pydantic CustomerCreate for request body
    customer_service: CustomerService = Depends(get_customer_service)
):
    """
    Registers a new customer in the system.
    """
    try:
        customer_id = customer_service.register_customer(
            request.first_name,
            request.last_name,
            request.email,
            request.phone_number,
            request.address,
            request.password,
            request.image_url
        )
        if not customer_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to register customer, possibly duplicate email."
            )
        return {"customer_id": customer_id, "message": "Customer registered successfully."}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{customer_id}/orders", response_model=List[Dict[str, Any]])
async def get_customer_orders(
    customer_id: int,
    customer_service: CustomerService = Depends(get_customer_service)
):
    """
    Retrieves the order history for a specific customer.
    """
    try:
        order_history = customer_service.get_customer_order_history(customer_id)
        # SP_GetCustomerOrderHistory should return an empty list if no orders, or customer not found
        return order_history
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{customer_id}", response_model=CustomerSchema) # Use Pydantic CustomerSchema for response
async def get_customer_details(
    customer_id: int,
    customer_service: CustomerService = Depends(get_customer_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves detailed information of a customer.
    """
    try:
        customer = customer_service.get_customer_profile(customer_id, db)
        return customer # FastAPI will automatically convert the SQLAlchemy ORM model to Pydantic schema
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{customer_id}", response_model=CustomerSchema) # Use Pydantic CustomerSchema for response
async def update_customer_info(
    customer_id: int,
    request: CustomerUpdate, # Use Pydantic CustomerUpdate for request body
    customer_service: CustomerService = Depends(get_customer_service),
    db: Session = Depends(get_db)
):
    """
    Updates a customer's profile information (e.g., address, phone number).
    """
    try:
        updated_customer = customer_service.update_customer_profile(
            db,
            customer_id,
            request.first_name,
            request.last_name,
            request.gender,
            request.dob.strftime('%Y-%m-%d') if request.dob else None,
            request.phone_number,
            request.address,
            request.image_url,
            request.email
        )
        return updated_customer
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{customer_id}/password", response_model=dict)
async def change_customer_password(
    customer_id: int,
    request: PasswordChange,
    customer_service: CustomerService = Depends(get_customer_service),
    db: Session = Depends(get_db)
):
    """
    Updates the customer's password after authenticating the old password.
    """
    try:
        success = customer_service.change_customer_password(
            db, customer_id, request.old_password, request.new_password
        )
        if success:
            return {"message": "Password updated successfully."}
        else:
            # This case might be covered by ValueError from service if old password is incorrect
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Failed to change password.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{customer_id}/prescriptions", response_model=List[Dict[str, Any]])
async def get_customer_prescriptions(
    customer_id: int,
    customer_service: CustomerService = Depends(get_customer_service)
):
    """
    Retrieves all prescriptions uploaded by a customer.
    """
    try:
        prescriptions = customer_service.get_customer_prescriptions(customer_id)
        return prescriptions
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{customer_id}/notifications", response_model=List[NotificationSchema]) # New endpoint
async def get_customer_notifications(
    customer_id: int,
    customer_service: CustomerService = Depends(get_customer_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves all notifications for a specific customer.
    """
    try:
        notifications = customer_service.get_customer_notifications(db, customer_id)
        # FastAPI will automatically convert the list of SQLAlchemy ORM Notification models
        # to a list of Pydantic NotificationSchema models.
        return notifications
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")