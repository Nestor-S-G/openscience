import { DISABLE_SPEED_DEBUG, ENABLE_SPEED_DEBUG } from "./debugTypes";

export const enable_speed_debug = () => {
    return {
        type: ENABLE_SPEED_DEBUG,
    };
};

export const disable_speed_debug = () => {
    return {
        type: DISABLE_SPEED_DEBUG,
    };
};
