# app/repositories/customer_repository.py
from sqlalchemy.orm import Session
from app.models.customer import Customer
from app.models.notification import Notification # Import the Notification ORM model
from app.utils.db import get_db_connection
from passlib.context import CryptContext
from typing import List, Dict, Any, Optional

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class CustomerRepository:
    def get_customer_by_id(self, db: Session, customer_id: int) -> Optional[Customer]:
        """
        Retrieves a customer by their ID using ORM.
        """
        return db.query(Customer).filter(Customer.customer_id == customer_id).first()

    def get_customer_by_email(self, db: Session, email: str) -> Optional[Customer]:
        """
        Retrieves a customer by their email using ORM.
        Useful for login.
        """
        return db.query(Customer).filter(Customer.email == email).first()

    def register_customer(
        self,
        first_name: str,
        last_name: str,
        email: str,
        phone_number: str | None,
        address: str | None,
        raw_password: str,
        image_url: str | None = None
    ) -> Optional[int]:
        """
        Registers a new customer using the SP_RegisterNewCustomer stored procedure.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                hashed_password = pwd_context.hash(raw_password)
                cursor.callproc(
                    'SP_RegisterNewCustomer',
                    (first_name, last_name, email, phone_number, address, hashed_password, image_url)
                )
                result = cursor.fetchone()
                connection.commit()
                return result['new_customer_id'] if result else None
        finally:
            connection.close()

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
    ) -> Optional[Customer]:
        """
        Updates a customer's profile information using ORM.
        """
        customer = db.query(Customer).filter(Customer.customer_id == customer_id).first()
        if customer:
            if first_name is not None:
                customer.first_name = first_name
            if last_name is not None:
                customer.last_name = last_name
            if gender is not None:
                customer.gender = gender
            if dob is not None:
                customer.dob = dob  # Ensure dob is a date object if needed by your model
            if phone_number is not None:
                customer.phone_number = phone_number
            if address is not None:
                customer.address = address
            if image_url is not None:
                customer.image_url = image_url
            if email is not None: # Add this block to update the email
                customer.email = email
            db.commit()
            db.refresh(customer)
        return customer

    def update_customer_password(self, db: Session, customer_id: int, new_password_hash: str) -> bool:
        """
        Updates a customer's password hash in the database.
        """
        customer = db.query(Customer).filter(Customer.customer_id == customer_id).first()
        if customer:
            customer.password_hash = new_password_hash
            db.commit()
            db.refresh(customer)
            return True
        return False

    def get_customer_order_history(self, customer_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves the order history for a specific customer using SP_GetCustomerOrderHistory.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc('SP_GetCustomerOrderHistory', (customer_id,))
                result = cursor.fetchall()
                return result
        finally:
            connection.close()

    def get_customer_prescriptions(self, customer_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves all prescriptions for a customer using direct query as no specific SP was provided.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT
                        prescription_id,
                        customer_id,
                        upload_date,
                        file_path,
                        validation_status,
                        pharmacist_id,
                        validation_date,
                        customer_notes,
                        pharmacist_notes
                    FROM Prescriptions
                    WHERE customer_id = %s
                    ORDER BY upload_date DESC;
                    """,
                    (customer_id,)
                )
                result = cursor.fetchall()
                return result
        finally:
            connection.close()

    def get_customer_notifications(self, db: Session, customer_id: int) -> List[Notification]:
        """
        Retrieves all notifications for a specific customer using ORM.
        """
        return db.query(Notification).filter(Notification.customer_id == customer_id).order_by(Notification.sent_date.desc()).all()