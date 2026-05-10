import React, { Component} from 'react';
import { Row, Button, Col } from 'react-bootstrap';
import { CountdownCircleTimer } from 'react-countdown-circle-timer';

export default class AskPlayer extends Component {

    renderTime = ({remainingTime}) => {

        return (
            <div style={{display: 'flex', alignItems: 'center', flexDirection: 'column'}}>
                <div>Respond in:</div>
                <div style={{fontSize: '40px'}}>{remainingTime}</div>
                <div>seconds</div>
            </div>
        );
    };

    render() {

        return (
            <div>
                <Row className="justify-content-center">
                    <Col/>
                    <Col className="d-flex justify-content-center">
                        { this.props.cheeky !== 100 ?
                            this.props.cheeky_image
                            :
                            this.props.normal_image
                        }
                    </Col>
                    <Col/>
                    <Col>
                        <Row className="justify-content-center">
                            <h3>Do you want me to spin the slots on this round?</h3>
                        </Row>
                        <Row className="justify-content-center">
                            <CountdownCircleTimer 
                                isPlaying 
                                duration={this.props.duration}
                                colors={[["#004777", 0.33], ["#F7B801", 0.33], ["#A30000"]]}
                                onComplete={() => [true, 1000]}
                            >
                                {this.renderTime}
                            </CountdownCircleTimer>
                        </Row>
                    </Col>
                    <Col/>
                </Row>
                <Row className="mt-5 justify-content-center">
                    <Button className="mr-5" onClick={this.props.yes}>Yes, spin the slots!</Button>
                    <Button className="ml-5" onClick={this.props.no}>No, I choose to pass!</Button>
                </Row>
            </div>
        )
    }
}
