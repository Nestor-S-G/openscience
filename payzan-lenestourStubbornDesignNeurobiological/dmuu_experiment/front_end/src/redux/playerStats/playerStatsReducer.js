import {
    SET_PERSONAL_INFO,
    SET_DEMOGRAPHIC_INFO,
    SET_MCQ_ANSWERS,
    APPEND_ROUND_DATA,
    SET_LOW_PROBABILITY_BET,
    CLEAR_LOW_PROBABILITY_BET,
    SET_ODDS_GUESS_ONE,
    SET_ODDS_GUESS_TWO,
    SET_ODDS_GUESS_THREE,
    SET_POST_GAME_QUIZ,
    BET_IN_C_BLOCK,
    SET_BET_IN_C_BLOCKS,
    CLEAR_BET_IN_C_BLOCKS,
    RESTART_GAME,
    SET_PERSONAL_INFO_FIRSTNAME,
    SET_PERSONAL_INFO_LASTNAME,
    SET_PERSONAL_INFO_EMAIL,
    SET_PRE_GAME_STRATEGY,
    SET_WAGER_AMOUNT,
    SET_CHANCE_GUESS,
} from "./playerStatsTypes";

import { CHANCE_CODING } from "../../components/intro/Chance";
import { PRE_GAME_STRATEGY_CODING } from "../../components/intro/PreGameStrategy";

export const initialState = {
    personal_info: {
        first_name: null,
        last_name: null,
        email: null,
    },
    demographic_info: {
        age: null,
        gender: null,
        major: null,
    },
    MCQ: {
        q1: null,
        q2: null,
        q3: null,
        q4: null,
        q5: null,
        q6: null
    },
    pre_game_strategy: PRE_GAME_STRATEGY_CODING.NO_STRATEGY,
    chance_guess: CHANCE_CODING.NOT_SURE,
    wager: 0,
    round_data: [],
    made_low_probability_bet: false,
    num_bet_in_c_block: 0,
    bet_in_c_block: false,
    odds_guess_one: { selection: null, didWin: null },
    odds_guess_two: { selection: null, didWin: null },
    odds_guess_three: { selection: null, didWin: null },
    post_game_quiz: {
        q1: null,
        q2: null,
        q3: null,
        other: null,
        correct: null,
    },
};

const playerStatsReducer = (state = initialState, action) => {
    let personal_info;

    switch (action.type) {
        case SET_PERSONAL_INFO:
            return {
                ...state,
                personal_info: action.payload,
            };

        case SET_PERSONAL_INFO_FIRSTNAME:
            personal_info = state.personal_info;
            personal_info.first_name = action.payload;
            return {
                ...state,
                personal_info,
            };

        case SET_PERSONAL_INFO_LASTNAME:
            personal_info = state.personal_info;
            personal_info.last_name = action.payload;
            return {
                ...state,
                personal_info,
            };

        case SET_PERSONAL_INFO_EMAIL:
            personal_info = state.personal_info;
            personal_info.email = action.payload;
            return {
                ...state,
                personal_info,
            };

        case SET_DEMOGRAPHIC_INFO:
            return {
                ...state,
                demographic_info: action.payload,
            };

        case SET_MCQ_ANSWERS:
            return {
                ...state,
                MCQ: action.payload,
            };

        case SET_CHANCE_GUESS:
            return {
                ...state,
                chance_guess: action.payload,
            };

        case SET_PRE_GAME_STRATEGY:
            return {
                ...state,
                pre_game_strategy: action.payload,
            };

        case SET_WAGER_AMOUNT:
            return {
                ...state,
                wager: action.payload,
            };

        case APPEND_ROUND_DATA:
            let round_data = [...state.round_data];
            round_data.push(action.payload);
            return {
                ...state,
                round_data,
            };

        case SET_LOW_PROBABILITY_BET:
            return {
                ...state,
                made_low_probability_bet: true,
            };

        case CLEAR_LOW_PROBABILITY_BET:
            return {
                ...state,
                made_low_probability_bet: false,
            };

        case SET_ODDS_GUESS_ONE:
            return {
                ...state,
                odds_guess_one: action.payload,
            };

        case SET_ODDS_GUESS_TWO:
            return {
                ...state,
                odds_guess_two: action.payload,
            };

        case SET_ODDS_GUESS_THREE:
            return {
                ...state,
                odds_guess_three: action.payload,
            };

        case SET_POST_GAME_QUIZ:
            return {
                ...state,
                post_game_quiz: action.payload,
            };

        case BET_IN_C_BLOCK:
            if (state.num_bet_in_c_block === 1) {
                return {
                    ...state,
                    bet_in_c_block: true,
                };
            } else {
                return {
                    ...state,
                    num_bet_in_c_block: state.num_bet_in_c_block + 1,
                };
            }

        case SET_BET_IN_C_BLOCKS:
            return {
                ...state,
                bet_in_c_block: true,
            };

        case CLEAR_BET_IN_C_BLOCKS:
            return {
                ...state,
                bet_in_c_block: false,
            };

        case RESTART_GAME:
            return {
                ...state,
                round_data: [],
                made_low_probability_bet: false,
                num_bet_in_c_block: 0,
                bet_in_c_block: false,
                odds_guess_one: { selection: null, didWin: null },
                odds_guess_two: { selection: null, didWin: null },
                odds_guess_three: { selection: null, didWin: null },
                post_game_quiz: {
                    q1: null,
                    q2: null,
                    q3: null,
                    other: null,
                    correct: null,
                },
                wager: 0,
            };

        default:
            return state;
    }
};

export default playerStatsReducer;
