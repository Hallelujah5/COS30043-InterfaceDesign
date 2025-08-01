from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from fastapi import Request
from fastapi.responses import RedirectResponse


from app.api.customer_routes import router as customer_router
from app.api.order_routes import router as order_router
from app.api.staff_routes import router as staff_router
from app.api.product_routes import router as product_router
from app.api.product_stock_routes import router as product_stock_router
from app.api.payment_routes import router as payment_router
from app.api.prescription_routes import router as prescription_router
from app.api.auth_routes import router as auth_router
from app.api.branch_routes import router as branch_router
from app.api.report_routes import router as report_router
from app.api.deliveries_routes import router as deliveries_router
from app.api.receipt_routes import router as receipt_router

# Quan trọng: Import tất cả các model để Base.metadata.create_all() có thể nhận diện chúng
# Cách này sẽ tải tất cả các model thông qua app/models/__init__.py
from app.models import *

# Import hàm tạo bảng từ db.py
from app.utils.db import create_db_tables


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")

app = FastAPI(title="Pharmacy Management API")

origins = [
    "*" # For the live Vercel deployment
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins, 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")



# Bao gồm các router API
app.include_router(customer_router)
app.include_router(order_router)
app.include_router(staff_router)
app.include_router(product_router)
app.include_router(product_stock_router)
app.include_router(payment_router)
app.include_router(prescription_router)
app.include_router(auth_router)
app.include_router(branch_router)
app.include_router(report_router)
app.include_router(deliveries_router)
app.include_router(receipt_router)

# Sự kiện khởi động ứng dụng: Tạo các bảng cơ sở dữ liệu nếu chúng chưa tồn tại
@app.on_event("startup")
async def startup_event():
    print("Ứng dụng đang khởi động...")
    # Gọi hàm để tạo các bảng cơ sở dữ liệu
    create_db_tables()
    print("Đã kiểm tra và tạo (nếu cần) các bảng cơ sở dữ liệu.")

@app.get("/")
async def root():
    return {"message": "Welcome to Pharmacy Management API"}


# @app.middleware("http")
# async def enforce_https(request: Request, call_next):
#     if request.url.scheme == "http":
#         https_url = request.url.replace(scheme="https")
#         return RedirectResponse(url=str(https_url))
#     return await call_next(request)