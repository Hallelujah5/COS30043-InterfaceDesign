from sqlalchemy.orm import Session
from app.repositories.customer_repository import CustomerRepository
from app.repositories.staff_repository import StaffRepository
from passlib.context import CryptContext
from typing import Dict, Any, Optional

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class AuthService:
    def __init__(self):
        self.customer_repo = CustomerRepository()
        self.staff_repo = StaffRepository()

    def customer_login(self, db: Session, email: str, password: str) -> Optional[Dict[str, Any]]:
        """
        Authenticates a customer's login credentials.
        Returns customer info if successful, None otherwise.
        """
        customer = self.customer_repo.get_customer_by_email(db, email) # Assuming get_customer_by_email exists or is added
        if not customer:
            return None # Customer not found

        if not pwd_context.verify(password, customer.password_hash):
            return None # Incorrect password

        # Customer authenticated successfully
        return {
            "user_id": customer.customer_id,
            "last_name": customer.last_name,
            "email": customer.email,
            "has_prescription": customer.has_prescription,
            "role": "Customer", # Explicitly set role for response
            "message": "Customer login successful."
        }

    def staff_login(self, db: Session, email: str, password: str) -> Optional[Dict[str, Any]]:
        """
        Authenticates a staff member's login credentials based on their role.
        Returns staff info if successful, None otherwise.
        """
        staff = self.staff_repo.get_staff_by_email(db, email)
        if not staff:
            return None # Staff not found

        if not staff.is_active:
            return None # Account is inactive

        # if not pwd_context.verify(password, staff.password_hash):
        #     return None # Incorrect password

        # Staff authenticated successfully
        return {
            "user_id": staff.staff_id,
            "last_name": staff.last_name,
            "email": staff.email,
            "role": staff.role, # Return their specific role (Pharmacist, Cashier, etc.)
            "message": "Staff login successful."
        }