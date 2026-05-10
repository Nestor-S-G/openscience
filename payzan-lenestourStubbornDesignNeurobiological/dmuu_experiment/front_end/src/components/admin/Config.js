import React, { Component, Fragment } from "react";
import {
    Button,
    Card,
    Col,
    Container,
    Form,
    InputGroup,
    Row,
} from "react-bootstrap";
import { FLASK_BACKEND } from "../../backend_interface/configLoader/configLoader";
import { Link } from "react-router-dom";
import { connect } from "react-redux";
import { TREATMENT_SENS_ORDER } from "../game/gamesequence/configParsing/populateBlocks";

const save_state = {
    NONE: "none",
    FAILED: "failed",
    SUCCEEDED: "succeeded",
};

class Config extends Component {
    state = {
        color_low_probability: "#FFF66D",
        color_low_name: "yellow",
        color_high_probability: "#002EFF",
        color_high_name: "blue",
        treatment: "test",
        treatment_sens_order: TREATMENT_SENS_ORDER.ORIGINAL,
        start_blue: false,
        reward_low: 1,
        reward_high: 2,
        multiplier: 4,
        bet_amount: 70,
        repetitions: 6,
        trials: 7,
        probability_low: 0.2,
        probability_high: 0.8,
        aaron_spin: 0.5,
        threshold: 130,
        missed_trials: 4,
        simulation_examples: 3,
        simulation_pause: 4,
        screen_1_stop_after: -1,
        screen_2_stop_after: -1,
        screen_3_stop_after: -1,
        sound: true,
        slow_trials: 4,
        odds_guess_1_win_amount: 10,
        odds_guess_2_win_amount: 10,
        odds_guess_2_lose_amount: 10,
        wager_high: 5,
        wager_low: 2,
        probability_show_lottery: 0.1,
        duration_break_block: 0,
        duration_break_sequence: 0,
        duration_odds_guess_1: 60,
        duration_odds_guess_2: 60,
        duration_practice_reminder: 8,
        duration_practice_screen_1: 4,
        duration_practice_screen_2: 4,
        duration_practice_screen_3: 4,
        duration_practice_aaron_mood_info: 4,
        duration_practice_game_choice: 4,
        duration_practice_game_spin: 4,
        duration_practice_game_aaron_bad_mood: 4,
        duration_practice_game_pass: 4,
        duration_practice_game_result: 4,
        duration_practice_game_missed_trial: 4,
        duration_experiment_reminder: 5,
        duration_experiment_slow_screen_1: 4,
        duration_experiment_slow_screen_2: 4,
        duration_experiment_slow_screen_3: 4,
        duration_experiment_slow_aaron_mood_info: 4,
        duration_experiment_slow_game_choice: 4,
        duration_experiment_slow_game_spin: 4,
        duration_experiment_slow_game_aaron_bad_mood: 4,
        duration_experiment_slow_game_pass: 4,
        duration_experiment_slow_game_result: 4,
        duration_experiment_slow_game_missed_trial: 4,
        duration_experiment_normal_screen_1: 2,
        duration_experiment_normal_screen_2: 2,
        duration_experiment_normal_screen_3: 2,
        duration_experiment_normal_aaron_mood_info: 4,
        duration_experiment_normal_game_choice: 2,
        duration_experiment_normal_game_spin: 1,
        duration_experiment_normal_game_aaron_bad_mood: 2,
        duration_experiment_normal_game_pass: 2,
        duration_experiment_normal_game_result: 2,
        duration_experiment_normal_game_missed_trial: 2,
        did_save_succeed: save_state.NONE,
    };

    // Unpack from props
    unpackConfig = () => {
        let unpacked_config = {};
        const { params } = this.props.config.config;

        // Color
        const { color } = params;
        unpacked_config.color_low_probability = color.low_probability;
        unpacked_config.color_low_name = color.low_name;
        unpacked_config.color_high_probability = color.high_probability;
        unpacked_config.color_high_name = color.high_name;

        // Treatment
        const { treatment } = params;
        unpacked_config.treatment = treatment;

        // Set last blue session to be normal mood
        const { treatment_sens_order } = params;
        unpacked_config.treatment_sens_order = treatment_sens_order;

        // Start sequence with blue high probability session
        const { start_blue } = params;
        unpacked_config.start_blue = start_blue;

        // Reward
        const { reward } = params;
        unpacked_config.reward_low = reward.low;
        unpacked_config.reward_high = reward.high;

        // Multiplier
        const { multiplier } = params;
        unpacked_config.multiplier = multiplier;

        // Bet Amount
        const { bet_amount } = params;
        unpacked_config.bet_amount = bet_amount;

        // Repetitions
        const { repetitions } = params;
        unpacked_config.repetitions = repetitions;

        // Trials
        const { trials } = params;
        unpacked_config.trials = trials;

        // Simulation
        const { simulation } = params;
        unpacked_config.simulation_examples = simulation.examples;
        unpacked_config.simulation_pause = simulation.pause;

        // Probability
        const { probability } = params;
        unpacked_config.probability_low = probability.low;
        unpacked_config.probability_high = probability.high;
        unpacked_config.aaron_spin = probability.aaron_spin;
        unpacked_config.probability_show_lottery = probability.show_lottery;

        // Threshold
        const { threshold } = params;
        unpacked_config.threshold = threshold;

        // Missed Trials
        const { missed_trials } = params;
        unpacked_config.missed_trials = missed_trials;

        // Stop after
        const { stop_after } = params;
        unpacked_config.screen_1_stop_after = stop_after.screen_1;
        unpacked_config.screen_2_stop_after = stop_after.screen_2;
        unpacked_config.screen_3_stop_after = stop_after.screen_3;

        // Sound
        const { sound } = params;
        unpacked_config.sound = sound;

        // Slow trials
        const { slow_trials } = params;
        unpacked_config.slow_trials = slow_trials;

        // Odds guess amounts
        const {
            odds_guess_1_win_amount,
            odds_guess_2_win_amount,
            odds_guess_2_lose_amount,
        } = params;
        unpacked_config.odds_guess_1_win_amount = odds_guess_1_win_amount;
        unpacked_config.odds_guess_2_win_amount = odds_guess_2_win_amount;
        unpacked_config.odds_guess_2_lose_amount = odds_guess_2_lose_amount;

        // Wager amounts
        const { wager_high, wager_low } = params;
        unpacked_config.wager_high = wager_high;
        unpacked_config.wager_low = wager_low;

        // Durations
        const { duration } = params;
        unpacked_config.duration_break_block = duration.break_block;
        unpacked_config.duration_break_sequence = duration.break_sequence;

        // Odds Guess
        unpacked_config.duration_odds_guess_1 = duration.odds_guess_1;
        unpacked_config.duration_odds_guess_2 = duration.odds_guess_2;

        // Practice
        const { practice } = duration;
        unpacked_config.duration_practice_reminder = practice.reminder;
        unpacked_config.duration_practice_screen_1 = practice.screen_1;
        unpacked_config.duration_practice_screen_2 = practice.screen_2;
        unpacked_config.duration_practice_screen_3 = practice.screen_3;
        unpacked_config.duration_practice_aaron_mood_info =
            practice.aaron_mood_info;

        // Practice game
        const { game } = practice;
        unpacked_config.duration_practice_game_choice = game.choice;
        unpacked_config.duration_practice_game_spin = game.spin;
        unpacked_config.duration_practice_game_aaron_bad_mood =
            game.aaron_bad_mood;
        unpacked_config.duration_practice_game_pass = game.pass;
        unpacked_config.duration_practice_game_result = game.result;
        unpacked_config.duration_practice_game_missed_trial = game.missed_trial;

        // Experiment
        const { experiment } = duration;
        unpacked_config.duration_experiment_reminder = experiment.reminder;

        // Slow
        const { slow } = experiment;
        unpacked_config.duration_experiment_slow_screen_1 = slow.screen_1;
        unpacked_config.duration_experiment_slow_screen_2 = slow.screen_2;
        unpacked_config.duration_experiment_slow_screen_3 = slow.screen_3;
        unpacked_config.duration_experiment_slow_aaron_mood_info =
            slow.aaron_mood_info;

        // Slow Game
        unpacked_config.duration_experiment_slow_game_choice = slow.game.choice;
        unpacked_config.duration_experiment_slow_game_spin = slow.game.spin;
        unpacked_config.duration_experiment_slow_game_aaron_bad_mood =
            slow.game.aaron_bad_mood;
        unpacked_config.duration_experiment_slow_game_pass = slow.game.pass;
        unpacked_config.duration_experiment_slow_game_result = slow.game.result;
        unpacked_config.duration_experiment_slow_game_missed_trial =
            slow.game.missed_trial;

        // Normal
        const { normal } = experiment;
        unpacked_config.duration_experiment_normal_screen_1 = normal.screen_1;
        unpacked_config.duration_experiment_normal_screen_2 = normal.screen_2;
        unpacked_config.duration_experiment_normal_screen_3 = normal.screen_3;
        unpacked_config.duration_experiment_normal_aaron_mood_info =
            normal.aaron_mood_info;

        // Slow Game
        unpacked_config.duration_experiment_normal_game_choice =
            normal.game.choice;
        unpacked_config.duration_experiment_normal_game_spin = normal.game.spin;
        unpacked_config.duration_experiment_normal_game_aaron_bad_mood =
            normal.game.aaron_bad_mood;
        unpacked_config.duration_experiment_normal_game_pass = normal.game.pass;
        unpacked_config.duration_experiment_normal_game_result =
            normal.game.result;
        unpacked_config.duration_experiment_normal_game_missed_trial =
            normal.game.missed_trial;

        return unpacked_config;
    };

    // Pack from state
    repackConfig = () => {
        let repackedConfig = {};

        // Color
        const {
            color_low_probability,
            color_low_name,
            color_high_probability,
            color_high_name,
        } = this.state;
        repackedConfig.color = {
            low_probability: color_low_probability,
            low_name: color_low_name,
            high_probability: color_high_probability,
            high_name: color_high_name,
        };

        // Treatment
        const { treatment } = this.state;
        repackedConfig.treatment = treatment;

        // Set last blue session to be normal mood
        const { treatment_sens_order } = this.state;
        repackedConfig.treatment_sens_order = treatment_sens_order;

        const { start_blue } = this.state;
        repackedConfig.start_blue = start_blue;

        // Reward
        const { reward_low, reward_high } = this.state;
        repackedConfig.reward = {
            low: reward_low,
            high: reward_high,
        };

        // Multiplier
        const { multiplier } = this.state;
        repackedConfig.multiplier = multiplier;

        // Bet amount
        const { bet_amount } = this.state;
        repackedConfig.bet_amount = bet_amount;

        // Repetitions
        const { repetitions } = this.state;
        repackedConfig.repetitions = repetitions;

        // Trials
        const { trials } = this.state;
        repackedConfig.trials = trials;

        // Simulation
        const { simulation_examples, simulation_pause } = this.state;
        repackedConfig.simulation = {
            examples: simulation_examples,
            pause: simulation_pause,
        };

        // Probability
        const {
            probability_low,
            probability_high,
            aaron_spin,
            probability_show_lottery,
        } = this.state;
        repackedConfig.probability = {
            low: probability_low,
            high: probability_high,
            aaron_spin,
            show_lottery: probability_show_lottery,
        };

        // Threshold
        const { threshold } = this.state;
        repackedConfig.threshold = threshold;

        // Missed trials
        const { missed_trials } = this.state;
        repackedConfig.missed_trials = missed_trials;

        // Stop after
        const {
            screen_1_stop_after,
            screen_2_stop_after,
            screen_3_stop_after,
        } = this.state;
        repackedConfig.stop_after = {
            screen_1: screen_1_stop_after,
            screen_2: screen_2_stop_after,
            screen_3: screen_3_stop_after,
        };

        // Sound
        const { sound } = this.state;
        repackedConfig.sound = sound;

        // Slow trials
        const { slow_trials } = this.state;
        repackedConfig.slow_trials = slow_trials;

        // Odds guess amounts
        const {
            odds_guess_1_win_amount,
            odds_guess_2_win_amount,
            odds_guess_2_lose_amount,
        } = this.state;
        repackedConfig.odds_guess_1_win_amount = odds_guess_1_win_amount;
        repackedConfig.odds_guess_2_win_amount = odds_guess_2_win_amount;
        repackedConfig.odds_guess_2_lose_amount = odds_guess_2_lose_amount;

        // Wager amounts
        const { wager_high, wager_low } = this.state;
        repackedConfig.wager_high = wager_high;
        repackedConfig.wager_low = wager_low;

        // Duration
        const {
            duration_break_block,
            duration_break_sequence,
            duration_odds_guess_1,
            duration_odds_guess_2,
            duration_practice_reminder,
            duration_practice_screen_1,
            duration_practice_screen_2,
            duration_practice_screen_3,
            duration_practice_aaron_mood_info,
            duration_practice_game_choice,
            duration_practice_game_spin,
            duration_practice_game_aaron_bad_mood,
            duration_practice_game_pass,
            duration_practice_game_result,
            duration_practice_game_missed_trial,
            duration_experiment_reminder,
            duration_experiment_slow_screen_1,
            duration_experiment_slow_screen_2,
            duration_experiment_slow_screen_3,
            duration_experiment_slow_aaron_mood_info,
            duration_experiment_slow_game_choice,
            duration_experiment_slow_game_spin,
            duration_experiment_slow_game_aaron_bad_mood,
            duration_experiment_slow_game_pass,
            duration_experiment_slow_game_result,
            duration_experiment_slow_game_missed_trial,
            duration_experiment_normal_screen_1,
            duration_experiment_normal_screen_2,
            duration_experiment_normal_screen_3,
            duration_experiment_normal_aaron_mood_info,
            duration_experiment_normal_game_choice,
            duration_experiment_normal_game_spin,
            duration_experiment_normal_game_aaron_bad_mood,
            duration_experiment_normal_game_pass,
            duration_experiment_normal_game_result,
            duration_experiment_normal_game_missed_trial,
        } = this.state;

        repackedConfig.duration = {
            break_block: duration_break_block,
            break_sequence: duration_break_sequence,
            odds_guess_1: duration_odds_guess_1,
            odds_guess_2: duration_odds_guess_2,
            practice: {
                reminder: duration_practice_reminder,
                screen_1: duration_practice_screen_1,
                screen_2: duration_practice_screen_2,
                screen_3: duration_practice_screen_3,
                aaron_mood_info: duration_practice_aaron_mood_info,
                game: {
                    choice: duration_practice_game_choice,
                    spin: duration_practice_game_spin,
                    aaron_bad_mood: duration_practice_game_aaron_bad_mood,
                    pass: duration_practice_game_pass,
                    result: duration_practice_game_result,
                    missed_trial: duration_practice_game_missed_trial,
                },
            },
            experiment: {
                reminder: duration_experiment_reminder,
                slow: {
                    screen_1: duration_experiment_slow_screen_1,
                    screen_2: duration_experiment_slow_screen_2,
                    screen_3: duration_experiment_slow_screen_3,
                    aaron_mood_info: duration_experiment_slow_aaron_mood_info,
                    game: {
                        choice: duration_experiment_slow_game_choice,
                        spin: duration_experiment_slow_game_spin,
                        aaron_bad_mood:
                            duration_experiment_slow_game_aaron_bad_mood,
                        pass: duration_experiment_slow_game_pass,
                        result: duration_experiment_slow_game_result,
                        missed_trial:
                            duration_experiment_slow_game_missed_trial,
                    },
                },
                normal: {
                    screen_1: duration_experiment_normal_screen_1,
                    screen_2: duration_experiment_normal_screen_2,
                    screen_3: duration_experiment_normal_screen_3,
                    aaron_mood_info: duration_experiment_normal_aaron_mood_info,
                    game: {
                        choice: duration_experiment_normal_game_choice,
                        spin: duration_experiment_normal_game_spin,
                        aaron_bad_mood:
                            duration_experiment_normal_game_aaron_bad_mood,
                        pass: duration_experiment_normal_game_pass,
                        result: duration_experiment_normal_game_result,
                        missed_trial:
                            duration_experiment_normal_game_missed_trial,
                    },
                },
            },
        };

        return repackedConfig;
    };

    componentDidMount() {
        // Load from props
        if (this.props.config.loaded) {
            this.setState(this.unpackConfig());
        }
    }

    onChange = (e) => {
        const { id, type, name, value } = e.target;
        let newValue = value;
        let obj_name = id;

        // Radio button gives back a string so need to parse it
        // as a number for treatment_sens_order
        if (name === "treatment_sens_order")
            newValue = parseInt(newValue);

        if (type === "radio") {
            obj_name = name;
        }

        if (type === "number") {
            newValue = parseFloat(newValue);
        }

        if (name === "sound" || name === "start_blue") {
            newValue = value === "true" ? true : false;
        }

        this.setState({ [obj_name]: newValue });
    };

    onSubmit = (e) => {
        e.preventDefault();
        const success = this.props.updateConfig(this.repackConfig());

        this.setState({
            did_save_succeed: success
                ? save_state.SUCCEEDED
                : save_state.FAILED,
        });
    };

    renderDidSaveSucceed = () => {
        const { did_save_succeed } = this.state;
        if (did_save_succeed === save_state.FAILED) {
            return <p style={{ color: "red" }}>Config failed to save!</p>;
        } else if (did_save_succeed === save_state.SUCCEEDED) {
            return (
                <p
                    style={{ color: "green" }}
                    data-test-id="cy-Config-savesucceed"
                >
                    Config saved successfully!
                </p>
            );
        }
        return null;
    };

    formProbabilityColor = () => {
        const {
            color_low_probability,
            color_high_probability,
            color_low_name,
            color_high_name,
        } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Color</Card.Header>
                <Card.Body>
                    <Card.Text>Click boxes to select color</Card.Text>
                    <Card.Text>
                        Please manually provide color names to be displayed as
                        text.
                    </Card.Text>
                    <Form.Group as={Row}>
                        <div className="col-6">
                            <Form.Label>Low Probability</Form.Label>
                        </div>
                        <div className="col">
                            <Form.Control
                                id="color_low_probability"
                                type="color"
                                onChange={this.onChange}
                                value={color_low_probability}
                            />
                        </div>
                    </Form.Group>
                    <Form.Group as={Row}>
                        <Col>
                            <Form.Label>Low Color Name</Form.Label>
                        </Col>
                        <Col>
                            <Form.Control
                                id="color_low_name"
                                type="text"
                                onChange={this.onChange}
                                value={color_low_name}
                            />
                        </Col>
                    </Form.Group>
                    <Form.Group as={Row}>
                        <div className="col-6">
                            <Form.Label>High Probability</Form.Label>
                        </div>
                        <div className="col">
                            <Form.Control
                                id="color_high_probability"
                                type="color"
                                onChange={this.onChange}
                                value={color_high_probability}
                            />
                        </div>
                    </Form.Group>
                    <Form.Group as={Row}>
                        <Col>
                            <Form.Label>High Color Name</Form.Label>
                        </Col>
                        <Col>
                            <Form.Control
                                id="color_high_name"
                                type="text"
                                onChange={this.onChange}
                                value={color_high_name}
                            />
                        </Col>
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formTreatment = () => {
        const { treatment } = this.state;
        return (
            <Card>
                <Card.Header as="h5">Treatment</Card.Header>
                <Card.Body>
                    <Card.Text>Type of experiment</Card.Text>
                    <Form.Group>
                        <Form.Check
                            type="radio"
                            label="Test"
                            value="test"
                            name="treatment"
                            onChange={this.onChange}
                            checked={treatment === "test"}
                        />
                        <Form.Check
                            type="radio"
                            label="Control"
                            value="control"
                            name="treatment"
                            onChange={this.onChange}
                            checked={treatment === "control"}
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formNormMoodLastBlue = () => {
        const { treatment_sens_order } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Sensitization phase order</Card.Header>
                <Card.Body>
                    <Card.Text>Set the ordering of the sensitization phase for treatment only.</Card.Text>
                    <Form.Group>
                        <Form.Check
                            type="radio"
                            label="Original Order: (L,0.8,1) (H,0.8,1) (L,0.8,0.5) (H,0.8,0.5)"
                            value={TREATMENT_SENS_ORDER.ORIGINAL}
                            name="treatment_sens_order"
                            onChange={this.onChange}
                            checked={treatment_sens_order === TREATMENT_SENS_ORDER.ORIGINAL}
                        />
                        <Form.Check
                            type="radio"
                            label="Normal mood at last blue session: (H,0.8,0.5) (L,0.8,0.5) (L,0.8,1) (H,0.8,1)"
                            value={TREATMENT_SENS_ORDER.NORMAL_MOOD_LAST}
                            name="treatment_sens_order"
                            onChange={this.onChange}
                            checked={treatment_sens_order === TREATMENT_SENS_ORDER.NORMAL_MOOD_LAST}
                        />
                        <Form.Check
                            type="radio"
                            label="Random order"
                            value={TREATMENT_SENS_ORDER.RANDOM}
                            name="treatment_sens_order"
                            onChange={this.onChange}
                            checked={treatment_sens_order === TREATMENT_SENS_ORDER.RANDOM}
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formStartBlue = () => {
        const { start_blue } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Blue session at start of each sequence</Card.Header>
                <Card.Body>
                    <Card.Text>High probability, sure play, $2</Card.Text>
                    <Form.Group>
                        <Form.Check
                            type="radio"
                            label="Off"
                            value={false}
                            name="start_blue"
                            onChange={this.onChange}
                            checked={!start_blue}
                        />
                        <Form.Check
                            type="radio"
                            label="On"
                            value={true}
                            name="start_blue"
                            onChange={this.onChange}
                            checked={start_blue}
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formReward = () => {
        const { reward_low, reward_high } = this.state;
        return (
            <Card>
                <Card.Header as="h5">Reward</Card.Header>
                <Card.Body>
                    <Card.Text>Amounts received if bet won</Card.Text>
                    <Form.Group>
                        <Form.Label>Low</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="reward_low"
                                type="number"
                                onChange={this.onChange}
                                value={reward_low}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>High</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="reward_high"
                                type="number"
                                onChange={this.onChange}
                                value={reward_high}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formMultiplier = () => {
        const { multiplier } = this.state;
        return (
            <Card>
                <Card.Header as="h5">Multiplicator</Card.Header>
                <Card.Body>
                    <Form.Group>
                        <Form.Control
                            id="multiplier"
                            type="number"
                            onChange={this.onChange}
                            value={multiplier}
                            min="1"
                            step="1"
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formBetAmount = () => {
        const { bet_amount } = this.state;
        return (
            <Card>
                <Card.Header as="h5">Bet Amount</Card.Header>
                <Card.Body>
                    <InputGroup>
                        <InputGroup.Prepend>
                            <InputGroup.Text>$</InputGroup.Text>
                        </InputGroup.Prepend>
                        <Form.Control
                            id="bet_amount"
                            type="number"
                            onChange={this.onChange}
                            value={bet_amount}
                            min="0"
                            step="0.01"
                        />
                    </InputGroup>
                </Card.Body>
            </Card>
        );
    };

    formRepetition = () => {
        const { repetitions } = this.state;
        return (
            <Card>
                <Card.Header as="h5">Repetitions</Card.Header>
                <Card.Body>
                    <Card.Text>Number of repetitions per sequence</Card.Text>
                    <Form.Control
                        id="repetitions"
                        type="number"
                        onChange={this.onChange}
                        value={repetitions}
                        min="0"
                        step="1"
                    />
                </Card.Body>
            </Card>
        );
    };

    formTrials = () => {
        const { trials } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Trials</Card.Header>
                <Card.Body>
                    <Card.Text>Number of trials per block</Card.Text>
                    <Form.Control
                        id="trials"
                        type="number"
                        onChange={this.onChange}
                        value={trials}
                        min="1"
                        step="1"
                    />
                </Card.Body>
            </Card>
        );
    };

    formSimulation = () => {
        const { simulation_examples, simulation_pause } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Simulation</Card.Header>
                <Card.Body>
                    <Card.Text>Simulation on page 4</Card.Text>
                    <Form.Group>
                        <Form.Label>Number of examples to run</Form.Label>
                        <Form.Control
                            id="simulation_examples"
                            type="number"
                            onChange={this.onChange}
                            value={simulation_examples}
                            min="1"
                            step="1"
                        />
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>
                            How long to pause between examples in seconds
                        </Form.Label>
                        <Form.Control
                            id="simulation_pause"
                            type="number"
                            onChange={this.onChange}
                            value={simulation_pause}
                            min="1"
                            step="1"
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formProbability = () => {
        const { probability_low, probability_high } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Probability</Card.Header>
                <Card.Body>
                    <Card.Text>Probability of winning bet</Card.Text>
                    <Form.Group>
                        <Form.Label>Bad Blocks</Form.Label>
                        <Form.Control
                            id="probability_low"
                            type="number"
                            onChange={this.onChange}
                            value={probability_low}
                            min="0"
                            max="1"
                            step="0.01"
                        />
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>Good Blocks</Form.Label>
                        <Form.Control
                            id="probability_high"
                            type="number"
                            onChange={this.onChange}
                            value={probability_high}
                            min="0"
                            max="1"
                            step="0.01"
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formAaronSpin = () => {
        const { aaron_spin } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Aaron Spin</Card.Header>
                <Card.Body>
                    <Card.Text>
                        Probability that Aaron generates an outcome when he's
                        cheeky
                    </Card.Text>
                    <Form.Control
                        id="aaron_spin"
                        type="number"
                        onChange={this.onChange}
                        value={aaron_spin}
                        min="0"
                        max="1"
                        step="0.01"
                    />
                </Card.Body>
            </Card>
        );
    };

    formProbabilityLotteryShow = () => {
        const { probability_show_lottery } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Probability Show Lottery</Card.Header>
                <Card.Body>
                    <Card.Text>
                        Probability that lottery is shown to participants who
                        have won money
                    </Card.Text>
                    <Form.Control
                        data-test-id="cy-Config-probabilityshowlottery"
                        id="probability_show_lottery"
                        type="number"
                        onChange={this.onChange}
                        value={probability_show_lottery}
                        min="0"
                        max="1"
                        step="0.01"
                    />
                </Card.Body>
            </Card>
        );
    };

    formThreshold = () => {
        const { threshold } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Threshold Value</Card.Header>
                <Card.Body>
                    <InputGroup>
                        <InputGroup.Prepend>
                            <InputGroup.Text>$</InputGroup.Text>
                        </InputGroup.Prepend>
                        <Form.Control
                            id="threshold"
                            type="number"
                            onChange={this.onChange}
                            value={threshold}
                            min="0"
                            step="0.01"
                        />
                    </InputGroup>
                </Card.Body>
            </Card>
        );
    };

    formMissedTrials = () => {
        const { missed_trials } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Max Missed Trials</Card.Header>
                <Card.Body>
                    <Card.Text>
                        Number of missed trials before experiment stops
                    </Card.Text>
                    <Card.Text>0 means disabled</Card.Text>
                    <Form.Control
                        id="missed_trials"
                        type="number"
                        onChange={this.onChange}
                        value={missed_trials}
                        min="0"
                        step="1"
                    />
                </Card.Body>
            </Card>
        );
    };

    formScreenStop = () => {
        const { screen_1_stop_after } = this.state;

        // const { screen_2_stop_after, screen_3_stop_after } = this.state;

        return (
            <Card>
                <Card.Header as="h5">
                    Stop incoming screen after block
                </Card.Header>
                <Card.Body>
                    <Card.Text>-1 means never</Card.Text>
                    <Card.Text>Please use arrows to change value</Card.Text>
                    <Form.Group>
                        <Form.Control
                            id="screen_1_stop_after"
                            type="number"
                            onChange={this.onChange}
                            value={screen_1_stop_after}
                            min="-1"
                            step="1"
                        />
                    </Form.Group>
                    {/* <Form.Group>
                        <Form.Label>Screen 2</Form.Label>
                        <Form.Control id="screen_2_stop_after" type="number" onChange={this.onChange} value={screen_2_stop_after} min="-1" step="1"/>
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>Screen 3</Form.Label>
                        <Form.Control id="screen_3_stop_after" type="number" onChange={this.onChange} value={screen_3_stop_after} min="-1" step="1"/>
                    </Form.Group> */}
                </Card.Body>
            </Card>
        );
    };

    formSound = () => {
        const { sound } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Sound</Card.Header>
                <Card.Body>
                    <Card.Text>Sound played with dollar icon</Card.Text>
                    <Form.Group>
                        <Form.Check
                            type="radio"
                            label="Off"
                            value={false}
                            name="sound"
                            onChange={this.onChange}
                            checked={!sound}
                        />
                        <Form.Check
                            type="radio"
                            label="On"
                            value={true}
                            name="sound"
                            onChange={this.onChange}
                            checked={sound}
                        />
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formSlowTrials = () => {
        const { slow_trials } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Slow Trials</Card.Header>
                <Card.Body>
                    <Card.Text>How many initial trials are slower</Card.Text>
                    <Form.Control
                        id="slow_trials"
                        type="number"
                        onChange={this.onChange}
                        value={slow_trials}
                        min="0"
                        step="1"
                    />
                </Card.Body>
            </Card>
        );
    };

    formOddsGuessOne = () => {
        const { duration_odds_guess_1, odds_guess_1_win_amount } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Odds Guess 1</Card.Header>
                <Card.Body>
                    <Form.Group>
                        <Form.Label>Duration(seconds)</Form.Label>
                        <Form.Control
                            id="duration_odds_guess_1"
                            type="number"
                            onChange={this.onChange}
                            value={duration_odds_guess_1}
                            min="0"
                            step="0.1"
                        />
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>Amount if win</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="odds_guess_1_win_amount"
                                type="number"
                                onChange={this.onChange}
                                value={odds_guess_1_win_amount}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formOddsGuessTwo = () => {
        const {
            duration_odds_guess_2,
            odds_guess_2_win_amount,
            odds_guess_2_lose_amount,
        } = this.state;

        return (
            <Card>
                <Card.Header as="h5">Odds Guess 2</Card.Header>
                <Card.Body>
                    <Form.Group>
                        <Form.Label>Duration(seconds)</Form.Label>
                        <Form.Control
                            id="duration_odds_guess_2"
                            type="number"
                            onChange={this.onChange}
                            value={duration_odds_guess_2}
                            min="0"
                            step="0.1"
                        />
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>Amount if win</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="odds_guess_2_win_amount"
                                type="number"
                                onChange={this.onChange}
                                value={odds_guess_2_win_amount}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>Amount if lose</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="odds_guess_2_lose_amount"
                                type="number"
                                onChange={this.onChange}
                                value={odds_guess_2_lose_amount}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    formWager = () => {
        const { wager_low, wager_high } = this.state;
        return (
            <Card>
                <Card.Header as="h5">Wager Amounts</Card.Header>
                <Card.Body>
                    <Card.Text>
                        Wager for players who never bet in yellow
                    </Card.Text>
                    <Form.Group>
                        <Form.Label>Low</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="wager_low"
                                type="number"
                                onChange={this.onChange}
                                value={wager_low}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>High</Form.Label>
                        <InputGroup>
                            <InputGroup.Prepend>
                                <InputGroup.Text>$</InputGroup.Text>
                            </InputGroup.Prepend>
                            <Form.Control
                                id="wager_high"
                                type="number"
                                onChange={this.onChange}
                                value={wager_high}
                                min="0"
                                step="0.01"
                            />
                        </InputGroup>
                    </Form.Group>
                </Card.Body>
            </Card>
        );
    };

    commonDurations = (durations) => {
        return (
            <Fragment>
                {Object.keys(durations).map((key, index) => (
                    <Form.Group key={key}>
                        <Form.Label>{durations[key]}</Form.Label>
                        <Form.Control
                            id={key}
                            type="number"
                            onChange={this.onChange}
                            value={this.state[key]}
                            min="0"
                            step="0.1"
                        />
                    </Form.Group>
                ))}
            </Fragment>
        );
    };

    packDurations = () => {
        const practice_durations = {
            duration_practice_screen_1: "Incoming",
            duration_practice_game_choice: "Game Ask Player",
            duration_practice_game_spin: "Game Spin",
            duration_practice_game_aaron_bad_mood: "Game Aaron Bad Mood",
            duration_practice_game_pass: "Game Pass",
            duration_practice_game_result: "Game Result",
            duration_practice_game_missed_trial: "Game Missed Trial",
        };

        const slow_durations = {
            duration_experiment_slow_screen_1: "Incoming",
            duration_experiment_slow_game_choice: "Game Ask Player",
            duration_experiment_slow_game_spin: "Game Spin",
            duration_experiment_slow_game_aaron_bad_mood: "Game Aaron Bad Mood",
            duration_experiment_slow_game_pass: "Game Pass",
            duration_experiment_slow_game_result: "Game Result",
            duration_experiment_slow_game_missed_trial: "Game Missed Trial",
        };

        const experiment_durations = {
            duration_experiment_normal_screen_1: "Incoming",
            duration_experiment_normal_game_choice: "Game Ask Player",
            duration_experiment_normal_game_spin: "Game Spin",
            duration_experiment_normal_game_aaron_bad_mood:
                "Game Aaron Bad Mood",
            duration_experiment_normal_game_pass: "Game Pass",
            duration_experiment_normal_game_result: "Game Result",
            duration_experiment_normal_game_missed_trial: "Game Missed Trial",
        };

        return { practice_durations, slow_durations, experiment_durations };
    };

    formDuration = () => {
        const packDurations = this.packDurations();

        const { duration_break_block, duration_break_sequence } = this.state;

        const { duration_practice_reminder, duration_experiment_reminder } =
            this.state;

        return (
            <Card>
                <Card.Header as="h5">Durations</Card.Header>
                <Card.Body>
                    <Card.Text>All values are in seconds</Card.Text>
                    <Form.Group>
                        <Form.Label>Break between 2 blocks</Form.Label>
                        <Form.Control
                            id="duration_break_block"
                            type="number"
                            onChange={this.onChange}
                            value={duration_break_block}
                            min="0"
                            step="0.1"
                        />
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>
                            Break (relax screen) between 2 sequences
                        </Form.Label>
                        <Form.Control
                            id="duration_break_sequence"
                            type="number"
                            onChange={this.onChange}
                            value={duration_break_sequence}
                            min="0"
                            step="0.1"
                        />
                    </Form.Group>
                    <Row>
                        <Col>
                            <Card>
                                <Card.Header as="h5">Practice</Card.Header>
                                <Card.Body>
                                    <Form.Group>
                                        <Form.Label>Reminder screen</Form.Label>
                                        <Form.Control
                                            id="duration_practice_reminder"
                                            type="number"
                                            onChange={this.onChange}
                                            value={duration_practice_reminder}
                                            min="0"
                                            step="0.1"
                                        />
                                    </Form.Group>
                                    {this.commonDurations(
                                        packDurations.practice_durations
                                    )}
                                </Card.Body>
                            </Card>
                        </Col>
                        <Col>
                            <Card>
                                <Card.Header as="h5">Experiment</Card.Header>
                                <Card.Body>
                                    <Form.Group>
                                        <Form.Label>Reminder screen</Form.Label>
                                        <Form.Control
                                            id="duration_experiment_reminder"
                                            type="number"
                                            onChange={this.onChange}
                                            value={duration_experiment_reminder}
                                            min="0"
                                            step="0.1"
                                        />
                                    </Form.Group>
                                    <Row>
                                        <Col>
                                            <Card>
                                                <Card.Header>Slow</Card.Header>
                                                <Card.Body>
                                                    {this.commonDurations(
                                                        packDurations.slow_durations
                                                    )}
                                                </Card.Body>
                                            </Card>
                                        </Col>
                                        <Col>
                                            <Card>
                                                <Card.Header>
                                                    Normal
                                                </Card.Header>
                                                <Card.Body>
                                                    {this.commonDurations(
                                                        packDurations.experiment_durations
                                                    )}
                                                </Card.Body>
                                            </Card>
                                        </Col>
                                    </Row>
                                </Card.Body>
                            </Card>
                        </Col>
                    </Row>
                </Card.Body>
            </Card>
        );
    };

    showDataBaseStatus = () => {
        if (this.props.config.source === "firebase") {
            return (
                <div>
                    Connected to firebase. Press save button at bottom of page
                    to save changes to config.
                </div>
            );
        } else if (this.props.config.source === FLASK_BACKEND) {
            const server_type =
                process.env.NODE_ENV === "production" ? "UNSW" : "development";
            return (
                <div>
                    Connected to {server_type} server. Press save button at
                    bottom of page to save changes to config.
                </div>
            );
        } else {
            return (
                <div>
                    Not connected to any server, config won't be saved online.
                </div>
            );
        }
    };

    render() {
        return (
            <Container>
                <Row>
                    <h1>Config page</h1>
                </Row>
                <Row>
                    <Link 
                        data-test-id="cy-Config-backtoadmin"
                    to="/admin">Back to admin dashboard</Link>
                </Row>
                <Row className="mt-2">
                    <h5>{this.showDataBaseStatus()}</h5>
                </Row>
                <Row>
                    <Form onSubmit={this.onSubmit}>
                        <Row className="mt-5">
                            <Col>{this.formTreatment()}</Col>
                            <Col>{this.formProbabilityColor()}</Col>
                            <Col>{this.formSimulation()}</Col>
                        </Row>
                        <Row className="mt-5">
                            <Col>{this.formNormMoodLastBlue()}</Col>
                            <Col>{this.formStartBlue()}</Col>
                        </Row>
                        <Row className="mt-5">
                            <Col>{this.formReward()}</Col>
                            <Col>{this.formMultiplier()}</Col>
                            <Col>{this.formBetAmount()}</Col>
                            <Col>{this.formThreshold()}</Col>
                        </Row>
                        <Row className="mt-5">
                            <Col>{this.formRepetition()}</Col>
                            <Col>{this.formTrials()}</Col>
                            <Col>{this.formMissedTrials()}</Col>
                        </Row>
                        <Row className="mt-5">
                            <Col>{this.formProbability()}</Col>
                            <Col>{this.formAaronSpin()}</Col>
                            <Col>{this.formProbabilityLotteryShow()}</Col>
                        </Row>
                        <Row className="mt-5 mb-5">
                            <Col>{this.formScreenStop()}</Col>
                            <Col>{this.formSound()}</Col>
                            <Col>{this.formSlowTrials()}</Col>
                        </Row>
                        <Row className="mt-5 mb-5">
                            <Col>{this.formOddsGuessOne()}</Col>
                            <Col>{this.formOddsGuessTwo()}</Col>
                            <Col>{this.formWager()}</Col>
                        </Row>
                        {this.formDuration()}
                        <Row className="mt-5 justify-content-center">
                            {this.renderDidSaveSucceed()}
                        </Row>
                        <Row className="mt-1 mb-5 justify-content-center">
                            <Button data-test-id="cy-Config-save" type="submit">
                                Save
                            </Button>
                        </Row>
                    </Form>
                </Row>
            </Container>
        );
    }
}

const mapStateToProps = (state) => {
    return {
        config: state.config,
    };
};

export default connect(mapStateToProps)(Config);
