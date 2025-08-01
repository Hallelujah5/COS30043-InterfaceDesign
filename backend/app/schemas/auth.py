from pydantic import BaseModel, EmailStr
from typing import Optional

class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    # might consider adding a 'role' field here if login is strictly separated by role
    # e.g., role: Optional[str] = None # 'customer' or 'staff'
    # Or have separate login endpoints for staff and customer, which is often cleaner.

class LoginResponse(BaseModel):
    user_id: int
    last_name: Optional[str] = None
    email: EmailStr
    role: str
    message: str
    has_prescription: Optional[bool] = None
    
    access_token: str
    token_type: str = "bearer"

    class Config:
        from_attributes = True