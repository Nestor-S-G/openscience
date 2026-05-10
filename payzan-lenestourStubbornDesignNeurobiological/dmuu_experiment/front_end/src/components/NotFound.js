/**
 * Page displayed when nothing is found
 */
import React from 'react';
import { Container } from 'react-bootstrap';
import { Link } from 'react-router-dom';

export default function NotFound() {
    return (
        <Container>
            <h1>The page you are requesting does not exist</h1>
            <Link to="/">Go back to home</Link>            
        </Container>
    )
}
