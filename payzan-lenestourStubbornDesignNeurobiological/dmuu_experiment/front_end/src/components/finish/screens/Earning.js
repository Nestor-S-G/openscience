import React, { Component } from "react";
import { MAX_AMOUNT_WON, SHOW_UP_REWARD } from "../Finish";

export default class Earning extends Component {

    showEarnings = () => {
        let { score } = this.props;

        if (score > MAX_AMOUNT_WON)
            score = MAX_AMOUNT_WON;

        // Add a show up reward of $5
        if (score < MAX_AMOUNT_WON - SHOW_UP_REWARD)
            score += SHOW_UP_REWARD;

        return (
            <div>
                <h3>
                    Your final earnings from the experiment are $
                    {score.toFixed(2)}.
                </h3>
            </div>
        );
    };

    render() {
        return (
            <div data-test-id="cy-Earning" className="text-center">
                {this.showEarnings()}
                <h3>
                    Please wait, the experimenter is going to proceed to the
                    payment procedure very soon.
                </h3>
            </div>
        );
    }
}
