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

export const setPersonalInfo = (personal_info) => {
    return {
        type: SET_PERSONAL_INFO,
        payload: personal_info,
    };
};

export const setPersonalInfoFirstName = (first_name) => {
    return {
        type: SET_PERSONAL_INFO_FIRSTNAME,
        payload: first_name,
    };
};

export const setPersonalInfoLastName = (last_name) => {
    return {
        type: SET_PERSONAL_INFO_LASTNAME,
        payload: last_name,
    };
};

export const setPersonalInfoEmail = (email) => {
    return {
        type: SET_PERSONAL_INFO_EMAIL,
        payload: email,
    };
};

export const setDemographicInfo = (demographic_info) => {
    return {
        type: SET_DEMOGRAPHIC_INFO,
        payload: demographic_info,
    };
};

export const setMCQAnswers = (mcq_answers) => {
    return {
        type: SET_MCQ_ANSWERS,
        payload: mcq_answers,
    };
};

export const setChanceGuess = (chance_guess) => {
    return {
        type: SET_CHANCE_GUESS,
        payload: chance_guess,
    };
};

export const setPreGameStrategy = (pre_game_strategy) => {
    return {
        type: SET_PRE_GAME_STRATEGY,
        payload: pre_game_strategy,
    };
};

export const setWagerAmount = (wager) => {
    return {
        type: SET_WAGER_AMOUNT,
        payload: wager,
    };
};

export const appendRoundData = (round) => {
    return {
        type: APPEND_ROUND_DATA,
        payload: round,
    };
};

export const setLowProbabilityBet = () => {
    return {
        type: SET_LOW_PROBABILITY_BET,
    };
};

export const clearLowProbabilityBet = () => {
    return {
        type: CLEAR_LOW_PROBABILITY_BET,
    };
};

export const setOddsGuessOne = (oddsGuessOneAnswers) => {
    return {
        type: SET_ODDS_GUESS_ONE,
        payload: oddsGuessOneAnswers,
    };
};

export const setOddsGuessTwo = (oddsGuessTwoAnswers) => {
    return {
        type: SET_ODDS_GUESS_TWO,
        payload: oddsGuessTwoAnswers,
    };
};

export const setOddsGuessThree = (oddsGuessThreeAnswers) => {
    return {
        type: SET_ODDS_GUESS_THREE,
        payload: oddsGuessThreeAnswers,
    };
};

export const setPostGameQuiz = (quizAnswers) => {
    return {
        type: SET_POST_GAME_QUIZ,
        payload: quizAnswers,
    };
};

export const betInCBlock = () => {
    return {
        type: BET_IN_C_BLOCK,
    };
};

export const setBetInCBlocks = () => {
    return {
        type: SET_BET_IN_C_BLOCKS,
    };
};

export const clearBetInCBlocks = () => {
    return {
        type: CLEAR_BET_IN_C_BLOCKS,
    };
};

export const restartGame = () => {
    return {
        type: RESTART_GAME,
    };
};
