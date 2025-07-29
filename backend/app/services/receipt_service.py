from sqlalchemy.orm import Session
from app.repositories.receipt_repository import ReceiptRepository
from app.models.receipt import Receipt
from typing import Optional

class ReceiptService:
    def __init__(self):
        self.receipt_repo = ReceiptRepository()

    def get_receipt_details(self, db: Session, receipt_id: int) -> Receipt:
        """
        Retrieves detailed information about a specific receipt.
        """
        receipt = self.receipt_repo.get_receipt_by_id(db, receipt_id)
        if not receipt:
            raise ValueError(f"Receipt with ID {receipt_id} not found.")
        return receipt