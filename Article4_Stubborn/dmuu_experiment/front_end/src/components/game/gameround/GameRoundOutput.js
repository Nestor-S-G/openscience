/**
 * Format the round data to be put into excel document
 */

export const CHOICE_TYPE = {
    PASS: 0,
    SPIN: 1,
    MISS: 2,
};

export const PLAY_OUTCOME = {
    REFUSED_TO_SHOW: 0,
    SHOWED: 1,
    MISSED: 2,
};

export const BLOCK_TYPE = {
    C: "C",
    S: "S",
};

export const AARON_MOOD = {
    CHEEKY: 0,
    NORMAL: 1,
};

/**
 * Summarizes and formats the data for the current round, to be sent to the backend.
 * @param {boolean} missed True if the player missed ran out of time to make a decision.
 * @param {Object} props Prop data from the component.
 * @param {Object} props.game_config Game config data loaded from the backend.
 * @param {string} props.game_config.block_type "C" or "S".
 * @param {number} props.game_config.probability The probability of winning in the current round.
 * @param {number} props.game_config.aaron_cheeky Probability of Aaron letting the player play the slot game.
 * @param {number} props.game_config.reward Reward in dollars if win current round.
 * @param {number} props.block_number Zero indexed current block number.
 * @param {number} props.rep Current sequence number.
 * @param {number} props.netOutcome Current accumulated earnings for all previous blocks.
 * @param {Object} state State data of the component.
 * @param {string} state.choice Choice that the player made.
 * @param {string} state.status_of_play Whether Aaron let the player play the game.
 * @param {number} state.rounds Current round or trial number.
 * @param {number} state.time_to_answer Current round reaction time in ms.
 * @param {number} state.outcome Outcome or amount won for the current round.
 * @param {number} state.net Net for the current block.
 * @returns {Object} The round info summarized.
 */
export const summarizeRoundData = (missed, props, state) => {
    const { game_config } = props;
    let choice, status_of_play, outcome;

    if (missed) {
        choice = CHOICE_TYPE.MISS;
        status_of_play = PLAY_OUTCOME.MISSED;
        outcome = 0;
    } else {
        choice = state.choice === "spin" ? CHOICE_TYPE.SPIN : CHOICE_TYPE.PASS;
        status_of_play =
            state.status_of_play === "showed"
                ? PLAY_OUTCOME.SHOWED
                : PLAY_OUTCOME.REFUSED_TO_SHOW;
        outcome = state.outcome;

        if (choice === CHOICE_TYPE.PASS)
            status_of_play = PLAY_OUTCOME.REFUSED_TO_SHOW;

        if (status_of_play === PLAY_OUTCOME.REFUSED_TO_SHOW)
            outcome = 0;
    }

    const roundInfo = {
        round_number: state.rounds,
        block_number: props.block_num + 1, // Zero indexed
        sequence_number: props.rep,
        block_type:
            game_config.block_type === "C" ? BLOCK_TYPE.C : BLOCK_TYPE.S,
        winning_probability: game_config.probability,
        aaron_mood:
            game_config.aaron_cheeky === 100
                ? AARON_MOOD.NORMAL
                : AARON_MOOD.CHEEKY, // game_config.aaron_cheeky should really be called probability of showing
        probability_aaron_show: game_config.aaron_cheeky / 100,
        reward_value: game_config.reward,
        reaction_time: missed ? 0 : state.time_to_answer,
        choice,
        status_of_play,
        outcome,
        accumulated_outcomes: parseFloat(
            (props.netOutcome + state.net).toFixed(2)
        ),
    };

    return roundInfo;
};
