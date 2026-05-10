// Wager shown to players who never bet in yellow session
import React, { Component } from "react";
import { Row, Col, Button } from "react-bootstrap";
import { connect } from "react-redux";
import { setWagerAmount } from "../../../redux/playerStats/playerStatsActions";

const WagerBox = (wager, func, id) => {
    return (
        <Col md={4}>
            <Row className="justify-content-center">
                <Button data-test-id={id} onClick={() => func(wager)}>
                    <h5>Wager of ${wager}</h5>
                </Button>
            </Row>
            <Row className="pt-3 justify-content-center">
                <h5>Win ${wager} if you implemented it</h5>
            </Row>
            <Row className="pt-2 justify-content-center">
                <h5>Lose ${wager} if you did not</h5>
            </Row>
        </Col>
    );
};

class Wager extends Component {
    onSubmitWager = (wager) => {
        this.props.setWager(wager);
        this.props.nextFunc(wager);
    };

    render() {
        const { wager_high, wager_low } = this.props;
        return (
            <>
                <Row className="justify-content-center" data-test-id="cy-Wager">
                    <h2>Tactics Of The Game</h2>
                </Row>
                <Row className="pt-5 justify-content-center">
                    <h3>
                        In the game you've just played, there was an optimal
                        strategy.
                    </h3>
                </Row>
                <Row className="pt-5 justify-content-center">
                    <h3>Do you think you implemented it?</h3>
                </Row>
                <Row className="pt-5 justify-content-center">
                    <h3 style={{ borderStyle: "double", padding: "5px" }}>
                        Place a wager
                    </h3>
                </Row>
                <Row className="pt-5 justify-content-center">
                    {WagerBox(wager_high, this.onSubmitWager, "cy-Wager-high")}
                    {WagerBox(wager_low, this.onSubmitWager, "cy-Wager-low")}
                </Row>
                <Row className="pt-5 justify-content-center">
                    <h5>To be added to your final payoff in the experiment!</h5>
                </Row>
            </>
        );
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        wager_high: state.config.config.params.wager_high,
        wager_low: state.config.config.params.wager_low,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        setWager: (wager) => dispatch(setWagerAmount(wager)),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(Wager);
