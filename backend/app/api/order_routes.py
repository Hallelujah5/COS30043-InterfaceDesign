# app/api/order_routes.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.services.order_service import OrderService
from app.utils.db import get_db
from app.schemas.order import (
    OrderPlace, OrderStatusUpdate, Order as OrderSchema,
    DetailedOrderResponse, CashierOrdersReviewResponse, DailyOrderSummary, # Changed response model
    # No longer need CashierOrderInfo, CashierReviewItem directly here as they are nested
)
from typing import List, Dict, Any, Optional
from datetime import datetime
from datetime import date 

router = APIRouter(prefix="/orders", tags=["Orders"])

# Dependency to get OrderService instance
def get_order_service() -> OrderService:
    return OrderService()

@router.post("/place", response_model=dict, status_code=status.HTTP_201_CREATED)
async def place_order(
    request: OrderPlace,
    order_service: OrderService = Depends(get_order_service)
):
    """
    Places a new order, adding items and updating product stock.
    Uses procedure SP_PlaceOrder.
    """
    try:
        new_order_id = order_service.place_order(
            request.customer_id,
            request.branch_id,
            [item.model_dump() for item in request.product_details], # Convert Pydantic models to dicts for JSON
            request.prescription_id,
            request.delivery_address,
            request.delivery_party,
            request.estimated_delivery_date,
            request.tracking_number,
            request.discount_amount,
            request.order_source
        )
        if not new_order_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to place order. Check product availability or input data."
            )
        return {"order_id": new_order_id, "message": "Order placed successfully."}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/pending-cashier-review", response_model=CashierOrdersReviewResponse) # Changed response model
async def get_cashier_pending_orders(
    cashier_id: int = Query(..., description="The ID of the cashier requesting the review details."),
    order_service: OrderService = Depends(get_order_service)
):
    """
    Retrieves a list of orders pending cashier review.
    Uses SP_GetCashierOrdersForCashier.
    """
    try:
        # The service layer now returns data already structured as a list of orders, each with its items
        cashier_review_data = order_service.get_cashier_pending_orders(cashier_id)

        if not cashier_review_data["orders"]: # Check the 'orders' key from the service
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"No orders found or assigned to cashier {cashier_id} for review.")

        # Pydantic will now directly validate the 'orders' list as CashierOrderInfo objects
        # as the service layer already structures the data correctly.
        return CashierOrdersReviewResponse(orders=cashier_review_data["orders"])
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/pending-processing", response_model=List[OrderSchema])
async def get_pending_processing_orders(
    order_service: OrderService = Depends(get_order_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves orders with 'Paid' or 'Processing' status that are not yet 'Ready for Pickup' or 'Delivered', for staff processing.
    """
    try:
        orders = order_service.get_pending_processing_orders(db)
        return orders
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{order_id}/status", response_model=OrderSchema)
async def update_order_status(
    order_id: int,
    request: OrderStatusUpdate,
    order_service: OrderService = Depends(get_order_service),
    db: Session = Depends(get_db)
):
    """
    Allows staff to update the status of an order (e.g., from 'Pending' to 'Processing').
    """
    try:
        updated_order = order_service.update_order_status(db, order_id, request.status)
        return updated_order
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{order_id}", response_model=DetailedOrderResponse)
async def get_order_details(
    order_id: int,
    order_service: OrderService = Depends(get_order_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves all information related to a specific order, including its items and delivery details.
    """
    try:
        order_details = order_service.get_order_details(db, order_id)
        # Pydantic will convert the dict returned by service to DetailedOrderResponse
        return order_details
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{order_id}/cancel", response_model=OrderSchema)
async def cancel_order(
    order_id: int,
    order_service: OrderService = Depends(get_order_service),
    db: Session = Depends(get_db)
):
    """
    Changes the order status to 'Cancelled' and potentially returns product stock.
    """
    try:
        cancelled_order = order_service.cancel_order(db, order_id)
        return cancelled_order
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/branches/{branch_id}/daily-summary", response_model=DailyOrderSummary)
async def get_daily_order_summary_for_branch(
    branch_id: int,
    summary_date: date = Query(..., description="Date for the summary in YYYY-MM-DD format"),
    order_service: OrderService = Depends(get_order_service)
):
    """
    Provides a daily overview of order count and total revenue for a specific branch.
    """
    try:
        # Convert date object to datetime for service layer if needed by repository method
        summary_datetime = datetime.combine(summary_date, datetime.min.time())
        summary = order_service.get_daily_order_summary_for_branch(branch_id, summary_datetime)
        if not summary:
            # If no orders for the day, return default summary for that date
            return {"order_date": summary_date.strftime('%Y-%m-%d'), "total_orders": 0, "total_revenue": 0.0}

        return summary
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")