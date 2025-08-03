from sqlalchemy import Column, Integer, String, Enum, Date, DateTime, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .base import Base 

class Customer(Base):
    __tablename__ = 'Customers'
    

    customer_id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    gender = Column(Enum('Male', 'Female'))
    dob = Column(Date)
    email = Column(String(255), nullable=False, unique=True)
    phone_number = Column(String(20))
    address = Column(String(255))
    image_url = Column(String(255))
    registration_date = Column(DateTime, default=func.now())
    is_active = Column(Boolean, default=True)
    password_hash = Column(String(255), nullable=False)
    has_prescription = Column(Boolean, default=False)

    # Relationships
    orders = relationship("Order", back_populates="customer")
    prescriptions = relationship("Prescription", back_populates="customer")
    notifications = relationship("Notification", back_populates="customer")
    
    
    likes = relationship("ProductLike", back_populates="customer") 

    def __repr__(self):
        return f"<Customer(id={self.customer_id}, name='{self.first_name} {self.last_name}')>"
