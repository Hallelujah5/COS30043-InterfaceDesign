# app/repositories/product_like_repository.py
from sqlalchemy.orm import Session
from sqlalchemy import func, exists
from app.models.productlike import ProductLike
from typing import Optional, List

class ProductLikeRepository:
    def get_like(self, db: Session, customer_id: int, product_id: int) -> Optional[ProductLike]:
        """
        Retrieves a specific like record by customer_id and product_id.
        """
        return db.query(ProductLike).filter_by(customer_id=customer_id, product_id=product_id).first()

    def like_product(self, db: Session, customer_id: int, product_id: int) -> ProductLike:
        """
        Creates a new 'like' record in the database.
        """
        db_like = ProductLike(customer_id=customer_id, product_id=product_id)
        db.add(db_like)
        db.commit()
        db.refresh(db_like)
        return db_like

    def unlike_product(self, db: Session, customer_id: int, product_id: int) -> bool:
        """
        Deletes a 'like' record from the database.
        Returns True if a record was deleted, False otherwise.
        """
        db_like = self.get_like(db, customer_id, product_id)
        if db_like:
            db.delete(db_like)
            db.commit()
            return True
        return False

    def get_like_count_for_product(self, db: Session, product_id: int) -> int:
        """
        Counts the total number of likes for a specific product.
        """
        return db.query(func.count(ProductLike.product_id)).filter(ProductLike.product_id == product_id).scalar() or 0

    def check_if_user_liked_product(self, db: Session, customer_id: int, product_id: int) -> bool:
        """
        Checks if a specific user has already liked a specific product.
        Returns True if the like exists, False otherwise.
        """
        return db.query(exists().where(ProductLike.customer_id == customer_id, ProductLike.product_id == product_id)).scalar()

    def get_likes_by_customer_id(self, db: Session, customer_id: int) -> List[ProductLike]:
        """
        Retrieves all like records for a specific customer.
        """
        return db.query(ProductLike).filter(ProductLike.customer_id == customer_id).all()
    
    def get_like_counts_for_products(self, db: Session, product_ids: List[int]) -> List[tuple]:
        """
        Efficiently counts the total number of likes for a list of product IDs.
        Returns a list of tuples, e.g., [(product_id, like_count), ...].
        """
        if not product_ids:
            return []
        
        return (
            db.query(ProductLike.product_id, func.count(ProductLike.product_id))
            .filter(ProductLike.product_id.in_(product_ids))
            .group_by(ProductLike.product_id)
            .all()
        )