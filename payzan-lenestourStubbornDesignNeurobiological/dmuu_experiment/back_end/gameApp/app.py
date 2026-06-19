"""Flask RESTFUL api for decision making under uncertainty backend.

Sets up the sqlite database and hooks up all the REST api endpoints to urls.
"""
from flask import Flask
from flask_restful import Api
from models import db

app = Flask(__name__, static_folder="../frontend", static_url_path="/")

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///experiments.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
api = Api(app)

with app.app_context():
    db.create_all()

@app.after_request
def after_request(response):
    """Add cross-site origin headers to all responses.
    """
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
    return response

# Routes
@app.route('/')
def index():
    """Serve the statically compiled React web app.
    """
    return app.send_static_file('index.html')

# API routes
# pylint: disable=wrong-import-position
import endpoints as dmuu_ep # Import after initializing db

api.add_resource(dmuu_ep.Home, '/about')
api.add_resource(dmuu_ep.FetchExcel, '/fetchxls/<xls_id>')
api.add_resource(dmuu_ep.ZipExcel, '/api/zipxls')
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

if __name__ == '__main__':
    app.run(debug=True)
