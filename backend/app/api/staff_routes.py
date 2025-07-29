from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.services.staff_service import StaffService
from app.utils.db import get_db
from app.schemas.staff import Staff as StaffSchema, StaffCreate, StaffUpdate, StaffRoleUpdate, StaffAssignOrder, StaffNotification
from typing import List, Dict, Any

router = APIRouter(prefix="/staff", tags=["Staff"])

# Dependency to get StaffService instance
def get_staff_service() -> StaffService:
    return StaffService()

@router.post("/register", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def register_staff(
    request: StaffCreate,
    staff_service: StaffService = Depends(get_staff_service)
):
    """
    Registers a new staff member in the system. 
    """
    try:
        staff_id = staff_service.register_staff(
            request.first_name,
            request.last_name,
            request.email,
            request.phone_number,
            request.password,
            request.role,
            request.branch_id,
            request.image_url
        )
        if not staff_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to register staff, possibly duplicate email or invalid branch."
            )
        return {"staff_id": staff_id, "message": "Staff registered successfully."}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{staff_id}/activate", response_model=Dict[str, str])
async def activate_staff_account(
    staff_id: int,
    staff_service: StaffService = Depends(get_staff_service),
    db: Session = Depends(get_db)
):
    """
    Activates a staff member's account by setting is_active to TRUE. 
    """
    try:
        success = staff_service.activate_staff_account(db, staff_id)
        if success:
            return {"message": f"Staff account with ID {staff_id} activated successfully."}
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Failed to activate staff account {staff_id}.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{staff_id}/deactivate", response_model=Dict[str, str])
async def deactivate_staff_account(
    staff_id: int,
    staff_service: StaffService = Depends(get_staff_service),
    db: Session = Depends(get_db)
):
    """
    Deactivates a staff member's account by setting is_active to FALSE. 
    """
    try:
        success = staff_service.deactivate_staff_account(db, staff_id)
        if success:
            return {"message": f"Staff account with ID {staff_id} deactivated successfully."}
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Failed to deactivate staff account {staff_id}.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/assign-order-to-cashier", response_model=Dict[str, str])
async def assign_order_to_cashier(
    request: StaffAssignOrder,
    staff_service: StaffService = Depends(get_staff_service)
):
    """
    Assigns a paid order to a cashier for final review (BranchManager only). 
    """
    try:
        success = staff_service.assign_order_to_cashier(
            request.order_id,
            request.cashier_id,
            request.branch_manager_id
        )
        if success:
            return {"message": f"Order {request.order_id} assigned to cashier {request.cashier_id} successfully."}
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Failed to assign order to cashier.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{staff_id}/notifications", response_model=List[StaffNotification])
async def get_staff_notifications(
    staff_id: int,
    staff_service: StaffService = Depends(get_staff_service)
):
    """
    Retrieves notifications for a specific staff member. 
    """
    try:
        notifications = staff_service.get_staff_notifications(staff_id)
        return notifications
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{staff_id}/update-role", response_model=Dict[str, str])
async def update_staff_role(
    staff_id: int,
    request: StaffRoleUpdate,
    staff_service: StaffService = Depends(get_staff_service),
    db: Session = Depends(get_db)
):
    """
    Allows management to change a staff member's role. 
    """
    try:
        success = staff_service.update_staff_role(db, staff_id, request.role)
        if success:
            return {"message": f"Staff ID {staff_id} role updated to {request.role} successfully."}
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Failed to update role for staff {staff_id}.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/branches/{branch_id}/staff", response_model=List[StaffSchema])
async def get_staff_by_branch(
    branch_id: int,
    staff_service: StaffService = Depends(get_staff_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves a list of all staff members working at a specific branch. 
    """
    try:
        staff_members = staff_service.get_staff_by_branch(db, branch_id)
        return staff_members
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{staff_id}", response_model=StaffSchema)
async def update_staff_profile(
    staff_id: int,
    request: StaffUpdate,
    staff_service: StaffService = Depends(get_staff_service),
    db: Session = Depends(get_db)
):
    """
    Updates a staff member's general profile information (e.g., name, phone, image).
    """
    try:
        updated_staff = staff_service.update_staff_profile(
            db,
            staff_id,
            request.first_name,
            request.last_name,
            request.phone_number,
            request.image_url
        )
        return updated_staff
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")