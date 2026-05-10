import { DISABLE_SPEED_DEBUG, ENABLE_SPEED_DEBUG } from "./debugTypes";

const initialState = {
    speed_debug: false,
};

const debugReducer = (state = initialState, action) => {
    switch (action.type) {
        case ENABLE_SPEED_DEBUG:
            return {
                ...state,
                speed_debug: true,
            };

        case DISABLE_SPEED_DEBUG:
            return {
                ...state,
                speed_debug: false,
            };

        default:
            return state;
    }
};

export default debugReducer;
