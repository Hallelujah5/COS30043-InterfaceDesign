from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal

class ReceiptBase(BaseModel):
    payment_id: int
    receipt_date: datetime
    receipt_details: Optional[str] = None # Can be a string of related details e.g. "10 x Apple : 100$"

class Receipt(ReceiptBase):
    receipt_id: int

    class Config:
        from_attributes = True