from pydantic import BaseModel
from datetime import datetime, date
from typing import List, Optional, Dict, Any

# Pydantic model for individual items within an order
class OrderItemDetails(BaseModel):
    product_id: int
    quantity: int

# Pydantic model for placing a new order
class OrderPlace(BaseModel):
    customer_id: int
    branch_id: int
    product_details: List[OrderItemDetails] # A list of items with product_id and quantity
    prescription_id: Optional[int] = None
    delivery_address: Optional[str] = None
    delivery_party: Optional[str] = None # Assuming this maps to ENUM in DB ('Shopee', 'Grab', etc.)
    estimated_delivery_date: Optional[datetime] = None
    tracking_number: Optional[str] = None
    discount_amount: float = 0.0
    order_source: str # 'In-store' or 'Online'

# Pydantic model for updating order status
class OrderStatusUpdate(BaseModel):
    status: str # Maps to ENUM in DB ('Pending', 'Paid', 'Processing', etc.)
    # staff_id: int # Optional: could be added if you want to track who updated it

# Pydantic model for displaying full order details (response model)
class Order(BaseModel):
    order_id: int
    customer_id: int
    branch_id: int
    order_date: datetime
    total_amount: float
    order_status: str
    prescription_id: Optional[int] = None
    delivery_id: Optional[int] = None
    discount_amount: float
    order_source: str
    cashier_id: Optional[int] = None

    class Config:
        from_attributes = True

# Pydantic model for Order Item details within an Order detail response
class OrderItem(BaseModel):
    order_item_id: int
    order_id: int
    product_id: int
    quantity: int
    unit_price: float

    class Config:
        from_attributes = True

# Pydantic model for detailed order response including items
class DetailedOrderResponse(Order):
    order_items: List[OrderItem] = []
    # Add other related details if fetched (e.g., Delivery, Prescription)
    delivery_address: Optional[str] = None
    delivery_status: Optional[str] = None
    delivery_party: Optional[str] = None
    estimated_delivery_date: Optional[datetime] = None
    tracking_number: Optional[str] = None
    prescription_file_path: Optional[str] = None
    prescription_validation_status: Optional[str] = None

    class Config:
        from_attributes = True

# Schema for Cashier Review Item (individual product in an order)
class CashierReviewItem(BaseModel):
    order_item_id: int
    product_id: int
    product_name: str
    quantity: int
    unit_price: float
    is_prescription_required: bool

    class Config:
        from_attributes = True

# Schema for Cashier Order Info, now including its specific items
class CashierOrderInfo(BaseModel):
    order_id: int
    customer_id: int
    customer_first_name: str
    customer_last_name: str
    order_date: datetime
    total_amount: float
    order_status: str
    prescription_id: Optional[int] = None
    prescription_file_path: Optional[str] = None
    order_items: List[CashierReviewItem] = [] # Added list of items specific to this order

    class Config:
        from_attributes = True

# Schema for the full cashier review response (list of orders, each with its items)
class CashierOrdersReviewResponse(BaseModel):
    orders: List[CashierOrderInfo] # Renamed from orders_info for clarity and simplicity

    class Config:
        from_attributes = True

# Schema for daily order summary
class DailyOrderSummary(BaseModel):
    order_date: date
    total_orders: int
    total_revenue: float