# app/api/product_routes.py
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.services.product_service import ProductService
from app.utils.db import get_db
from app.schemas.product import Product as ProductSchema, ProductBase 
from typing import List, Dict, Any, Optional

router = APIRouter(prefix="/products", tags=["Products"])

# Dependency to get ProductService instance
def get_product_service() -> ProductService:
    return ProductService()

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED) # Changed to dict for message and ID
async def create_product(
    request: ProductBase, # Use ProductBase or a specific ProductCreate schema
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db) # You might not need db directly if service uses SP via raw connection
):
    """
    Creates a new product in the system using a stored procedure.
    """
    try:
        new_product_id = product_service.import_new_product(
            request.name,
            request.manufacturer,
            request.description,
            request.price,
            request.category,
            request.is_prescription_required,
            request.image_url # Thêm image_url vào đây
        )
        if not new_product_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create product, possibly duplicate name."
            )
        return {"product_id": new_product_id, "message": "Product created successfully."}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.put("/{product_id}", response_model=dict) # Changed to dict for message
async def update_product_info(
    product_id: int,
    request: ProductBase, # Use ProductBase or a specific ProductUpdate schema
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db) # db is needed for get_product_details in service layer
):
    """
    Updates an existing product's information using a stored procedure.
    """
    try:
        success = product_service.update_product(
            db, # Truyền db vào đây
            product_id,
            request.name,
            request.manufacturer,
            request.description,
            request.price,
            request.category,
            request.is_prescription_required,
            request.image_url # Thêm image_url vào đây
        )
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update product with ID {product_id}."
            )
        return {"message": f"Product with ID {product_id} updated successfully."}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")


@router.get("/", response_model=List[ProductSchema])
async def get_all_products(
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves a list of all available products.
    """
    try:
        products = product_service.get_all_products(db)
        return products
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/prescription-required", response_model=List[ProductSchema])
async def get_prescription_required_products(
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db)
):
    """
    Filters and displays products that require an accompanying prescription for purchase.
    """
    try:
        products = product_service.get_prescription_required_products(db)
        return products
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/search", response_model=List[ProductSchema])
async def search_products(
    query: Optional[str] = Query(None, description="Search by product name"),
    category: Optional[str] = Query(None, description="Filter by product category"),
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db)
):
    """
    Searches for products by name or category.
    """
    try:
        products = product_service.search_products(db, query, category)
        return products
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/{product_id}", response_model=ProductSchema)
async def get_product_details(
    product_id: int,
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db)
):
    """
    Provides detailed information about a specific product.
    """
    try:
        product = product_service.get_product_details(db, product_id)
        return product
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

