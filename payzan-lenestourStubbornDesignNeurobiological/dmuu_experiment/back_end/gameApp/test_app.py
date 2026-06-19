""" Test the Flask RESTFUL api for decision making under uncertainty backend.
"""
import os
import tempfile

import pytest

from flask import Flask
from flask_restful import Api
from models import db

@pytest.fixture
def client():
    """Sets up the sqlite database and hooks up all the REST api endpoints to urls.

    Uses a temporary file for the database which is created and deleted after the test.
    """
    app = Flask(__name__, static_folder="../questionnaire/build", static_url_path="/")

    app.testing = True

    # Set up temporary database for testing
    db_fd, db_path = tempfile.mkstemp()
    app.config['SQLALCHEMY_DATABASE_URI'] = f"sqlite:///{db_path}"
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)
    api = Api(app)

    @app.after_request
    def after_request(response):
        """Add cross-site origin headers to all responses.
        """
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
        response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
        return response

    # Routes
    @app.route('/questionnaire')
    def index():
        """Serve the statically compiled React web app.
        """
        return app.send_static_file('index.html')

    # API routes
    # pylint: disable=import-outside-toplevel
    import endpoints as dmuu_ep # Import after initializing db

    api.add_resource(dmuu_ep.Home, '/about')
    api.add_resource(dmuu_ep.FetchExcel, '/fetchxls/<xls_id>')
    api.add_resource(dmuu_ep.CreateEntry, '/create')
    api.add_resource(dmuu_ep.ExperimentDataUpdate, '/exUpdate')
    api.add_resource(dmuu_ep.DeleteEntry, '/delete/<id_num>')
    api.add_resource(dmuu_ep.FetchList, '/list')
    api.add_resource(dmuu_ep.RemakeTable, '/remakeTable')
    api.add_resource(dmuu_ep.UploadPDF, '/uploadpdf')
    api.add_resource(dmuu_ep.DownloadPDF, '/fetchpdf')
    api.add_resource(dmuu_ep.GetPDFName, '/pdfname')
    api.add_resource(dmuu_ep.ConfigFile, '/config')
    api.add_resource(dmuu_ep.QuestionnaireCreate, '/qcreate')
    api.add_resource(dmuu_ep.QuestionnaireGet, '/qget')
    api.add_resource(dmuu_ep.EmailCheck, '/emails')
    api.add_resource(dmuu_ep.EmailReset, '/emailReset')
    api.add_resource(dmuu_ep.EmailTableRemake, "/remakeEmailTable")
    api.add_resource(dmuu_ep.SetFinishedPage, "/setFinish")
    api.add_resource(dmuu_ep.GetFinishedPage, "/getFinish")
    api.add_resource(dmuu_ep.GetInProgressData, "/getInProgress")
    api.add_resource(dmuu_ep.DownloadSQLdb, '/fetchdb')
    api.add_resource(dmuu_ep.UploadSQLdb, '/uploaddb')
    api.add_resource(dmuu_ep.ExperimentViewed, '/api/viewed')

    with app.test_client() as client_app:
        with app.app_context():
            db.create_all()
        yield client_app

    os.close(db_fd)
    os.unlink(db_path)

# pylint: disable=redefined-outer-name
def test_home(client):
    """Test the about page"""
    res = client.get('/about')

    assert res.status_code == 200
    data = res.get_json()
    assert "about" in data
    assert data["about"] == "Elise experiment backend"

# pylint: disable=redefined-outer-name
def test_viewed_set(client):
    """Test setting the viewed parameter"""
    exp_entry = {
        "personal_info": {
            "first_name": "test",
            "last_name": "test",
            "email": "test@test.com",
            "experiment_type": "test"
        },
        "data": []
    }

    # Create a single entry
    res = client.post("/create", json=exp_entry)

    assert res.status_code == 201
    assert res.get_json() == {"id": 1}

    # Test set true
    res = client.post("/api/viewed", json={
        "id": 1,
        "viewed": True
    })

    assert res.status_code == 204

    res = client.get("/list")

    assert res.status_code == 200
    data = res.get_json()
    assert len(data) == 1
    assert data[0]["viewed"] is True

    # Test set false
    res = client.post("/api/viewed", json={
        "id": 1,
        "viewed": False
    })

    assert res.status_code == 204

    res = client.get("/list")

    assert res.status_code == 200
    data = res.get_json()
    assert len(data) == 1
    assert data[0]["viewed"] is False

    # Test invalid ids
    # id doesn't exist
    res = client.post("/api/viewed", json={
        "id": 2,
        "viewed": False
    })

    assert res.status_code == 404
    data = res.get_json()
    assert data == {"message": "Experiment with id 2 not found"}

    # id incorrect type
    res = client.post("/api/viewed", json={
        "id": "two",
        "viewed": False
    })

    assert res.status_code == 400
    data = res.get_json()
    assert data == {
        "message": {
            "id": "Please provide id of experiment"
        }
    }

    # Test invalid viewed value
    # viewed incorrect type
    res = client.post("/api/viewed", json={
        "id": 1,
        "viewed": "nope"
    })

    assert res.status_code == 400
    data = res.get_json()
    assert data == {
        "message": {
            "viewed": "Please provide value of viewed to set"
        }
    }

    # Test missing fields
    res = client.post("/api/viewed", json={})

    assert res.status_code == 400
    data = res.get_json()
    assert data == {
        "message": {
            "id": "Please provide id of experiment"
        }
    }
