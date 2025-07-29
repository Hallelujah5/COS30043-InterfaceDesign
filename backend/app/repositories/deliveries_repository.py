from sqlalchemy.orm import Session
from app.models.deliveries import Deliveries
from typing import Optional

class DeliveriesRepository:
    def get_delivery_by_id(self, db: Session, delivery_id: int) -> Optional[Deliveries]:
        """
        Retrieves a specific delivery by its ID using ORM.
        """
        return db.query(Deliveries).filter(Deliveries.delivery_id == delivery_id).first()

    def update_delivery_status(self, db: Session, delivery_id: int, new_status: str) -> bool:
        """
        Updates the delivery_status of a delivery.
        """
        delivery = db.query(Deliveries).filter(Deliveries.delivery_id == delivery_id).first()
        if delivery:
            # Validate new_status against ENUM values if not handled by DB itself
            valid_statuses = ['Scheduled', 'On The Way', 'Delivered', 'Cancelled']
            if new_status not in valid_statuses:
                raise ValueError(f"Invalid delivery status: {new_status}. Must be one of {valid_statuses}")
            
            delivery.delivery_status = new_status
            db.commit()
            db.refresh(delivery)
            return True
        return False