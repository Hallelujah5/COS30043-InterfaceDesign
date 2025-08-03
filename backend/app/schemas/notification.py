
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class Notification(BaseModel):
    notification_id: int
    customer_id: Optional[int] = None
    staff_id: Optional[int] = None
    order_id: Optional[int] = None
    prescription_id: Optional[int] = None
    product_id: Optional[int] = None
    message_content: str
    notification_type: str 
    delivery_id: Optional[int] = None
    sent_date: datetime
    branch_id: Optional[int] = None
    is_sent: bool

    class Config:
        from_attributes = True 