
from sqlalchemy.orm import Session
from app.repositories.order_repository import OrderRepository
from app.models.order import Order 
from app.models.order_item import OrderItem 
from typing import List, Dict, Any, Optional
from datetime import datetime

class OrderService:
    def __init__(self):
        self.order_repo = OrderRepository()

    def place_order(
        self,
        customer_id: int,
        branch_id: int,
        product_details: List[Dict[str, Any]],
        prescription_id: Optional[int],
        delivery_address: Optional[str],
        delivery_party: Optional[str],
        estimated_delivery_date: Optional[datetime],
        tracking_number: Optional[str],
        discount_amount: float,
        order_source: str
    ) -> int:
        """
        Places a new order.
        """
        if not product_details:
            raise ValueError("Order must contain at least one product.")
        # Further validation (e.g., product_id exists, quantity is positive) can be added here
        # or rely on SP_PlaceOrder for some validations.
        return self.order_repo.place_order(
            customer_id,
            branch_id,
            product_details,
            prescription_id,
            delivery_address,
            delivery_party,
            estimated_delivery_date,
            tracking_number,
            discount_amount,
            order_source
        )

    def update_order_status(self, db: Session, order_id: int, new_status: str) -> Order:
        """
        Updates the status of an order.
        """
        order = self.order_repo.get_order_details(db, order_id) # Use get_order_details to ensure existence
        if not order:
            raise ValueError(f"Order with ID {order_id} not found.")

        # Basic status transition validation (can be more complex based on business rules)
        valid_statuses = ['Pending', 'Paid', 'Processing', 'Ready for Pickup', 'Delivered', 'Cancelled', 'Rejected-Refund']
        if new_status not in valid_statuses:
            raise ValueError(f"Invalid order status: {new_status}")

        updated_order = self.order_repo.update_order_status(db, order_id, new_status)
        if not updated_order:
            raise Exception("Failed to update order status.")
        return updated_order

    def get_order_details(self, db: Session, order_id: int) -> Dict[str, Any]:
        """
        Retrieves all information related to a specific order.
        """
        order_orm = self.order_repo.get_order_details(db, order_id)
        if not order_orm:
            raise ValueError(f"Order with ID {order_id} not found.")

        # Manually assemble the DetailedOrderResponse to include related fields
        order_dict = order_orm.__dict__
        order_dict['order_items'] = [item.__dict__ for item in order_orm.order_items]

        # Add delivery details if available
        if order_orm.delivery:
            order_dict['delivery_address'] = order_orm.delivery.delivery_address
            order_dict['delivery_status'] = order_orm.delivery.delivery_status
            order_dict['delivery_party'] = order_orm.delivery.delivery_party
            order_dict['estimated_delivery_date'] = order_orm.delivery.estimated_delivery_date
            order_dict['tracking_number'] = order_orm.delivery.tracking_number
        else:
            order_dict['delivery_address'] = None
            order_dict['delivery_status'] = None
            order_dict['delivery_party'] = None
            order_dict['estimated_delivery_date'] = None
            order_dict['tracking_number'] = None

        # Add prescription details if available
        if order_orm.prescription:
            order_dict['prescription_file_path'] = order_orm.prescription.file_path
            order_dict['prescription_validation_status'] = order_orm.prescription.validation_status
        else:
            order_dict['prescription_file_path'] = None
            order_dict['prescription_validation_status'] = None

        # Clean up SQLAlchemy internal states (e.g., '_sa_instance_state')
        for key in list(order_dict.keys()):
            if key.startswith('_sa_'):
                del order_dict[key]
        for item in order_dict.get('order_items', []):
            for key in list(item.keys()):
                if key.startswith('_sa_'):
                    del item[key]
            # Ensure product details from join are mapped correctly if you need them.
            # Example: item['product_name'] = item['product'].name if item.get('product') else None
            # del item['product'] # Remove SQLAlchemy product object
        return order_dict

    def get_cashier_pending_orders(self, cashier_id: int) -> Dict[str, Any]:
        """
        Gets orders assigned to a cashier for final review and structures them.
        """
        raw_data = self.order_repo.get_cashier_pending_orders_details(cashier_id)
        
        orders_info = raw_data["orders_info"]
        order_items = raw_data["order_items"]

        # Create a dictionary to hold items for each order_id
        order_items_map = {}
        for item in order_items:
            order_id = item['order_id']
            if order_id not in order_items_map:
                order_items_map[order_id] = []
            order_items_map[order_id].append(item)

        # Assemble the final structured response
        structured_orders = []
        for order_data in orders_info:
            order_id = order_data['order_id']
            # Create a copy to avoid modifying the original dict from db cursor result
            order_with_items = dict(order_data)
            order_with_items['order_items'] = order_items_map.get(order_id, [])
            structured_orders.append(order_with_items)
            
        return {"orders": structured_orders}


    def get_pending_processing_orders(self, db: Session) -> List[Order]:
        """
        Retrieves orders that are 'Paid' or 'Processing' but not yet 'Ready for Pickup' or 'Delivered'.
        """
        return self.order_repo.get_pending_processing_orders(db)

    def cancel_order(self, db: Session, order_id: int) -> Order:
        """
        Cancels an order and handles stock return.
        """
        order = self.order_repo.cancel_order(db, order_id)
        if not order:
            raise ValueError(f"Order with ID {order_id} not found or cannot be cancelled.")
        return order

    def get_daily_order_summary_for_branch(self, branch_id: int, summary_date: datetime) -> Dict[str, Any]:
        """
        Provides a daily order summary for a branch.
        """
        # You might add a check here if branch_id exists.
        return self.order_repo.get_daily_order_summary_for_branch(branch_id, summary_date)