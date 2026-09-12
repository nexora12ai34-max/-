"""
Authentication endpoint tests
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health_check():
    """Test health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_root():
    """Test root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    assert "service" in response.json()


def test_status():
    """Test status endpoint."""
    response = client.get("/api/status")
    assert response.status_code == 200
    assert response.json()["status"] == "operational"


def test_register_user():
    """Test user registration."""
    response = client.post("/api/auth/register", json={
        "email": "test@example.com",
        "password": "secure_password",
        "full_name": "Test User"
    })
    assert response.status_code == 200
    assert "user_id" in response.json()


def test_login_user():
    """Test user login."""
    # First register
    client.post("/api/auth/register", json={
        "email": "login_test@example.com",
        "password": "test_pass",
        "full_name": "Login Test"
    })
    
    # Then login
    response = client.post("/api/auth/login", json={
        "email": "login_test@example.com",
        "password": "test_pass"
    })
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"


def test_invalid_login():
    """Test login with invalid credentials."""
    response = client.post("/api/auth/login", json={
        "email": "nonexistent@example.com",
        "password": "wrong_password"
    })
    assert response.status_code == 401
