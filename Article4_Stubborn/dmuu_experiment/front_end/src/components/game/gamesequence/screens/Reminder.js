// Reminder
// Shows the player the color of the probabilities

import React, { Component } from 'react';
import {Row, Container} from 'react-bootstrap';
import { capitalize } from '../../../../utility/TemplateParser';
import invert from 'invert-color';
import stc from 'string-to-color';

export default class Reminder extends Component {

    state = {
        low_color: '',
        low_text_color: '',
        low_probability: 0,
        high_color: '',
        high_text_color: '',
        high_probability: 0
    }

    componentDidMount()
    {
        const {low_color, low_probability, high_color, high_probability} = this.props.probs;
        this.setState({
            low_color: capitalize(low_color),
            low_text_color: invert(stc(low_color), true),
            low_probability,
            high_color: capitalize(high_color),
            high_text_color: invert(stc(high_color), true),
            high_probability
        });
    }

    render() {
        const {low_color, low_text_color, low_probability, high_color, high_text_color, high_probability} = this.state;

        return (
            <Container className="h-100">
                <div className="d-flex flex-column justify-content-center h-100">
                    <div className="mb-5">
                        <Row className="justify-content-center">
                            <h1>Reminder</h1>
                        </Row>
                        <Row className="mt-5 justify-content-center text-center" style={{"backgroundColor": low_color, "color": low_text_color}}>
                            <h2>{low_color} background indicates that the chance of a winning bet <br/> (the slots being the same) is low ({low_probability}%)</h2> 
                        </Row>
                        <Row className="mt-5 justify-content-center text-center" style={{"backgroundColor": high_color, "color": high_text_color}}>
                            <h2>{high_color} background indicates that the chance of a winning bet is high ({high_probability}%)</h2>
                        </Row>
                    </div>
                </div>
            </Container>
        )
    }
}
