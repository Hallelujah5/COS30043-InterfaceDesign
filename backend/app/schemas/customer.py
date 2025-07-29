from pydantic import BaseModel, EmailStr
from datetime import datetime, date
from typing import Optional

class CustomerBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone_number: Optional[str] = None
    address: Optional[str] = None
    image_url: Optional[str] = None

class CustomerCreate(CustomerBase):
    password: str

class CustomerUpdate(CustomerBase):
    # For updating, all fields are optional
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    gender: Optional[str] = None
    dob: Optional[date] = None # Date type for date of birth
    phone_number: Optional[str] = None
    address: Optional[str] = None
    email: Optional[EmailStr] = None
    image_url: Optional[str] = None # Added image_url

class Customer(CustomerBase):
    customer_id: int
    registration_date: datetime
    is_active: bool
    has_prescription: bool

    class Config:
        from_attributes = True