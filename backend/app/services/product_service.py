from sqlalchemy.orm import Session
from typing import List, Optional
import math
# Import repositories for both products and likes
from app.repositories.product_repository import ProductRepository
from app.repositories.product_like_repository import ProductLikeRepository

# Import the Pydantic schema to structure the API response
from app.schemas.product import Product as ProductSchema, PaginatedProductResponse
from app.models.product import Product as ProductModel # The SQLAlchemy model


class ProductService:
    def __init__(self):
        self.product_repo = ProductRepository()
        # Add the like repository as a dependency
        self.like_repo = ProductLikeRepository()

    def get_all_products(self, db: Session) -> List[ProductSchema]:
        """
        Gets all products and enriches them with their respective like counts.
        """
        products_from_db = self.product_repo.get_all_products(db)
        
        products_with_likes = []
        for product_model in products_from_db:
            # For each product, get its like count from the like repository
            like_count = self.like_repo.get_like_count_for_product(db, product_model.product_id)
            
            # Convert the SQLAlchemy model to a Pydantic schema object
            product_schema = ProductSchema.from_orm(product_model)
            
            # Assign the fetched like count to the new field in the schema
            product_schema.like_count = like_count
            products_with_likes.append(product_schema)
            
        return products_with_likes

    def delete_product(self, db: Session, product_id: int) -> bool:
        """
        Business logic to delete a product.
        """
        product = self.product_repo.get_product_by_id(db, product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found.")
        
        return self.product_repo.delete_product(db, product_id)

    def get_product_details(self, db: Session, product_id: int) -> ProductSchema:
        """
        Gets details for a specific product, including its like count.
        """
        product = self.product_repo.get_product_by_id(db, product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found.")

        # Similar to get_all_products, we enrich the single product
        like_count = self.like_repo.get_like_count_for_product(db, product.product_id)
        product_schema = ProductSchema.from_orm(product)
        product_schema.like_count = like_count
        
        return product_schema

    def search_products(self, db: Session, query: str | None = None, category: str | None = None) -> List[ProductSchema]:
        """
        Searches products and enriches the results with like counts.
        """
        products_from_db = self.product_repo.search_products(db, query, category)
        # Apply the same enrichment logic as get_all_products
        products_with_likes = []
        for product_model in products_from_db:
            like_count = self.like_repo.get_like_count_for_product(db, product_model.product_id)
            product_schema = ProductSchema.from_orm(product_model)
            product_schema.like_count = like_count
            products_with_likes.append(product_schema)
            
        return products_with_likes

    def get_prescription_required_products(self, db: Session) -> List[ProductSchema]:
        """
        Gets prescription-required products and enriches them with like counts.
        """
        products_from_db = self.product_repo.get_prescription_required_products(db)
        # Apply the same enrichment logic
        products_with_likes = []
        for product_model in products_from_db:
            like_count = self.like_repo.get_like_count_for_product(db, product_model.product_id)
            product_schema = ProductSchema.from_orm(product_model)
            product_schema.like_count = like_count
            products_with_likes.append(product_schema)
            
        return products_with_likes
    
    def import_new_product(
        self,
        name: str,
        manufacturer: Optional[str],
        description: Optional[str],
        price: float,
        category: Optional[str],
        is_prescription_required: bool,
        image_url: Optional[str] = None
    ) -> int:
        """
        Imports a new product into the system.
        """
        new_product_id = self.product_repo.import_new_product(
            name, manufacturer, description, price, category, is_prescription_required, image_url
        )
        if new_product_id is None:
            raise Exception("Failed to import new product.")
        return new_product_id

    def update_product(
        self,
        db: Session,
        product_id: int,
        name: str,
        manufacturer: Optional[str],
        description: Optional[str],
        price: float,
        category: Optional[str],
        is_prescription_required: bool,
        image_url: Optional[str] = None
    ) -> bool:
        """
        Updates an existing product's information.
        """
        existing_product = self.product_repo.get_product_by_id(db, product_id)
        if not existing_product:
            raise ValueError(f"Product with ID {product_id} not found for update.")

        success = self.product_repo.update_product(
            product_id, name, manufacturer, description, price, category, is_prescription_required, image_url
        )
        if not success:
            raise Exception(f"Failed to update product with ID {product_id}.")
        return True


    def get_all_products_paginated(self, db: Session, page: int, size: int) -> PaginatedProductResponse:
        """
        Gets all products with pagination and enriches them with like counts using a robust method.
        """
        if page < 1: page = 1
        if size < 1: size = 10
        
        skip = (page - 1) * size
        
        total_items = self.product_repo.get_total_product_count(db)
        products_from_db = self.product_repo.get_paginated_products(db, skip=skip, limit=size)
        
        products_with_likes = []
        for product_model in products_from_db:
            # For each product, get its like count individually.
            # While this is less performant (N+1 queries), it is far more reliable on limited-resource servers.
            try:
                like_count = self.like_repo.get_like_count_for_product(db, product_model.product_id)
            except Exception as e:
                print(f"Error fetching like count for product {product_model.product_id}: {e}")
                like_count = 0
            product_schema = ProductSchema.from_orm(product_model)
            product_schema.like_count = like_count
            products_with_likes.append(product_schema)
            
        total_pages = math.ceil(total_items / size)
        
        return PaginatedProductResponse(
            total_items=total_items,
            total_pages=total_pages,
            current_page=page,
            items=products_with_likes
        )