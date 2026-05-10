import { 
    FETCH_INSTRUCTION_TEXT_REQUEST,
    FETCH_INSTRUCTION_TEXT_SUCCESS,
    FETCH_INSTRUCTION_TEXT_FAILURE,
    COMPLETE_SIMULATION, 
    COMPLETE_PRACTICE, 
    DOWNLOADED_FAQ
} from './instructionTypes';

const initialState = {
    loading: false,
    text: {},
    textLoaded: false,
    error: "",
    simulationComplete: false,
    practiceComplete: false,
    downloadedFAQ: false
}

const instructionReducer = (state = initialState, action) => {
    switch (action.type) {

        case FETCH_INSTRUCTION_TEXT_REQUEST:
            return {
                ...state,
                loading: true
            }

        case FETCH_INSTRUCTION_TEXT_SUCCESS:
            return {
                ...state,
                loading: false,
                text: action.payload,
                textLoaded: true,
                error: ""
            }

        case FETCH_INSTRUCTION_TEXT_FAILURE:
            return {
                ...state,
                loading: false,
                text: {},
                textLoaded: false,
                error: action.payload
            }

        case COMPLETE_SIMULATION:
            return {
                ...state,
                simulationComplete: true
            }

        case COMPLETE_PRACTICE:
            return {
                ...state,
                practiceComplete: true
            }
        
        case DOWNLOADED_FAQ:
            return {
                ...state,
                downloadedFAQ: true
            }

        default:
            return state;
    }
}

export default instructionReducer;