import React from "react";
import Reward from "./components/Reward";
import { Row } from "react-bootstrap";
import { MAX_AMOUNT_WON, SHOW_UP_REWARD } from "../Finish";

export const winCommon = (net, thresh, score, reward, mult, show_up_reward, wager=0) => {
    const initial_score = net - thresh + wager;
    const mult_score = initial_score * mult;

    const final_score = () => {
        if (initial_score < 0)
            return (
                <h3>
                    Therefore, you final score in the game is $
                    {initial_score.toFixed(2)}.
                </h3>
            );
        return (
            <h3>
                Therefore, you final score in the game is $
                {initial_score.toFixed(2)} x {mult} = ${mult_score.toFixed(2)}.
            </h3>
        );
    };

    const overall_msg = () => {
        if (score > MAX_AMOUNT_WON)
            return (
                <h3>
                    So overall your final score is ${score.toFixed(2)}. Recall
                    that the maximum payment in the experiment is $
                    {MAX_AMOUNT_WON}, which you will receive shortly,
                    congratulations!
                </h3>
            );
        else if (score < MAX_AMOUNT_WON - SHOW_UP_REWARD && show_up_reward) {
            return (
                <h3>So overall you won ${score.toFixed(2)}, which will be added to the show-up
                reward of ${SHOW_UP_REWARD}, congratulations!</h3>
            );
        }
        return (
            <h3>So overall you won ${score.toFixed(2)}, congratulations!</h3>
        );
    };

    const proceed_msg = () => {
        if (score <= MAX_AMOUNT_WON)
            return (
                <Row className="pt-5">
                    <h3>
                        We're going to proceed to the payment procedure soon,
                        thanks for your patience.
                    </h3>
                </Row>
            );
    };

    const wager_msg = () => {
        if (wager)
            return "+ wager amount";
    }

    return (
        <>
            <Row 
                className="justify-content-center"
                data-test-id="cy-WinCommon"
            >
                <h2>The game is over!</h2>
            </Row>
            <Row className="pt-5">
                <h3>
                    Your net accumulated outcomes across all the rounds you
                    performed {wager_msg()} are ${(net + wager).toFixed(2)}.
                </h3>
            </Row>
            <Row className="pt-5">
                <h3>
                    The threshold value has been set at ${thresh.toFixed(2)}.
                </h3>
            </Row>
            <Row className="pt-5">{final_score()}</Row>
            <Reward
                className="pt-5"
                reward={reward}
                didWin={initial_score > 0}
            />
            <Row className="pt-5">{overall_msg()}</Row>
            {proceed_msg()}
        </>
    );
};
