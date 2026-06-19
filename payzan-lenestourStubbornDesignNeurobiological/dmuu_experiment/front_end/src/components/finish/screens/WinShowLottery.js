/**
 * Score greater than zero and wheel of fortune going to be shown
 */
import React, { Component } from "react";
import { Row, Button } from "react-bootstrap";
import { winCommon } from "./WinCommon";

export default class WinShowLottery extends Component {
    render() {
        const { net, thresh, score, reward, nextFunc, mult, wager } = this.props;

        return (
            <>
                {winCommon(net, thresh, score, reward, mult, false, wager)}
                <Row className="justify-content-center pt-5">
                    <Button
                        data-test-id="cy-WinShowLottery-Button"
                        onClick={nextFunc}
                    >
                            Next
                    </Button>
                </Row>
            </>
        );
    }
}
