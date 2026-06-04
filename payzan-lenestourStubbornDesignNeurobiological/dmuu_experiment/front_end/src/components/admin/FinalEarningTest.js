/**
 * Admin component used to check by hand the different final earnings pages
 */

import React, { Component } from "react";
import { Row, FormCheck, Form } from "react-bootstrap";
import { Link, withRouter } from "react-router-dom";
import { connect } from "react-redux";
import {
    setBetInCBlocks,
    clearBetInCBlocks,
    setOddsGuessOne,
    setOddsGuessTwo,
    setLowProbabilityBet,
    clearLowProbabilityBet,
} from "../../redux/playerStats/playerStatsActions";

class FinalEarningTest extends Component {
    state = {
        value: 0,
        c_checked: false,
        odds_guess_one_win: false,
        odds_guess_two_win: -1,
        sendToBackend: false,
        betLowProbability: false,
    };

    componentDidMount() {
        const { bet_in_c_block, odds_guess_one, odds_guess_two } =
            this.props.playerStats;
        const odds_guess_two_win =
            odds_guess_two.didWin === null ? -1 : odds_guess_two.didWin;

        this.setState({
            c_checked: bet_in_c_block,
            odds_guess_one_win: odds_guess_one.didWin !== null,
            odds_guess_two_win,
        });
    }

    onChange = (e) => {
        this.setState({ value: e.target.value });
    };

    handleToggleLowProb = () => {
        const betLowProbability = !this.state.betLowProbability;
        if (betLowProbability) this.props.setLP();
        else this.props.clearLP();
        this.setState({ betLowProbability });
    };

    handleToggleC = () => {
        const c_checked = !this.state.c_checked;
        if (c_checked) {
            this.props.setC();
            this.props.setLP();
        } else {
            this.props.clearC();
            this.props.clearLP();
        }
        this.setState({ c_checked });
    };

    handleToggleOddsGuessOneWin = () => {
        const odds_guess_one_win = !this.state.odds_guess_one_win;
        if (odds_guess_one_win)
            this.props.setOddsGuessOne({
                selection: 1,
                didWin: 1,
            });
        else
            this.props.setOddsGuessOne({
                selection: null,
                didWin: null,
            });
        this.setState({ odds_guess_one_win });
    };

    handleToggleOddsGuessTwo = (e) => {
        switch (parseInt(e.target.value)) {
            case 0:
                this.props.setOddsGuessTwo({
                    selection: 5,
                    didWin: 0,
                });
                break;

            case 1:
                this.props.setOddsGuessTwo({
                    selection: 4,
                    didWin: 1,
                });
                break;

            default:
                this.props.setOddsGuessTwo({
                    selection: null,
                    didWin: null,
                });
                break;
        }

        this.setState({ odds_guess_two_win: parseInt(e.target.value) });
    };

    handleToggleSendFinish = (e) => {
        this.setState({ sendToBackend: e.target.value });
    };

    render() {
        const { params } = this.props.config;

        return (
            <>
                <Row className="mt-5">
                    <h5>Test Net Value: </h5>
                    <input
                        data-test-id="cy-FinalEarningTest-input"
                        type="number"
                        value={this.state.value}
                        onChange={this.onChange}
                    />
                </Row>
                <Row className="mt-1">
                    <p>
                        The threshold is $
                        <span data-test-id="cy-FinalEarningTest-threshold">
                            {params.threshold}
                        </span>
                    </p>
                </Row>
                <Row>
                    <p>The multiplier is {params.multiplier}</p>
                </Row>
                <Row>
                    <FormCheck
                        data-test-id="cy-FinalEarningTest-BetYellowSession-FormCheck"
                        label="Bet in yellow session at least once"
                        checked={this.state.betLowProbability}
                        onChange={this.handleToggleLowProb}
                    />
                </Row>
                <Row>
                    <FormCheck
                        data-test-id="cy-FinalEarningTest-BetInCMoreThanOnce-FormCheck"
                        label="Bet in C block (yellow session) more than once"
                        checked={this.state.c_checked}
                        onChange={this.handleToggleC}
                    />
                </Row>
                <Row>
                    <FormCheck
                        label="Set win in Odds Guess One"
                        checked={this.state.odds_guess_one_win}
                        onChange={this.handleToggleOddsGuessOneWin}
                    />
                </Row>
                <Row>
                    <FormCheck
                        label="Send finish to backend, must set email on first page to work"
                        checked={this.state.sendToBackend}
                        onChange={this.handleToggleSendFinish}
                    />
                </Row>
                <Row className="mt-3">
                    <Form.Group>
                        <FormCheck
                            type="radio"
                            label="Clear Odds Guess Two"
                            name="oddsGuessTwo"
                            id="clearOddsGuessTwo"
                            value={-1}
                            checked={this.state.odds_guess_two_win === -1}
                            onChange={this.handleToggleOddsGuessTwo}
                        />
                        <FormCheck
                            type="radio"
                            label="Odds Guess Two Win"
                            name="oddsGuessTwo"
                            id="winOddsGuessTwo"
                            value={1}
                            checked={this.state.odds_guess_two_win === 1}
                            onChange={this.handleToggleOddsGuessTwo}
                        />
                        <FormCheck
                            type="radio"
                            label="Odds Guess Two Lose"
                            name="oddsGuessTwo"
                            id="loseOddsGuessTwo"
                            value={0}
                            checked={this.state.odds_guess_two_win === 0}
                            onChange={this.handleToggleOddsGuessTwo}
                        />
                    </Form.Group>
                </Row>
                <Row className="mt-2">
                    <Link
                        data-test-id="cy-FinalEarningTest-test-final-page"
                        className="btn btn-primary"
                        to={{
                            pathname: "/finish",
                            data: {
                                net: Math.round(this.state.value * 100) / 100,
                                low_color: params.color.low_name,
                                high_color: params.color.high_name,
                                threshold: params.threshold,
                                multiplier: params.multiplier,
                                suppressOutput: !this.state.sendToBackend,
                            },
                        }}
                    >
                        Test final page
                    </Link>
                </Row>
            </>
        );
    }
}

// Redux stuff
const mapStateToProps = (state) => {
    return {
        playerStats: state.stats,
        config: state.config.config,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        setLP: () => dispatch(setLowProbabilityBet()),
        clearLP: () => dispatch(clearLowProbabilityBet()),
        setC: () => dispatch(setBetInCBlocks()),
        clearC: () => dispatch(clearBetInCBlocks()),
        setOddsGuessOne: (payload) => dispatch(setOddsGuessOne(payload)),
        setOddsGuessTwo: (payload) => dispatch(setOddsGuessTwo(payload)),
    };
};

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(withRouter(FinalEarningTest));
