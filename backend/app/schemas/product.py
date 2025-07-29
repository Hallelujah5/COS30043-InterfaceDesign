# app/schemas/product.py
from pydantic import BaseModel
from typing import Optional

class ProductBase(BaseModel):
    name: str
    manufacturer: Optional[str] = None
    description: Optional[str] = None
    price: float
    category: Optional[str] = None
    is_prescription_required: bool = False
    image_url: Optional[str] = None # Added image_url

class Product(ProductBase):
    product_id: int

    class Config:
        from_attributes = True 