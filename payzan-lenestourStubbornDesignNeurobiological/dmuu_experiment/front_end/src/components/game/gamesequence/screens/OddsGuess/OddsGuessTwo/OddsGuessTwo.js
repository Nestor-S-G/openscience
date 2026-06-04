import React, { Component } from "react";
import { Container, Row, Col, Image, Button } from "react-bootstrap";
import { connect } from "react-redux";
import {
    setOddsGuessTwo,
    setOddsGuessThree,
} from "../../../../../../redux/playerStats/playerStatsActions";
import { parseOddsGuessSelection } from "../OddsGuessOutput";
import "./OddsGuessTwo.css";

const FINISH_TIMEOUT_MS = 1000;
const ODDS_GUESS_QUIZ_LOW_PROBABILITY = 30;

class OddsGuessTwo extends Component {
    state = {
        showMsg: false,
        picked: false,
    };

    componentDidMount() {
        this.timeout = setTimeout(this.timeoutExceed, this.props.timeout * 1000);
    }

    componentWillUnmount() {
        clearTimeout(this.timeout);
        clearTimeout(this.promptFinishTimeout);
    }

    finishPrompt = () => {
        this.promptFinishTimeout = setTimeout(
            this.props.finish,
            FINISH_TIMEOUT_MS
        );
    };

    selectAnswer = (answer) => {
        clearTimeout(this.timeout);
        this.setState({ picked: true }, () => this.submitAnswer(answer));
        this.setState({ showMsg: true }, this.finishPrompt);
    };

    timeoutExceed = () => {
        this.submitAnswer("none");
        this.props.finish();
    }

    clickLessThan = () => {
        this.selectAnswer("less_than");
    };

    clickGreaterThan = () => {
        this.selectAnswer("greater_than_or_equal");
    };

    clickGetOut = () => {
        this.submitAnswer("get_me_out");
        this.props.finish();
    };

    getCorrectAnswer = () => {
        if (this.props.actualLowProb * 100 < ODDS_GUESS_QUIZ_LOW_PROBABILITY) {
            return "less_than";
        } else return "greater_than_or_equal";
    };

    submitAnswer = (answer) => {
        const output = {
            selection: parseOddsGuessSelection(answer),
            didWin: (answer === this.getCorrectAnswer()) ? 1 : 0,
        };

        // Since this can repeat, it should be considered to redux as oddsGuessThree
        if (this.props.repeat) {
            this.props.setOddsGuessThreeAnswers(output);
        } else {
            this.props.setOddsGuessTwoAnswers(output);
        }
    };

    showMessage = () => {
        if (this.state.showMsg) {
            return (
                <Row className="justify-content-center odds-guess-two-msg">
                    <h5>Your answer has been recorded</h5>
                </Row>
            );
        }
    };

    render() {
        const { winAmount, lowProbColor, loseAmount } = this.props;
        return (
            <Container className="pt-5">
                <div className="odds-guess-two-title">
                    <Row className="justify-content-center p-2">
                        <h2>Here is a short break from play</h2>
                    </Row>
                    <Row className="ml-5 mr-5 mb-3">
                        <h2>
                            Answer correctly to this simple question and an
                            additional ${winAmount} will be added to your net
                            accumulated outcomes in the end!
                        </h2>
                    </Row>
                </div>
                <Row className="mt-5">
                    <h2>
                        Winning probability, that is, the chance of the shapes being the same when the machine
                        stops in a {lowProbColor} session is:{" "}
                    </h2>
                </Row>
                <Row className="mt-5 justify-content-center">
                    <Col className="col-auto">
                        <Image height="225px" src={process.env.PUBLIC_URL + "/assets/low_probability.png"} />
                    </Col>
                    <Col className="align-content-center col-4">
                        <Row className="mt-5 justify-content-center mt-2">
                            <Button
                                onClick={this.clickLessThan}
                                className="mr-5"
                                disabled={this.state.picked}
                            >
                                {"<"}
                                {ODDS_GUESS_QUIZ_LOW_PROBABILITY}%
                            </Button>
                            <Button
                                onClick={this.clickGreaterThan}
                                disabled={this.state.picked}
                            >
                                ≥{ODDS_GUESS_QUIZ_LOW_PROBABILITY}%
                            </Button>
                        </Row>
                        <Row className="justify-content-center mt-5">
                            <Button
                                onClick={this.clickGetOut}
                                disabled={this.state.picked}
                            >
                                I'm not quite sure, get me out of here!
                            </Button>
                        </Row>
                    </Col>
                    <Col className="ml-3">
                        <Row className="mt-5">
                            <h5>
                                You will win ${winAmount} if you're
                                correct!
                            </h5>
                        </Row>
                        <Row className="odds-guess-warning mt-5 justify-content-center">
                            <h5>
                                ⚠ An incorrect answer leads to subtracting $
                                {loseAmount} from your net accumulated outcomes
                                in the end!
                            </h5>
                        </Row>
                    </Col>
                </Row>
                {this.showMessage()}
            </Container>
        );
    }
}

const mapStateToProps = (state) => {
    return {
        winAmount: state.config.config.params.odds_guess_2_win_amount,
        loseAmount: state.config.config.params.odds_guess_2_lose_amount,
        timeout: state.config.config.params.duration.odds_guess_2,
        lowProbColor: state.config.config.params.color.low_name,
        actualLowProb: state.config.config.params.probability.low,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        setOddsGuessTwoAnswers: (answer) => dispatch(setOddsGuessTwo(answer)),
        setOddsGuessThreeAnswers: (answer) =>
            dispatch(setOddsGuessThree(answer)),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(OddsGuessTwo);
