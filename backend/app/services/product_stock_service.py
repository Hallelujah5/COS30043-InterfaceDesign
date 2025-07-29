from sqlalchemy.orm import Session
from app.repositories.product_stock_repository import ProductStockRepository
from app.models.product_stock import ProductStock
from typing import List, Dict, Any, Optional

class ProductStockService:
    def __init__(self):
        self.product_stock_repo = ProductStockRepository()

    def get_branch_product_stock_status(self, branch_id: int) -> List[Dict[str, Any]]:
        """
        Gets the product stock status for a specific branch.
        """
        # You might want to check if the branch_id exists first.
        # For simplicity, relying on the SP to return empty list if branch_id is invalid.
        return self.product_stock_repo.get_branch_product_stock_status(branch_id)

    def restock_product(self, branch_id: int, product_id: int, quantity_to_add: int):
        """
        Adds stock to a product at a branch.
        """
        if quantity_to_add <= 0:
            raise ValueError("Quantity to add must be positive.")
        self.product_stock_repo.restock_product(branch_id, product_id, quantity_to_add)
        return {"message": "Product restocked successfully."}

    def get_low_stock_products(self, db: Session, branch_id: Optional[int] = None) -> List[ProductStock]:
        """
        Gets products with stock quantity below min_stock_level.
        """
        return self.product_stock_repo.get_low_stock_products(db, branch_id)

    def update_min_stock_level(self, db: Session, branch_id: int, product_id: int, new_min_stock_level: int) -> ProductStock:
        """
        Updates the minimum stock level for a product at a branch.
        """
        if new_min_stock_level < 0:
            raise ValueError("Minimum stock level cannot be negative.")

        updated_item = self.product_stock_repo.update_min_stock_level(db, branch_id, product_id, new_min_stock_level)
        if not updated_item:
            raise ValueError(f"ProductStock item for product {product_id} at branch {branch_id} not found.")
        return updated_item