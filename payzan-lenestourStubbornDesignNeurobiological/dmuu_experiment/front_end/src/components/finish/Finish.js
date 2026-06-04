import React, { Component } from "react";
import FinalQuiz from "./FinalQuiz/FinalQuiz";
import Lottery from "./Lottery/Lottery";
import { Container } from "react-bootstrap";
import Earning from "./screens/Earning";
import { screenStates, FinishStateMachine } from "./FinishStates";
import Lose from "./screens/Lose";
import { connect } from "react-redux";
import { setPostGameQuiz } from "../../redux/playerStats/playerStatsActions";
import { getTotalOddsGuessReward } from "./CalcOddsGuessEarnings";
import WinShowLottery from "./screens/WinShowLottery";
import WinShowBet from "./screens/WinShowBet";
import WinNoBet from "./screens/WinNoBet";
import Wager from "./screens/Wager";
import LotteryOutcomeNoBet from "./screens/LotteryOutcomeNoBet";
import LotteryOutcomeShowBet from "./screens/LotteryOutcomeShowBet";
import { sendFinishPageToBackend } from "../../backend_interface/outputFile/finishPage";
import {
    formatOutputData,
    sendDataToBackend,
} from "../../backend_interface/outputFile/outputFile";
import { withRouter } from "react-router-dom";
import Loader from "../loader/Loader";

export const MAX_AMOUNT_WON = 110;
export const MAX_AMOUNT_LOST = 50;
export const SHOW_UP_REWARD = 5;
class Finish extends Component {
    constructor(props) {
        super(props);

        this.fsm = new FinishStateMachine();
    }

    state = {
        net: 0,
        threshold: 0,
        multiplier: 0,
        curState: screenStates.LOADING,
        oddsGuessEarnings: 0,
        earnings: 0,
        quiz: null,
        demo: null,
        greater_than_threshold: false,
        prizeMoney: 0,
        lotteryWinAmnt: 0,
        playerStats: null,
        experiment_type: null,
        waiting: false,
        done: false,
    };

    // Previous finished experiment loaded
    setFinishSkip = (finish_data) => {
        this.setState({
            curState: finish_data.endState,
            earnings: finish_data.score,
            net: finish_data.net,
            threshold: finish_data.thresh,
            oddsGuessEarnings: finish_data.reward,
            multiplier: finish_data.mult,
            lotteryWinAmnt: finish_data.lotteryWinAmnt,
            greater_than_threshold: finish_data.didWin,
        });
    };

    componentDidMount() {
        const { location } = this.props;

        let { playerStats, experiment_type, probabilityLottery } = this.props;

        if (location.data) {
            if (location.data.finishInProgress) {
                playerStats = location.data.playerStats;
                experiment_type = location.data.experiment_type;
            }

            this.setState({ playerStats, experiment_type });

            if (location.data.finishSkip) {
                this.setFinishSkip(location.data.finish_data);
            } else {
                const { net, threshold, multiplier } = location.data;

                const oddsGuessEarnings = getTotalOddsGuessReward(
                    playerStats,
                    this.props
                );

                const earnings = this.calculateInitalEarnings(
                    net,
                    threshold,
                    multiplier,
                    oddsGuessEarnings
                );
                const greater_than_threshold = earnings > 0;

                this.fsm.nextState({
                    didWin: greater_than_threshold,
                    didBetYellow: playerStats.made_low_probability_bet,
                    didBet: playerStats.bet_in_c_block,
                    probabilityLottery,
                });

                const prizeMoney = greater_than_threshold
                    ? 0
                    : Math.abs(earnings);

                this.setState({
                    net,
                    threshold,
                    multiplier,
                    curState: this.fsm.getState(),
                    earnings,
                    greater_than_threshold,
                    oddsGuessEarnings,
                    prizeMoney,
                });
            }
        }
    }

    componentDidUpdate() {
        this.sendFinishToBackend();
    }

    // If the player has finished the experiment
    // send finish screen information to backend
    sendFinishToBackend = () => {
        const endStates = [
            screenStates.WIN_NO_BET,
            screenStates.LOTTERY_EARNING_NO_BET,
            screenStates.EARNING,
        ];

        if (
            endStates.includes(this.state.curState) &&
            !this.props.location.data.suppressOutput &&
            this.state.playerStats.personal_info.email !== null
        ) {
            const {
                net,
                threshold,
                multiplier,
                earnings,
                lotteryWinAmnt,
                oddsGuessEarnings,
                greater_than_threshold,
            } = this.state;
            const { playerStats, experiment_type } = this.state;
            let finish_data = {};

            finish_data.endState = this.state.curState;
            finish_data.score = earnings;
            finish_data.net = net;
            finish_data.thresh = threshold;
            finish_data.reward = oddsGuessEarnings;
            finish_data.mult = multiplier;
            finish_data.lotteryWinAmnt = lotteryWinAmnt;
            finish_data.didWin = greater_than_threshold;

            // Send final quiz results to backend and finish screen info
            if (this.state.waiting === false) {
                this.setState({ waiting: true }, () => {
                    sendDataToBackend(
                        formatOutputData(playerStats, experiment_type),
                        () =>
                            sendFinishPageToBackend({
                                email: playerStats.personal_info.email,
                                finish_data,
                            }, this.setState({ done: true })),
                        () => this.props.history.push("/checkConnection")
                    );
                });
            }
        }
    };

    calculateInitalEarnings(net, threshold, multiplier, oddsGuessEarnings, wager=0) {
        const difference = net - threshold + wager;
        let earnings = oddsGuessEarnings;

        if (difference < 0) earnings += difference;
        else earnings += multiplier * difference;

        return Math.max(-MAX_AMOUNT_LOST, earnings);
    }

    finishQuiz = (answers) => {
        this.props.saveQuizAnswers(answers); // Save to redux
        let new_playerStats = this.state.playerStats;
        new_playerStats.post_game_quiz = answers; // Save to state
        this.fsm.nextState();
        this.setState({
            curState: this.fsm.getState(),
            playerStats: new_playerStats,
        });
    };

    finishLottery = (win) => {
        this.fsm.nextState({
            didBetYellow: this.state.playerStats.made_low_probability_bet,
            didBet: this.state.playerStats.bet_in_c_block,
        });

        this.setState({
            curState: this.fsm.getState(),
            lotteryWinAmnt: win,
            earnings: this.state.earnings + win,
        });
    };

    finishWager = (wager) => {
        let new_playerStats = this.state.playerStats;
        new_playerStats.wager = wager; // Save to state

        // Recalculate earnings since wager should be before threshold and multiplier
        const oddsGuessEarnings = getTotalOddsGuessReward(
            this.state.playerStats,
            this.props
        );
        const earnings = this.calculateInitalEarnings(
            this.state.net,
            this.state.threshold,
            this.state.multiplier,
            oddsGuessEarnings,
            wager
        );
        const greater_than_threshold = earnings > 0;
        const prizeMoney = greater_than_threshold
            ? 0
            : Math.abs(earnings);

        this.fsm.nextState({
            didWin: greater_than_threshold,
            probabilityLottery: this.props.probabilityLottery,
        });

        this.setState({
            earnings,
            curState: this.fsm.getState(),
            playerStats: new_playerStats,
            greater_than_threshold,
            prizeMoney
        });
    };

    finishLose = () => {
        this.fsm.nextState();
        this.setState({
            curState: this.fsm.getState(),
        });
    };

    finishWin = () => {
        this.fsm.nextState();
        this.setState({
            curState: this.fsm.getState(),
        });
    };

    finishLotteryEarningBet = () => {
        this.fsm.nextState();
        this.setState({ curState: this.fsm.getState() });
    };

    selectPage = () => {
        let page;
        const {
            net,
            threshold,
            multiplier,
            earnings,
            lotteryWinAmnt,
            oddsGuessEarnings,
            greater_than_threshold,
        } = this.state;

        switch (this.state.curState) {
            case screenStates.WIN_LOTTERY:
                page = (
                    <WinShowLottery
                        net={net}
                        thresh={threshold}
                        score={earnings}
                        reward={oddsGuessEarnings}
                        nextFunc={this.finishWin}
                        mult={multiplier}
                        wager={this.props.playerStats.wager}
                    />
                );
                break;
            case screenStates.WIN_BET:
                page = (
                    <WinShowBet
                        net={net}
                        thresh={threshold}
                        score={earnings}
                        reward={oddsGuessEarnings}
                        nextFunc={this.finishWin}
                        mult={multiplier}
                    />
                );
                break;

            case screenStates.WIN_NO_BET:
                page = (
                    <WinNoBet
                        net={net}
                        thresh={threshold}
                        score={earnings}
                        reward={oddsGuessEarnings}
                        mult={multiplier}
                        wager={this.props.playerStats.wager}
                    />
                );
                console.log("Finished!");
                break;

            case screenStates.LOSE:
                page = (
                    <Lose
                        net={net}
                        thresh={threshold}
                        score={earnings}
                        nextFunc={this.finishLose}
                        reward={oddsGuessEarnings}
                        wager={this.props.playerStats.wager}
                    />
                );
                break;

            case screenStates.WIN_WAGER:
                page = (
                    <WinShowLottery
                        net={net}
                        thresh={threshold}
                        score={earnings}
                        reward={oddsGuessEarnings}
                        nextFunc={this.finishWin}
                        mult={multiplier}
                    />
                );
                break;

            case screenStates.LOSE_WAGER:
                page = (
                    <Lose
                        net={net}
                        thresh={threshold}
                        score={earnings}
                        nextFunc={this.finishLose}
                        reward={oddsGuessEarnings}
                    />
                );
                break;

            case screenStates.WAGER:
                page = (
                    <Wager
                        nextFunc={this.finishWager}
                    />
                );
                break;

            case screenStates.FINAL_QUIZ:
                const { low_color, high_color } = this.props.location.data;
                page = (
                    <FinalQuiz
                        finish={this.finishQuiz}
                        low_color={low_color}
                        high_color={high_color}
                    />
                );
                break;

            case screenStates.LOTTERY:
                page = (
                    <Lottery
                        finish={this.finishLottery}
                        prizeMoney={this.state.prizeMoney}
                    />
                );
                break;

            case screenStates.LOTTERY_EARNING_BET:
                page = (
                    <LotteryOutcomeShowBet
                        lotteryWinAmnt={lotteryWinAmnt}
                        score={earnings}
                        nextFunc={this.finishLotteryEarningBet}
                        didWin={greater_than_threshold}
                    />
                );
                break;

            case screenStates.LOTTERY_EARNING_NO_BET:
                page = (
                    <LotteryOutcomeNoBet
                        lotteryWinAmnt={lotteryWinAmnt}
                        score={earnings}
                        didWin={greater_than_threshold}
                    />
                );
                console.log("Finished!");
                break;

            case screenStates.EARNING:
                page = (
                    <Earning
                        score={earnings}
                        didWin={greater_than_threshold}
                    />
                );
                console.log("Finished!");
                break;

            default:
                page = <p>Loading</p>;
                break;
        }

        return page;
    };

    render() {
        if (!this.props.location.data) {
            return <h1>Error go back to home page</h1>;
        }

        if (this.state.waiting && !this.state.done) {
            return <Loader/>;
        }

        return (
            <Container className="h-100">
                <div className="d-flex flex-column justify-content-center h-100">
                    {this.selectPage()}
                </div>
            </Container>
        );
    }
}

// Redux stuff
const mapStateToProps = (state) => {
    return {
        playerStats: state.stats,
        experiment_type: state.config.config.params.treatment,
        low_prob: state.config.config.params.probability.low,
        odds_guess_1_win_amount:
            state.config.config.params.odds_guess_1_win_amount,
        odds_guess_2_win_amount:
            state.config.config.params.odds_guess_2_win_amount,
        odds_guess_2_lose_amount:
            state.config.config.params.odds_guess_2_lose_amount,
        probabilityLottery: state.config.config.params.probability.show_lottery,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        saveQuizAnswers: (answers) => dispatch(setPostGameQuiz(answers)),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(Finish));
