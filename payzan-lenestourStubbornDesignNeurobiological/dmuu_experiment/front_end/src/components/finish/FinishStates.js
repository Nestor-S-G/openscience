// Finite state machine for finish page

// Check if the player has net amount greater than threshold
// Then check if player has bet in a low probability round
export const screenStates = {
    WIN_LOTTERY: "WIN_LOTTERY",
    WIN_BET: "WIN_BET",
    WIN_NO_BET: "WIN_NO_BET",
    WIN_WAGER: "WIN_WAGER",
    LOSE: "LOSE",
    LOSE_WAGER: "LOSE_WAGER",
    WAGER: "WAGER",
    FINAL_QUIZ: "FINAL_QUIZ",
    LOTTERY: "LOTTERY",
    LOTTERY_EARNING_BET: "LOTTERY_EARNING_BET",
    LOTTERY_EARNING_NO_BET: "LOTTERY_EARNING_NO_BET",
    EARNING: "EARNING",
    LOADING: "LOADING",
};

export class FinishStateMachine {
    constructor() {
        this.curState = screenStates.LOADING;
    }

    getState() {
        return this.curState;
    }

    transition(to) {
        this.curState = to;
    }

    nextState(data) {
        this.curState = this.getNextState(data);
    }

    getNextState(data) {
        switch (this.curState) {
            case screenStates.LOADING:
                return this.loadingState(data);

            case screenStates.LOSE:
                return this.loseState();

            case screenStates.LOSE_WAGER:
                return this.loseWagerState();

            case screenStates.WIN_LOTTERY:
                return this.winLotteryState();

            case screenStates.WIN_BET:
                return this.winBetState();

            case screenStates.WIN_WAGER:
                return this.winWagerState();

            case screenStates.FINAL_QUIZ:
                return this.finalQuizState();

            case screenStates.LOTTERY:
                return this.lotteryState(data);

            case screenStates.LOTTERY_EARNING_BET:
                return this.lotteryEarningBetState();

            case screenStates.WAGER:
                return this.wagerState(data);

            default:
                return screenStates.LOADING;
        }
    }

    playLottery = (probabilityLottery) => {
        return Math.random() < probabilityLottery;
    };

    // State transitions outwards from a particular state
    loadingState(data) {
        const { didWin, didBetYellow, didBet, probabilityLottery } = data;
        if (!didBetYellow) return screenStates.WAGER;
        if (didWin) {
            if (this.playLottery(probabilityLottery))
                return screenStates.WIN_LOTTERY;
            return didBet ? screenStates.WIN_BET : screenStates.WIN_NO_BET;
        } else {
            return screenStates.LOSE;
        }
    }

    loseState() {
        return screenStates.LOTTERY;
    }

    loseWagerState() {
        return screenStates.WAGER;
    }

    winLotteryState() {
        return screenStates.LOTTERY;
    }

    winBetState() {
        return screenStates.FINAL_QUIZ;
    }

    winWagerState() {
        return screenStates.WAGER;
    }

    finalQuizState() {
        return screenStates.EARNING;
    }

    lotteryState(data) {
        const { didBetYellow, didBet } = data;
        if (!didBetYellow) return screenStates.LOTTERY_EARNING_NO_BET;
        return didBet
            ? screenStates.LOTTERY_EARNING_BET
            : screenStates.LOTTERY_EARNING_NO_BET;
    }

    lotteryEarningBetState() {
        return screenStates.FINAL_QUIZ;
    }

    wagerState(data) {
        const { didWin, probabilityLottery } = data;
        if (didWin) {
            if (this.playLottery(probabilityLottery))
                return screenStates.WIN_LOTTERY;
            return screenStates.WIN_NO_BET;
        } else {
            return screenStates.LOSE;
        }
    }
}
