# app/models/order_item.py
from sqlalchemy import Column, Integer, DECIMAL, ForeignKey
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class OrderItem(Base):
    __tablename__ = 'OrderItems'
    __table_args__ = {'schema': 'pharmacy_db'}

    order_item_id = Column(Integer, primary_key=True, autoincrement=True)
    order_id = Column(Integer, ForeignKey('pharmacy_db.Orders.order_id', ondelete='CASCADE'), nullable=False)
    product_id = Column(Integer, ForeignKey('pharmacy_db.Products.product_id', ondelete='CASCADE'), nullable=False)
    quantity = Column(Integer, nullable=False)
    unit_price = Column(DECIMAL(10, 2), nullable=False)

    # Relationships
    order = relationship("Order", back_populates="order_items")
    product = relationship("Product", back_populates="order_items")

    def __repr__(self):
        return f"<OrderItem(id={self.order_item_id}, order_id={self.order_id}, product_id={self.product_id}, quantity={self.quantity})>"