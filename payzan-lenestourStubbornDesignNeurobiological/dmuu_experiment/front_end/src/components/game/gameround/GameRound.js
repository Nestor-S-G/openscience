// A single round of the game
import React, { Component, Fragment } from "react";
import { Image } from "react-bootstrap";
import Phaser from "phaser";
import { connect } from "react-redux";
import AskPlayer from "./screens/AskPlayer";
import Cheeky from "./screens/Cheeky";
import Pass from "./screens/Pass";
import SlotGame from "../slotgame/SlotGame";
import MissedTrial from "./screens/MissedTrial";
import GameRoundHeader from "./GameRoundHeader";
import {
    appendRoundData,
    betInCBlock,
} from "../../../redux/playerStats/playerStatsActions";
import { summarizeRoundData } from "./GameRoundOutput";
import {
    formatOutputData,
    sendDataToBackend,
} from "../../../backend_interface/outputFile/outputFile";
import Loader from "../../loader/Loader";
import { withRouter } from "react-router-dom";

const screenStates = {
    ASK_PLAYER: "choice",
    BAD_MOOD: "aaron_bad_mood",
    GAME: "game",
    PASS: "pass",
    NEXT_ROUND: "nextround",
    MISSED: "missed_trial",
    TRANSITION: "transition",
};

const TICK_INTERVAL_MS = 100;

class GameRound extends Component {

    // Only have one instance of the slot game
    // Needed due to some react double render issues
    _gameStarted = false

    state = {
        rounds: 1,
        startTime: 0,
        elapsedTime: 0,
        screenTransitionTime: 0,
        curScreen: 0,
        misses: 0,
        curState: "",
        action: null,
        gameFinish: false,
        net: 0,
        did_bet: false,
        choice: "none",
        time_to_answer: 0,
        status_of_play: "none",
        outcome: 0,
        reactionTime: 0,
        waiting: false,
    };

    // Timer methods

    startTimer = () => {
        this.timerID = setInterval(() => this.tick(), TICK_INTERVAL_MS);
    };

    stopTimer = () => {
        clearInterval(this.timerID);
        clearTimeout(this.speedDebugTimeout);
    };

    tick() {
        this.nextState();
    }

    componentDidMount() {
        this.startTimer();
        this.rand = new Phaser.Math.RandomDataGenerator();

        // For asking the player
        this.cheekyImage = (
            <Image
                className="m-auto"
                id="cheeky"
                onLoad={this.onLoad}
                src={
                    process.env.PUBLIC_URL +
                    "/assets/instruction_pages/aaron_cheeky_slot.png"
                }
            />
        );
        this.normalImage = (
            <Image
                className="m-auto"
                id="normal"
                onLoad={this.onLoad}
                src={
                    process.env.PUBLIC_URL +
                    "/assets/instruction_pages/aaron_slot.png"
                }
            />
        );

        this.setState({
            startTime: Date.now(),
            curState: screenStates.ASK_PLAYER,
            reactionTime: Date.now(),
        });
    }

    componentWillUnmount() {
        this.stopTimer();
    }

    // Finished the round and moving onto the next block
    checkFinished = () => {
        return this.state.rounds > this.props.config.trials;
    };

    checkSlow = () => {
        return this.state.rounds <= this.props.game_config.slow_trials;
    };

    pickDuration = () => {
        const { duration, slow_duration } = this.props.game_config;
        return this.checkSlow() ? slow_duration : duration;
    };

    // Check if duration for current screen has passed
    checkDurationPassed(elapsedTime, screenTransitionTime, curState) {
        const duration = this.pickDuration();
        return elapsedTime - screenTransitionTime > duration[curState] * 1000;
    }

    nextState = () => {
        const {
            startTime,
            curState,
            action,
            screenTransitionTime,
            misses,
            gameFinish,
            rounds,
        } = this.state;
        let newState = curState;
        let newAction = action;
        let newSTT = screenTransitionTime;
        let newMisses = misses;
        let newRounds = rounds;
        let newGameFinish = gameFinish;
        let missedTrial = false;
        let elapsedTime = Date.now() - startTime;
        let reactionTime = this.state.reactionTime;

        switch (curState) {
            case screenStates.ASK_PLAYER:
                if (action) {
                    if (action.type === "yes") {
                        if (action.mood === "bad") {
                            newState = screenStates.BAD_MOOD;
                            newAction = null;
                        } else {
                            newState = screenStates.GAME;
                            newGameFinish = false;
                            newAction = null;
                            clearInterval(this.timerID);
                        }
                    } else {
                        const duration = this.pickDuration();
                        if (duration[screenStates.PASS] > 0) {
                            newState = screenStates.PASS;
                        } else {
                            newState = screenStates.TRANSITION;
                        }
                        newAction = null;
                    }
                } else {
                    if (
                        this.checkDurationPassed(
                            elapsedTime,
                            screenTransitionTime,
                            curState
                        )
                    ) {
                        // The timer has run out
                        newState = screenStates.MISSED;
                        newAction = null;
                        missedTrial = true;
                    }
                }
                break;

            case screenStates.BAD_MOOD:
                if (
                    this.checkDurationPassed(
                        elapsedTime,
                        screenTransitionTime,
                        curState
                    )
                ) {
                    newState = screenStates.ASK_PLAYER;
                    newRounds += 1;
                }
                break;

            case screenStates.GAME:
                if (gameFinish) {
                    // restart timer
                    this.startTimer();

                    newState = screenStates.ASK_PLAYER;
                    newRounds += 1;
                }
                break;

            case screenStates.PASS:
                if (
                    this.checkDurationPassed(
                        elapsedTime,
                        screenTransitionTime,
                        curState
                    )
                ) {
                    newState = screenStates.ASK_PLAYER;
                    newRounds += 1;
                }
                break;

            case screenStates.MISSED:
                if (
                    this.checkDurationPassed(
                        elapsedTime,
                        screenTransitionTime,
                        curState
                    )
                ) {
                    // Too many misses do something
                    newState = screenStates.ASK_PLAYER;
                    newMisses += 1;
                    newRounds += 1;
                }
                break;

            case screenStates.TRANSITION:
                newState = screenStates.ASK_PLAYER;
                newRounds += 1;
                break;

            default:
                newState = screenStates.NEXT_ROUND;
                break;
        }

        if (newState !== curState) {
            newSTT = Date.now() - this.state.startTime;
            reactionTime = Date.now();
        }

        // New round or miss
        if (newRounds !== rounds) {
            if (newMisses !== misses) {
                this.saveRoundInfo(true);
            } else {
                this.saveRoundInfo(false);
            }
        }

        this.setState({
            curState: newState,
            action: newAction,
            screenTransitionTime: newSTT,
            misses: newMisses,
            rounds: newRounds,
            gameFinish: newGameFinish,
            elapsedTime,
            reactionTime,
        });

        // Finish game and pass the net amount earned this round
        if (this.checkFinished()) {
            const slow_trials_completed = Math.min(
                this.props.config.trials,
                this.props.config.slow_trials
            );

            // Send data at the end of each block
            if (
                !this.props.game_config.practice &&
                !this.props.game_config.debug
            ) {
                const { playerStats, experiment_type } = this.props;
                this.setState({ waiting: true }, () =>
                {
                    this.stopTimer();
                    sendDataToBackend(
                        formatOutputData(playerStats, experiment_type),
                        () => {
                                this.props.finish(
                                    this.state.net,
                                    slow_trials_completed,
                                    this.state.did_bet);
                        },
                        () => this.props.history.push('/checkConnection')
                    );
                });
            } else {
                this.props.finish(
                    this.state.net,
                    slow_trials_completed,
                    this.state.did_bet);
            }

        }
        if (missedTrial) {
            this.props.missed_trial();
        }
    };

    // Save the status at the end of each round into redux state
    // Check whether there was a miss
    saveRoundInfo = (missed) => {
        if (!this.props.game_config.practice)
            this.props.saveRoundInfo(
                summarizeRoundData(missed, this.props, this.state)
            );
    };

    pickScreen() {
        const duration = this.pickDuration();

        if (!duration) {
            return <span>Loading</span>;
        }

        if (this.state.waiting) {
            return <Loader/>;
        };

        switch (this.state.curState) {
            case screenStates.ASK_PLAYER:
                return this.askShow(duration);

            case screenStates.BAD_MOOD:
                return this.aaronCheeky();

            case screenStates.GAME:
                if (!this._gameStarted) {
                    this._gameStarted = true;
                    if (this.props.reduxDebug.speed_debug)
                        return this.fakeSlotGame();
                    return this.slotGame(duration);
                }
                return <span>Loading</span>;

            case screenStates.PASS:
                return this.passSlot();

            case screenStates.MISSED:
                return this.missedTrial();

            default:
                return <span>Loading</span>;
        }
    }

    checkAaronMood = () => {
        const { aaron_cheeky } = this.props.game_config;

        // Check aaron's mood
        let mood = "good";
        if (aaron_cheeky !== 100) {
            const pick = this.rand.integerInRange(1, 100);
            if (pick > aaron_cheeky) {
                mood = "bad";
            }
        }

        return mood;
    };

    checkCBlock = () => {
        console.log(this.props.game_config.block_type);
        if (this.props.game_config.block_type === "C") {
            this.props.betInCBlock();
        }
    };

    // Time between the screen transitioning to asking the player
    // and when the player clicks in seconds
    // How accurate it is depends on TICK_INTERVAL_MS
    getReactionTime = () => {
        const time_between =
            (Date.now() - this.state.reactionTime);
        return parseFloat(time_between);
    };

    playerYes = () => {
        const mood = this.checkAaronMood();
        this.props.madeBet();
        this.checkCBlock();
        this.setState({
            action: { type: "yes", mood },
            did_bet: true,
            choice: "spin",
            time_to_answer: this.getReactionTime(),
            status_of_play: mood === "good" ? "showed" : "refused",
        });
    };

    playerNo = () => {
        this.setState({
            action: { type: "no" },
            choice: "pass",
            time_to_answer: this.getReactionTime(),
        });
    };

    askShow(durations) {
        return (
            <Fragment>
                <AskPlayer
                    yes={this.playerYes}
                    no={this.playerNo}
                    cheeky={this.props.game_config.aaron_cheeky}
                    duration={durations.choice}
                    normal_image={this.normalImage}
                    cheeky_image={this.cheekyImage}
                />
            </Fragment>
        );
    }

    aaronCheeky() {
        return <Cheeky />;
    }

    // Check if the player won and calculate amount
    getSlotOutcome(win) {
        const { bet_amount } = this.props.config;
        const { reward } = this.props.game_config;

        if (win) return reward - bet_amount;
        else return -bet_amount;
    }

    finishSlotGame = (win) => {
        const outcome = this.getSlotOutcome(win);
        const net = this.state.net + outcome;

        this.setState(
            {
                gameFinish: true,
                win,
                net: parseFloat(net.toFixed(2)),
                outcome,
            },
            this.nextState
        );
        this._gameStarted = false;
    };

    // Speed debug just give result after a short delay
    fakeSlotGame() {
        const { probability } = this.props.game_config;
        const win = Math.random() < probability;

        this.speedDebugTimeout = setTimeout(() => {
            this.finishSlotGame(win);
        }, 100);
        return <h1>Speed Debug! {win ? "Win" : "Lose"}</h1>;
    }

    slotGame(durations) {
        const { sound } = this.props.config;
        const {
            reward,
            probability,
            aaron_cheeky,
            high,
        } = this.props.game_config;
        const is_cheeky = aaron_cheeky !== 100;

        return (
            <SlotGame
                spin_duration={durations.spin}
                result_duration={durations.result}
                probability={probability * 100}
                cheeky={is_cheeky}
                reward={reward}
                finish={this.finishSlotGame}
                sound={sound}
                high={high}
            />
        );
    }

    passSlot() {
        return <Pass />;
    }

    missedTrial() {
        return <MissedTrial />;
    }

    render() {
        const {
            config,
            game_config,
            block_num,
            block_len,
            misses,
        } = this.props;
        const { rounds } = this.state;
        const { missed_trials, trials } = config;
        const { color } = game_config;

        return (
            <div className="d-flex flex-column h-100">
                <GameRoundHeader color={color}>
                    Session: {Math.min(block_num + 1, block_len)}/{block_len} Round: {Math.min(rounds, trials)}/
                    {trials} Missed: {misses}/{missed_trials}
                </GameRoundHeader>
                <div
                    className="d-flex flex-row flex-grow-1 justify-content-center align-items-center mb-5"
                    id="game-div"
                >
                    {this.pickScreen()}
                </div>
            </div>
        );
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        playerStats: state.stats,
        experiment_type: state.config.config.params.treatment,
        config: state.config.config.params,
        reduxDebug: state.debug,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        saveRoundInfo: (roundInfo) => dispatch(appendRoundData(roundInfo)),
        betInCBlock: () => dispatch(betInCBlock()),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(GameRound));
