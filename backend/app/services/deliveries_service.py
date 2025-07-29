from sqlalchemy.orm import Session
from app.repositories.deliveries_repository import DeliveriesRepository
from app.models.deliveries import Deliveries
from typing import Optional

class DeliveriesService:
    def __init__(self):
        self.delivery_repo = DeliveriesRepository()

    def get_delivery_details(self, db: Session, delivery_id: int) -> Deliveries:
        """
        Retrieves detailed information about a specific delivery.
        """
        delivery = self.delivery_repo.get_delivery_by_id(db, delivery_id)
        if not delivery:
            raise ValueError(f"Delivery with ID {delivery_id} not found.")
        return delivery

    def update_delivery_status(self, db: Session, delivery_id: int, new_status: str) -> bool:
        """
        Updates the status of a delivery.
        """
        delivery = self.delivery_repo.get_delivery_by_id(db, delivery_id)
        if not delivery:
            raise ValueError(f"Delivery with ID {delivery_id} not found.")

        success = self.delivery_repo.update_delivery_status(db, delivery_id, new_status)
        if not success:
            raise Exception("Failed to update delivery status.")
        return success