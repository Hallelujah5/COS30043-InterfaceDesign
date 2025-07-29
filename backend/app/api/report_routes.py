from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.services.report_service import ReportService
from app.utils.db import get_db # get_db is still needed for dependency injection, even if not directly used in service methods that call SPs
from app.schemas.report import SalesReportRequest, SalesReportItem, ProductDemandReportRequest, ProductDemandReportItem
from typing import List
from datetime import datetime

router = APIRouter(prefix="/reports", tags=["Reports"])

# Dependency to get ReportService instance
def get_report_service() -> ReportService:
    return ReportService()

@router.get("/sales", response_model=List[SalesReportItem])
async def get_sales_report(
    branch_id: int = Query(..., description="ID of the branch for the report"),
    start_date: datetime = Query(..., description="Start date and time for the report (e.g., '2023-01-01T00:00:00')"),
    end_date: datetime = Query(..., description="End date and time for the report (e.g., '2023-01-31T23:59:59')"),
    report_service: ReportService = Depends(get_report_service),
    db: Session = Depends(get_db) # Keep db dependency for consistency, even if not directly used by service for SP calls
):
    """
    Generates a sales report for a specific branch within a given time frame.
    """
    try:
        report_data = report_service.generate_sales_report(branch_id, start_date, end_date)
        return report_data
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")

@router.get("/product-demand", response_model=List[ProductDemandReportItem])
async def get_product_demand_report(
    start_date: datetime = Query(..., description="Start date and time for the report (e.g., '2023-01-01T00:00:00')"),
    end_date: datetime = Query(..., description="End date and time for the report (e.g., '2023-01-31T23:59:59')"),
    limit: int = Query(10, gt=0, description="Number of top products to return"),
    report_service: ReportService = Depends(get_report_service),
    db: Session = Depends(get_db) # Keep db dependency for consistency
):
    """
    Generates a report on high-demand products based on sales data within a given time frame.
    """
    try:
        report_data = report_service.generate_product_demand_report(start_date, end_date, limit)
        return report_data
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Internal server error: {e}")