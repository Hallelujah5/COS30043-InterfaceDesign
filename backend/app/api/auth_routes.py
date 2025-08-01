from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.services.auth_service import AuthService
from app.utils.db import get_db
from app.schemas.auth import LoginRequest, LoginResponse
from typing import Dict, Any
from app.utils.auth import create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES
from datetime import timedelta

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Dependency to get AuthService instance
def get_auth_service() -> AuthService:
    return AuthService()

@router.post("/customers/login", response_model=LoginResponse)
async def customer_login(
    request: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
    db: Session = Depends(get_db)
):
    """
    Authenticates a customer's login credentials.
    """
    auth_result = auth_service.customer_login(db, request.email, request.password)
    if not auth_result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid customer credentials or account inactive."
        )
    # Create the JWT
    expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token = create_access_token(data={"sub": auth_result["email"]}, expires_delta=expires)
    
    # Add the token to the response
    auth_result["access_token"] = token
    auth_result["token_type"] = "bearer"
    
    return LoginResponse(**auth_result)

@router.post("/staff/login", response_model=LoginResponse)
async def staff_login(
    request: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
    db: Session = Depends(get_db)
):
    """
    Authenticates a staff member's login credentials.
    """
    auth_result = auth_service.staff_login(db, request.email, request.password)
    if not auth_result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid staff credentials or account inactive."
        )
    # Create the JWT
    expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token = create_access_token(data={"sub": auth_result["email"]}, expires_delta=expires)

    # Add the token to the response
    auth_result["access_token"] = token
    auth_result["token_type"] = "bearer"
    return LoginResponse(**auth_result)