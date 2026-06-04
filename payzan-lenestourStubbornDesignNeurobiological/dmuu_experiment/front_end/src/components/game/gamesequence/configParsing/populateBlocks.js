// Takes the config and generates sequences
// as defined in the design structure specification

// Specs were given as (Reward size, probability of winning bet, probability of aaron showing cards)
// e.g. (H, 0.8, 1) = Rewards is high, probability of winning bet is high and probability of Aaron showing is 100%
// Because the winning probability is an adjustable parameter (one for high and low)
// it is intepreted instead as high or low probability
// Also aaron showing cards is changed to aaron being cheeky
// Similarly it is also an adjustable parameter
const block_design_structure = {
    "practice": {
        "t1": {
            "reward": "high",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": false,
            "type": "P"
        },
        "t2": {
            "reward": "high",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": true,
            "type": "P"
        },
        "t3": {
            "reward": "low",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": true,
            "type": "P"
        },
        "t4": {
            "reward": "low",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": false,
            "type": "P"
        },
        "t5": {
            "reward": "low",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": false,
            "type": "P"
        },
        "t6": {
            "reward": "high",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": true,
            "type": "P"
        },
        "t7": {
            "reward": "low",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": false,
            "type": "P"
        }
    },
    "sensitization": {
        "s1": { // (L, 0.8, 1)
            "reward": "low",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": false,
            "type": "S"
        },
        "s2": { // (H, 0.8, 1)
            "reward": "high",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": false,
            "type": "S"
        },
        "s3": { // (L, 0.8, 0.5)
            "reward": "low",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": true,
            "type": "S"
        },
        "s4": { // (H, 0.8, 0.5)
            "reward": "high",
            "color": "high_probability",
            "probability": "high",
            "aaron_cheeky": true,
            "type": "S"
        }
    },
    "test_blocks": {
        "c1": { // (H, 0.2, 0.5)
            "reward": "high",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": true,
            "type": "C"
        },
        "c2": { // (L, 0.2, 0.5)
            "reward": "low",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": true,
            "type": "C"
        },
        "c3": { // (L, 0.2, 1)
            "reward": "low",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": false,
            "type": "C"
        },
        "c4": { // (H, 0.2, 1)
            "reward": "high",
            "color": "low_probability",
            "probability": "low",
            "aaron_cheeky": false,
            "type": "C"
        }
    }
};

export const TREATMENT_SENS_ORDER = {
    ORIGINAL: 0,
    NORMAL_MOOD_LAST: 1,
    RANDOM: 2
};

/**
 * Determine the game config blocks to use depending on experiment type.
 * @param {*} config_file Config containing experiment treatment type (control or test)
 * @param {*} config_file.params.treatment_sens_order Ordering of the sensitization phase
 * @param {boolean} practice_flag Experiment in practice mode.
 * @param {boolean} debug_flag Experiment in debug mode.
 * @returns Array of game config blocks.
 */
function populateBlocks(config_file, practice_flag, debug_flag) {
    const { sensitization, test_blocks, practice } = block_design_structure;

    if (debug_flag) {
        return createDebugSequence(test_blocks, sensitization);
    }

    if (practice_flag) {
        return createPracticeSequence(practice);
    }

    const { treatment, treatment_sens_order, start_blue } = config_file.params;

    // Create test or control sequence
    let sequence;

    if (treatment === "test")
        sequence = createTestSequence(test_blocks, sensitization, treatment_sens_order);
    else
        sequence = createControlSequence(test_blocks, sensitization);

    if (start_blue)
        sequence.unshift(sensitization.s2);

    return sequence;
}

function createDebugSequence(testBlocks, sensBlocks) {
    const {c2, c3} = testBlocks;
    const {s2, s3} = sensBlocks;

    return [c3, s2, s3, c2];
}

function createPracticeSequence(practiceBlocks) {
    const { t1, t2, t3, t4, t5, t6, t7 } = practiceBlocks;

    return [t1, t2, t3, t4, t5, t6, t7];
}

/**
 * Create blocks for treatment experiment.
 * @param {*} testBlocks Pre-defined test blocks.
 * @param {*} sensitization Pre-defined sensitization blocks.
 * @param {*} treatment_sens_order Whether to use alternate sensitization phase ordering.
 * @returns Array of blocks.
 */
function createTestSequence(testBlocks, sensitization, treatment_sens_order) {
    let blocks = [];
    const { c1, c2, c3, c4 } = testBlocks;
    const { s1, s2, s3, s4 } = sensitization;

    let t = [c1, c2, c3, c4];
    // Original ordering
    let sensBlocks = [s1, s2, s3, s4];

    if (treatment_sens_order === TREATMENT_SENS_ORDER.NORMAL_MOOD_LAST)
        sensBlocks = [s4, s3, s1, s2];

    while (t.length !== 0) {
        if (treatment_sens_order === TREATMENT_SENS_ORDER.RANDOM) {
            let tempBlocks = [s1, s2, s3, s4];
            sensBlocks = [];

            while (tempBlocks.length !== 0)
                sensBlocks.push(pickRandBlock(tempBlocks));
        }

        // Sensitization blocks
        sensBlocks.forEach((item) => {
            blocks.push(item);
        });

        // Followed by a test block
        blocks.push(pickRandBlock(t));
    }

    return blocks;
}

// Test blocks followed by 4 sensitization phases
// 1 sensitization block is interspersed in the test blocks
// so that the start sequence is one of
// [L, H, L, L, L], [L, L, H, L, L], [L, L, L, H, L]
// and this block is taken randomly from 1 sensitization phase
// Ensure first test block is always non cheeky
function createControlSequence(testBlocks, sensitization) {
    let blocks = [];
    const { c1, c2, c3, c4 } = testBlocks;
    const sensBlocks = [
        sensitization.s1,
        sensitization.s2,
        sensitization.s3,
        sensitization.s4,
    ];

    // Pick first block to be non cheeky
    let non_cheeky = [c3, c4];
    blocks.push(pickRandBlock(non_cheeky));

    // Get the rest of the test blocks
    let t = [c1, c2].concat(non_cheeky);

    // Pick a random last test block
    const lastBlock = pickRandBlock(t);

    // Pick a random sensitization block and place into pool
    let firstSensBlocks = [...sensBlocks];
    const sBlock = pickRandBlock(firstSensBlocks);
    t.push(sBlock);

    while (t.length !== 0) {
        blocks.push(pickRandBlock(t));
    }

    // Place the lastBlock
    blocks.push(lastBlock);

    // Push the rest of the first sensitization blocks
    firstSensBlocks.forEach((item) => {
        blocks.push(item);
    });

    // 3 sensitization phases
    for (let i = 0; i < 3; ++i) {
        sensBlocks.forEach((item) => {
            blocks.push(item);
        });
    }

    return blocks;
}

function pickRandBlock(blocks) {
    if (!blocks.length)
        return {};

    const randPos = Math.floor(Math.random() * blocks.length);
    const randBlock = blocks[randPos];

    blocks.splice(randPos, 1);

    return randBlock;
}

export default populateBlocks;

export const exportedForTesting = {
    pickRandBlock,
    createControlSequence,
    createTestSequence,
    block_design_structure
};
