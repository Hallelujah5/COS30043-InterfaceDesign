from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Optional
from decimal import Decimal

class SalesReportRequest(BaseModel):
    branch_id: int
    start_date: datetime
    end_date: datetime

class SalesReportItem(BaseModel):
    product_name: str
    total_quantity_sold: int
    total_revenue: Decimal

    class Config:
        from_attributes = True # Enable ORM mode

class ProductDemandReportRequest(BaseModel):
    start_date: datetime
    end_date: datetime
    limit: int = Field(10, gt=0, description="Number of top products to return")

class ProductDemandReportItem(BaseModel):
    product_id: int
    product_name: str
    total_quantity_ordered: int
    total_revenue: Decimal

    class Config:
        from_attributes = True # Enable ORM mode