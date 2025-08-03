
from sqlalchemy import Column, Integer, Text, Enum, DateTime, Boolean, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base # Corrected relative import

class Notification(Base):
    __tablename__ = 'Notifications'
    

    notification_id = Column(Integer, primary_key=True, autoincrement=True)
    customer_id = Column(Integer, ForeignKey('Customers.customer_id', ondelete='CASCADE'))
    staff_id = Column(Integer, ForeignKey('Staff.staff_id', ondelete='CASCADE'))
    order_id = Column(Integer, ForeignKey('Orders.order_id', ondelete='CASCADE'))
    prescription_id = Column(Integer, ForeignKey('Prescriptions.prescription_id', ondelete='CASCADE'))
    product_id = Column(Integer, ForeignKey('Products.product_id', ondelete='CASCADE'))
    message_content = Column(Text, nullable=False)
    notification_type = Column(Enum('Order Status', 'Prescription Validation', 'Promotion', 'Product Stock Alert', 'System Message', 'Delivery Status'), nullable=False)
    delivery_id = Column(Integer, ForeignKey('Deliveries.delivery_id', ondelete='SET NULL'))
    sent_date = Column(DateTime, default=func.now())
    branch_id = Column(Integer, ForeignKey('Branches.branch_id', ondelete='SET NULL'))
    is_sent = Column(Boolean, default=False)
    

    # Relationships
    customer = relationship("Customer", back_populates="notifications")
    staff = relationship("Staff", back_populates="notifications")
    order = relationship("Order", back_populates="notifications")
    prescription = relationship("Prescription", back_populates="notifications")
    product = relationship("Product", back_populates="notifications")
    delivery = relationship("Deliveries", back_populates="notifications")
    branch = relationship("Branch", back_populates="notifications")

    def __repr__(self):
        return f"<Notification(id={self.notification_id}, type='{self.notification_type}', sent={self.is_sent})>"