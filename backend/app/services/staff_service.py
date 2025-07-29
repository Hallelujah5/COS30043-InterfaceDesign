from sqlalchemy.orm import Session
from app.repositories.staff_repository import StaffRepository
from app.models.staff import Staff
from app.schemas.staff import StaffNotification
from passlib.context import CryptContext
from typing import List, Dict, Any, Optional

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class StaffService:
    def __init__(self):
        self.staff_repo = StaffRepository()

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
    ) -> int:
        """
        Handles the business logic for staff registration using SP_RegisterNewStaff.
        """
        # Basic validation for role
        valid_roles = ['Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff']
        if role not in valid_roles:
            raise ValueError(f"Invalid role: {role}. Must be one of {valid_roles}")

        # You might want to check for existing email before calling SP
        # staff_exists = self.staff_repo.get_staff_by_email(db, email) # This requires a db session, consider passing it or handling in repo
        # if staff_exists:
        #     raise ValueError("Staff with this email already exists.")

        new_staff_id = self.staff_repo.register_staff(
            first_name, last_name, email, phone_number, raw_password, role, branch_id, image_url
        )
        if new_staff_id is None:
            raise Exception("Failed to register new staff member, possibly duplicate email or invalid branch_id.")
        return new_staff_id

    def activate_staff_account(self, db: Session, staff_id: int) -> bool:
        """
        Activates a staff member's account.
        """
        staff = self.staff_repo.get_staff_by_id(db, staff_id)
        if not staff:
            raise ValueError(f"Staff with ID {staff_id} not found.")
        if staff.is_active:
            raise ValueError(f"Staff account with ID {staff_id} is already active.")

        success = self.staff_repo.update_staff_active_status(db, staff_id, True)
        if not success:
            raise Exception("Failed to activate staff account.")
        return success

    def deactivate_staff_account(self, db: Session, staff_id: int) -> bool:
        """
        Deactivates a staff member's account.
        """
        staff = self.staff_repo.get_staff_by_id(db, staff_id)
        if not staff:
            raise ValueError(f"Staff with ID {staff_id} not found.")
        if not staff.is_active:
            raise ValueError(f"Staff account with ID {staff_id} is already inactive.")

        success = self.staff_repo.update_staff_active_status(db, staff_id, False)
        if not success:
            raise Exception("Failed to deactivate staff account.")
        return success

    def assign_order_to_cashier(
        self,
        order_id: int,
        cashier_id: int,
        branch_manager_id: Optional[int] = None # The staff_id of the BM who performs this action
    ) -> bool:
        """
        Assigns an order to a cashier using the stored procedure.
        Requires that the cashier_id corresponds to a 'Cashier' role.
        """
        # Note: In a real application, you'd add authentication and authorization
        # here to ensure only a BranchManager can call this.
        # For now, we'll assume the caller (BM) is authenticated.

        # You might want to verify if the cashier_id actually belongs to a 'Cashier'
        # This requires a database session.
        # staff = self.staff_repo.get_staff_by_id(db, cashier_id)
        # if not staff or staff.role != 'Cashier':
        #     raise ValueError(f"Staff ID {cashier_id} is not a valid Cashier.")

        # The SP_AssignOrderToCashier handles the order status check internally.
        success = self.staff_repo.assign_order_to_cashier_sp(order_id, cashier_id, branch_manager_id)
        if not success:
            raise Exception("Failed to assign order to cashier.")
        return success

    def get_staff_notifications(self, staff_id: int) -> List[StaffNotification]:
        """
        Retrieves notifications for a staff member.
        """
        # You might want to check if the staff_id exists first.
        # staff = self.staff_repo.get_staff_by_id(db, staff_id) # Requires db session
        # if not staff:
        #     raise ValueError(f"Staff with ID {staff_id} not found.")
        
        notifications_data = self.staff_repo.get_staff_notifications(staff_id)
        return [StaffNotification(**n) for n in notifications_data]

    def update_staff_role(self, db: Session, staff_id: int, new_role: str) -> bool:
        """
        Updates the role of a staff member.
        Only a BranchManager or higher-level admin should perform this.
        """
        staff = self.staff_repo.get_staff_by_id(db, staff_id)
        if not staff:
            raise ValueError(f"Staff with ID {staff_id} not found.")
        
        # Basic validation for new_role
        valid_roles = ['Pharmacist', 'Cashier', 'BranchManager', 'WarehouseStaff']
        if new_role not in valid_roles:
            raise ValueError(f"Invalid role: {new_role}. Must be one of {valid_roles}")

        success = self.staff_repo.update_staff_role(db, staff_id, new_role)
        if not success:
            raise Exception("Failed to update staff role.")
        return success

    def get_staff_by_branch(self, db: Session, branch_id: int) -> List[Staff]:
        """
        Retrieves all staff members for a specific branch.
        """
        # You might want to verify if the branch_id exists.
        staff_members = self.staff_repo.get_staff_by_branch(db, branch_id)
        return staff_members

    def update_staff_profile(
        self,
        db: Session,
        staff_id: int,
        first_name: str | None = None,
        last_name: str | None = None,
        phone_number: str | None = None,
        image_url: str | None = None
    ) -> Staff:
        """
        Updates a staff member's general profile information.
        """
        staff = self.staff_repo.get_staff_by_id(db, staff_id)
        if not staff:
            raise ValueError(f"Staff with ID {staff_id} not found.")

        updated_staff = self.staff_repo.update_staff_profile(
            db, staff_id, first_name, last_name, phone_number, image_url
        )
        if not updated_staff:
            raise Exception("Failed to update staff profile.")
        return updated_staff