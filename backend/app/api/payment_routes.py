from fastapi import APIRouter, Depends, HTTPException, status
from app.services.payment_service import PaymentService
from app.schemas.payment import ProcessPaymentRequest, ProcessPaymentResponse, PendingPaymentsResponse

router = APIRouter(prefix="/payments", tags=["Payments"])

# Dependency to get PaymentService instance
def get_payment_service() -> PaymentService:
    return PaymentService()

@router.post("/process", response_model=ProcessPaymentResponse, status_code=status.HTTP_200_OK)
async def process_payment(
    request: ProcessPaymentRequest,
    payment_service: PaymentService = Depends(get_payment_service)
):
    """
    Processes a payment for a given order.
    """
    try:
        result = payment_service.process_payment(request.order_id, request.payment_method)
        return result
    except Exception as e:
        # Catch specific exceptions if needed, e.g., if order_id is not found.
        # For now, a general 400 or 500 for any processing error.
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Payment processing failed: {e}"
        )
    

@router.get("/{customer_id}/pending-payments", response_model=PendingPaymentsResponse, status_code=status.HTTP_200_OK)
async def get_pending_payments(
    customer_id: int,
    payment_service: PaymentService = Depends(get_payment_service)
):
    """
    Fetch all pending payments (without payment_date) for a specific customer.
    """
    try:
        result = payment_service.get_pending_payments_by_customer(customer_id)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to fetch pending payments: {e}"
        )