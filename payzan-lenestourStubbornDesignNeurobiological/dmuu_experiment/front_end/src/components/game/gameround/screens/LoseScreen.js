// Unused - replaced inside the slot game insted
// Shows Aaron with the images when losing

import React, { Component, Fragment } from 'react';
import { Row, Image, Col} from 'react-bootstrap';

export default class LoseScreen extends Component {
    render() {
        const pub = process.env.PUBLIC_URL; 
        return (
            <Fragment>
                <Col>
                    <Row className="mt-5 justify-content-center">
                        <h2>The 2 slots don't match!</h2>
                    </Row>
                    <Row className="mt-5 justify-content-center">
                        <Col/>
                        <Col className="d-flex justify-content-center">
                            <Image className="mt-auto ml-auto mb-auto" style={{height: "auto", width: "100px"}} src={pub + `/assets/${this.props.fruitOne}.jpg`}></Image>
                        </Col>
                        <Col className="d-flex justify-content-center">
                            <Image src={pub + "/assets/instruction_pages/aaron_reveal_lose.png"}></Image>
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
