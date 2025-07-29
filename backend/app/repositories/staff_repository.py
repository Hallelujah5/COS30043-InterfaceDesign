from sqlalchemy.orm import Session
from app.models.staff import Staff
from app.utils.db import get_db_connection
from passlib.context import CryptContext
from typing import List, Dict, Any, Optional

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class StaffRepository:
    def get_staff_by_id(self, db: Session, staff_id: int) -> Optional[Staff]:
        """
        Retrieves a staff member by their ID using ORM.
        """
        return db.query(Staff).filter(Staff.staff_id == staff_id).first()

    def get_staff_by_email(self, db: Session, email: str) -> Optional[Staff]:
        """
        Retrieves a staff member by their email using ORM.
        Useful for login.
        """
        return db.query(Staff).filter(Staff.email == email).first()

    def register_staff(
        self,
        first_name: str,
        last_name: str,
        email: str,
        phone_number: str | None,
        raw_password: str,
        role: str,
        branch_id: int | None,
        image_url: str | None = None
    ) -> Optional[int]:
        """
        Registers a new staff member using the SP_RegisterNewStaff stored procedure.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                hashed_password = pwd_context.hash(raw_password)
                cursor.callproc(
                    'SP_RegisterNewStaff',
                    (first_name, last_name, email, phone_number, hashed_password, role, branch_id, image_url)
                )
                result = cursor.fetchone() # SP_RegisterNewStaff returns new_staff_id
                connection.commit()
                return result['new_staff_id'] if result else None
        finally:
            connection.close()

    def update_staff_active_status(self, db: Session, staff_id: int, is_active: bool) -> bool:
        """
        Activates or deactivates a staff member's account.
        """
        staff = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if staff:
            staff.is_active = is_active
            db.commit()
            db.refresh(staff)
            return True
        return False

    def assign_order_to_cashier_sp(
        self,
        order_id: int,
        cashier_id: int,
        branch_manager_id: Optional[int] = None
    ) -> bool:
        """
        Assigns an order to a cashier using SP_AssignOrderToCashier.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # SP_AssignOrderToCashier(p_order_id, p_cashier_id, p_branch_manager_id)
                cursor.callproc('SP_AssignOrderToCashier', (order_id, cashier_id, branch_manager_id))
                connection.commit()
                return True # If no exception, assume success
        except Exception as e:
            connection.rollback()
            print(f"Error assigning order to cashier via SP: {e}")
            raise
        finally:
            connection.close()

    def get_staff_notifications(self, staff_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves all notifications for a specific staff member.
        Direct query as no specific SP for this was provided.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT
                        notification_id,
                        message_content,
                        notification_type,
                        sent_date,
                        order_id,
                        prescription_id,
                        product_id,
                        branch_id,
                        is_sent
                    FROM Notifications
                    WHERE staff_id = %s
                    ORDER BY sent_date DESC;
                    """,
                    (staff_id,)
                )
                result = cursor.fetchall()
                return result
        finally:
            connection.close()

    def update_staff_role(self, db: Session, staff_id: int, new_role: str) -> bool:
        """
        Updates the role of a staff member.
        """
        staff = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if staff:
            # Ensure the new_role is a valid ENUM value if checking at this layer
            valid_roles = ['Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff']
            if new_role not in valid_roles:
                raise ValueError(f"Invalid role: {new_role}. Must be one of {valid_roles}")
            staff.role = new_role
            db.commit()
            db.refresh(staff)
            return True
        return False

    def get_staff_by_branch(self, db: Session, branch_id: int) -> List[Staff]:
        """
        Retrieves all staff members working at a specific branch.
        """
        return db.query(Staff).filter(Staff.branch_id == branch_id).all()

    def update_staff_profile(
        self,
        db: Session,
        staff_id: int,
        first_name: str | None = None,
        last_name: str | None = None,
        phone_number: str | None = None,
        image_url: str | None = None
    ) -> Optional[Staff]:
        """
        Updates a staff member's general profile information.
        """
        staff = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if staff:
            if first_name is not None:
                staff.first_name = first_name
            if last_name is not None:
                staff.last_name = last_name
            if phone_number is not None:
                staff.phone_number = phone_number
            if image_url is not None:
                staff.image_url = image_url
            db.commit()
            db.refresh(staff)
        return staff