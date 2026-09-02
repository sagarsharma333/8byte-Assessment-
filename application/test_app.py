from app import app

# i take for literall the meaning for dummy sorry
# but real health checks and tests should be more complex and check the database connection and other dependencies

def test_health_endpoint():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200