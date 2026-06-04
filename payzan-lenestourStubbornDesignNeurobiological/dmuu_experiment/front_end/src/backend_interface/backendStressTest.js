// Send 600 rounds of data at a relatively fast speed to simulate server load

import { formatOutputData, sendDataToBackend } from "./outputFile/outputFile";

const FAKE_FIRST_NAME = "debug_firstname";
const FAKE_LAST_NAME = "debug_surname";
const FAKE_EMAIL = "debug@debug.com";
const NUM_ROUNDS = 600;
const INTERVAL_LENGTH_MS = 100;
const experiment_type = "stress_test";

let interval;

const createAndAppendRoundData = (playerStats) => {
    const random_round_data = {
        round_number: Math.floor(Math.random() * 100),
        block_number: Math.floor(Math.random() * 100),
        sequence_number: Math.floor(Math.random() * 100),
        block_type: Math.random() > 0.5 ? "C" : "S",
        winning_probability: Math.random() > 0.5 ? 0.8 : 0.2,
        aaron_mood: Math.random() > 0.5 ? 0 : 1,
        probability_aaron_show: 0.5,
        reward_value: Math.random(),
        reaction_time: Math.random(),
        choice: Math.random() > 0.5 ? 1 : 2,
        status_of_play: Math.random() > 0.5 ? 1 : 2,
        outcome: Math.floor(Math.random() * 100),
        accumulated_outcomes: Math.floor(Math.random() * 1000),
    };

    playerStats.round_data.push(random_round_data);
};

const sendFakeRoundData = (playerStats, count) => {
    if (count < NUM_ROUNDS) {
        createAndAppendRoundData(playerStats);
        sendDataToBackend(formatOutputData(playerStats, experiment_type));
    } else {
        clearInterval(interval);
        console.log("Finished backend stress test!");
    }
    count++;
    return count;
};

const setupPlayerStats = (playerStats) => {
    playerStats.personal_info = {
        first_name: FAKE_FIRST_NAME,
        last_name: FAKE_LAST_NAME,
        email: FAKE_EMAIL,
        experiment_type,
    };

    playerStats.demographic_info = {
        age: 69,
        gender: 1,
        major: 1,
    };

    playerStats.MCQ = {
        q1: 1,
        q2: 0,
        q3: 1,
    };

    playerStats.post_game_quiz = {
        q1: 2,
        q2: 1,
        q3: 14,
        other: "stress test",
        correct: 0,
    };

    playerStats.odds_guess_one = {
        didWin: 0,
        selection: 1,
    };

    playerStats.odds_guess_two = {
        didWin: 0,
        selection: 1,
    };

    playerStats.odds_guess_three = {
        didWin: 0,
        selection: 1,
    };

    playerStats.round_data = [];
};

export const backendStressTest = () => {
    let playerStats = {};
    let count = 0;

    console.log("Starting backend stress test!");
    setupPlayerStats(playerStats);

    interval = setInterval(() => {
        count = sendFakeRoundData(playerStats, count);
    }, INTERVAL_LENGTH_MS);
};
