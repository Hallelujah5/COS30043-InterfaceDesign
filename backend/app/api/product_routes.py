# app/api/product_routes.py
from fastapi import APIRouter, Depends, HTTPException, Query, status, APIRouter, Depends, HTTPException, status, File, Form, UploadFile
from sqlalchemy.orm import Session
from app.services.product_service import ProductService
from app.services.product_like_service import ProductLikeService
from app.utils.db import get_db
from app.schemas.product import Product as ProductSchema, ProductBase, LikedProduct, PaginatedProductResponse
from typing import List, Dict, Any, Optional
from app.schemas.product import LikedProduct 
from app.schemas.customer import Customer
from app.utils.auth import get_current_active_customer
import os, shutil



router = APIRouter(prefix="/products", tags=["Products"])

# Dependency to get ProductService instance
def get_product_service() -> ProductService:
    return ProductService()

def get_product_like_service() -> ProductLikeService:
    return ProductLikeService()

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_product(
    # Instead of a single Pydantic model, we now accept form data
    name: str = Form(...),
    manufacturer: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    price: float = Form(...),
    category: Optional[str] = Form(None),
    is_prescription_required: bool = Form(False),
    file: Optional[UploadFile] = File(None), # The image file is now optional
    product_service: ProductService = Depends(get_product_service)
    # current_staff: Staff = Depends(get_current_active_staff) # Optional: for role protection
):
    """
    Creates a new product, now accepting an image file upload.
    """
    image_url = None
    if file:
        # Validate file type
        ext = os.path.splitext(file.filename)[1].lower()
        if ext not in [".png", ".jpg", ".jpeg"] or file.content_type not in ["image/png", "image/jpeg"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only .png and .jpg image files are allowed."
            )

        # Define the directory to save product images
        upload_dir = "app/static/products"
        os.makedirs(upload_dir, exist_ok=True)

        # Create a unique filename to avoid overwrites (optional but recommended)
        # For simplicity, we'll use the original filename
        file_path = os.path.join(upload_dir, file.filename)
        
        # Save the file to the server's disk
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Create the publicly accessible URL for the saved image
        image_url = f"https://cos30043-interfacedesign-production-ff6f.up.railway.app/static/products/{file.filename}"

    try:
        new_product_id = product_service.import_new_product(
            name=name,
            manufacturer=manufacturer,
            description=description,
            price=price,
            category=category,
            is_prescription_required=is_prescription_required,
            image_url=image_url  
        )
        return {"product_id": new_product_id, "message": "Product created successfully."}
    except Exception as e:
        # Clean up uploaded file if database operation fails
        if image_url and os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    product_service: ProductService = Depends(get_product_service)
    # Add staff dependency for protection:
    # current_staff: Staff = Depends(get_current_active_staff)
):
    """
    Deletes a product from the system.
    """
    # Add role check:
    # if current_staff.role != "Manager":
    #     raise HTTPException(status_code=403, detail="Not authorized to delete products")
    try:
        success = product_service.delete_product(db, product_id)
        if not success:
            # This case is handled by the service raising a ValueError
            pass
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))



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


@router.get("", response_model=PaginatedProductResponse)
async def get_all_products_paginated(
    page: int = 1, 
    size: int = 9, # Default to 9 items to fit a 3x3 grid
    product_service: ProductService = Depends(get_product_service),
    db: Session = Depends(get_db)
):
    """
    Retrieves a paginated list of all available products.
    """
    try:
        paginated_products = product_service.get_all_products_paginated(db, page=page, size=size)
        return paginated_products
    except Exception as e:
        # It's good practice to log the error here
        # import logging
        # logging.exception("Error fetching paginated products")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An internal server error occurred.")

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



# --- NEW LIKE-RELATED ENDPOINTS ---

@router.post("/{product_id}/like", status_code=status.HTTP_204_NO_CONTENT)
async def like_product(
    product_id: int,
    db: Session = Depends(get_db),
    like_service: ProductLikeService = Depends(get_product_like_service),
    current_customer: Customer = Depends(get_current_active_customer) # Authentication
):
    """
    Allows the currently authenticated customer to 'like' a product.
    """
    try:
        like_service.like_product(db, customer_id=current_customer.customer_id, product_id=product_id)
        # No content is returned on success, just a 204 status code.
    except ValueError as e:
        # Handles cases like "product not found" or "already liked"
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected error occurred.")


@router.delete("/{product_id}/like", status_code=status.HTTP_204_NO_CONTENT)
async def unlike_product(
    product_id: int,
    db: Session = Depends(get_db),
    like_service: ProductLikeService = Depends(get_product_like_service),
    current_customer: Customer = Depends(get_current_active_customer) # Authentication
):
    """
    Allows the currently authenticated customer to remove their 'like' from a product.
    """
    try:
        like_service.unlike_product(db, customer_id=current_customer.customer_id, product_id=product_id)
        # No content is returned on success, just a 204 status code.
    except ValueError as e:
        # Handles cases like "product not found" or "not liked yet"
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected error occurred.")


@router.get("/me/likes", response_model=List[LikedProduct])
async def get_my_liked_products(
    db: Session = Depends(get_db),
    current_customer: Customer = Depends(get_current_active_customer),
    like_service: ProductLikeService = Depends(get_product_like_service)
):
    """
    Retrieves a list of all products liked by the current authenticated customer.
    """
    try:
        liked_products = like_service.get_likes_by_customer(db, current_customer.customer_id)
        return liked_products
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected error occurred.")