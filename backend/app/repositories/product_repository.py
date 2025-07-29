# app/repositories/product_repository.py
from sqlalchemy.orm import Session
from app.models.product import Product # Your SQLAlchemy ORM model
from app.utils.db import get_db_connection
from typing import List, Dict, Any, Optional

class ProductRepository:
    def get_all_products(self, db: Session) -> List[Product]:
        """
        Retrieves all products from the database using ORM.
        """
        return db.query(Product).all()

    def get_product_by_id(self, db: Session, product_id: int) -> Optional[Product]:
        """
        Retrieves a single product by its ID using ORM.
        """
        return db.query(Product).filter(Product.product_id == product_id).first()

    def search_products(self, db: Session, query: str | None = None, category: str | None = None) -> List[Product]:
        """
        Searches for products by name or category using ORM.
        """
        products = db.query(Product)
        if query:
            products = products.filter(Product.name.ilike(f"%{query}%")) # Case-insensitive search
        if category:
            products = products.filter(Product.category.ilike(f"%{category}%"))
        return products.all()

    def get_prescription_required_products(self, db: Session) -> List[Product]:
        """
        Retrieves all products that require a prescription using ORM.
        """
        return db.query(Product).filter(Product.is_prescription_required == True).all()
    
    def import_new_product(
        self,
        name: str,
        manufacturer: Optional[str],
        description: Optional[str],
        price: float,
        category: Optional[str],
        is_prescription_required: bool,
        image_url: Optional[str]
    ) -> Optional[int]:
        """
        Imports a new product using the SP_ImportNewProduct stored procedure.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.callproc(
                    'SP_ImportNewProduct',
                    (name, manufacturer, description, price, category, is_prescription_required, image_url)
                )
                result = cursor.fetchone() # SP returns new_product_id
                connection.commit()
                return result['new_product_id'] if result else None
        finally:
            connection.close()

    def update_product(
        self,
        product_id: int,
        name: str,
        manufacturer: Optional[str],
        description: Optional[str],
        price: float,
        category: Optional[str],
        is_prescription_required: bool,
        image_url: Optional[str]
    ) -> bool:
        """
        Updates an existing product using the SP_UpdateProduct stored procedure.
        Returns True if successful, False otherwise.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # Call the stored procedure
                cursor.callproc(
                    'SP_UpdateProduct',
                    (product_id, name, manufacturer, description, price, category, is_prescription_required, image_url)
                )
                connection.commit()
                # SP_UpdateProduct doesn't return a specific value for success/failure,
                # so we assume success if no error is raised.
                # In a real application, you might want to check cursor.rowcount for affected rows.
                return True
        except Exception as e:
            connection.rollback()
            print(f"Error updating product: {e}") # Log the error
            return False
        finally:
            connection.close()