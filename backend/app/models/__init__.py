from .base import Base
from .branch import Branch
from .staff import Staff
from .product import Product
from .customer import Customer
from .productlike import ProductLike
from .product_stock import ProductStock
from .prescription import Prescription
from .deliveries import Deliveries
from .order import Order
from .order_item import OrderItem
from .payment import Payment
from .receipt import Receipt
from .notification import Notification
# from sqlalchemy.orm import relationship


# # Bind AFTER all imports
# Customer.likes = relationship("ProductLike", back_populates="customer")
# ProductLike.customer = relationship("Customer", back_populates="likes")

# Product.likes = relationship("ProductLike", back_populates="product")
# ProductLike.product = relationship("Product", back_populates="likes")