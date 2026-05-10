/**
 * Score > 0 and the participant bet in 2 yellow rounds during the game
 */
import React, { Component } from "react";
import { Row, Button } from "react-bootstrap";
import FillOutQuiz from "./components/FillOutQuiz";
import { winCommon } from "./WinCommon";

export default class WinShowBet extends Component {
    render() {
        const { net, thresh, score, reward, nextFunc, mult } = this.props;

        return (
            <>
                {winCommon(net, thresh, score, reward, mult, true)}
                <FillOutQuiz className="pt-5" />
                <Row className="justify-content-center pt-5">
                    <Button
                        data-test-id="cy-WinShowBet-next"
                        onClick={nextFunc}
                    >
                        Next
                    </Button>
                </Row>
            </>
        );
    }
}
