from pydantic import BaseModel, EmailStr
from datetime import datetime, date
from typing import Optional, List  
from .product_like import ProductLike as ProductLikeSchema 

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
    
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    gender: Optional[str] = None
    dob: Optional[date] = None # Date type for date of birth
    phone_number: Optional[str] = None
    address: Optional[str] = None
    email: Optional[EmailStr] = None
    image_url: Optional[str] = None

class Customer(CustomerBase):
    customer_id: int
    registration_date: datetime
    is_active: bool
    has_prescription: bool

    likes: List[ProductLikeSchema] = []

    class Config:
        from_attributes = True