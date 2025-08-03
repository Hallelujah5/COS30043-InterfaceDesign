
from sqlalchemy import Column, Integer, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base 

class Receipt(Base):
    __tablename__ = 'Receipts'


    receipt_id = Column(Integer, primary_key=True, autoincrement=True)
    payment_id = Column(Integer, ForeignKey('Payments.payment_id', ondelete='CASCADE'), nullable=False, unique=True)
    receipt_date = Column(DateTime, default=func.now())
    receipt_details = Column(Text)

    # Relationships
    payment = relationship("Payment", back_populates="receipt", uselist=False)

    def __repr__(self):
        return f"<Receipt(id={self.receipt_id}, payment_id={self.payment_id})>"