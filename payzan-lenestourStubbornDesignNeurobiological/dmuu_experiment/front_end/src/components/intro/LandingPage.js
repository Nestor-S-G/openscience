// The landing page

import axios from "axios";
import React, { Component } from "react";
import { Container, Row, Image, Button } from "react-bootstrap";
import { Link } from "react-router-dom";
import { connect } from "react-redux";
import { BACKEND_API_EMAIL, BACKEND_API_GETFIN, BACKEND_API_GETINPROG } from "../../backend_interface/backend_url";
import { setPersonalInfoEmail } from "../../redux/playerStats/playerStatsActions";
import { getPlayerStats } from "../../backend_interface/outputFile/outputFile";
import { configForceControl, configForceTest } from "../../redux/config/configActions";

const SPACE_BAR_KEY_CODE = 32;
const LEFT_BRACKET_KEY_CODE = 219;
const RIGHT_BRACKET_KEY_CODE = 221;

class LandingPage extends Component {
    state = {
        reveal_admin: false,
        value: "",
        verified: null,
        experiment_state: null,
        finish_data: null,
        force_test: false,
        force_control: false
    };

    getInProgressData = (email) => {
        axios
            .post(BACKEND_API_GETINPROG, { email: email })
            .then((res) => {
                this.setState(
                    {
                        verified: true,
                        finish_data: getPlayerStats(res.data),
                    },
                    () => this.props.saveEmail(email)
                );
            })
            .catch(() => console.log("Error getting inProgress data"));
    };

    getFinishData = (email) => {
        axios
            .post(BACKEND_API_GETFIN, { email: email })
            .then((res) => {
                this.setState(
                    {
                        verified: true,
                        finish_data: res.data,
                    },
                    () => this.props.saveEmail(email)
                );
            })
            .catch(() => console.log("Error getting finish data"));
    };

    checkEmail = () => {
        const email = this.state.value;
        axios
            .post(BACKEND_API_EMAIL, { email })
            .then((res) => {
                console.log("Email found!");

                if (res.data.experiment_state === "FINISHED") {
                    this.setState(
                        { experiment_state: res.data.experiment_state },
                        this.getFinishData(email)
                    );
                } else if (res.data.experiment_state === "IN_PROGRESS") {
                    this.setState(
                        { experiment_state: res.data.experiment_state },
                        this.getInProgressData(email)
                    );
                } else {
                    this.setState(
                        {
                            verified: true,
                            experiment_state: res.data.experiment_state,
                        },
                        () => this.props.saveEmail(email)
                    );
                }
            })
            .catch(() => {
                console.log("Email not found!");
                this.setState({ verified: false }, () =>
                    this.props.saveEmail(null)
                );
            });
    };

    componentDidMount() {
        document.addEventListener("keydown", this.keypress, false);
    }

    componentWillUnmount() {
        document.removeEventListener("keydown", this.keypress, false);
    }

    keypress = (e) => {
        if (e.keyCode === SPACE_BAR_KEY_CODE) {
            this.setState({ reveal_admin: !this.state.reveal_admin });
        } else if (e.keyCode === LEFT_BRACKET_KEY_CODE) {
            this.props.forceTest();
            this.setState({ force_test: true, force_control: false });
        } else if (e.keyCode === RIGHT_BRACKET_KEY_CODE) {
            this.props.forceControl();
            this.setState({ force_control: true, force_test: false });
        }
    };

    forceTestMsg = () => {
        if (this.state.force_test)
            return (<Row><h5>Running experiment type T</h5></Row>);
        else if (this.state.force_control)
            return (<Row><h5>Running experiment type C</h5></Row>);
    };

    showAdminButton = () => {
        if (this.state.reveal_admin) {
            return (
                <Row className="mt-5 justify-content-center">
                    <Link className="btn btn-primary" to="/admin">
                        Go to Admin
                    </Link>
                </Row>
            );
        }
    };

    onChangeEmail = (e) => {
        this.setState({ value: e.target.value });
    };

    emailCheckPrompt = () => {
        return (
            <>
                <Row className="mt-5">
                    <h5>Enter your email to get started: </h5>
                </Row>
                <Row className="mt-1">
                    <input
                        data-test-id="cy-LandingPage-enter-email"
                        type="email"
                        value={this.state.value}
                        onChange={this.onChangeEmail}
                    />
                </Row>
                <Row className="mt-2">
                    <Button 
                        data-test-id="cy-LandingPage-checkEmail-button" 
                        onClick={this.checkEmail}
                    >
                        Check Email
                    </Button>
                </Row>
            </>
        );
    };

    proceedMsg = () => {
        if (this.state.verified === true) {
            let link = (
                <Link className="btn btn-primary" to="/instructions">
                    Proceed
                </Link>
            );
            switch (this.state.experiment_state) {
                case "FINISHED":
                    link = (
                        <Link
                            className="btn btn-primary"
                            to={{
                                pathname: "/finish",
                                data: {
                                    finishSkip: true,
                                    finish_data: this.state.finish_data,
                                    suppressOutput: true,
                                },
                            }}
                        >
                            Proceed
                        </Link>
                    );
                    break;

                case "IN_PROGRESS":
                    const { params } = this.props.config;
                    const { round_data, personal_info } = this.state.finish_data;
                    const in_progress_net = round_data[round_data.length - 1].accumulated_outcomes;
                    link = (
                        <Link
                            className="btn btn-primary"
                            to={{
                                pathname: "/finish",
                                data: {
                                    finishInProgress: true,
                                    playerStats: this.state.finish_data,
                                    experiment_type: personal_info.experiment_type,
                                    net: in_progress_net,
                                    low_color: params.color.low_name,
                                    high_color: params.color.high_name,
                                    threshold: params.threshold,
                                    multiplier: params.multiplier,
                                    suppressOutput: false,
                                },
                            }}
                        >
                            Proceed
                        </Link>
                    );
                    break;

                case "NEW":
                default:
                    break;
            }
            return (
                <>
                    <Row className="mt-5 justify-content-center">
                        <h5>Email found! Please proceed.</h5>
                    </Row>
                    <Row className="mt-2 justify-content-center">{link}</Row>
                </>
            );
        } else if (this.state.verified === false)
            return (
                <>
                    <Row className="mt-5 justify-content-center">
                        <h5>
                            Email not found! Please complete the online
                            questionnaire first.
                        </h5>
                    </Row>
                    <Row className="mt-2 justify-content-center">
                        <Link
                            className="btn btn-primary"
                            to={{pathname: "/questionnaire"}}
                        >
                            Go to online questionnaire
                        </Link>
                    </Row>
                </>
            );
    };

    showDevelopmentMode = () => {
        if (process.env.NODE_ENV === "development")
            return <h1>Running in development mode</h1>;
    };

    render() {
        return (
            <Container style={{ height: "100%" }}>
                <div className="d-flex flex-column align-items-center justify-content-center h-100">
                    <Row className="justify-content-center">
                        <Row className="m-auto">
                            <Image
                                src={
                                    process.env.PUBLIC_URL +
                                    "/assets/logo-unsw.png"
                                }
                            />
                        </Row>
                    </Row>
                    <Row className="mt-5 justify-content-center">
                        <h1>
                            The Decision-Making Under Uncertainty Experiment
                        </h1>
                        {this.showDevelopmentMode()}
                    </Row>
                    {this.forceTestMsg()}
                    {this.emailCheckPrompt()}
                    {this.proceedMsg()}
                    {this.showAdminButton()}
                </div>
            </Container>
        );
    }
}

// Redux stuff
const mapStateToProps = (state) => {
    return {
        config: state.config.config,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        saveEmail: (email) => dispatch(setPersonalInfoEmail(email)),
        forceTest: () => dispatch(configForceTest()),
        forceControl: () => dispatch(configForceControl())
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(LandingPage);
