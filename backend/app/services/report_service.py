from sqlalchemy.orm import Session
from app.utils.db import get_db_connection # For calling stored procedures
from app.schemas.report import SalesReportItem, ProductDemandReportItem
from typing import List, Dict, Any
from datetime import datetime

class ReportService:
    def __init__(self):
        # No specific repository for reports as per design,
        # so direct DB interaction for SPs or complex queries.
        pass

    def generate_sales_report(self, branch_id: int, start_date: datetime, end_date: datetime) -> List[SalesReportItem]:
        """
        Generates a sales report for a specific branch within a time period using SP_GenerateSalesReport.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # Call the stored procedure
                cursor.callproc(
                    'SP_GenerateSalesReport',
                    (branch_id, start_date.strftime('%Y-%m-%d %H:%M:%S'), end_date.strftime('%Y-%m-%d %H:%M:%S'))
                )
                results = cursor.fetchall()
                # Convert results to Pydantic models
                return [SalesReportItem(**item) for item in results]
        except Exception as e:
            print(f"Error generating sales report via SP: {e}")
            raise
        finally:
            connection.close()

    def generate_product_demand_report(self, start_date: datetime, end_date: datetime, limit: int = 10) -> List[ProductDemandReportItem]:
        """
        Analyzes order data to identify high-demand products over a period.
        This uses a direct SQL query as no specific SP was provided for product demand.
        """
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                # SQL query to aggregate product demand
                query = """
                    SELECT
                        P.product_id,
                        P.name AS product_name,
                        SUM(OI.quantity) AS total_quantity_ordered,
                        SUM(OI.quantity * OI.unit_price) AS total_revenue
                    FROM
                        Orders O
                    JOIN
                        OrderItems OI ON O.order_id = OI.order_id
                    JOIN
                        Products P ON OI.product_id = P.product_id
                    WHERE
                        O.order_date BETWEEN %s AND %s
                        AND O.order_status IN ('Paid', 'Processing', 'Ready for Pickup', 'Delivered')
                    GROUP BY
                        P.product_id, P.name
                    ORDER BY
                        total_quantity_ordered DESC, total_revenue DESC
                    LIMIT %s;
                """
                cursor.execute(query, (start_date.strftime('%Y-%m-%d %H:%M:%S'), end_date.strftime('%Y-%m-%d %H:%M:%S'), limit))
                results = cursor.fetchall()
                return [ProductDemandReportItem(**item) for item in results]
        except Exception as e:
            print(f"Error generating product demand report: {e}")
            raise
        finally:
            connection.close()