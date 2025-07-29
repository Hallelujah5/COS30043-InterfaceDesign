from app.repositories.payment_repository import PaymentRepository
from typing import Dict, Any

class PaymentService:
    def __init__(self):
        self.payment_repo = PaymentRepository()

    def process_payment(self, order_id: int, payment_method: str) -> Dict[str, Any]:
        """
        Handles the business logic for processing a payment.
        """
        payment_details = self.payment_repo.process_payment(order_id, payment_method)
        if payment_details is None:
            raise Exception("Failed to process payment. Order might not exist or payment already processed.")
        
        # You might want to add additional business logic here, e.g., 
        # trigger an email notification (though a trigger in DB already does this),
        # update other related systems, etc.
        
        return {
            "message": "Payment processed successfully.",
            "order_id": payment_details['order_id'],
            "payment_method": payment_details['payment_method'],
            "amount_paid": payment_details['amount_paid']
        }
    
    
    def get_pending_payments_by_customer(self, customer_id: int) -> Dict[str, Any]:
        """
        Retrieves all pending payments for a specific customer.
        """
        pending_payments = self.payment_repo.get_pending_payments_by_customer(customer_id)
        
        return {
            "message": f"Found {len(pending_payments)} pending payments for customer {customer_id}.",
            "customer_id": customer_id,
            "pending_payments": pending_payments,
            "total_pending_amount": sum(payment['amount'] for payment in pending_payments)
        }