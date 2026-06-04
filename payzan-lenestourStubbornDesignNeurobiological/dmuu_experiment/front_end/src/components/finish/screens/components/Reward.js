/**
 * Return message for odds guess reward
 * if reward is zero return null
 */
import React from "react";
import { Row } from "react-bootstrap";

export default function Reward({ reward, className, didWin }) {
    let reward_msg = null;

    if (didWin) {
        if (reward < 0) {
            reward_msg = (
                <h3>
                    However you lost ${(-reward).toFixed(2)} from the short
                    lotteries you played during the game.
                </h3>
            );
        } else if (reward > 0) {
            reward_msg = (
                <h3>
                    You further won ${reward.toFixed(2)} from the short lotteries
                    you played during the game.
                </h3>
            );
        }
    } else {
        if (reward < 0) {
            reward_msg = (
                <h3>
                    You further lost ${(-reward).toFixed(2)} from the short
                    lotteries you played during the game.
                </h3>
            );
        } else if (reward > 0) {
            reward_msg = (
                <h3>
                    However you won ${reward.toFixed(2)} from the short lotteries
                    you played during the game.
                </h3>
            );
        }
    }

    if (reward_msg)
        return <Row className={className}>{reward_msg}</Row>;
    
    return reward_msg;
}
