/**
 * Page displayed connection error
 */
import React from 'react';
import { Container } from 'react-bootstrap';

export default function CheckConnection() {
    return (
        <Container>
            <h1>Lost connection to the server!</h1>
            <h1>Please contact BizLabs!</h1>
        </Container>
    )
}
