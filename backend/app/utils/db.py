import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv # Optional: for local .env file

# Load environment variables from a .env file if it exists (for local development)
load_dotenv()


DB_HOSTNAME = os.getenv("DATABASE_HOSTNAME", "crossover.proxy.rlwy.net")
DB_USERNAME = os.getenv("DATABASE_USERNAME", "root")
DB_PASSWORD = os.getenv("DATABASE_PASSWORD", "RyOGxHWouZsjMbHPpvGeqpJgNkvCZKQT")
DB_NAME = os.getenv("DATABASE_NAME", "railway")
DB_PORT = os.getenv("DATABASE_PORT", "43399") 

# Construct the database URL
SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOSTNAME}/{DB_NAME}"

# --- Standard SQLAlchemy Setup (no changes needed below) ---
engine = create_engine(SQLALCHEMY_DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# You might need a function to create tables if you don't have one
def create_db_tables():
    # This function is usually called once at startup in main.py
    Base.metadata.create_all(bind=engine)

