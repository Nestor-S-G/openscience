import { FETCH_CONFIG_REQUEST, FETCH_CONFIG_SUCCESS, FETCH_CONFIG_FAILURE, CONFIG_FORCE_CONTROL, CONFIG_FORCE_TEST } from './configTypes';

export const configFetchRequest = () => {
    return {
        type: FETCH_CONFIG_REQUEST 
    }
}

export const configFetchSuccess = (config) => {
    return {
        type: FETCH_CONFIG_SUCCESS,
        payload: config
    }
}

export const configFetchFailure = (error) => {
    return {
        type: FETCH_CONFIG_FAILURE,
        payload: error
    }
}

export const configForceControl = () => {
    return {
        type: CONFIG_FORCE_CONTROL
    }
}

export const configForceTest = () => {
    return {
        type: CONFIG_FORCE_TEST
    }
}
