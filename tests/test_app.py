import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    return app.test_client()

def test_hello_endpoint(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"The current time:" in response.data

