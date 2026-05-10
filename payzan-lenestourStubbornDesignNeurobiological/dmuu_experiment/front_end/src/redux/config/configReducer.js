import { FETCH_CONFIG_FAILURE, FETCH_CONFIG_SUCCESS, FETCH_CONFIG_REQUEST, CONFIG_FORCE_CONTROL, CONFIG_FORCE_TEST } from './configTypes';

const intialState = {
    loading: false,
    loaded: false,
    config: {},
    source: '',
    error: ''
}

const configReducer = (state = intialState, action) => {
    let cur_state;

    switch (action.type) {
        case FETCH_CONFIG_REQUEST:
            return {
                ...state,
                loading: true
            }

        case FETCH_CONFIG_SUCCESS:
            return {
                loading: false,
                loaded: true,
                config: action.payload.config,
                source: action.payload.source,
                error: ''
            }
        
        case FETCH_CONFIG_FAILURE:
            return {
                loading: false,
                loaded: false,
                config: {},
                error: action.payload
            }

        case CONFIG_FORCE_CONTROL:
            cur_state = state;
            cur_state.config.params.treatment = "control";
            return {
                ...cur_state
            }

        case CONFIG_FORCE_TEST:
            cur_state = state;
            cur_state.config.params.treatment = "test";
            return {
                ...cur_state
            }

        default:
            return state;
    }
}

export default configReducer;