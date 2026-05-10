import React, { Component } from "react";
import { Row, Button } from "react-bootstrap";
import FillOutQuiz from "./components/FillOutQuiz";
import { LotteryOutcomeCommon } from "./LotteryOutcomeCommon";

export default class LotteryOutcomeShowBet extends Component {
    render() {
        const { lotteryWinAmnt, score, nextFunc, didWin } = this.props;

        return (
            <>
                {LotteryOutcomeCommon(lotteryWinAmnt, score, didWin)}
                <FillOutQuiz className="pt-5" />
                <Row 
                    className="pt-5 justify-content-center"
                >
                    <Button
                        onClick={nextFunc}
                        data-test-id="cy-LotteryOutcomeShowBet-next"
                    >
                        Next
                    </Button>
                </Row>
            </>
        );
    }
}
