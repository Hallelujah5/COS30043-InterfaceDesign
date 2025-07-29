from sqlalchemy.orm import Session
from app.repositories.customer_repository import CustomerRepository
from app.models.customer import Customer
from app.models.notification import Notification # Import Notification ORM model
from passlib.context import CryptContext
from typing import List, Dict, Any

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class CustomerService:
    def __init__(self):
        self.customer_repo = CustomerRepository()

    def register_customer(
        self,
        first_name: str,
        last_name: str,
        email: str,
        phone_number: str | None,
        address: str | None,
        raw_password: str,
        image_url: str | None = None # Added image_url parameter
    ) -> int:
        """
        Handles the business logic for customer registration.
        """
        new_customer_id = self.customer_repo.register_customer(
            first_name, last_name, email, phone_number, address, raw_password, image_url # Pass image_url
        )
        if new_customer_id is None:
            raise Exception("Failed to register new customer.")
        return new_customer_id

    def get_customer_profile(self, customer_id: int, db: Session) -> Customer:
        """
        Retrieves the detailed profile of a customer.
        """
        customer = self.customer_repo.get_customer_by_id(db, customer_id)
        if not customer:
            raise ValueError(f"Customer with ID {customer_id} not found.")
        return customer

    def get_customer_order_history(self, customer_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves the order history for a specific customer.
        """
        # You might want to add a check here if the customer_id exists using get_customer_profile
        # For now, relying on the SP to handle non-existent customer_id gracefully (empty list).
        return self.customer_repo.get_customer_order_history(customer_id)

    def update_customer_profile(
        self,
        db: Session,
        customer_id: int,
        first_name: str | None = None,
        last_name: str | None = None,
        gender: str | None = None,
        dob: str | None = None,
        phone_number: str | None = None,
        address: str | None = None,
        image_url: str | None = None,
        email: str | None = None
    ) -> Customer:
        """
        Updates a customer's profile information.
        """
        customer = self.customer_repo.get_customer_by_id(db, customer_id)
        if not customer:
            raise ValueError(f"Customer with ID {customer_id} not found.")

        updated_customer = self.customer_repo.update_customer_profile(
            db, customer_id, first_name, last_name, gender, dob, phone_number, address, image_url, email # Pass image_url and email
        )
        if not updated_customer:
            raise Exception("Failed to update customer profile.")
        return updated_customer

    def change_customer_password(self, db: Session, customer_id: int, old_password: str, new_password: str) -> bool:
        """
        Changes the customer's password after verifying the old password.
        """
        customer = self.customer_repo.get_customer_by_id(db, customer_id)
        if not customer:
            raise ValueError(f"Customer with ID {customer_id} not found.")

        # Verify old password
        if not pwd_context.verify(old_password, customer.password_hash):
            raise ValueError("Incorrect old password.")

        # Hash and update new password
        new_password_hash = pwd_context.hash(new_password)
        success = self.customer_repo.update_customer_password(db, customer_id, new_password_hash)
        if not success:
            raise Exception("Failed to update password.")
        return True

    def get_customer_prescriptions(self, customer_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves all prescriptions for a customer.
        """
        # You might want to add a check here if the customer_id exists.
        return self.customer_repo.get_customer_prescriptions(customer_id)

    def get_customer_notifications(self, db: Session, customer_id: int) -> List[Notification]:
        """
        Retrieves all notifications for a specific customer.
        """
        # Ensure the customer exists before fetching notifications
        customer = self.customer_repo.get_customer_by_id(db, customer_id)
        if not customer:
            raise ValueError(f"Customer with ID {customer_id} not found.")
        return self.customer_repo.get_customer_notifications(db, customer_id)