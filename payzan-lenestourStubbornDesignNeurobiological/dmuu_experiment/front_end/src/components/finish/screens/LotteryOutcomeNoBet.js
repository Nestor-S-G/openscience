import React, { Component } from "react";
import { LotteryOutcomeCommon } from "./LotteryOutcomeCommon";

export default class LotteryOutcomeNoBet extends Component {
    render() {
        const { lotteryWinAmnt, score, didWin, wager } = this.props;

        return <>{LotteryOutcomeCommon(lotteryWinAmnt, score, didWin, wager)}</>;
    }
}
