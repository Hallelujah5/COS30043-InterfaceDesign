
from sqlalchemy import Column, Integer, DECIMAL, DateTime, Enum, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Order(Base):
    __tablename__ = 'Orders'

    order_id = Column(Integer, primary_key=True, autoincrement=True)
    customer_id = Column(Integer, ForeignKey('Customers.customer_id', ondelete='CASCADE'), nullable=False)
    branch_id = Column(Integer, ForeignKey('Branches.branch_id', ondelete='CASCADE'), nullable=False)
    order_date = Column(DateTime, default=func.now())
    total_amount = Column(DECIMAL(10, 2), default=0.00)
    order_status = Column(Enum('Pending', 'Paid', 'Processing', 'Ready for Pickup', 'Delivered', 'Cancelled', 'Rejected-Refund'), default='Pending')
    prescription_id = Column(Integer, ForeignKey('Prescriptions.prescription_id', ondelete='SET NULL'), unique=True)
    delivery_id = Column(Integer, ForeignKey('Deliveries.delivery_id', ondelete='SET NULL'), unique=True)
    discount_amount = Column(DECIMAL(10,2), default=0.00)
    order_source = Column(Enum('In-store', 'Online'))
    cashier_id = Column(Integer, ForeignKey('Staff.staff_id', ondelete='SET NULL'))

    # Relationships
    customer = relationship("Customer", back_populates="orders")
    branch = relationship("Branch", back_populates="orders")
    prescription = relationship("Prescription", back_populates="order", uselist=False)
    delivery = relationship("Deliveries", back_populates="order", uselist=False)
    order_items = relationship("OrderItem", back_populates="order")
    payment = relationship("Payment", back_populates="order", uselist=False)
    cashier = relationship("Staff", foreign_keys=[cashier_id], back_populates="orders_handled")
    notifications = relationship("Notification", back_populates="order")

    def __repr__(self):
        return f"<Order(id={self.order_id}, customer_id={self.customer_id}, status='{self.order_status}')>"