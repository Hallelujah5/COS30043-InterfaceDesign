# app/repositories/order_repository.py
from sqlalchemy.orm import Session
from app.models.order import Order # Your SQLAlchemy ORM model for Order
from app.models.order_item import OrderItem # Your SQLAlchemy ORM model for OrderItem
from app.models.product import Product # Your SQLAlchemy ORM model for Product
from app.models.deliveries import Deliveries # Your SQLAlchemy ORM model for Delivery
from app.models.prescription import Prescription # Your SQLAlchemy ORM model for Prescription
from app.utils.db import get_db_connection
from typing import List, Dict, Any, Optional
from datetime import datetime
import json
from sqlalchemy.orm import joinedload

class OrderRepository:
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
        Places a new order using the SP_PlaceOrder stored procedure.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # Convert product_details list to JSON string for the SP
                product_details_json = json.dumps(product_details) # Assuming json module is imported

                cursor.callproc(
                    'SP_PlaceOrder',
                    (
                        customer_id,
                        branch_id,
                        product_details_json,
                        prescription_id,
                        delivery_address,
                        delivery_party,
                        estimated_delivery_date,
                        tracking_number,
                        discount_amount,
                        order_source
                    )
                )
                result = cursor.fetchone() # SP_PlaceOrder returns new_order_id
                connection.commit()
                return result['new_order_id'] if result else None
        finally:
            connection.close()

    def update_order_status(self, db: Session, order_id: int, new_status: str) -> Optional[Order]:
        """
        Updates the status of an order using ORM.
        """
        order = db.query(Order).filter(Order.order_id == order_id).first()
        if order:
            order.order_status = new_status
            db.commit()
            db.refresh(order)
        return order

    def get_order_details(self, db: Session, order_id: int) -> Optional[Order]:
        """
        Retrieves all information related to a specific order, including its items and delivery details using ORM.
        This will require loading relationships.
        """
        order = db.query(Order).options(
            # Eager load related data for a comprehensive view
            joinedload(Order.order_items).joinedload(OrderItem.product),
            joinedload(Order.delivery),
            joinedload(Order.prescription)
        ).filter(Order.order_id == order_id).first()
        return order

    def get_cashier_pending_orders_details(self, cashier_id: int) -> Dict[str, Any]:
        """
        Retrieves details for orders pending cashier review using SP_GetCashierOrdersForCashier.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # SP_GetCashierOrdersForCashier returns two result sets
                cursor.callproc('SP_GetCashierOrdersForCashier', (cashier_id,))

                # First result set: Order and Prescription info
                orders_info = cursor.fetchall()

                # Move to next result set for order items
                cursor.nextset()
                order_items_info = cursor.fetchall()

                return {
                    "orders_info": orders_info,
                    "order_items": order_items_info
                }
        finally:
            connection.close()

    def get_pending_processing_orders(self, db: Session) -> List[Order]:
        """
        Retrieves orders that are 'Paid' or 'Processing' but not yet 'Ready for Pickup' or 'Delivered'.
        """
        return db.query(Order).filter(
            Order.order_status.in_(['Paid', 'Processing'])
        ).all()

    def cancel_order(self, db: Session, order_id: int) -> Optional[Order]:
        """
        Cancels an order using the SP_CancelOrder stored procedure.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc('SP_CancelOrder', (order_id,))
                connection.commit()
                
                # After successful cancellation, retrieve the updated order using ORM
                order = db.query(Order).filter(Order.order_id == order_id).first()
                if order:
                    db.refresh(order)  # Refresh to get the latest data from DB
                return order
        except Exception as e:
            connection.rollback()
            raise e
        finally:
            connection.close()

    def get_daily_order_summary_for_branch(self, branch_id: int, summary_date: datetime) -> Dict[str, Any]:
        """
        Provides an overview of daily order count and total revenue at a branch.
        A stored procedure like SP_GenerateSalesReport could be adapted,
        or a direct query is sufficient for simple aggregation.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # Using SP_GenerateSalesReport but for a single day summary
                # You might need a new SP like SP_GetDailyOrderSummary if SP_GenerateSalesReport
                # returns too much detail or is not suitable for a single day summary.
                # For now, let's assume SP_GenerateSalesReport can provide the needed info
                # if start_date and end_date are the same.
                # If not, a direct query is more appropriate.
                
                # Direct query for daily summary
                cursor.execute(
                    """
                    SELECT
                        DATE(order_date) AS order_date,
                        COUNT(order_id) AS total_orders,
                        SUM(total_amount) AS total_revenue
                    FROM Orders
                    WHERE branch_id = %s
                    AND DATE(order_date) = DATE(%s)
                    AND order_status IN ('Paid', 'Processing', 'Ready for Pickup', 'Delivered')
                    GROUP BY DATE(order_date);
                    """,
                    (branch_id, summary_date.strftime('%Y-%m-%d'))
                )
                result = cursor.fetchone()
                return result if result else {"order_date": summary_date.strftime('%Y-%m-%d'), "total_orders": 0, "total_revenue": 0.0}
        finally:
            connection.close()