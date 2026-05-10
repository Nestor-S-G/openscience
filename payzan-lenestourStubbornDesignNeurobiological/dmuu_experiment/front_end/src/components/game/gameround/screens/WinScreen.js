// Unused - replaced inside the slot game insted
// Shows Aaron with the images when winning

import React, { Component, Fragment } from 'react';
import {Image, Row, Col} from 'react-bootstrap';

export default class WinScreen extends Component {

    render() {
        const pub = process.env.PUBLIC_URL; 
        return (
            <Fragment>
                <Col>
                    <Row className="mt-5 justify-content-center">
                        <h2>You win {this.props.amount}!</h2>
                    </Row>
                    <Row className="mt-5 justify-content-center">
                        <Col/>
                        <Col className="d-flex justify-content-center">
                            <Image className="mt-auto ml-auto mb-auto" style={{height: "auto", width: "100px"}} src={pub + `/assets/${this.props.fruitOne}.jpg`}></Image>
                        </Col>
                        <Col className="d-flex justify-content-center">
                            <Image src={pub + "/assets/instruction_pages/aaron_reveal_win.png"}></Image>
                        </Col>
                        <Col className="d-flex justify-content-center">
                            <Image className="mt-auto mr-auto mb-auto" style={{height: "auto", width: "100px"}} src={pub + `/assets/${this.props.fruitTwo}.jpg`}></Image>
                        </Col>
                        <Col/>
                    </Row>
                </Col>
            </Fragment>
        )
    }
}
