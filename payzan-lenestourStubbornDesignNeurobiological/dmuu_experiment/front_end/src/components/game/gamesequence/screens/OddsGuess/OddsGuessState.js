/**
 * Decide to show OddsGuessOne or OddsGuessTwo depending
 * what the player has chosen beforehand
 */

import store from "../../../../../redux/store";

const MAX_TIMES_ODDS_GUESS_SHOW = 3;

const screenStates = {
    ODDS_GUESS_1: "odds_guess_1",
    ODDS_GUESS_1_REPEAT: "odds_guess_1_repeat",
    ODDS_GUESS_2: "odds_guess_2",
    ODDS_GUESS_2_REPEAT: "odds_guess_2_repeat",
};

const choices = {
    SLOT: 1,
    WHEEL: 2,
    TIMEOUT: 3,
};

export class OddsGuessState {
    constructor(isPractice) {
        this.timesShownOddsGuess = 0;
        this.isPractice = isPractice;
        this.curState = screenStates.ODDS_GUESS_1;
    }

    isOddsGuessCondition = (didBet, isLowProbability) => {
        if (
            this.timesShownOddsGuess >= MAX_TIMES_ODDS_GUESS_SHOW ||
            !didBet ||
            this.isPractice ||
            !isLowProbability
        )
            return false;

        const playerStats = store.getState().stats;

        // Check whether timeout occured
        if (this.timesShownOddsGuess === 1) {
            const { selection } = playerStats.odds_guess_one;

            if (selection === choices.TIMEOUT)
                this.timesShownOddsGuess = 0;
        }

        if (this.timesShownOddsGuess === 2) {
            const { selection } = playerStats.odds_guess_two;

            if (selection === choices.TIMEOUT) {
                this.timesShownOddsGuess = 0;
            }
        }

        return true;
    };

    getState() {
        let newState = null;

        if (this.timesShownOddsGuess === 0) {
            console.log("First time");
            newState = screenStates.ODDS_GUESS_1;
        } else if (this.timesShownOddsGuess === 1) {
            console.log("Second time");
            newState = screenStates.ODDS_GUESS_2;
        } else if (this.timesShownOddsGuess === 2) {
            console.log("Third time");
            // 50-50 chance of odds guess 1 or 2
            if (Math.random() > 0.5)
                newState = screenStates.ODDS_GUESS_1_REPEAT;
            else
                newState = screenStates.ODDS_GUESS_2_REPEAT;
        }

        this.timesShownOddsGuess += 1;
        this.curState = newState;

        console.log(newState);

        return newState;
    }
}
