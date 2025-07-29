@REM ==============================================================================================
@REM THIS .BAT FILE IS CREATED TO AUTOMATIC SETUP, AND CAN ONLY WORK ON WINDOWS, USING IS OPTIONAL.
@REM ==============================================================================================

@echo off
REM Set up paths
set FRONTEND_DIR=frontend
set BACKEND_DIR=backend

REM Open frontend dev server in a new terminal
start cmd /k "cd /d %~dp0%FRONTEND_DIR% && npm run dev"

REM Activate backend venv and run FastAPI
cd /d %~dp0%BACKEND_DIR%
call .\venv\Scripts\activate
uvicorn app.main:app --reload
