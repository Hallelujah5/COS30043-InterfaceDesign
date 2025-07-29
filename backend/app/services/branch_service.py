from sqlalchemy.orm import Session
from app.repositories.branch_repository import BranchRepository
from app.models.branch import Branch # Assuming app.models.branch
from typing import List, Optional

class BranchService:
    def __init__(self):
        self.branch_repo = BranchRepository()

    def get_all_branches(self, db: Session) -> List[Branch]:
        """
        Retrieves all branches.
        """
        return self.branch_repo.get_all_branches(db)

    def get_branch_details(self, db: Session, branch_id: int) -> Branch:
        """
        Retrieves detailed information about a specific branch.
        """
        branch = self.branch_repo.get_branch_by_id(db, branch_id)
        if not branch:
            raise ValueError(f"Branch with ID {branch_id} not found.")
        return branch