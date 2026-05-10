// Definitions for odds guess parameters in the output file

export const SELECTION_TYPES = {
    SLOT: 1,
    WHEEL: 2,
    TIMEOUT: 3,
    LESS_THAN: 4,
    GREATER_THAN: 5,
    I_DONT_KNOW: 6,
};

export const parseOddsGuessSelection = (selection) => {
    switch (selection) {
        case "slot":
            return SELECTION_TYPES.SLOT;

        case "wheel":
            return SELECTION_TYPES.WHEEL;

        case "none":
            return SELECTION_TYPES.TIMEOUT;

        case "less_than":
            return SELECTION_TYPES.LESS_THAN;

        case "greater_than_or_equal":
            return SELECTION_TYPES.GREATER_THAN;

        case "get_me_out":
            return SELECTION_TYPES.I_DONT_KNOW;

        default:
            return SELECTION_TYPES.I_DONT_KNOW;
    }
};
