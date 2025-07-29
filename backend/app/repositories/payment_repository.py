from app.utils.db import get_db_connection
from typing import Dict, Any, Optional

class PaymentRepository:
    def process_payment(self, order_id: int, payment_method: str) -> Optional[Dict[str, Any]]:
        """
        Processes a payment for an order using the SP_ProcessPayment stored procedure.
        Returns payment details or None if processing fails.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # SP_ProcessPayment updates the Payment record and triggers Notifications
                cursor.callproc('SP_ProcessPayment', (order_id, payment_method))
                connection.commit()
                
                # In SP_ProcessPayment, we don't have an explicit SELECT to return a value
                # so we might need to fetch the updated payment/order status here
                # For simplicity, we'll assume the SP successfully updated the payment
                # and the calling service will confirm by other means if needed.
                # If SP_ProcessPayment was designed to return new payment_id or status,
                # we would fetch it here.
                
                # As per your SP definition, it doesn't return anything directly for a SELECT.
                # We can return a success indicator or try to fetch the updated status if critical.
                # For now, assuming successful execution if no exception is raised.
                
                # To confirm, let's try to fetch the updated order status (though not the payment directly)
                cursor.execute("SELECT order_status, total_amount FROM Orders WHERE order_id = %s", (order_id,))
                order_info = cursor.fetchone()
                
                if order_info and order_info['order_status'] == 'Paid':
                    return {
                        "order_id": order_id,
                        "payment_method": payment_method,
                        "transaction_status": "Completed", # Inferred from SP_ProcessPayment logic
                        "amount_paid": order_info['total_amount']
                    }
                return None
        except Exception as e:
            # Log the error for debugging
            print(f"Error processing payment for order {order_id}: {e}")
            raise # Re-raise the exception to be handled by the service layer
        finally:
            connection.close()


    def get_pending_payments_by_customer(self, customer_id: int) -> list[Dict[str, Any]]:
        """
        Fetches all pending payments (without payment_date) for a specific customer.
        Returns a list of pending payment records.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                sql = """
                    SELECT 
                        p.payment_id,
                        p.order_id,
                        p.amount,
                        p.payment_method,
                        p.transaction_status,
                        o.order_date,
                        o.total_amount as order_total,
                        o.order_status
                    FROM Payments p
                    JOIN Orders o ON p.order_id = o.order_id
                    WHERE o.customer_id = %s
                    AND p.transaction_status = 'Pending'
                    ORDER BY o.order_date DESC;
                """
                cursor.execute(sql, (customer_id,))
                results = cursor.fetchall()
                return results
        except Exception as e:
            print(f"Error fetching pending payments for customer {customer_id}: {e}")
            raise
        finally:
            connection.close()