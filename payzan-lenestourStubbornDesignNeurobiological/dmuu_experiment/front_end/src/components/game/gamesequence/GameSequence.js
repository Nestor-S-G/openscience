// GameSequence
// The actual experiment itself
// Extracts the blocks from the config file and sets up the game rounds
import React, { Component } from "react";
import Reminder from "./screens/Reminder";
import GameRound from "../gameround/GameRound";
import Incoming from "./screens/Incoming";
import { Redirect } from "react-router-dom";
import { INS_PRACTICE } from "../../instructions/InstructionOrder";
import { completePractice } from "../../../redux/instruction/instructionActions";
import {
    restartGame,
    setLowProbabilityBet,
} from "../../../redux/playerStats/playerStatsActions";
import { connect } from "react-redux";
import populateBlocks from "./configParsing/populateBlocks";
import {
    selectDuration,
    extractDurations,
    speed_debug_durations,
} from "./configParsing/extractDuration";
import BreakBlock from "./screens/Break/BreakBlock";
import BreakSequence from "./screens/Break/BreakSequence/BreakSequence";
import ExceedMissedTrials from "./screens/ExceedMissedTrials";
import OddsGuessOne from "./screens/OddsGuess/OddsGuessOne/OddsGuessOne";
import OddsGuessTwo from "./screens/OddsGuess/OddsGuessTwo/OddsGuessTwo";
import { OddsGuessState } from "./screens/OddsGuess/OddsGuessState";

const screenStates = {
    LOADING: "loading",
    REMINDER: "reminder",
    INCOMING: "screen_1",
    GAME: "game",
    MISSED_TRIALS: "missed_trial",
    FINISHED: "finished",
    BREAK_BLOCK: "break_block",
    BREAK_SEQUENCE: "break_sequence",
    ODDS_GUESS_1: "odds_guess_1",
    ODDS_GUESS_1_REPEAT: "odds_guess_1_repeat",
    ODDS_GUESS_2: "odds_guess_2",
    ODDS_GUESS_2_REPEAT: "odds_guess_2_repeat",
};

const TICK_INTERVAL_MS = 100;

class GameSequence extends Component {
    constructor(props) {
        super(props);

        const { config, practice, debug } = this.props;
        const blocks = populateBlocks(config, practice, debug);

        this.oddsGuessState = new OddsGuessState(this.props.practice);

        this.state = {
            config,
            rep: 1,
            blocks,
            block_num: 0,
            startTime: Date.now(),
            elapsedTime: 0,
            screenTransitionTime: 0,
            misses: 0,
            curState: screenStates.LOADING,
            finished_experiment: false,
            net: 0,
            slow_trials: config.params.slow_trials,
            total_blocks_completed: 0,
        };
    }

    startTimer = () => {
        this.timer = setInterval(() => this.tick(), TICK_INTERVAL_MS);
    };

    tick() {
        this.setState(
            { elapsedTime: Date.now() - this.state.startTime },
            this.nextState
        );
    }

    componentDidMount() {
        this.props.resetStats();
        this.startTimer();
    }

    componentWillUnmount() {
        clearInterval(this.timer);
    }

    getCurAaronMood = () => {
        const { blocks, block_num } = this.state;
        return blocks[block_num].aaron_cheeky ? "bad" : "good";
    };

    getNextState = (curState) => {
        let newState;
        switch (curState) {
            case screenStates.LOADING:
                newState = screenStates.REMINDER;
                break;

            case screenStates.REMINDER:
                newState = screenStates.INCOMING;
                break;

            case screenStates.INCOMING:
                newState = screenStates.GAME;
                break;

            case screenStates.MISSED_TRIALS:
                if (this.props.practice) {
                    newState = screenStates.FINISHED;
                }
                break;

            case screenStates.BREAK_BLOCK:
                newState = screenStates.INCOMING;
                break;

            case screenStates.BREAK_SEQUENCE:
                newState = screenStates.REMINDER;
                break;

            case screenStates.ODDS_GUESS_1:
            case screenStates.ODDS_GUESS_1_REPEAT:
            case screenStates.ODDS_GUESS_2:
            case screenStates.ODDS_GUESS_2_REPEAT:
                if (this.props.config.params.duration.break_block > 0) {
                    newState = screenStates.BREAK_BLOCK;
                } else {
                    newState = screenStates.INCOMING;
                }
                break;

            default:
                newState = screenStates.LOADING;
                break;
        }

        return newState;
    };

    // Statemachine
    nextState = () => {
        const { curState, screenTransitionTime, elapsedTime } = this.state;
        const { config, practice, reduxDebug } = this.props;

        let newState = curState;
        let newSTT = screenTransitionTime;
        let duration = selectDuration(config, practice, this.state.slow_trials);

        if (reduxDebug.speed_debug) {
            console.log("Speed debug enabled!");
            duration = speed_debug_durations;
        }

        if (duration.hasOwnProperty(curState)) {
            if (
                elapsedTime - screenTransitionTime >
                duration[curState] * 1000
            ) {
                newState = this.getNextState(curState);
            }
        } else {
            newState = this.getNextState(curState);
        }

        // Screen has changed
        if (newState !== curState) {
            newSTT = elapsedTime;
        }

        this.setState({ curState: newState, screenTransitionTime: newSTT });
    };

    isLowProbability = () => {
        const { blocks, block_num } = this.state;
        const { probability } = blocks[block_num];

        return probability === "low";
    };

    // Function to call if player made a bet (clicked yes)
    // Check if low probability round and update store
    playerMadeBet = () => {
        const { made_low_probability_bet } = this.props.playerStats;
        if (!made_low_probability_bet && this.isLowProbability()) {
            this.props.setLowProbabilityBet();
        }
    };

    playGame() {
        const { blocks, block_num } = this.state;

        const config = this.state.config.params;

        const curblock = blocks[block_num];
        const color = config.color[curblock.color];
        const reward = config.reward[curblock.reward];
        const probability = config.probability[curblock.probability];
        const { duration } = config;

        // Disable timer
        clearInterval(this.timer);

        // First few rounds of actual are slower and only in the first block
        let normal_duration = extractDurations(duration, "normal");
        if (this.props.reduxDebug.speed_debug)
            normal_duration = speed_debug_durations;
        let slow_duration = extractDurations(duration, "slow");

        let slow_trials = this.state.slow_trials;
        if (this.props.practice) {
            slow_trials = 0;
        }

        const { rep, misses, net } = this.state;

        // Create config object

        let game_config = {
            color,
            reward,
            probability,
            duration: normal_duration.game,
            slow_duration: slow_duration.game,
            slow_trials,
            aaron_cheeky: this.getAaronMood(curblock.aaron_cheeky),
            high: curblock.reward === "high",
            practice: this.props.practice,
            debug: this.props.debug,
            block_type: curblock.type,
        };

        return (
            <GameRound
                game_config={game_config}
                finish={this.finishGame}
                rep={rep}
                block_num={block_num}
                block_len={blocks.length}
                missed_trial={this.missedTrial}
                misses={misses}
                madeBet={this.playerMadeBet}
                netOutcome={net}
            />
        );
    }

    finishedBlocks = () => {
        const { block_num, blocks } = this.state;
        if (block_num >= blocks.length - 1) {
            return true;
        }
        return false;
    };

    finishedAllRepetitions = () => {
        const { rep, config } = this.state;
        return rep >= config.params.repetitions;
    };

    nextRepetition = (elapsedTime, curState) => {
        const { config, rep, total_blocks_completed } = this.state;
        const { practice, debug } = this.props;
        const blocks = populateBlocks(config, practice, debug);

        this.setState(
            {
                curState,
                rep: rep + 1,
                block_num: 0,
                blocks,
                elapsedTime,
                screenTransitionTime: elapsedTime,
                total_blocks_completed: total_blocks_completed + 1,
                slow_trials: config.params.slow_trials // Slow trials every repetition
            },
            () => {
                this.nextState();
                this.startTimer();
            }
        );
    };

    // Used by GameRound to notify its done with the current block
    finishGame = (earnings, slow_trials_completed, did_bet) => {
        const {
            startTime,
            block_num,
            net,
            config,
            slow_trials,
            total_blocks_completed,
        } = this.state;
        const net_total = net + earnings;

        let newState = screenStates.INCOMING;
        const elapsedTime = Date.now() - startTime;
        let startTimer = false;

        if (this.finishedBlocks()) {
            if (
                this.oddsGuessState.isOddsGuessCondition(
                    did_bet,
                    this.isLowProbability()
                )
            ) {
                newState = this.oddsGuessState.getState();
            } else if (this.props.practice || this.finishedAllRepetitions()) {
                newState = screenStates.FINISHED;
            } else {
                // Next repetition
                // Break sequence
                if (config.params.duration.break_sequence > 0) {
                    newState = screenStates.BREAK_SEQUENCE;
                }

                console.log(`Earnings at end of block = ${earnings}`);
                console.log(`Net total = ${net_total}`);
                console.log(`Slow trials completed = ${slow_trials_completed}`);

                this.setState({net: net_total},
                    () => this.nextRepetition(elapsedTime, newState));
                
                return;
            }
        } else {
            if (
                this.oddsGuessState.isOddsGuessCondition(
                    did_bet,
                    this.isLowProbability()
                )
            ) {
                newState = this.oddsGuessState.getState();
            } else {
                startTimer = true;
                if (config.params.duration.break_block > 0) {
                    newState = screenStates.BREAK_BLOCK;
                }
            }
        }

        console.log(`Earnings at end of block = ${earnings}`);
        console.log(`Net total = ${net_total}`);
        console.log(`Slow trials completed = ${slow_trials_completed}`);

        this.setState(
            {
                curState: newState,
                block_num: block_num + 1,
                net: net_total,
                screenTransitionTime: elapsedTime,
                elapsedTime,
                slow_trials: slow_trials - slow_trials_completed,
                total_blocks_completed: total_blocks_completed + 1,
            },
            () => {
                if (startTimer) this.startTimer();
            }
        );
    };

    missesExceeded = (misses) => {
        const config = this.state.config.params;
        return misses >= config.missed_trials ? true : false;
    };

    missedTrial = () => {
        const { curState, misses } = this.state;
        let curMisses = misses + 1;

        let newState = curState;

        if (this.missesExceeded(curMisses)) {
            newState = screenStates.MISSED_TRIALS;
            if (this.props.practice) {
                newState = screenStates.FINISHED;
            }
        } else {
            this.startTimer();
        }

        this.setState({ misses: curMisses, curState: newState });
    };

    /**
     * Called whenever odds guess one or two screen is finished
     */
    finishGuess = () => {
        // Transitioning between one repetition to the next
        if (this.finishedBlocks()) {
            if (this.finishedAllRepetitions()) {
                this.setState({ curState: screenStates.FINISHED });
            } else {
                let newState = screenStates.INCOMING;
                const elapsedTime = Date.now() - this.state.startTime;

                if (this.props.config.params.duration.break_sequence > 0) {
                    newState = screenStates.BREAK_SEQUENCE;
                }
                this.nextRepetition(elapsedTime, newState);
            }
        } else {
            this.startTimer();
            this.tick();
        }
    };

    // bool aaron_cheeky
    getAaronMood = (aaron_cheeky) => {
        const config = this.state.config.params;

        const aaron_cheeky_probability = config.probability.aaron_spin * 100;

        return aaron_cheeky ? aaron_cheeky_probability : 100;
    };

    // Select a page depending on the current state
    selectPage = () => {
        const { blocks, block_num, config, curState } = this.state;
        const curBlock = blocks[block_num];
        const {
            color,
            probability,
            threshold,
            multiplier,
            reward,
            duration,
        } = config.params;
        const { low_name, high_name } = color;
        const { low, high } = probability;

        const low_probability = low * 100;
        const high_probability = high * 100;
        let page;
        switch (curState) {
            case screenStates.LOADING:
                page = <span>Loading Config...</span>;
                break;

            case screenStates.REMINDER:
                page = (
                    <Reminder
                        probs={{
                            low_color: low_name,
                            low_probability,
                            high_color: high_name,
                            high_probability,
                        }}
                    />
                );
                break;

            case screenStates.INCOMING:
                const colorBlock = color[curBlock.color];
                const colorName = color[`${curBlock.probability}_name`];
                const mood = this.getAaronMood(curBlock.aaron_cheeky);
                const block_reward = reward[curBlock.reward];

                page = (
                    <Incoming
                        colorName={colorName}
                        color={colorBlock}
                        mood={mood}
                        reward={block_reward}
                        high_reward={curBlock.reward === "high"}
                    />
                );
                break;

            case screenStates.GAME:
                page = this.playGame();
                break;

            case screenStates.MISSED_TRIALS:
                page = <ExceedMissedTrials />;
                break;

            case screenStates.FINISHED:
                if (this.props.practice) {
                    if (!this.missesExceeded(this.state.misses))
                        this.props.finishPractice();
                    page = (
                        <Redirect
                            to={{
                                pathname: "/instructions",
                                page: INS_PRACTICE,
                            }}
                        />
                    );
                } else {
                    page = (
                        <Redirect
                            to={{
                                pathname: "/finish",
                                data: {
                                    net: this.state.net,
                                    low_color: low_name,
                                    high_color: high_name,
                                    threshold,
                                    multiplier,
                                    suppressOutput: false,
                                },
                            }}
                        />
                    );
                }
                break;

            case screenStates.BREAK_BLOCK:
                page = <BreakBlock />;
                break;

            case screenStates.BREAK_SEQUENCE:
                page = <BreakSequence time={duration.break_sequence}/>;
                break;

            case screenStates.ODDS_GUESS_1:
                page = <OddsGuessOne finish={this.finishGuess} />;
                break;

            case screenStates.ODDS_GUESS_1_REPEAT:
                page = <OddsGuessOne finish={this.finishGuess} repeat={true} />;
                break;

            case screenStates.ODDS_GUESS_2:
                page = <OddsGuessTwo finish={this.finishGuess} />;
                break;

            case screenStates.ODDS_GUESS_2_REPEAT:
                page = <OddsGuessTwo finish={this.finishGuess} repeat={true} />;
                break;

            default:
                page = <span>Loading Config...</span>;
                break;
        }

        return page;
    };

    render() {
        return this.selectPage();
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        playerStats: state.stats,
        config: state.config.config,
        reduxDebug: state.debug,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        finishPractice: () => dispatch(completePractice()),
        setLowProbabilityBet: () => dispatch(setLowProbabilityBet()),
        resetStats: () => dispatch(restartGame()),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(GameSequence);
