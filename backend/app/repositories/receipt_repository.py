from sqlalchemy.orm import Session
from app.models.receipt import Receipt
from typing import Optional

class ReceiptRepository:
    def get_receipt_by_id(self, db: Session, receipt_id: int) -> Optional[Receipt]:
        """
        Retrieves a specific receipt by its ID using ORM.
        """
        return db.query(Receipt).filter(Receipt.receipt_id == receipt_id).first()