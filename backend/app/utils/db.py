# FILE: app/utils/db.py
# REASON FOR CHANGE: Added the missing `get_db_connection` function required by the
# CustomerRepository to execute stored procedures.

import os
import pymysql # Import pymysql for raw connections
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Load environment variables from a .env file if it exists (for local development)
load_dotenv()

# --- Read Database Credentials from Environment Variables ---
DB_HOSTNAME = os.getenv("DATABASE_HOSTNAME", "crossover.proxy.rlwy.net")
DB_USERNAME = os.getenv("DATABASE_USERNAME", "root")
DB_PASSWORD = os.getenv("DATABASE_PASSWORD", "RyOGxHWouZsjMbHPpvGeqpJgNkvCZKQT")
DB_NAME = os.getenv("DATABASE_NAME", "railway")
DB_PORT = int(os.getenv("DATABASE_PORT", "43399")) # Convert port to integer

# --- SQLAlchemy ORM Setup (for standard queries) ---
SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOSTNAME}:{DB_PORT}/{DB_NAME}"
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_db_connection():
    """
    Creates and returns a raw PyMySQL database connection.
    This is used for calling stored procedures that don't work with the ORM.
    """
    try:
        connection = pymysql.connect(
            host=DB_HOSTNAME,
            user=DB_USERNAME,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=DB_PORT,
            cursorclass=pymysql.cursors.DictCursor # Returns results as dictionaries
        )
        return connection
    except pymysql.MySQLError as e:
        print(f"Error connecting to MySQL database: {e}")
        return None

# This function is usually called once at startup in main.py
def create_db_tables():
    Base.metadata.create_all(bind=engine)
