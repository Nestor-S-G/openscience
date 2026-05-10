import React, { Component } from "react";
import { Row } from "react-bootstrap";

export default class FillOutQuiz extends Component {
    render() {
        return (
            <Row className={this.props.className}>
                <h3>
                    In the meantime, please fill out this short questionnaire
                    (please make sure you do pay attention and don't rush, as it
                    won't get you out of here earlier in any case ;-)
                </h3>
            </Row>
        );
    }
}
