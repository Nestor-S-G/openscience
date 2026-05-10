/**
 * Get the total amount earned in odds guess
 */
import { SELECTION_TYPES } from "../game/gamesequence/screens/OddsGuess/OddsGuessOutput";

// Calculate the reward based on what was selected
function getOddsGuessReward(odds_guess, odds_guess_params) {
    const {
        odds_guess_1_win_amount,
        odds_guess_2_win_amount,
        odds_guess_2_lose_amount,
    } = odds_guess_params;

    switch (odds_guess.selection) {
        case SELECTION_TYPES.SLOT:
        case SELECTION_TYPES.WHEEL:
            if (odds_guess.didWin) {
                return odds_guess_1_win_amount;
            }
            break;

        case SELECTION_TYPES.LESS_THAN:
        case SELECTION_TYPES.GREATER_THAN:
            if (odds_guess.didWin) {
                return odds_guess_2_win_amount;
            } else {
                return -odds_guess_2_lose_amount;
            }

        default:
            return 0;
    }
    return 0;
}

export function getTotalOddsGuessReward(playerStats, odds_guess_params) {
    const { odds_guess_one, odds_guess_two, odds_guess_three } = playerStats;

    return (
        getOddsGuessReward(odds_guess_one, odds_guess_params) +
        getOddsGuessReward(odds_guess_two, odds_guess_params) +
        getOddsGuessReward(odds_guess_three, odds_guess_params)
    );
}
