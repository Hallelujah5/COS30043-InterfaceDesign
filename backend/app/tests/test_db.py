import sys
import os
# Add the backend directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))
from app.utils.db import get_db_connection, SessionLocal
import pymysql
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.sql import text

def test_raw_connection():
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            print(f"Raw PyMySQL connection test: {result}")
    except pymysql.Error as e:
        print(f"Raw connection failed: {str(e)}")
    finally:
        conn.close()

def test_orm_connection():
    try:
        with SessionLocal() as db:
            result = db.execute(text("SELECT 1")).fetchone()
            print(f"ORM connection test: {result}")
    except SQLAlchemyError as e:
        print(f"ORM connection failed: {str(e)}")

if __name__ == "__main__":
    print("Testing database connections...")
    test_raw_connection()
    test_orm_connection()

# cd pharmacy-management/backend/
# python -m app.tests.test_db
