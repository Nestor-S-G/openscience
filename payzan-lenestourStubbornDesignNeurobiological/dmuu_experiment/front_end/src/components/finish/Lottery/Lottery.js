import React, { Component } from "react";
import { Button, Row } from "react-bootstrap";
import { Winwheel } from "../../../winwheel/Winwheel";
import wheelConfig from "./LotteryConfig";
import tick_mp3 from "./tick.mp3";

import "../../../winwheel/Winwheel.css";

const WINNING_MESSAGE_TIME_MS = 2500;

class Lottery extends Component {
    constructor(props) {
        super(props);

        this.state = {
            loaded: false,
            spinning: false,
            finished: false,
            win_amnt: 0,
        };
    }

    componentDidMount() {
        this.tickSound = new Audio(tick_mp3);
        // Need to put this here since the canvas is only defined after a render
        this.wheel = new Winwheel(
            wheelConfig(
                this.finishSpinning,
                this.playSound,
                parseFloat(this.props.prizeMoney.toFixed(2))
            )
        );
    }

    componentWillUnmount() {
        if (this.state.spinning)
            this.wheel.stopAnimation();
        clearTimeout(this.finishTimer);
    }

    finishSpinning = (segment) => {
        if (!this.state.finished) {
            const win_amnt = segment.value + this.props.prizeMoney;
            this.setState({ finished: true, win_amnt }, () => {
                this.finishTimer = setTimeout(
                    () => this.props.finish(win_amnt),
                    WINNING_MESSAGE_TIME_MS
                );
            });
        }
    };

    playSound = () => {
        this.tickSound.currentTime = 0;
        this.tickSound.play();
    };

    spinWheel = () => {
        if (this.state.spinning === false) {
            this.wheel.startAnimation();
            this.setState({ spinning: true });
        }
    };

    showWinMsg = () => {
        if (this.state.finished) {
            const { win_amnt } = this.state;
            return (
                <Row className="pt-5 justify-content-center">
                    <h4>Congratulations! You won ${win_amnt.toFixed(2)}</h4>
                </Row>
            );
        }
    };

    showSpinBtn = () => {
        if (!(this.state.finished || this.state.spinning))
            return (
                <Row
                    data-test-id="cy-Lottery-spin" 
                    className="justify-content-center mt-5"
                >
                    <Button onClick={this.spinWheel}>Spin</Button>
                </Row>
            );
    };

    render() {
        return (
            <div className="container">
                <Row className="pt-5 justify-content-center">
                    <h1>Thanks for your participation!</h1>
                </Row>
                <Row className="pt-2 justify-content-center text-center">
                    <p>
                        To thank you for your time, we are inviting you to
                        participate in the following wheel of fortune, in which
                        you can only win money!
                    </p>
                    <p>
                        The values you can win are shown on the wheel. Click
                        spin to start the wheel!
                    </p>
                </Row>
                <Row className="justify-content-center">
                    <div data-test-id="cy-Lottery-wheel" className="the_wheel">
                        <canvas
                            id="canvas"
                            height={434}
                            width={434}
                            className="the_canvas"
                        >
                            <p style={{ color: "white" }} align="center">
                                Sorry, your browser doesn't support canvas.
                                Please try another.
                            </p>
                        </canvas>
                    </div>
                </Row>
                {this.showWinMsg()}
                {this.showSpinBtn()}
            </div>
        );
    }
}

export default Lottery;
