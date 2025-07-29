from sqlalchemy.orm import Session
from app.models.branch import Branch # Assuming you have app.models.branch
from typing import List, Optional

class BranchRepository:
    def get_all_branches(self, db: Session) -> List[Branch]:
        """
        Retrieves all branches using ORM.
        """
        return db.query(Branch).all()

    def get_branch_by_id(self, db: Session, branch_id: int) -> Optional[Branch]:
        """
        Retrieves a specific branch by its ID using ORM.
        """
        return db.query(Branch).filter(Branch.branch_id == branch_id).first()