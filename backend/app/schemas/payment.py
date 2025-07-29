from pydantic import BaseModel
from typing import Literal, List
from decimal import Decimal
from datetime import datetime

class ProcessPaymentRequest(BaseModel):
    order_id: int
    payment_method: Literal['Cash', 'Credit Card', 'Debit Card', 'E-Wallet']

class ProcessPaymentResponse(BaseModel):
    message: str
    order_id: int
    payment_method: str

class PendingPaymentItem(BaseModel):
    payment_id: int
    order_id: int
    amount: Decimal
    payment_method: str
    transaction_status: str
    order_date: datetime
    order_total: Decimal
    order_status: str

class PendingPaymentsResponse(BaseModel):
    message: str
    customer_id: int
    pending_payments: List[PendingPaymentItem]
    total_pending_amount: Decimal