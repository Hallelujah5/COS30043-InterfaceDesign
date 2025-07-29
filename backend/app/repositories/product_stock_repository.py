from sqlalchemy.orm import Session
from app.models.product_stock import ProductStock
from app.utils.db import get_db_connection
from typing import List, Dict, Any, Optional

class ProductStockRepository:
    def get_branch_product_stock_status(self, branch_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves the product stock status for a specific branch using SP_GetBranchProductStockStatus.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc('SP_GetBranchProductStockStatus', (branch_id,))
                result = cursor.fetchall()
                return result
        finally:
            connection.close()

    def restock_product(self, branch_id: int, product_id: int, quantity_to_add: int):
        """
        Adds stock to a product at a branch using SP_RestockProductStock.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc('SP_RestockProductStock', (branch_id, product_id, quantity_to_add))
                connection.commit()
                # SP_RestockProductStock doesn't return anything directly, relies on Notifications trigger
        finally:
            connection.close()

    def get_low_stock_products(self, db: Session, branch_id: Optional[int] = None) -> List[ProductStock]:
        """
        Retrieves products with stock quantity below min_stock_level using ORM.
        A stored procedure might be efficient here, but for now using ORM query.
        """
        query = db.query(ProductStock).filter(ProductStock.stock_quantity <= ProductStock.min_stock_level)
        if branch_id:
            query = query.filter(ProductStock.branch_id == branch_id)
        return query.all()

    def update_min_stock_level(self, db: Session, branch_id: int, product_id: int, new_min_stock_level: int) -> Optional[ProductStock]:
        """
        Updates the minimum stock level for a product at a branch using ORM.
        """
        product_stock_item = db.query(ProductStock).filter(
            ProductStock.branch_id == branch_id,
            ProductStock.product_id == product_id
        ).first()

        if product_stock_item:
            product_stock_item.min_stock_level = new_min_stock_level
            db.commit()
            db.refresh(product_stock_item)
        return product_stock_item