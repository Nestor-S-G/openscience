import React, { Component } from 'react'
import { Container, Col, Row, Image } from "react-bootstrap";
import wheel_img from "../../../images/wheel.png";
import wheel_highlight_img from "../../../images/wheel_highlight.png";
import match_img from "../../../images/match.png";
import "./Prompt.css";

export default class Prompt extends Component {

    showMessage = () => {
        if (this.props.selection !== "none") {
            return (
                <Row id="odds-guess-one-message" className="mt-5">
                    <h3>
                        Your choice has been recorded and if you win, the $
                        {this.props.winAmount} will be added to your net
                        accumulated outcomes at the end.
                    </h3>
                </Row>
            );
        }
    };

    render() {
        const { winAmount, onClickSlot, onClickWheel } = this.props;

        return (
            <Container>
                <Row className="mt-5 text-center odds-guess-one-title">
                    <h1>
                        Just a short break from play and an opportunity for you
                        to win an additional ${winAmount}
                    </h1>
                </Row>
                <Row className="mt-5">
                    <h3>
                        Aaron is about to spin the machine in a yellow session
                        with another player:
                    </h3>
                </Row>
                <Row className="mt-5 justify-content-center">
                    <Image src={process.env.PUBLIC_URL + "/assets/low_probability.png"} />
                </Row>
                <Row>
                    <h3>He's also about to spin this wheel of fortune:</h3>
                </Row>
                <Row className="mt-5 justify-content-center">
                    <Image src={wheel_img} />
                </Row>
                <Row className="mt-5">
                    <h3>
                        Click on the lottery that you want to play (it's free
                        <span role="img" aria-label="smiley">😊</span>):
                    </h3>
                </Row>
                {this.showMessage()}
                <Row className="mt-5">
                    <Col
                        className="odds-guess-button mr-2"
                        onClick={onClickSlot}
                    >
                        <h4>
                            Win ${winAmount} if the machine stops
                            with the shapes being the same:
                        </h4>
                        <Image src={match_img} />
                    </Col>
                    <Col
                        className="odds-guess-button ml-2"
                        onClick={onClickWheel}
                    >
                        <h4>
                            Win ${winAmount} if the wheel stops
                            somewhere
                        </h4>
                        <h4 className="odds-guess-one-white-zone">
                            in the white zone:
                        </h4>
                        <Image className="ml-5" src={wheel_highlight_img} />
                    </Col>
                </Row>
                <div className="odds-guess-one-space" />
            </Container>
        )
    }
}

