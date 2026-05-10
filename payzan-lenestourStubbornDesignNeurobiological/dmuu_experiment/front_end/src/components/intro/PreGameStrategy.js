import React, { Component } from "react";
import { connect } from "react-redux";
import { setPreGameStrategy } from "../../redux/playerStats/playerStatsActions";
import { Container, Form, Button, Row, Col } from "react-bootstrap";
import "./PreGameStrategy.css";

export const PRE_GAME_STRATEGY_CODING = {
    NO_STRATEGY: 0,
    LOW_CONFIDENCE: 1,
    FAIRLY_CONFIDENT: 2,
    VERY_CONFIDENT: 3,
};

class PreGameStrategy extends Component {
    state = {
        pre_game_strategy: null,
    };

    onChange = (e) => {
        const { id } = e.target;
        let newValue = this.state.pre_game_strategy;

        if (id === "noStrategy") {
            newValue = PRE_GAME_STRATEGY_CODING.NO_STRATEGY;
        } else if (id === "lowConfidence") {
            newValue = PRE_GAME_STRATEGY_CODING.LOW_CONFIDENCE;
        } else if (id === "fairlyConfident") {
            newValue = PRE_GAME_STRATEGY_CODING.FAIRLY_CONFIDENT;
        } else if (id === "veryConfident") {
            newValue = PRE_GAME_STRATEGY_CODING.VERY_CONFIDENT;
        }

        this.setState({ pre_game_strategy: newValue });
    };

    onSubmit = () => {
        const { pre_game_strategy } = this.state;
        if (pre_game_strategy !== null) {
            this.props.rdxSetPreGameStrategy(pre_game_strategy);
            this.props.history.push("/game");
        }
    };

    render() {
        const { pre_game_strategy } = this.state;
        return (
            <Container className="h-100 d-flex flex-column">
                <Row className="mt-5 justify-content-center text-center">
                    <h1 style={{ lineHeight: "200%" }}>
                        Have you devised a strategy on how to play the game, and
                        if you have, how confident are you that it's gonna work?
                    </h1>
                </Row>
                <Row className="flex-fill" />
                <Row className="justify-content-center">
                    <Col>
                        <Row className="justify-content-center">
                            <h2>I don't have a strategy</h2>
                        </Row>
                        <Row className="justify-content-center mt-3">
                            <Form.Check
                                type="radio"
                                id="noStrategy"
                                name="confidence"
                                onChange={this.onChange}
                                checked={
                                    pre_game_strategy ===
                                    PRE_GAME_STRATEGY_CODING.NO_STRATEGY
                                }
                            />
                        </Row>
                    </Col>
                    <Col>
                        <Row className="justify-content-center">
                            <h2>I do have a strategy</h2>
                        </Row>
                        <Row className="d-flex justify-content-center mt-3">
                            <Col md="10">
                                <div className="pregame-stack-base">
                                    <div className="pregame-overlay pregame-line" />
                                    <Row className="pregame-overlay">
                                        <Col className="text-center">
                                            <Row>
                                                <Col className="pregame-blank" />
                                                <Col className="p-0">
                                                    <input
                                                        type="radio"
                                                        id="lowConfidence"
                                                        name="confidence"
                                                        onChange={this.onChange}
                                                        style={{
                                                            display: "flex",
                                                            marginRight: "auto",
                                                        }}
                                                        checked={
                                                            pre_game_strategy ===
                                                            PRE_GAME_STRATEGY_CODING.LOW_CONFIDENCE
                                                        }
                                                    />
                                                </Col>
                                                <Col />
                                            </Row>
                                            <p>I'm not quite sure about it</p>
                                        </Col>
                                        <Col className="text-center">
                                            <input
                                                type="radio"
                                                id="fairlyConfident"
                                                name="confidence"
                                                onChange={this.onChange}
                                                style={{
                                                    display: "flex",
                                                    margin: "0 auto",
                                                }}
                                                checked={
                                                    pre_game_strategy ===
                                                    PRE_GAME_STRATEGY_CODING.FAIRLY_CONFIDENT
                                                }
                                            />
                                            <p>
                                                I feel fairly confident about it
                                            </p>
                                        </Col>
                                        <Col className="text-center">
                                            <Row>
                                                <Col />
                                                <Col className="p-0">
                                                    <input
                                                        type="radio"
                                                        id="veryConfident"
                                                        name="confidence"
                                                        onChange={this.onChange}
                                                        style={{
                                                            display: "flex",
                                                            marginLeft: "auto",
                                                        }}
                                                        checked={
                                                            pre_game_strategy ===
                                                            PRE_GAME_STRATEGY_CODING.VERY_CONFIDENT
                                                        }
                                                    />
                                                </Col>
                                                <Col className="pregame-blank" />
                                            </Row>
                                            <p>I really think it's right</p>
                                        </Col>
                                    </Row>
                                </div>
                            </Col>
                        </Row>
                    </Col>
                </Row>
                <Row className="flex-fill" />
                <Row className="justify-content-center mb-5">
                    <Button
                        onClick={this.onSubmit}
                        disabled={pre_game_strategy == null}
                    >
                        Submit
                    </Button>
                </Row>
            </Container>
        );
    }
}

// Redux stuff
const mapDispatchToProps = (dispatch) => {
    return {
        rdxSetPreGameStrategy: (pre_game_strategy) =>
            dispatch(setPreGameStrategy(pre_game_strategy)),
    };
};

export default connect(null, mapDispatchToProps)(PreGameStrategy);
