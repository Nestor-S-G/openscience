/**
 * OddsGuessOne
 * Player must choose between slot machine or wheel of fortune
 * If the player does not choose anything in a specified amount of time
 * then it times out.
 * Stores player's selection and result from the selection in redux store.
 * After selecting a message indicating that the selection has been recorded.
 * Do not actually play the slot machine or wheel of fortune to save time.
 * Instead a simulation with random function is used.
 * Return back to the normal game afterwards.
 */

import React, { Component } from "react";
import { connect } from "react-redux";
import Prompt from "./screens/Prompt/Prompt";
import {
    setOddsGuessOne,
    setOddsGuessThree,
} from "../../../../../../redux/playerStats/playerStatsActions";
import "./OddsGuessOne.css";
import { parseOddsGuessSelection } from "../OddsGuessOutput";

// How long to prompt the player after selection
const MS_IN_A_SECOND = 1000;
const MESSAGE_DISPLAY_MS = 2000;
const WHEEL_PROBABILITY_WIN = 0.3;

class OddsGuessOne extends Component {
    state = {
        selection: "none",
    };

    componentDidMount() {
        this.startTimeout();
        this._mounted = true;
    }

    componentWillUnmount() {
        clearTimeout(this.oddsGuessTimeout);
        clearTimeout(this.finishTimeout);
        this._mounted = false;
    }

    // Player must make a decision within certain time
    startTimeout = () => {
        this.oddsGuessTimeout = setTimeout(
            this.finishTimeUp,
            this.props.timeout * MS_IN_A_SECOND
        );
    };

    // Show selection confirmation and simulate game
    showSelectionMessage = () => {
        this.finishTimeout = setTimeout(
            () => this.simulateGame(),
            MESSAGE_DISPLAY_MS
        );
    };

    select = (selection) => {
        /**
         * Player can only make a selection if it is currently "none"
         * since they cannot change their mind after selecting
         */
        if (this.state.selection === "none") {
            // Player made selection, disable initial timeout
            clearTimeout(this.oddsGuessTimeout);
            this.setState({ selection }, this.showSelectionMessage);
        }
    };

    // Player ran out of time to choose
    finishTimeUp = () => {
        console.log("OddsGuessOne: Ran out of time to choose!");
        this.finishOddsGuess(false);
        this.returnToGameSequence();
    };

    /**
     * Simulate game by drawing a number between 0 and 100
     */
    simulateGame = () => {
        let probability;
        if (this.state.selection === "slot") {
            probability = this.props.slotProbability;
        } else {
            probability = WHEEL_PROBABILITY_WIN;
        }
        probability *= 100;

        const gameDraw = Math.floor(Math.random() * 100);
        const didWin = gameDraw <= probability ? true : false;

        console.log(`OddsGuessOne: Simulation probability = ${probability}%`);
        console.log(`OddsGuessOne: Draw = ${gameDraw}, didWin = ${didWin}`);

        this.finishOddsGuess(didWin);
    };

    finishOddsGuess = (didWin) => {
        const output = {
            selection: parseOddsGuessSelection(this.state.selection),
            didWin: didWin ? 1 : 0,
        };

        console.log(output);

        // Since this can repeat, it should be considered to redux as oddsGuessThree
        if (this.props.repeat) {
            this.props.setOddsGuessThreeAnswers(output);
        } else {
            this.props.setOddsGuessOneAnswers(output);
        }
        this.returnToGameSequence();
    };

    returnToGameSequence = () => {
        if (this._mounted) {
            this.props.finish();
            this._mounted = false;
        }
    }

    render() {
        return (
            <Prompt
                winAmount={this.props.winAmount}
                selection={this.state.selection}
                onClickSlot={() => this.select("slot")}
                onClickWheel={() => this.select("wheel")}
            />
        );
    }
}

const mapStateToProps = (state) => {
    return {
        winAmount: state.config.config.params.odds_guess_1_win_amount,
        timeout: state.config.config.params.duration.odds_guess_1,
        slotProbability: state.config.config.params.probability.low,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        setOddsGuessOneAnswers: (answers) => dispatch(setOddsGuessOne(answers)),
        setOddsGuessThreeAnswers: (answer) =>
            dispatch(setOddsGuessThree(answer)),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(OddsGuessOne);
