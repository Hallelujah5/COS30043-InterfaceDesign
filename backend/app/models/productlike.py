
from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from .base import Base

class ProductLike(Base):
    """
    SQLAlchemy ORM model for the ProductLikes table.
    This table represents a many-to-many relationship between Customers and Products,
    indicating that a customer has 'liked' a product.
    """
    __tablename__ = "ProductLikes"

    # Composite primary key to ensure a user can only like a product once
    customer_id = Column(Integer, ForeignKey("Customers.customer_id", ondelete="CASCADE"), primary_key=True)
    product_id = Column(Integer, ForeignKey("Products.product_id", ondelete="CASCADE"), primary_key=True)
    liked_date = Column(DateTime, default=func.now())

    customer = relationship("Customer", back_populates="likes")
    product = relationship("Product", back_populates="likes")
    

