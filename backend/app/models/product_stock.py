
from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base 

class ProductStock(Base):
    __tablename__ = 'ProductStock'

    branch_id = Column(Integer, ForeignKey('Branches.branch_id', ondelete='CASCADE'), primary_key=True)
    product_id = Column(Integer, ForeignKey('Products.product_id', ondelete='CASCADE'), primary_key=True)
    stock_quantity = Column(Integer, default=0)
    min_stock_level = Column(Integer, default=10)
    last_updated = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationships
    branch = relationship("Branch", back_populates="product_stock_items")
    product = relationship("Product", back_populates="product_stock_items")

    def __repr__(self):
        return f"<ProductStock(branch_id={self.branch_id}, product_id={self.product_id}, stock={self.stock_quantity})>"