from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class DeliveriesBase(BaseModel):
    delivery_address: str
    delivery_status: str # ENUM: 'Scheduled', 'On The Way', 'Delivered', 'Cancelled'
    delivery_party: Optional[str] = None # ENUM: 'Shopee', 'Grab', 'Be', 'XanhSM'
    estimated_delivery_date: Optional[datetime] = None
    tracking_number: Optional[str] = None

class DeliveriesStatusUpdate(BaseModel):
    delivery_status: str # ENUM: 'Scheduled', 'On The Way', 'Delivered', 'Cancelled'

class Deliveries(DeliveriesBase):
    delivery_id: int

    class Config:
        from_attributes = True