# app/models/staff.py
from sqlalchemy import Column, Integer, String, Enum, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Staff(Base):
    __tablename__ = 'Staff'
    __table_args__ = {'schema': 'pharmacy_db'}

    staff_id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    phone_number = Column(String(20))
    image_url = Column(String(255)) # Added image_url column
    password_hash = Column(String(255), nullable=False)
    role = Column(Enum('Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff'), nullable=False)
    is_active = Column(Boolean, default=True)
    branch_id = Column(Integer, ForeignKey('pharmacy_db.Branches.branch_id', ondelete='SET NULL'))

    # Relationships
    branch = relationship("Branch", back_populates="staff")
    prescriptions_validated = relationship("Prescription", foreign_keys="Prescription.pharmacist_id", back_populates="pharmacist")
    orders_handled = relationship("Order", foreign_keys="Order.cashier_id", back_populates="cashier")
    notifications = relationship("Notification", back_populates="staff")

    def __repr__(self):
        return f"<Staff(id={self.staff_id}, name='{self.first_name} {self.last_name}', role='{self.role}')>"