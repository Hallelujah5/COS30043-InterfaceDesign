from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.services.branch_service import BranchService
from app.utils.db import get_db
from app.schemas.branch import Branch as BranchSchema
from typing import List

router = APIRouter(prefix="/branches", tags=["Branches"])

# Dependency to get BranchService instance
def get_branch_service() -> BranchService:
    return BranchService()

@router.get("/", response_model=List[BranchSchema])
async def get_all_branches(
    branch_service: BranchService = Depends(get_branch_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves a list of all pharmacy branches.
    """
    try:
        branches = branch_service.get_all_branches(db)
        return branches
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{branch_id}", response_model=BranchSchema)
async def get_branch_details(
    branch_id: int,
    branch_service: BranchService = Depends(get_branch_service),
    db: Session = Depends(get_db)
):
    """
    Provides detailed information about a specific pharmacy branch.
    """
    try:
        branch = branch_service.get_branch_details(db, branch_id)
        return branch
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")