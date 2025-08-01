# app/utils/auth.py
import os
from datetime import datetime, timedelta
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from app.repositories.customer_repository import CustomerRepository
from app.models.customer import Customer
from app.utils.db import get_db

# --- Configuration ---
# For production, load this from environment variables or a config file
SECRET_KEY = "your-super-secret-key-that-is-long-and-random"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30 # Token validity period

# --- Password Hashing ---
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# --- OAuth2 Scheme ---
# This tells FastAPI to look for a "Bearer" token in the Authorization header.
# The `tokenUrl` points to your future login endpoint.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/customers/login")


# --- Utility Functions ---
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain password against a hashed one."""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Creates a new JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    # The 'sub' (subject) claim is a standard for identifying the user
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


# --- The Core Dependency ---
def get_current_active_customer(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> Customer:
    """
    Dependency to get the current authenticated and active customer.
    This is what you will use to protect your routes.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    repo = CustomerRepository()
    customer = repo.get_customer_by_email(db, email=email) #
    if customer is None:
        raise credentials_exception

    if not customer.is_active: #
        raise HTTPException(status_code=400, detail="Inactive user")

    return customer