// Sends the output file using axios
import axios from "axios";
import axiosRetry from "axios-retry";
import { BACKEND_API_ABOUT, BACKEND_API_EXUPDATE } from "../backend_url";
import { dummyData } from "./outputFileTest";
import { initialState } from "../../redux/playerStats/playerStatsReducer";
import { CHOICE_TYPE } from "../../components/game/gameround/GameRoundOutput";

const RETRY_DELAY = 1000;
const NUM_RETRIES = 300;

export function sendDataToBackend(data, func = null, failfunc = null) {
    axiosRetry(axios, {retries: NUM_RETRIES, retryDelay: (retries) => {
        console.log(`Failed to connect: ${retries}`);
        return RETRY_DELAY;
    }});
    axios.get(BACKEND_API_ABOUT)
        .then(() => {
            axios
                .post(BACKEND_API_EXUPDATE, data)
                .then(() => {
                    console.log("Successfully sent data to backend");
                    if (func) func();
                })
                .catch(() => console.log("Failed to send to backend"));
        })
        .catch(() => {
            console.log("Failed check backend connectivity");
            if (failfunc) failfunc();
        });
}

// Copy all the other information (MCQ, Odds guess etc) into each round played
export function formatOutputData(playerStats, experiment_type) {
    let formattedOutput = {};

    const { first_name, last_name, email } = playerStats.personal_info;
    formattedOutput.personal_info = {
        first_name: first_name === null ? "debug" : first_name,
        last_name: last_name === null ? "debug" : last_name,
        email: email === null ? "debug" : email,
        experiment_type,
    };

    if (playerStats.round_data.length === 0) {
        formattedOutput.personal_info = dummyData.personal_info;
        formattedOutput.data = dummyData.data;
    } else formattedOutput.data = playerStats.round_data;

    formattedOutput.data.forEach((row, index, arr) => {
        const { age, gender, major } = playerStats.demographic_info;
        arr[index].age = age;
        arr[index].gender = gender;
        arr[index].major = major;

        const { q1, q2, q3, q4, q5, q6 } = playerStats.MCQ;
        arr[index].MCQ_Q1 = q1;
        arr[index].MCQ_Q2 = q2;
        arr[index].MCQ_Q3 = q3;
        arr[index].MCQ_Q4 = q4;
        arr[index].MCQ_Q5 = q5;
        arr[index].MCQ_Q6 = q6;

        arr[index].chance_guess = playerStats.chance_guess;
        arr[index].pre_game_strategy = playerStats.pre_game_strategy;
        arr[index].wager = playerStats.wager;

        arr[index].post_game_quiz_q1 = playerStats.post_game_quiz.q1;
        arr[index].post_game_quiz_q2 = playerStats.post_game_quiz.q2;
        arr[index].post_game_quiz_q3 = playerStats.post_game_quiz.q3;
        arr[index].post_game_quiz_q3_other = playerStats.post_game_quiz.other;
        arr[index].post_game_quiz_correct = playerStats.post_game_quiz.correct;

        const { odds_guess_one, odds_guess_two, odds_guess_three } =
            playerStats;
        arr[index].odds_guess_one_reply = odds_guess_one.selection;
        arr[index].odds_guess_one_did_win = odds_guess_one.didWin;
        arr[index].odds_guess_two_reply = odds_guess_two.selection;
        arr[index].odds_guess_two_did_win = odds_guess_two.didWin;
        arr[index].odds_guess_three_reply = odds_guess_three.selection;
        arr[index].odds_guess_three_did_win = odds_guess_three.didWin;
    });

    return formattedOutput;
}

// Return redux formatted playerStats data
export function getPlayerStats(inputData) {
    let playerStats = initialState;

    const { first_name, last_name, email, experiment_type } =
        inputData.personal_info;
    playerStats.personal_info = {
        first_name,
        last_name,
        email,
        experiment_type,
    };

    const last_row = inputData.data[inputData.data.length - 1];
    const { age, gender, major } = last_row;
    playerStats.demographic_info = {
        age,
        gender,
        major,
    };

    const { MCQ_Q1, MCQ_Q2, MCQ_Q3 } = last_row;
    playerStats.MCQ = {
        q1: MCQ_Q1,
        q2: MCQ_Q2,
        q3: MCQ_Q3,
    };

    playerStats.pre_game_strategy = last_row.pre_game_strategy;
    playerStats.wager = last_row.wager;

    playerStats.round_data = inputData.data;

    for (let i = 0; i < playerStats.round_data.length; i++) {
        let round = playerStats.round_data[i];
        if (round.block_type === "C" && round.choice === CHOICE_TYPE.SPIN)
            playerStats.num_bet_in_c_block++;
    }

    if (playerStats.num_bet_in_c_block > 2) playerStats.bet_in_c_block = true;

    const {
        odds_guess_one_reply,
        odds_guess_one_did_win,
        odds_guess_two_reply,
        odds_guess_two_did_win,
        odds_guess_three_reply,
        odds_guess_three_did_win,
    } = last_row;

    playerStats.odds_guess_one = {
        selection: odds_guess_one_reply,
        didWin: odds_guess_one_did_win,
    };

    playerStats.odds_guess_two = {
        selection: odds_guess_two_reply,
        didWin: odds_guess_two_did_win,
    };

    playerStats.odds_guess_three = {
        selection: odds_guess_three_reply,
        didWin: odds_guess_three_did_win,
    };

    const {
        post_game_quiz_q1,
        post_game_quiz_q2,
        post_game_quiz_q3,
        post_game_quiz_q3_other,
        post_game_quiz_correct,
    } = last_row;

    playerStats.post_game_quiz = {
        q1: post_game_quiz_q1,
        q2: post_game_quiz_q2,
        q3: post_game_quiz_q3,
        other: post_game_quiz_q3_other,
        correct: post_game_quiz_correct,
    };

    return playerStats;
}
