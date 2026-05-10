import React, { Component } from "react";
import { Row } from "react-bootstrap";
import axios from "axios";
import * as Survey from "survey-react";
import surveyJson from "./questionnaire.json";
import "./Questionnaire.css";
import "survey-react/survey.css";
import "./mySurvey.css";
import { BACKEND_API_QCREATE } from "../../backend_interface/backend_url";

const completedHtml = `<p><h2>Thanks very much for your time. Your replies have been recorded and you can now return to the experiment.</h2></p><p><h2>The BizLab Team.</h2></p><p><h2><a href="${process.env.PUBLIC_URL}">Click here to return to the experiment</a></h2></p>`;

class Questionnaire extends Component {
    constructor(props) {
        super(props);

        surveyJson.completedHtml = completedHtml;
        this.surveryModel = new Survey.Model(surveyJson);
    }

    onComplete(survey, options) {
        axios
            .post(BACKEND_API_QCREATE, survey.data)
            .then(() => {
                console.log("Successfully sent to backend");
            })
            .catch(() => {
                console.log("Failed to send to backend");
            });
    }

    render() {
        return (
            <div className="Questionnaire">
                <Row>
                    <h1>
                        Thanks a lot for agreeing to participate in The
                        Decision-Making Under Uncertainty Experiment!
                    </h1>
                </Row>
                <Row>
                    <h3>
                        As part of the experiment, it is important that you tell
                        us a bit about yourself by answering the following
                        questions. All the data collected for the experiment
                        will not reveal your identity. In other words, this
                        study is confidential.
                    </h3>
                </Row>
                <Survey.Survey
                    model={this.surveryModel}
                    onComplete={this.onComplete}
                />
            </div>
        );
    }
}

export default Questionnaire;
