from sqlalchemy import Column, Integer, String, Text, DECIMAL, Boolean
from sqlalchemy.orm import relationship
from .base import Base 

class Product(Base):
    __tablename__ = 'Products'


    product_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False, unique=True)
    manufacturer = Column(String(255))
    description = Column(Text)
    price = Column(DECIMAL(10, 2), nullable=False)
    category = Column(String(100))
    image_url = Column(String(255))
    is_prescription_required = Column(Boolean, default=False)

    
    order_items = relationship("OrderItem", back_populates="product")
    product_stock_items = relationship("ProductStock", back_populates="product")
    notifications = relationship("Notification", back_populates="product")
    
    likes = relationship("ProductLike", back_populates="product")

    def __repr__(self):
        return f"<Product(id={self.product_id}, name='{self.name}', price={self.price})>"