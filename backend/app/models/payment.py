
from sqlalchemy import Column, Integer, DECIMAL, DateTime, Enum, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Payment(Base):
    __tablename__ = 'Payments'

    payment_id = Column(Integer, primary_key=True, autoincrement=True)
    order_id = Column(Integer, ForeignKey('Orders.order_id', ondelete='CASCADE'), nullable=False, unique=True)
    payment_date = Column(DateTime, default=func.now())
    amount = Column(DECIMAL(10, 2), nullable=False)
    payment_method = Column(Enum('Cash', 'Credit Card', 'Debit Card', 'E-Wallet'), nullable=False)
    transaction_status = Column(Enum('Pending', 'Completed', 'Failed', 'Refunded'), default='Pending')

    # Relationships
    order = relationship("Order", back_populates="payment", uselist=False)
    receipt = relationship("Receipt", back_populates="payment", uselist=False)

    def __repr__(self):
        return f"<Payment(id={self.payment_id}, order_id={self.order_id}, status='{self.transaction_status}')>"