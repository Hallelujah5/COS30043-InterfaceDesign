# app/models/branch.py
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Branch(Base):
    __tablename__ = 'Branches'
    __table_args__ = {'schema': 'pharmacy_db'}

    branch_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False, unique=True)
    address = Column(String(255), nullable=False)
    phone_number = Column(String(20))

    # Relationships
    staff = relationship("Staff", back_populates="branch")
    orders = relationship("Order", back_populates="branch")
    product_stock_items = relationship("ProductStock", back_populates="branch")
    notifications = relationship("Notification", back_populates="branch")

    def __repr__(self):
        return f"<Branch(id={self.branch_id}, name='{self.name}')>"