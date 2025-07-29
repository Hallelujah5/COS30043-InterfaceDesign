# app/models/delivery.py
from sqlalchemy import Column, Integer, String, Enum, DateTime
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Deliveries(Base):
    __tablename__ = 'Deliveries'
    __table_args__ = {'schema': 'pharmacy_db'}

    delivery_id = Column(Integer, primary_key=True, autoincrement=True)
    delivery_address = Column(String(255), nullable=False)
    delivery_status = Column(Enum('Scheduled', 'On The Way', 'Delivered', 'Cancelled'), default='Scheduled')
    delivery_party = Column(Enum('Shopee', 'Grab', 'Be', 'XanhSM'))
    estimated_delivery_date = Column(DateTime)
    tracking_number = Column(String(100))

    # Relationships
    order = relationship("Order", back_populates="delivery", uselist=False) # One-to-one with Order
    notifications = relationship("Notification", back_populates="delivery")

    def __repr__(self):
        return f"<Delivery(id={self.delivery_id}, status='{self.delivery_status}')>"