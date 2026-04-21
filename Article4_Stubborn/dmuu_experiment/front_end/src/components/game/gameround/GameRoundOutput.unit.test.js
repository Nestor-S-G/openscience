import {
    CHOICE_TYPE,
    PLAY_OUTCOME,
    BLOCK_TYPE,
    AARON_MOOD,
    summarizeRoundData,
} from "./GameRoundOutput";

describe("Test summarizeRoundData", () => {
    const game_config = {
        block_type: "C",
        probability: 0.8,
        aaron_cheeky: 50,
        reward: 1.2,
    };

    const props = {
        game_config,
        block_num: 2,
        rep: 4,
        netOutcome: 23.53,
    };

    const state = {
        choice: "spin",
        status_of_play: "showed",
        rounds: 3,
        time_to_answer: 655,
        outcome: 1.2,
        net: 6.27,
    };

    it("Should show correct output for non-missed trial.", () => {
        const expected = {
            round_number: 3,
            block_number: 3,
            sequence_number: 4,
            block_type: BLOCK_TYPE.C,
            winning_probability: 0.8,
            aaron_mood: AARON_MOOD.CHEEKY,
            probability_aaron_show: 0.5,
            reward_value: 1.2,
            reaction_time: 655,
            choice: CHOICE_TYPE.SPIN,
            status_of_play: PLAY_OUTCOME.SHOWED,
            outcome: 1.2,
            accumulated_outcomes: 29.8,
        };
        const actual = summarizeRoundData(false, props, state);

        expect(actual).toStrictEqual(expected);
    });

    it("Should show correct output for missed trial.", () => {
        const expected = {
            round_number: 3,
            block_number: 3,
            sequence_number: 4,
            block_type: BLOCK_TYPE.C,
            winning_probability: 0.8,
            aaron_mood: AARON_MOOD.CHEEKY,
            probability_aaron_show: 0.5,
            reward_value: 1.2,
            reaction_time: 0,
            choice: CHOICE_TYPE.MISS,
            status_of_play: PLAY_OUTCOME.MISSED,
            outcome: 0,
            accumulated_outcomes: 29.8,
        };
        const actual = summarizeRoundData(true, props, state);

        expect(actual).toStrictEqual(expected);
    });
});
