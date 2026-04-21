import {
    FETCH_INSTRUCTION_TEXT_REQUEST,
    FETCH_INSTRUCTION_TEXT_SUCCESS,
    FETCH_INSTRUCTION_TEXT_FAILURE,
    COMPLETE_PRACTICE, 
    COMPLETE_SIMULATION, 
    DOWNLOADED_FAQ
} from './instructionTypes';
import { instruction_list, instruction_fetch_list } from './instructionFetchList';

export const fetchInstructionTextRequest = () => {
    return {
        type: FETCH_INSTRUCTION_TEXT_REQUEST
    }
}

export const fetchInstructionTextSuccess = (instruction_arr) => {
    return {
        type: FETCH_INSTRUCTION_TEXT_SUCCESS,
        payload: instruction_arr
    }
}

export const fetchInstructionTextFailure = (error) => {
    return {
        type: FETCH_INSTRUCTION_TEXT_FAILURE,
        payload: error
    }
}

export const completePractice = () => {
    return {
        type: COMPLETE_PRACTICE
    }
}

export const completeSimulation = () => {
    return {
        type: COMPLETE_SIMULATION
    }
}

export const downloadedFAQ = () => {
    return {
        type: DOWNLOADED_FAQ
    }
}

export const fetchInstructions = () => {
    return (dispatch) => {
        // Initiate request
        dispatch(fetchInstructionTextRequest());
        Promise.all(instruction_fetch_list)
            .then((values) => {
                // Successfully fetched all instructions
                // Convert to an object
                const instructions = {};
                for (let i = 0; i < instruction_list.length; ++i)
                {
                    instructions[instruction_list[i]] = values[i].data;
                }

                dispatch(fetchInstructionTextSuccess(instructions))
            })
            .catch( error => {
                // At least one instruction failed to fetch
                dispatch(fetchInstructionTextFailure("Failed to fetch instructions"));
            })
    } 
}