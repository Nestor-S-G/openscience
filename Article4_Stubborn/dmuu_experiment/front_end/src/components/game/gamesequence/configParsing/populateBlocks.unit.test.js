import { exportedForTesting, TREATMENT_SENS_ORDER } from "./populateBlocks";
const {
    pickRandBlock,
    createControlSequence,
    createTestSequence,
    block_design_structure,
} = exportedForTesting;

const simple_test_blocks = { "c1": "c1", "c2": "c2", "c3": "c3", "c4": "c4" };
const simple_sens_blocks = { "s1": "s1", "s2": "s2", "s3": "s3", "s4": "s4" };

describe("Test pickRandBlock", () => {
    let blocks;

    beforeEach(() => {
        jest.spyOn(Math, "random").mockImplementation(() => {
            return 0;
        });
        blocks = [1, 2, 3, 4];
    });

    afterEach(() => {
        jest.spyOn(Math, "random").mockRestore();
    });

    it("Should pick a random block", () => {
        expect(pickRandBlock(blocks)).toEqual(1);
    });

    it("Should remove the item from the block", () => {
        pickRandBlock(blocks);
        expect(blocks).toEqual([2, 3, 4]);
    });

    it("Should do nothing for empty arrays", () => {
        blocks = [];
        pickRandBlock(blocks);
        expect(blocks).toEqual([]);
    });
});

describe("Test createControlSequence", () => {
    const { sensitization, test_blocks } = block_design_structure;
    const { c3, c4 } = test_blocks;
    const { s1, s2, s3, s4 } = sensitization;

    const NUM_SEQS = 100;

    for (let i = 0; i < NUM_SEQS; i++) {
        let control_sequence = createControlSequence(
            test_blocks,
            sensitization
        );

        it("Should have non cheeky in the first block", () => {
            expect(control_sequence[0]).toHaveProperty("aaron_cheeky", false);
            expect([c3, c4]).toContainEqual(control_sequence[0]);
        });

        it("Should be of length 20", () => {
            expect(control_sequence.length).toEqual(20);
        });

        it("Should have 1 blue interspersed in yellows for first 5 blocks", () => {
            expect(control_sequence[0]).toHaveProperty("probability", "low");
            expect(["low", "high"]).toContainEqual(
                control_sequence[1].probability
            );
            expect(["low", "high"]).toContainEqual(
                control_sequence[2].probability
            );
            expect(["low", "high"]).toContainEqual(
                control_sequence[3].probability
            );
            expect(control_sequence[4]).toHaveProperty("probability", "low");
        });

        it("Should have the rest of the blocks be blue", () => {
            for (let k = 5; k < control_sequence.length; k++)
                expect(control_sequence[k]).toHaveProperty(
                    "probability",
                    "high"
                );
        });

        it("Should end with 4 sensitization phases", () => {
            const expectedEnd = [
                s1,
                s2,
                s3,
                s4,
                s1,
                s2,
                s3,
                s4,
                s1,
                s2,
                s3,
                s4,
            ];

            expect([s1, s2, s3, s4]).toContainEqual(control_sequence[5]);
            expect([s1, s2, s3, s4]).toContainEqual(control_sequence[6]);
            expect([s1, s2, s3, s4]).toContainEqual(control_sequence[7]);
            expect(control_sequence.slice(8)).toEqual(expectedEnd);
        });
    }

    it.skip("DEBUG: Visually inspect randomization of C blocks", () => {
        const NUM_SEQS = 20;

        for (let i = 0; i < NUM_SEQS; i++)
            console.log(createControlSequence(simple_test_blocks, simple_sens_blocks));

    });
});

describe("Test createTestSequence", () => {
    const { sensitization, test_blocks } = block_design_structure;
    const { c1, c2, c3, c4 } = test_blocks;
    const { s1, s2, s3, s4 } = sensitization;

    const NUM_SEQS = 20;

    for (let i = 0; i < NUM_SEQS; i++) {
        let test_sequence = createTestSequence(test_blocks, sensitization, TREATMENT_SENS_ORDER.ORIGINAL);

        it("Should have length 20", () => {
            expect(test_sequence.length).toEqual(20);
        });

        it("Should have 4 sensitization phases", () => {
            const sens_phase = [s1, s2, s3, s4];

            expect(test_sequence.slice(0, 4)).toEqual(sens_phase);
            expect(test_sequence.slice(5, 9)).toEqual(sens_phase);
            expect(test_sequence.slice(10, 14)).toEqual(sens_phase);
            expect(test_sequence.slice(15, 19)).toEqual(sens_phase);
        });

        it("Should have a random test block between sensitization", () => {
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[4]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[9]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[14]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[19]);
        });
    }

    for (let i = 0; i < NUM_SEQS; i++) {
        let test_sequence = createTestSequence(test_blocks, sensitization, TREATMENT_SENS_ORDER.NORMAL_MOOD_LAST);

        it("Should have length 20", () => {
            expect(test_sequence.length).toEqual(20);
        });

        it("Should have 4 sensitization phases", () => {
            const sens_phase = [s4, s3, s1, s2];

            expect(test_sequence.slice(0, 4)).toEqual(sens_phase);
            expect(test_sequence.slice(5, 9)).toEqual(sens_phase);
            expect(test_sequence.slice(10, 14)).toEqual(sens_phase);
            expect(test_sequence.slice(15, 19)).toEqual(sens_phase);
        });

        it("Should have a random test block between sensitization", () => {
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[4]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[9]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[14]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[19]);
        });
    }

    for (let i = 0; i < NUM_SEQS; i++) {
        let test_sequence = createTestSequence(test_blocks, sensitization, TREATMENT_SENS_ORDER.RANDOM);

        it("Should have length 20", () => {
            expect(test_sequence.length).toEqual(20);
        });

        it("Should have 4 sensitization phases", () => {
            const sens_phase = [s1, s2, s3, s4];

            expect(test_sequence.slice(0, 4)).toEqual(expect.arrayContaining(sens_phase));
            expect(expect.arrayContaining(sens_phase)).toEqual(expect.arrayContaining(sens_phase));
            expect(test_sequence.slice(5, 9)).toEqual(expect.arrayContaining(sens_phase));
            expect(expect.arrayContaining(sens_phase)).toEqual(expect.arrayContaining(sens_phase));
            expect(test_sequence.slice(10, 14)).toEqual(expect.arrayContaining(sens_phase));
            expect(expect.arrayContaining(sens_phase)).toEqual(expect.arrayContaining(sens_phase));
            expect(test_sequence.slice(15, 19)).toEqual(expect.arrayContaining(sens_phase));
            expect(expect.arrayContaining(sens_phase)).toEqual(expect.arrayContaining(sens_phase));
        });

        it("Should have a random test block between sensitization", () => {
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[4]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[9]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[14]);
            expect([c1, c2, c3, c4]).toContainEqual(test_sequence[19]);
        });
    }

    it.skip("DEBUG: Visually inspect randomization of S blocks", () => {
        const NUM_SEQS = 20;

        for (let i = 0; i < NUM_SEQS; i++)
            console.log(createTestSequence(simple_test_blocks, simple_sens_blocks, TREATMENT_SENS_ORDER.RANDOM));
    });
});
