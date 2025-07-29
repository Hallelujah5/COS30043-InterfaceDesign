from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os
import pymysql

# Nhập đối tượng Base từ gói models của bạn
# Đây là Base duy nhất mà tất cả các model của bạn sẽ kế thừa
from app.models.base import Base

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL", "mysql+pymysql://root:root@localhost/pharmacy_db")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Hàm này tạo kết nối PyMySQL trực tiếp, dùng cho các Stored Procedure
def get_db_connection():
    connection = pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "root"),
        database=os.getenv("DB_NAME", "pharmacy_db"),
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection

# Dependency cho FastAPI để cung cấp session SQLAlchemy
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Hàm này sẽ tạo tất cả các bảng được định nghĩa trong SQLAlchemy models
# Nó cần được gọi sau khi tất cả các model đã được load vào bộ nhớ
def create_db_tables():
    Base.metadata.create_all(bind=engine)