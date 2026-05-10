import React, { Component } from "react";
import { connect } from "react-redux";
import { Container, Row } from "react-bootstrap";
import { Link, withRouter } from "react-router-dom";
import { Button } from "react-bootstrap";
import { sendDummyDataToBackend } from "../../backend_interface/outputFile/outputFileTest";
import FinalEarningTest from "./FinalEarningTest";
import UploadFAQ from "./UploadFAQ";
import DebugPanel from "./Debug";
import { backendStressTest } from "../../backend_interface/backendStressTest";
import { BACKEND_URL } from "../../backend_interface/backend_url";
import preval from 'preval.macro';
import ManageDb from "./ManageDb";

class Admin extends Component {
    exitAdmin = () => {
        this.props.history.push("/");
    };

    render() {
        return (
            <Container>
                <Row>
                    <h1>Admin Dashboard</h1>
                </Row>
                <Row>
                    <p>Last updated: {preval`module.exports = new Date().toLocaleString();`}</p>
                </Row>
                <Row>
                    <p>Backend url: {BACKEND_URL}</p>
                </Row>
                <Row className="mt-5">
                    <Link 
                        data-test-id="cy-Admin-editconfig"
                        className="btn btn-primary" to="/admin/config">
                        Edit Config
                    </Link>
                </Row>
                <UploadFAQ />
                <Row className="mt-5">
                    <Link className="btn btn-primary" to="/admin/experiments">
                        Experiments Download Page
                    </Link>
                </Row>
                <Row className="mt-5">
                    <h5>Make sure that debug@debug.com has done questionnaire for below tests.</h5>
                </Row>
                <Row className="mt-5">
                    <h5 data-test-id="cy-Admin-current-email">
                        Current email: {this.props.email === null ? "no email set" : this.props.email}
                    </h5>
                </Row>
                <FinalEarningTest />
                <DebugPanel/>
                <Row className="mt-5">
                    <h5>Developer tools</h5>
                </Row>
                <Row className="mt-5">
                    <Button onClick={sendDummyDataToBackend}>
                        Send dummy data to backend
                    </Button>
                </Row>
                <Row className="mt-5">
                    <Button onClick={backendStressTest}>
                        Stress test backend
                    </Button>
                </Row>
                <ManageDb />
                <Row className="mt-5">
                    <p>
                        Short version of the game to test functionality quickly
                    </p>
                </Row>
                <Row>
                    <Link
                        className="btn btn-primary"
                        to={{
                            pathname: "/test/game_debug",
                        }}
                    >
                        Test game
                    </Link>
                </Row>
                <Row className="mt-5">
                    <div className="btn btn-primary" onClick={this.exitAdmin}>
                        Exit Admin Dashboard
                    </div>
                </Row>
            </Container>
        );
    }
}

const mapStateToProps = (state) => {
    return {
        email: state.stats.personal_info.email,
    };
};

export default connect(mapStateToProps)(withRouter(Admin));
