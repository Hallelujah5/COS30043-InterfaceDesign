# app/services/product_like_service.py
from sqlalchemy.orm import Session
from app.repositories.product_like_repository import ProductLikeRepository
from app.repositories.product_repository import ProductRepository # Assuming you have a ProductRepository
from app.models.productlike import ProductLike
from app.schemas.product import LikedProduct 
from typing import List

class ProductLikeService:
    def __init__(self):
        self.like_repo = ProductLikeRepository()
        self.product_repo = ProductRepository() # To check if product exists

    def like_product(self, db: Session, customer_id: int, product_id: int) -> ProductLike:
        """
        Business logic to like a product.
        """
        # 1. Check if the product exists
        product = self.product_repo.get_product_by_id(db, product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found.")

        # 2. Check if the user has already liked this product
        existing_like = self.like_repo.get_like(db, customer_id, product_id)
        if existing_like:
            raise ValueError("You have already liked this product.")

        # 3. Create the like
        return self.like_repo.like_product(db, customer_id, product_id)

    def unlike_product(self, db: Session, customer_id: int, product_id: int) -> bool:
        """
        Business logic to unlike a product.
        """
        # 1. Check if the product exists (optional, but good for consistency)
        product = self.product_repo.get_product_by_id(db, product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found.")
        
        # 2. Attempt to remove the like
        success = self.like_repo.unlike_product(db, customer_id, product_id)
        if not success:
            raise ValueError("You have not liked this product, so you cannot unlike it.")
            
        return success

    def get_likes_by_customer(self, db: Session, customer_id: int) -> List[LikedProduct]:
        """
        Business logic to get all products liked by a customer.
        """
        likes = self.like_repo.get_likes_by_customer_id(db, customer_id)
        # We only need to return the product_id, so we map it to our schema
        return [LikedProduct(product_id=like.product_id) for like in likes]