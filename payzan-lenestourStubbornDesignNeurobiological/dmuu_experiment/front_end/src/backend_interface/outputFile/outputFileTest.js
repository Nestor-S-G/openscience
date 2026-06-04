// Send dummy data to backend
import { sendDataToBackend } from "./outputFile";

export const dummyData = {
    personal_info: {
        first_name: "Dummy",
        last_name: "Data",
        email: "debug@debug.com",
        experiment_type: "Dummy",
    },
    data: [
        {
            round_number: 1,
            block_number: 1,
            sequence_number: 1,
            block_type: "D",
            winning_probability: 0.5,
            aaron_mood: 1,
            probability_aaron_show: 0.4,
            reward_value: 2,
            reaction_time: 1.3,
            choice: 1,
            status_of_play: 1,
            outcome: 0.7,
            accumulated_outcomes: 1.3,
            age: 20,
            gender: 1,
            major: 4,
            MCQ_Q1: 0,
            MCQ_Q2: 1,
            MCQ_Q3: 0,
            post_game_quiz_q1: 2,
            post_game_quiz_q2: 1,
            post_game_quiz_q3: 134,
            post_game_quiz_q3_other: "dummy",
            post_game_quiz_correct: 1,
            odds_guess_one_reply: 1,
            odds_guess_one_did_win: 0,
            odds_guess_two_reply: 2,
            odds_guess_two_did_win: 0,
            odds_guess_three_reply: 5,
            odds_guess_three_did_win: 0,
        },
    ],
};

export function sendDummyDataToBackend() {
    sendDataToBackend(dummyData);
}
