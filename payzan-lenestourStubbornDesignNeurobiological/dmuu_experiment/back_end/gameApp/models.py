from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Experiments(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(20), nullable=False)
    last_name = db.Column(db.String(20), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    experiment_type = db.Column(db.String(20), nullable=False)
    date_completed = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    viewed = db.Column(db.Boolean, nullable=False, default=False)

    @staticmethod
    def serialize_list(l):
        return [m.serialize() for m in l]

    def serialize(self):
        return {
            "id": self.id,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "experiment_type": self.experiment_type,
            "date_completed": self.date_completed.isoformat(),
            "viewed": self.viewed
        }

    def __repr__(self):
        return f"Name: {self.first_name} {self.last_name} ID: {self.id}"

class Emails(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    experiment_state = db.Column(db.String(20), nullable=False)

    @staticmethod
    def serialize_list(l):
        return [m.serialize() for m in l]

    def serialize(self):
        return {"id": self.id, "email": self.email, "experiment_state": self.experiment_state}

class PDFFileName(db.Model):
    name = db.Column(db.String(120), primary_key=True)

    def serialize(self):
        return {"file_name": self.name}