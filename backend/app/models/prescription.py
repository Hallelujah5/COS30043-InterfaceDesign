# app/models/prescription.py
from sqlalchemy import Column, Integer, String, DateTime, Enum, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Prescription(Base):
    __tablename__ = 'Prescriptions'
    __table_args__ = {'schema': 'pharmacy_db'}

    prescription_id = Column(Integer, primary_key=True, autoincrement=True)
    customer_id = Column(Integer, ForeignKey('pharmacy_db.Customers.customer_id', ondelete='CASCADE'), nullable=False)
    upload_date = Column(DateTime, default=func.now())
    file_path = Column(String(255))
    validation_status = Column(Enum('Pending', 'Approved', 'Rejected'), default='Pending')
    pharmacist_id = Column(Integer, ForeignKey('pharmacy_db.Staff.staff_id', ondelete='SET NULL'))
    validation_date = Column(DateTime)
    customer_notes = Column(Text)
    pharmacist_notes = Column(Text)

    # Relationships
    customer = relationship("Customer", back_populates="prescriptions")
    pharmacist = relationship("Staff", foreign_keys=[pharmacist_id], back_populates="prescriptions_validated")
    order = relationship("Order", back_populates="prescription", uselist=False) # One-to-one with Order
    notifications = relationship("Notification", back_populates="prescription")

    def __repr__(self):
        return f"<Prescription(id={self.prescription_id}, status='{self.validation_status}', customer_id={self.customer_id})>"  