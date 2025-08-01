from pydantic import BaseModel
from datetime import datetime
from .product import Product as ProductSchema 

class ProductLikeBase(BaseModel):
    customer_id: int
    product_id: int

class ProductLikeCreate(ProductLikeBase):
    pass

class ProductLike(ProductLikeBase):
    liked_date: datetime

    class Config:
        from_attributes = True


class ProductWithLikeInfo(ProductSchema):
    like_count: int = 0
    user_has_liked: bool = False
