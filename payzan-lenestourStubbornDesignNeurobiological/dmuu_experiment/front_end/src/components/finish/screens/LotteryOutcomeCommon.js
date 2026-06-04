import React from "react";
import { Row } from "react-bootstrap";
import { MAX_AMOUNT_WON, SHOW_UP_REWARD } from "../Finish";

export const LotteryOutcomeCommon = (lotteryWinAmnt, score, winGame, wager) => {
    let wagerText;

    if (wager > 0) {
        wagerText = " + amount won in the wager";
        score += wager;
    }

    if (score > MAX_AMOUNT_WON) score = MAX_AMOUNT_WON + lotteryWinAmnt;
    const final_earnings_msg = () => {

        if (winGame) {
            if (score > MAX_AMOUNT_WON)
                return (
                    <h3>
                        Your final earnings from the experiment (what you've
                        just earned at the wheel of fortune + the amount you won
                        in the game{wagerText}) are thus ${score.toFixed(2)}. Recall that
                        the maximum payment in the experiment is $
                        {MAX_AMOUNT_WON}, which you will receive shortly,
                        congratulations!
                    </h3>
                );
            else if (score < MAX_AMOUNT_WON - SHOW_UP_REWARD) {
                return (
                    <h3>
                        Your final earnings from the experiment (what you've
                        just earned at the wheel of fortune + the amount you won
                        in the game{wagerText}) are thus ${score.toFixed(2)}, which will be
                        added to the show-up reward of ${SHOW_UP_REWARD}.
                    </h3>
                );
            }
            return (
                <h3>
                    Your final earnings from the experiment (what you've just
                    earned at the wheel of fortune + the amount you won in the
                    game{wagerText}) are thus ${score.toFixed(2)}.
                </h3>
            );
        }

        return (
            <h3>
                Your final earnings from the experiment (what you've just earned
                at the wheel of fortune{wagerText} - the amount you lost in the game) are
                thus ${score.toFixed(2)}, which will be added to the show-up
                reward of ${SHOW_UP_REWARD}.
            </h3>
        );
    };

    return (
        <>
            <Row data-test-id="cy-LotteryOutcomeCommon-lucky">
                <h3>
                    Lucky you! You just won ${lotteryWinAmnt.toFixed(2)} at the
                    wheel of fortune.
                </h3>
            </Row>
            <Row className="pt-5">{final_earnings_msg()}</Row>
            <Row className="pt-5">
                <h3>
                    Thanks again for participating, we're going to proceed to
                    the payment procedure soon; thanks for your patience.
                </h3>
            </Row>
        </>
    );
};
