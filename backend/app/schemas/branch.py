from pydantic import BaseModel
from typing import Optional

class BranchBase(BaseModel):
    name: str
    address: str
    phone_number: Optional[str] = None

class Branch(BranchBase):
    branch_id: int

    class Config:
        from_attributes = True