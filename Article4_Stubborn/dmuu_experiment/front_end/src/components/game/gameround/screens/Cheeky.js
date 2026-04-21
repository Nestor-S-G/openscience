import React, { Component, Fragment } from 'react';
import { Row, Image, Col } from 'react-bootstrap';

export default class Cheeky extends Component {
    render() {
        return (
            <Fragment>
                <Row className="mt-5">
                    <Col/>
                    <Col>
                        <Image src={process.env.PUBLIC_URL + "/assets/instruction_pages/aaron_cheeky.png"}></Image>
                    </Col>
                    <Col className="text-center">
                        <h1>Take your money back!! I'm feeling cheeky!</h1>
                    </Col>
                    <Col/>
                </Row>
            </Fragment>
        )
    }
}
