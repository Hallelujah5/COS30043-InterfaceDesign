from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.services.product_stock_service import ProductStockService
from app.utils.db import get_db
from app.schemas.product_stock import ProductStockStatus, ProductStockRestock, ProductStockUpdateMinStock, ProductStock as ProductStockSchema
from typing import List, Dict, Any, Optional

router = APIRouter(prefix="/product_stock", tags=["ProductStock"])

# Dependency to get ProductStockService instance
def get_product_stock_service() -> ProductStockService:
    return ProductStockService()

@router.get("/branches/{branch_id}", response_model=List[ProductStockStatus])
async def get_branch_product_stock_status(
    branch_id: int,
    product_stock_service: ProductStockService = Depends(get_product_stock_service)
):
    """
    Retrieves the real-time product stock levels across branches,
    including minimum stock level thresholds and alerts for low stock. 
    Uses procedure SP_GetBranchProductStockStatus.
    """
    try:
        product_stock_status = product_stock_service.get_branch_product_stock_status(branch_id)
        if not product_stock_status:
            # It's possible a branch exists but has no product stock records, or branch_id is invalid.
            # You might add a check here for branch existence first if needed.
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"No product stock found for branch ID {branch_id} or branch does not exist.")
        return product_stock_status
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.post("/restock", response_model=dict, status_code=status.HTTP_200_OK)
async def restock_product(
    request: ProductStockRestock,
    product_stock_service: ProductStockService = Depends(get_product_stock_service)
):
    """
    Adds products to the product stock (restock) at a specific branch.
    Uses procedure SP_RestockProductStock.
    """
    try:
        result = product_stock_service.restock_product(
            request.branch_id,
            request.product_id,
            request.quantity_to_add
        )
        return result
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/low-stock", response_model=List[ProductStockSchema]) # Assuming ProductStockSchema is suitable for this output
async def get_low_stock_products(
    branch_id: Optional[int] = Query(None, description="Filter low stock by branch ID"),
    product_stock_service: ProductStockService = Depends(get_product_stock_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves a list of products with stock quantity below their minimum stock level,
    optionally filtered by branch. This helps proactive replenishment.
    """
    try:
        low_stock_products = product_stock_service.get_low_stock_products(db, branch_id)
        return low_stock_products
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/update-min-stock-level", response_model=ProductStockSchema)
async def update_min_stock_level(
    request: ProductStockUpdateMinStock,
    product_stock_service: ProductStockService = Depends(get_product_stock_service),
    db: Session = Depends(get_db)
):
    """
    Allows managers or warehouse staff to adjust the minimum stock level
    threshold for a product at a specific branch.
    """
    try:
        updated_item = product_stock_service.update_min_stock_level(
            db,
            request.branch_id,
            request.product_id,
            request.min_stock_level
        )
        return updated_item
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")