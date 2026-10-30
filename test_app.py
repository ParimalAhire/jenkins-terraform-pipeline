from app import app


def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_home_page_loads():
    response = client().get("/")
    assert response.status_code == 200
    assert b"Deployed by Jenkins" in response.data


def test_health_endpoint():
    response = client().get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_version_endpoint_returns_json():
    response = client().get("/version")
    assert response.status_code == 200
    assert "version" in response.get_json()
