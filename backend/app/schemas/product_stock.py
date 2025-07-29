from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ProductStockBase(BaseModel):
    branch_id: int
    product_id: int
    stock_quantity: int
    min_stock_level: int
    last_updated: datetime

class ProductStockUpdateMinStock(BaseModel):
    branch_id: int
    product_id: int
    min_stock_level: int

class ProductStockRestock(BaseModel):
    branch_id: int
    product_id: int
    quantity_to_add: int

class ProductStockStatus(BaseModel):
    product_id: int
    product_name: str
    category: Optional[str] = None
    stock_quantity: int
    min_stock_level: int
    last_updated: datetime
    stock_status_alert: str # 'Dưới ngưỡng' or 'Đủ'

    class Config:
        from_attributes = True

class ProductStock(BaseModel):
    branch_id: int
    product_id: int
    stock_quantity: int
    min_stock_level: int
    last_updated: datetime

    class Config:
        from_attributes = True