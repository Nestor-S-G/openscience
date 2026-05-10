import React, { Component } from 'react';
import { Container, Row } from 'react-bootstrap';

export default class ExceedMissedTrials extends Component {
    render() {
        return (
            <Container className="h-100">
                <div className="d-flex flex-column justify-content-center h-100">
                    <Row className="justify-content-center">
                        <h1>Number of trials exceeded limit, experiment over</h1>
                    </Row>
                </div>
            </Container>
        )
    }
}
