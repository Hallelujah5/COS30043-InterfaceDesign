# app/services/product_service.py
from sqlalchemy.orm import Session
from app.repositories.product_repository import ProductRepository
from app.models.product import Product # Your SQLAlchemy ORM model
from typing import List, Dict, Any, Optional

class ProductService:
    def __init__(self):
        self.product_repo = ProductRepository()

    def get_all_products(self, db: Session) -> List[Product]:
        """
        Gets all products.
        """
        return self.product_repo.get_all_products(db)

    def get_product_details(self, db: Session, product_id: int) -> Product:
        """
        Gets details for a specific product.
        """
        product = self.product_repo.get_product_by_id(db, product_id)
        if not product:
            raise ValueError(f"Product with ID {product_id} not found.")
        return product

    def search_products(self, db: Session, query: str | None = None, category: str | None = None) -> List[Product]:
        """
        Searches products by name or category.
        """
        return self.product_repo.search_products(db, query, category)

    def get_prescription_required_products(self, db: Session) -> List[Product]:
        """
        Gets products that require a prescription.
        """
        return self.product_repo.get_prescription_required_products(db)
    
    def import_new_product(
        self,
        name: str,
        manufacturer: Optional[str],
        description: Optional[str],
        price: float,
        category: Optional[str],
        is_prescription_required: bool,
        image_url: Optional[str] = None # Added image_url parameter
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
        image_url: Optional[str] = None # Added image_url parameter
    ) -> bool:
        """
        Updates an existing product's information.
        """
        # Optional: Add a check if product_id exists before attempting to update
        existing_product = self.product_repo.get_product_by_id(db, product_id)
        if not existing_product:
            raise ValueError(f"Product with ID {product_id} not found for update.")

        success = self.product_repo.update_product(
            product_id, name, manufacturer, description, price, category, is_prescription_required, image_url
        )
        if not success:
            raise Exception(f"Failed to update product with ID {product_id}.")
        return True