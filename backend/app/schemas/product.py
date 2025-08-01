# app/schemas/product.py
from pydantic import BaseModel
from typing import Optional, List

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
    like_count: int = 0

    class Config:
        from_attributes = True 

class LikedProduct(BaseModel):
    product_id: int
    
    
class PaginatedProductResponse(BaseModel):
    total_items: int
    total_pages: int
    current_page: int
    items: List[Product]