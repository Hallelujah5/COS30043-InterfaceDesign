
from sqlalchemy import Column, Integer, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from app.utils.db import Base

class ProductLike(Base):
    """
    SQLAlchemy ORM model for the ProductLikes table.
    This table represents a many-to-many relationship between Customers and Products,
    indicating that a customer has 'liked' a product.
    """
    __tablename__ = "ProductLikes"
    __table_args__ = {'schema': 'pharmacy_db'}

    # Composite primary key to ensure a user can only like a product once
    customer_id = Column(Integer, ForeignKey("pharmacy_db.Customers.customer_id", ondelete="CASCADE"), primary_key=True)
    product_id = Column(Integer, ForeignKey("pharmacy_db.Products.product_id", ondelete="CASCADE"), primary_key=True)
    
    # Timestamp for when the like occurred
    liked_date = Column(DateTime, default=func.now())

    # Relationships to easily access related Customer and Product objects
    customer = relationship("Customer")
    product = relationship("Product")

