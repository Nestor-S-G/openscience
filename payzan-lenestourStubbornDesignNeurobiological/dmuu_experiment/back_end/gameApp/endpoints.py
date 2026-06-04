from flask import request, jsonify, send_from_directory, send_file
from flask_restful import Resource, reqparse, inputs
from models import db, Experiments, PDFFileName, Emails
import json
import tablib
from pathlib import Path
from http_status import HttpStatus
from datetime import datetime
from sqlalchemy.orm.exc import MultipleResultsFound, NoResultFound
import io
import zipfile
import shutil
import os

ROOT_FOLDER = "./"
SQLITE3_DB_NAME = "experiments.db"

EXPERIMENT_FOLDER = "./experiments/"
JSON_FOLDER = EXPERIMENT_FOLDER + "json/"
XLS_FOLDER = EXPERIMENT_FOLDER + "xls/"
XLS_FOLDER_TMP = XLS_FOLDER + "tmp/"

QUESTIONNAIRE_FOLDER = "./questionnaire/"
Q_JSON_FOLDER = QUESTIONNAIRE_FOLDER + "json/"
Q_XLS_FOLDER = QUESTIONNAIRE_FOLDER + "xls/"

FINISH_PAGE_FOLDER = "./finishPage/"

EXPERIMENT_STATE_NEW = "NEW"
EXPERIMENT_STATE_IN_PROGRESS = "IN_PROGRESS"
EXPERIMENT_STATE_FINISHED = "FINISHED"

class Home(Resource):
    def get(self):
        return {'about': 'Elise experiment backend'}

CONFIG_FILE = EXPERIMENT_FOLDER + "config.json"
class ConfigFile(Resource):
    # Return config in json
    def get(self):
        json_data = json.load(open(CONFIG_FILE))
        return jsonify(json_data)

    # Take json and store in config file
    def post(self):
        data = request.json
        with open(CONFIG_FILE, "w+") as f:
            f.write(json.dumps(data))
        return {'message': 'Config file updated successfully'}, HttpStatus.CREATED_201.value

# Get a list of all the ids in the database
class FetchList(Resource):
    def get(self):
        experiments = Experiments.query.all()
        experiment_list = Experiments.serialize_list(experiments)

        for experiment in experiment_list:
            status = "Invalid"
            email_entry = Emails.query.filter_by(email=experiment['email']).first()
            if email_entry is not None:
                state = email_entry.experiment_state
                if state == EXPERIMENT_STATE_NEW:
                    status = "New"
                elif state == EXPERIMENT_STATE_IN_PROGRESS:
                    status = "In Progress"
                elif state == EXPERIMENT_STATE_FINISHED:
                    status = "Finished"

            experiment['status'] = status

        return experiment_list, HttpStatus.OK_200.value

# Get using id of the excel file to be grabbed
class FetchExcel(Resource):
    # Create the xls file and save locally a copy
    def save_to_xls(self, id_num):
        Path(XLS_FOLDER).mkdir(parents=True, exist_ok=True)
        xls_data = tablib.Dataset()
        json_data = json.load(open(f"{JSON_FOLDER}{id_num}.json"))
        data = json_data['data']

        xls_data.headers = list(data[0].keys())

        for row in data:
            r = [i for i in list(row.values())]
            xls_data.append(r)

        with open(f"{XLS_FOLDER}{id_num}.xls", "wb") as f:
            f.write(xls_data.export('xls'))

    def get(self, xls_id):
        # Create xls from json
        # Recreate it each time since the json could be updated whenever
        exp = Experiments.query.filter_by(id=xls_id).first()
        if exp is None:
            return {"message": f"Experiment with id {xls_id} doesn't exist"}, HttpStatus.MISSING_404.value

        exp.viewed = True
        db.session.commit()
        self.save_to_xls(xls_id)

        response = send_from_directory(directory=XLS_FOLDER, filename="{}.xls".format(xls_id), cache_timeout=0)
        response.headers['content-type'] = 'application/vnd.ms-excel'
        return response

def zip_files(exp_file_names, qst_file_name):
    """Takes a list of experiment file names and questionnaire file names
    and returns zipped data.

    Since questionnaires are precreated, the list should be pairs of id.xls
    and desired target filename.
    """
    if len(exp_file_names) == 0:
        return None

    data = io.BytesIO()
    with zipfile.ZipFile(data, mode="w") as zpf:
        for file in exp_file_names:
            zpf.write(f"{XLS_FOLDER_TMP}{file}", f"game/{file}")
        for file in qst_file_name:
            zpf.write(f"{Q_XLS_FOLDER}{file[0]}", f"questionnaire/{file[1]}")
    data.seek(0)

    return data

def save_to_xls(id_num, file_name):
    """Convert to json to xls file, return 1 if succeeded.

    Stores the converted xls to temporary xls folder.

    Arguments:
        id_num (int): The id_num of the json file.
        file_name (string): The name of the xls file.
    """
    json_file = f"{JSON_FOLDER}{id_num}.json"

    if not os.path.isfile(json_file):
        return 0

    data = None
    with open(json_file, "r", encoding="UTF-8") as fjson:
        json_data = json.load(fjson)

        if "data" not in json_data:
            return 0

        data = json_data['data']

    if data is None or len(data) == 0:
        return 0

    xls_data = tablib.Dataset()
    xls_data.headers = list(data[0].keys())

    for row in data:
        rnd = list(row.values())
        xls_data.append(rnd)

    with open(f"{XLS_FOLDER_TMP}{file_name}", "wb") as fxls:
        fxls.write(xls_data.export('xls'))

    return 1

def create_exp_list(exp_list):
    """Create experiment list tuple from query.

    Return:
        exp_list_tuple (List):
            List of tuples with the format (id, filename.xls).
            filename.xls does not include full path.
    """
    exp_list_tuple = []

    for entry in exp_list:
        file_name = f"{entry['email']}_{entry['experiment_type']}_id-{entry['id']}.xls"
        exp_list_tuple.append((entry["id"], file_name, entry['email']))

    return exp_list_tuple

def zip_experiments(exp_list):
    """Takes in a list of tuples (id, filename)"""
    tmp_xls_folder = Path(XLS_FOLDER_TMP)
    tmp_xls_folder.mkdir(parents=True, exist_ok=True)
    exp_list_tuple = create_exp_list(exp_list)

    file_list = []
    qst_list = []
    for exp in exp_list_tuple:
        exp_id = exp[0]
        exp_file = exp[1]
        exp_email = exp[2]

        if save_to_xls(exp_id, exp_file):
            file_list.append(exp_file)

            email_entry = Emails.query.filter_by(email=exp_email).first()
            if email_entry is not None:
                xls_id = email_entry.id
                qst_list.append((f"{xls_id}.xls", exp_file))

    # Save to zip file
    zip_data = zip_files(file_list, qst_list)

    shutil.rmtree(tmp_xls_folder)

    return zip_data

class ZipExcel(Resource):
    """Endpoint to experiments as a zip file."""
    def get(self):
        """Zip excel experiments.

        By default only downloads unviewed files.
        Specify in query string all=1 to download all.
        """
        get_all = request.args.get("all")
        if get_all == "1":
            exp_list = Experiments.query.all()
        else:
            exp_list = Experiments.query.filter_by(viewed=False).all()

        for exp in exp_list:
            exp.viewed = True
        db.session.commit()

        zip_data = zip_experiments(Experiments.serialize_list(exp_list))
        if zip_data is not None:
            return send_file(
                zip_data,
                mimetype="application/zip",
                cache_timeout=0
            )

        return {"message": "No experiments found!"}, HttpStatus.MISSING_404.value

class CreateEntry(Resource):

    # Save to json file, need brackets for tablib compatibility
    def save_to_json(self, json_data, id_num):
        Path(JSON_FOLDER).mkdir(parents=True, exist_ok=True)
        with open(f"{JSON_FOLDER}{id_num}.json", "w+") as f:
            f.write(json.dumps(json_data))


    # Save to entry to db to easily access
    # Returns id of entry
    def save_entry_to_db(self, data):
        personal_data = data['personal_info']
        experiment = Experiments(
            first_name=personal_data['first_name'], last_name=personal_data['last_name'], email=personal_data['email'], experiment_type=personal_data['experiment_type'])
        db.session.add(experiment)
        db.session.commit()

        return experiment.id

    def post(self):
        data = request.json
        id_num = self.save_entry_to_db(data)
        self.save_to_json(request.json, id_num)

        return {'id' : id_num}, HttpStatus.CREATED_201.value

# Receive and store experiment data using email as key
class ExperimentDataUpdate(Resource):

    # Save json file, need brackets for tablib compatibility
    def save_to_json(self, json_data, id_num):
        Path(JSON_FOLDER).mkdir(parents=True, exist_ok=True)
        with open(f"{JSON_FOLDER}{id_num}.json", "w+") as f:
            f.write(json.dumps(json_data))

    # Returns id of entry
    def save_entry_to_db(self, data):
        personal_data = data['personal_info']
        experiment = Experiments(
            first_name=personal_data['first_name'], last_name=personal_data['last_name'], email=personal_data['email'], experiment_type=personal_data['experiment_type'])
        db.session.add(experiment)
        db.session.commit()

        return experiment.id

    # Receive an email in the post request
    # Assume email already exists in email database
    def post(self):
        data = request.json
        email = data['personal_info']['email']
        experiment_id = None

        # Check email exists in experiments database otherwise create
        experiment = Experiments.query.filter_by(email=email).first()
        if experiment is None:
            experiment_id = self.save_entry_to_db(data)
        else:
            experiment_id = experiment.id
            experiment.date_completed = datetime.utcnow()

        self.save_to_json(data, experiment_id)

        # Update experiment status to IN_PROGRESS
        email_entry = Emails.query.filter_by(email=email).first()
        email_entry.experiment_state = EXPERIMENT_STATE_IN_PROGRESS
        db.session.commit()

        return {'id' : experiment_id, 'message': 'Successfully received experiment data'}, HttpStatus.CREATED_201.value

# Save the finish screen data and update experiment_status
class SetFinishedPage(Resource):
    # Save json file
    def save_to_json(self, json_data, id_num):
        Path(FINISH_PAGE_FOLDER).mkdir(parents=True, exist_ok=True)
        with open(f"{FINISH_PAGE_FOLDER}{id_num}.json", "w+") as f:
            f.write(json.dumps(json_data))

    def post(self):
        data = request.json
        email = data['email']

        email_entry = Emails.query.filter_by(email=email).first()
        email_id = email_entry.id

        # Update experiment status to FINISHED
        email_entry.experiment_state = EXPERIMENT_STATE_FINISHED
        db.session.commit()

        self.save_to_json(data['finish_data'], email_id)

        return {'id' : email_id, 'message': 'Successfully received finish page data'}, HttpStatus.CREATED_201.value

# Grab the finish screen data
class GetFinishedPage(Resource):

    def post(self):
        data = request.json
        email = data['email']

        email_entry = Emails.query.filter_by(email=email).first()
        email_id = email_entry.id

        json_data = json.load(open(f"{FINISH_PAGE_FOLDER}{email_id}.json"))
        return jsonify(json_data)


# Get the accumulated outcomes from the last row
class GetInProgressData(Resource):
    def post(self):
        data = request.json
        email = data['email']

        experiment = Experiments.query.filter_by(email=email).first()
        if experiment is not None:
            json_data = json.load(open(f"{JSON_FOLDER}{experiment.id}.json"))
            return json_data, HttpStatus.OK_200.value

        return {'message': 'Email not found'}, HttpStatus.MISSING_404.value


class DeleteEntry(Resource):

    def delete_file(self, folder, id_num):
        extension = "json"
        if folder == XLS_FOLDER:
            extension = "xls"
        fileToRemove = Path(f"{folder}{id_num}.{extension}")
        try:
            fileToRemove.unlink()
        except FileNotFoundError as e:
            print(f"Error: {e.filename} - {e.strerror}.")

    def post(self, id_num):
        entryToDelete = Experiments.query.filter_by(id=id_num)
        entryToDelete.delete()
        db.session.commit()
        self.delete_file(JSON_FOLDER, id_num)
        self.delete_file(XLS_FOLDER, id_num)

        return {'id': id_num}, HttpStatus.OK_200.value

class RemakeTable(Resource):
    def get(self):
        Experiments.__table__.drop(db.engine)
        db.create_all()

        return {"message": "Remake table experiments success"}, HttpStatus.OK_200.value

PDF_NAME = "FAQs.pdf"

class GetPDFName(Resource):
    def get(self):
        name = PDFFileName.query.first()
        return name.serialize()

class UploadPDF(Resource):

    def allowed_file(self, filename):
        return '.' in filename and filename.rsplit('.', 1)[1].lower() == 'pdf'

    def post(self):
        # Check if post request has file part
        if 'file' not in request.files:
            return {"message": "Error no file selected"}, HttpStatus.FORBIDDEN_403.value
        file = request.files['file']
        # If user does not select file
        if file.filename == '':
            return {"message": "Error no file selected"}, HttpStatus.FORBIDDEN_403.value
        if file and self.allowed_file(file.filename):
            # Delete the old file first
            fileToRemove = Path(EXPERIMENT_FOLDER + PDF_NAME)
            try:
                fileToRemove.unlink()
            except FileNotFoundError as e:
                print(f"Error: {e.filename} - {e.strerror}.")
            file.save(EXPERIMENT_FOLDER + PDF_NAME)

            # Store the name in database to show to user
            name = PDFFileName.query.first()

            if name is None:
                name = PDFFileName(name=file.filename)
                db.session.add(name)
            else:
                name.name = file.filename
            db.session.commit()

            return {'message' : "File successfully uploaded"}, HttpStatus.CREATED_201.value

        return {"message": "Error file upload failed"}, HttpStatus.FORBIDDEN_403.value

class DownloadPDF(Resource):
    def get(self):
        response = send_from_directory(directory=EXPERIMENT_FOLDER, filename=PDF_NAME, cache_timeout=0)
        response.headers['content-type'] = 'application/pdf'
        return response

# Create email and questionnaire entry
class QuestionnaireCreate(Resource):
    # Save to json file, need brackets for tablib compatibility
    def save_to_json(self, json_data, id_num):
        Path(Q_JSON_FOLDER).mkdir(parents=True, exist_ok=True)
        with open(f"{Q_JSON_FOLDER}{id_num}.json", "w+") as f:
            f.write(json.dumps(json_data))

    # Create the xls file and save locally a copy
    def save_to_xls(self, id_num):
        Path(Q_XLS_FOLDER).mkdir(parents=True, exist_ok=True)
        xls_data = tablib.Dataset()
        json_data = json.load(open(f"{Q_JSON_FOLDER}{id_num}.json"))
        data = json_data['questionnaire']

        xls_data.headers = ["Question", "Value"]

        for row in data.items():
            xls_data.append(row)

        with open(f"{Q_XLS_FOLDER}{id_num}.xls", "wb") as f:
            f.write(xls_data.export('xls'))

    # Save email to db if not exist otherwise reset state
    # Returns id of email
    def save_entry_to_db(self, email):
        email_entry = Emails.query.filter_by(email=email).first()

        if email_entry is None:
            email = Emails(email=email, experiment_state=EXPERIMENT_STATE_NEW)
            db.session.add(email)
            db.session.commit()
            return email.id

        email_entry.experiment_state = EXPERIMENT_STATE_NEW    
        db.session.commit()
        email_id = email_entry.id

        return email_id

    def post(self):
        data = request.json
        email = data['email']
        id_num = self.save_entry_to_db(email)
        self.save_to_json(data, id_num)
        self.save_to_xls(id_num)

        return {'id' : id_num}, HttpStatus.CREATED_201.value

# Get questionnaire entry using email
class QuestionnaireGet(Resource):
    # Expects email in json
    def post(self):
        email = request.json['email']
        email_entry = Emails.query.filter_by(email=email).first()
        if email_entry is None:
            return {"error": "Email doesn't exist!"}, HttpStatus.MISSING_404.value
        xls_id = email_entry.id
        response = send_from_directory(directory=Q_XLS_FOLDER, filename="{}.xls".format(xls_id))
        response.headers['content-type'] = 'application/vnd.ms-excel'
        return response

# Check if email exists in database
class EmailCheck(Resource):

    # Get list of all emails
    def get(self):
        emails = Emails.query.all()
        return Emails.serialize_list(emails), HttpStatus.OK_200.value

    def post(self):
        email = request.json['email']
        email_entry = Emails.query.filter_by(email=email).first() 
        if email_entry is not None:
            return email_entry.serialize(), HttpStatus.OK_200.value
        return {}, HttpStatus.MISSING_404.value

# Reset email back to NEW
class EmailReset(Resource):
    def post(self):
        data = request.json
        email = data['email']

        email_entry = Emails.query.filter_by(email=email).first()
        email_id = email_entry.id

        # Reset experiment status to NEW
        email_entry.experiment_state = EXPERIMENT_STATE_NEW
        db.session.commit()

        return {'id' : email_id, 'message': 'Successfully reset email'}, HttpStatus.OK_200.value

class EmailTableRemake(Resource):
    def get(self):
        Emails.__table__.drop(db.engine)
        db.create_all()

        return {"message": "Remake table emails success"}, HttpStatus.OK_200.value

class DownloadSQLdb(Resource):

    def get(self):
        '''Return download response for sqlite3 database file

        Allow download of sqlite3 experiments.db file for inspection.
        :rtype Response
        '''
        response = send_from_directory(
            directory=ROOT_FOLDER,
            filename=SQLITE3_DB_NAME,
            cache_timeout=0
        )
        response.headers['content-type'] = 'application/vnd.sqlite3'

        return response

class UploadSQLdb(Resource):

    def allowed_file(self, filename):
        return '.' in filename and filename.rsplit('.', 1)[1].lower() == 'db'

    def post(self):
        error_response = ({"message": "Error no file selected"}, HttpStatus.FORBIDDEN_403.value)
        file_name = ROOT_FOLDER + SQLITE3_DB_NAME

        # Check if post request has file part
        if 'file' not in request.files:
            return error_response

        file = request.files['file']
        # If user does not select file
        if file.filename == '':
            return error_response

        if file and self.allowed_file(file.filename):
            # Delete the old file first
            fileToRemove = Path(file_name)

            try:
                fileToRemove.unlink()
                file.save(file_name)
            except Exception as e:
                print(f"Error: {e.strerror}.")

            return {'message' : "Database upload success"}, HttpStatus.CREATED_201.value

        return {"message": "Error database upload failed"}, HttpStatus.FORBIDDEN_403.value

class ExperimentViewed(Resource):
    """RESTFUL API to set experiment as viewed/not viewed.

    By default newly created experiment entries are set as not viewed.
    """
    def __init__(self) -> None:
        """Inits ExperimentViewed Resource with argparser."""
        self.reqparse = reqparse.RequestParser()
        self.reqparse.add_argument(
            "id",
            type=int,
            help="Please provide id of experiment",
            required=True
        )
        self.reqparse.add_argument(
            "viewed",
            type=inputs.boolean,
            help="Please provide value of viewed to set",
            required=True
        )
        super(ExperimentViewed, self).__init__()

    def post(self):
        """POST request to set viewed value.

        Viewed value is used for filtering experiment entries
        based on whether they have been viewed.

        Args:
            id (int): ID of the experiment entry.
            viewed (bool): Viewed status of the experiment entry.
        """
        args = self.reqparse.parse_args()
        exp_id = args.get("id")
        viewed = args.get("viewed")

        try:
            experiment = Experiments.query.filter_by(id=exp_id).one()
            experiment.viewed = viewed
            db.session.commit()
        except NoResultFound:
            return (
                {"message": f"Experiment with id {exp_id} not found"},
                HttpStatus.MISSING_404.value
            )
        except MultipleResultsFound:
            return (
                {"message": f"Multiple experiments with id {exp_id} found"},
                HttpStatus.BAD_REQUEST_400.value
            )

        return {}, HttpStatus.NO_CONTENT_SUCCESS_204.value
