import React, { Component } from "react";
import PropTypes from "prop-types";
import { Row, Button } from "react-bootstrap";
import Reward from "./components/Reward";
import { MAX_AMOUNT_LOST } from "../Finish";

class Lose extends Component {
    render() {
        const { net, thresh, score, nextFunc, reward, wager } = this.props;

        const initial_score = net - thresh + wager;

        const show_initial_score = () => {
            return (
                <h3>
                    Therefore, your final score in the game is $
                    {initial_score.toFixed(2)}.
                </h3>
            );
        };

        const show_amount_lose = (score) => {
            const init_score_reward = Math.abs(initial_score + reward);

            if (score === 0) return <h3>So overall you get nothing, sorry!</h3>;
            else if (Math.abs(init_score_reward) > MAX_AMOUNT_LOST) {
                return (
                    <h3>
                        So overall you lost ${init_score_reward.toFixed(2)}, sorry!
                        Since we capped the losses on your end at $
                        {MAX_AMOUNT_LOST}, this means you lost $
                        {MAX_AMOUNT_LOST}.
                    </h3>
                );
            } else
                return (
                    <h3>So overall you lost ${(-score).toFixed(2)}, sorry!</h3>
                );
        };

        const wager_msg = () => {
            if (wager)
                return "+ wager amount";
        }

        return (
            <>
                <Row className="justify-content-center">
                    <h2>The game is over!</h2>
                </Row>
                <Row className="pt-5 pl-5">
                    <h3>
                        Your net accumulated outcomes across all the rounds you
                        played {wager_msg()} are ${(net + wager).toFixed(2)}.
                    </h3>
                </Row>
                <Row className="pt-5 pl-5">
                    <h3>
                        The threshold value has been set at ${thresh.toFixed(2)}
                        .{" "}
                    </h3>
                </Row>
                <Row className="pt-5 pl-5">{show_initial_score()}</Row>
                <Reward
                    className="pt-5 pl-5"
                    reward={reward}
                    didWin={initial_score > 0}
                />
                <Row 
                    className="pt-5 pl-5"
                    data-test-id="cy-Finish-Lose-component"
                >
                    {show_amount_lose(score)}
                </Row>
                <Row 
                    className="pt-5 justify-content-center"
                    data-test-id="cy-Finish-Lose-Next-Button"
                >
                    <Button 
                        data-test-id="cy-Finish-Lose-next"
                        onClick={nextFunc}
                    >
                        Next
                    </Button>
                </Row>
            </>
        );
    }
}

Lose.propTypes = {
    net: PropTypes.number.isRequired,
    thresh: PropTypes.number.isRequired,
    nextFunc: PropTypes.func.isRequired,
};

export default Lose;
