from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class StaffBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone_number: Optional[str] = None
    image_url: Optional[str] = None
    role: str # This should ideally be an Enum matching your DB, e.g., 'Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff'
    branch_id: Optional[int] = None

class StaffCreate(StaffBase):
    password: str

class StaffUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    image_url: Optional[str] = None
    # Role and branch_id are updated via specific endpoints/logic, not general update

class StaffRoleUpdate(BaseModel):
    role: str # This should be an Enum in a real app

class StaffAssignOrder(BaseModel):
    order_id: int
    cashier_id: int
    branch_manager_id: Optional[int] = None # Optional, for logging who assigned

class StaffNotification(BaseModel):
    notification_id: int
    message_content: str
    notification_type: str
    sent_date: datetime
    order_id: Optional[int] = None
    prescription_id: Optional[int] = None
    product_id: Optional[int] = None
    branch_id: Optional[int] = None
    is_sent: bool

    class Config:
        from_attributes = True

class Staff(StaffBase):
    staff_id: int
    is_active: bool

    class Config:
        from_attributes = True